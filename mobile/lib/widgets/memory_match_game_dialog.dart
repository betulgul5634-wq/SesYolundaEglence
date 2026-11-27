import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../services/audio_speech_service.dart';
import '../services/sound_effects_service.dart';
import '../models/reward_state.dart';
import '../utils/word_pictogram_helper.dart';

class _MemoryCard {
  final int id;
  final String word;
  final String emoji;
  bool isFlipped = false;
  bool isMatched = false;

  _MemoryCard({
    required this.id,
    required this.word,
    required this.emoji,
  });
}

/// 🃏 KLİNİK SES HAFIZA VE EŞLEŞTİRME KARTI OYUNU
/// Masadaki klinik kart eşleştirme terapisini dijital ortama taşır.
/// Çocuk kartı her çevirdiğinde terapist sesi kelimeyi telaffuz eder.
class MemoryMatchGameDialog extends StatefulWidget {
  final String phoneme;
  final String soundTitle;
  final List<String> targetWords;
  final VoidCallback onGameWon;

  const MemoryMatchGameDialog({
    super.key,
    required this.phoneme,
    required this.soundTitle,
    required this.targetWords,
    required this.onGameWon,
  });

  @override
  State<MemoryMatchGameDialog> createState() => _MemoryMatchGameDialogState();
}

class _MemoryMatchGameDialogState extends State<MemoryMatchGameDialog> {
  final AudioSpeechService _audioService = AudioSpeechService();
  final SoundEffectsService _sfx = SoundEffectsService();
  final RewardState _rewardState = RewardState();

  late List<_MemoryCard> _cards;
  int? _firstFlippedIndex;
  bool _isChecking = false;
  int _moves = 0;
  int _matchedPairs = 0;
  final int _totalPairs = 4; // 8 Kart (4 Çift)
  bool _isGameWon = false;

  @override
  void initState() {
    super.initState();
    _initCards();
  }

  void _initCards() {
    _moves = 0;
    _matchedPairs = 0;
    _firstFlippedIndex = null;
    _isChecking = false;
    _isGameWon = false;

    // Hedef öğelerden görseli birbirinden FARKLI 4 benzersiz kart çifti seç
    final validWords = widget.targetWords
        .map((w) => w.trim())
        .where((w) => w.isNotEmpty)
        .toSet()
        .toList();

    final List<String> chosenWords = [];
    final Set<String> usedEmojis = {};
    final Map<String, String> resolvedEmojis = {};

    if (validWords.isNotEmpty) {
      validWords.shuffle(math.Random());
      const distinctPool = [
        '🌟', '🚀', '🦋', '🎨', '🍀', '🎵', '🌈', '💎',
        '🦊', '🐳', '🍓', '⚽', '🎯', '🪁', '🧸', '🎈',
      ];
      int poolIdx = 0;

      String nextDistinctEmoji() {
        while (poolIdx < distinctPool.length) {
          final cand = distinctPool[poolIdx++];
          if (!usedEmojis.contains(cand)) return cand;
        }
        return '✨';
      }

      // 1. Önce uzun kelimelerden görseli benzersiz olanları seç
      for (final w in validWords) {
        if (chosenWords.length >= 4) break;
        if (w.length <= 3 && !w.contains(' ')) continue;
        final em = WordPictogramHelper.getPictogram(w);
        if (!usedEmojis.contains(em)) {
          usedEmojis.add(em);
          resolvedEmojis[w] = em;
          chosenWords.add(w);
        }
      }
      // 2. Heceler veya kalan öğeler için her çifte KESİNLİKLE farklı görsel ata
      for (final w in validWords) {
        if (chosenWords.length >= 4) break;
        if (chosenWords.contains(w)) continue;
        final distinct = nextDistinctEmoji();
        usedEmojis.add(distinct);
        resolvedEmojis[w] = distinct;
        chosenWords.add(w);
      }
    }

    if (chosenWords.isEmpty) {
      chosenWords.addAll([
        '${widget.phoneme}a',
        '${widget.phoneme}e',
        '${widget.phoneme}ı',
        '${widget.phoneme}i',
      ]);
      const syms = ['🌟', '🚀', '🦋', '🎨'];
      for (int i = 0; i < chosenWords.length; i++) {
        resolvedEmojis[chosenWords[i]] = syms[i];
      }
    }

    final List<_MemoryCard> cardList = [];
    int idCounter = 0;

    for (final word in chosenWords) {
      final emoji = resolvedEmojis[word] ?? WordPictogramHelper.getPictogram(word);
      // Çift 1
      cardList.add(_MemoryCard(id: idCounter++, word: word, emoji: emoji));
      // Çift 2
      cardList.add(_MemoryCard(id: idCounter++, word: word, emoji: emoji));
    }

    cardList.shuffle(math.Random());
    _cards = cardList;
  }

  void _onCardTap(int index) {
    if (_isChecking || _cards[index].isFlipped || _cards[index].isMatched) return;

    final tappedCard = _cards[index];
    _sfx.playPop();

    setState(() {
      tappedCard.isFlipped = true;
    });

    // Kelimenin Terapist Telaffuzunu Dinlet
    _audioService.speakTurkish(tappedCard.word, phoneme: widget.phoneme);

    if (_firstFlippedIndex == null) {
      // İlk kart açıldı
      _firstFlippedIndex = index;
    } else {
      // İkinci kart açıldı, kontrol et
      _moves++;
      final firstCard = _cards[_firstFlippedIndex!];

      if (firstCard.word.toLowerCase() == tappedCard.word.toLowerCase()) {
        // EŞLEŞTİ!
        _sfx.playSuccessDing();
        setState(() {
          firstCard.isMatched = true;
          tappedCard.isMatched = true;
          _matchedPairs++;
          _firstFlippedIndex = null;
        });

        // Çıkartma Albümüne Ekle
        _rewardState.unlockSticker(tappedCard.word);

        if (_matchedPairs >= _totalPairs) {
          _onGameVictory();
        }
      } else {
        // Eşleşmedi, 900ms sonra geri kapat
        _isChecking = true;
        Timer(const Duration(milliseconds: 900), () {
          if (mounted) {
            setState(() {
              firstCard.isFlipped = false;
              tappedCard.isFlipped = false;
              _firstFlippedIndex = null;
              _isChecking = false;
            });
          }
        });
      }
    }
  }

  void _onGameVictory() {
    _sfx.playVictoryFanfare();
    setState(() {
      _isGameWon = true;
    });
    _rewardState.addReward(earnedStars: 4, earnedXp: 70, earnedGems: 30);
    widget.onGameWon();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      child: Container(
        width: 440,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          gradient: const LinearGradient(
            colors: [Color(0xFFEDE7F6), Color(0xFFD1C4E9)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          border: Border.all(color: const Color(0xFF7E57C2), width: 3),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Üst Başlık & İlerleme
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7E57C2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Text('🃏', style: TextStyle(fontSize: 24)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ses Hafıza Kartları (${widget.soundTitle})',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF311B92),
                        ),
                      ),
                      Text(
                        'Aynı kelimeleri bul ve yüksek sesle tekrar et! 🗣️',
                        style: const TextStyle(fontSize: 11, color: Colors.black54, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.black54),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Hamle ve Eşleşme Skoru
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMiniStat('Eşleşen', '$_matchedPairs / $_totalPairs', const Color(0xFF2E7D32)),
                _buildMiniStat('Hamle', '$_moves', const Color(0xFFE65100)),
                _buildMiniStat('Kalan', '${_totalPairs - _matchedPairs}', const Color(0xFF1565C0)),
              ],
            ),
            const SizedBox(height: 14),

            // KARTLAR IZGARASI (4 x 2)
            SizedBox(
              height: 280,
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _cards.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.85,
                ),
                itemBuilder: (ctx, i) {
                  final card = _cards[i];
                  final isOpen = card.isFlipped || card.isMatched;

                  return GestureDetector(
                    onTap: () => _onCardTap(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        color: isOpen ? Colors.white : const Color(0xFF5E35B1),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: card.isMatched
                              ? const Color(0xFF00E676)
                              : (isOpen ? const Color(0xFF9575CD) : const Color(0xFF4527A0)),
                          width: card.isMatched ? 3 : 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: isOpen
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(card.emoji, style: const TextStyle(fontSize: 32)),
                                const SizedBox(height: 4),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  child: Text(
                                    card.word,
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      height: 1.15,
                                      fontWeight: FontWeight.w900,
                                      color: card.isMatched ? const Color(0xFF2E7D32) : const Color(0xFF311B92),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('❓', style: TextStyle(fontSize: 26)),
                                const SizedBox(height: 2),
                                Text(
                                  widget.phoneme,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            // Zafer Bildirimi / Tekrar Oyna
            if (_isGameWon)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFF4CAF50), width: 2),
                ),
                child: Column(
                  children: [
                    const Text('🎉 TEBRİKLER! TÜM KARTLARI EŞLEŞTİRDİN! 🏆',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF1B5E20), fontSize: 13)),
                    const SizedBox(height: 4),
                    const Text('⭐ +4 Yıldız | ⚡ +70 XP | 💎 +30 Elmas',
                        style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF2E7D32), fontSize: 12)),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () => setState(() => _initCards()),
                      child: const Text('Tekrar Oyna 🔄', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(String title, String val, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Text(title, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.grey[700])),
          Text(val, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: color)),
        ],
      ),
    );
  }
}
