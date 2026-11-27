import 'package:flutter/material.dart';
import '../services/audio_speech_service.dart';
import '../services/sound_effects_service.dart';
import '../models/reward_state.dart';

class _PuzzleTile {
  final int id;
  final String word;
  final String emoji;
  bool isRevealed = false;

  _PuzzleTile({
    required this.id,
    required this.word,
    required this.emoji,
  });
}

/// 🧩 GİZEMLİ YAPBOZ & BÜYÜLÜ RESİM KEŞFİ
/// Çocuk hedef kelimeleri söyledikçe yapboz parçaları birer birer açılır ve
/// arkasındaki muhteşem rengarenk büyülü şatolu uzay dünyası ortaya çıkar!
class PhonemeMysteryPuzzleDialog extends StatefulWidget {
  final String phoneme;
  final String soundTitle;
  final List<String> words;

  const PhonemeMysteryPuzzleDialog({
    super.key,
    required this.phoneme,
    required this.soundTitle,
    required this.words,
  });

  @override
  State<PhonemeMysteryPuzzleDialog> createState() => _PhonemeMysteryPuzzleDialogState();
}

class _PhonemeMysteryPuzzleDialogState extends State<PhonemeMysteryPuzzleDialog> with SingleTickerProviderStateMixin {
  final AudioSpeechService _audioService = AudioSpeechService();
  final SoundEffectsService _sfx = SoundEffectsService();
  final RewardState _rewardState = RewardState();

  late List<_PuzzleTile> _tiles;
  bool _isAllRevealed = false;
  late AnimationController _sparkleController;

  static final Map<String, List<Map<String, String>>> _curatedWords = {
    'P': [
      {'word': 'Pasta', 'emoji': '🎂'},
      {'word': 'Pilav', 'emoji': '🍚'},
      {'word': 'Park', 'emoji': '🎡'},
      {'word': 'Panda', 'emoji': '🐼'},
      {'word': 'Piyano', 'emoji': '🎹'},
      {'word': 'Portakal', 'emoji': '🍊'},
    ],
    'B': [
      {'word': 'Balık', 'emoji': '🐟'},
      {'word': 'Balon', 'emoji': '🎈'},
      {'word': 'Bebek', 'emoji': '👶'},
      {'word': 'Araba', 'emoji': '🚗'},
      {'word': 'Tabak', 'emoji': '🍽️'},
      {'word': 'Biber', 'emoji': '🫑'},
    ],
    'T': [
      {'word': 'Tarak', 'emoji': '🪮'},
      {'word': 'Top', 'emoji': '⚽'},
      {'word': 'Tavşan', 'emoji': '🐰'},
      {'word': 'Saat', 'emoji': '⏰'},
      {'word': 'Sepet', 'emoji': '🧺'},
      {'word': 'Terlik', 'emoji': '🩴'},
    ],
    'D': [
      {'word': 'Dondurma', 'emoji': '🍦'},
      {'word': 'Davul', 'emoji': '🥁'},
      {'word': 'Dede', 'emoji': '👴'},
      {'word': 'Ördek', 'emoji': '🦆'},
      {'word': 'Bardak', 'emoji': '🥛'},
      {'word': 'Yıldız', 'emoji': '⭐'},
    ],
    'K': [
      {'word': 'Kedi', 'emoji': '🐱'},
      {'word': 'Köpek', 'emoji': '🐶'},
      {'word': 'Kuş', 'emoji': '🐦'},
      {'word': 'Ekmek', 'emoji': '🍞'},
      {'word': 'Tabak', 'emoji': '🍽️'},
      {'word': 'Balık', 'emoji': '🐟'},
    ],
    'G': [
      {'word': 'Gözlük', 'emoji': '👓'},
      {'word': 'Gemi', 'emoji': '🚢'},
      {'word': 'Güneş', 'emoji': '☀️'},
      {'word': 'Gazete', 'emoji': '📰'},
      {'word': 'Gitar', 'emoji': '🎸'},
      {'word': 'Geyik', 'emoji': '🦌'},
    ],
    'F': [
      {'word': 'Fil', 'emoji': '🐘'},
      {'word': 'Fare', 'emoji': '🐭'},
      {'word': 'Fırça', 'emoji': '🖌️'},
      {'word': 'Fener', 'emoji': '🏮'},
      {'word': 'Fındık', 'emoji': '🌰'},
      {'word': 'Zürafa', 'emoji': '🦒'},
    ],
    'V': [
      {'word': 'Vazo', 'emoji': '🏺'},
      {'word': 'Vagon', 'emoji': '🚃'},
      {'word': 'Vida', 'emoji': '🔩'},
      {'word': 'Vişne', 'emoji': '🍒'},
      {'word': 'Tavşan', 'emoji': '🐰'},
      {'word': 'Deve', 'emoji': '🐪'},
    ],
    'S': [
      {'word': 'Su', 'emoji': '💧'},
      {'word': 'Süt', 'emoji': '🥛'},
      {'word': 'Saat', 'emoji': '⏰'},
      {'word': 'Süpürge', 'emoji': '🧹'},
      {'word': 'Masa', 'emoji': '🪵'},
      {'word': 'Aslan', 'emoji': '🦁'},
    ],
    'Z': [
      {'word': 'Zebra', 'emoji': '🦓'},
      {'word': 'Zil', 'emoji': '🔔'},
      {'word': 'Zeytin', 'emoji': '🫒'},
      {'word': 'Zürafa', 'emoji': '🦒'},
      {'word': 'Yüzük', 'emoji': '💍'},
      {'word': 'Deniz', 'emoji': '🌊'},
    ],
    'Ş': [
      {'word': 'Şapka', 'emoji': '👒'},
      {'word': 'Şeker', 'emoji': '🍬'},
      {'word': 'Şemsiye', 'emoji': '☂️'},
      {'word': 'Şişe', 'emoji': '🍾'},
      {'word': 'Kuş', 'emoji': '🐦'},
      {'word': 'Güneş', 'emoji': '☀️'},
    ],
    'J': [
      {'word': 'Jelibon', 'emoji': '🍬'},
      {'word': 'Jandarma', 'emoji': '👮'},
      {'word': 'Jet', 'emoji': '✈️'},
      {'word': 'Jaguar', 'emoji': '🐆'},
      {'word': 'Baraj', 'emoji': '🌊'},
      {'word': 'Garaj', 'emoji': '🚗'},
    ],
    'H': [
      {'word': 'Havuç', 'emoji': '🥕'},
      {'word': 'Horoz', 'emoji': '🐓'},
      {'word': 'Havlu', 'emoji': '🧖'},
      {'word': 'Kahve', 'emoji': '☕'},
      {'word': 'Sahil', 'emoji': '🏖️'},
      {'word': 'Lahana', 'emoji': '🥬'},
    ],
    'Ç': [
      {'word': 'Çilek', 'emoji': '🍓'},
      {'word': 'Çanta', 'emoji': '🎒'},
      {'word': 'Çiçek', 'emoji': '🌸'},
      {'word': 'Çekiç', 'emoji': '🔨'},
      {'word': 'Uçak', 'emoji': '✈️'},
      {'word': 'Bahçe', 'emoji': '🏡'},
    ],
    'C': [
      {'word': 'Ceket', 'emoji': '🧥'},
      {'word': 'Civciv', 'emoji': '🐥'},
      {'word': 'Ceviz', 'emoji': '🥜'},
      {'word': 'Cami', 'emoji': '🕌'},
      {'word': 'Gece', 'emoji': '🌙'},
      {'word': 'Böcek', 'emoji': '🐞'},
    ],
    'M': [
      {'word': 'Maymun', 'emoji': '🐒'},
      {'word': 'Masa', 'emoji': '🪵'},
      {'word': 'Mısır', 'emoji': '🌽'},
      {'word': 'Mantar', 'emoji': '🍄'},
      {'word': 'Elma', 'emoji': '🍎'},
      {'word': 'Kalem', 'emoji': '✏️'},
    ],
    'N': [
      {'word': 'Nar', 'emoji': '🍎'},
      {'word': 'Nokta', 'emoji': '🎯'},
      {'word': 'Nine', 'emoji': '👵'},
      {'word': 'Nal', 'emoji': '🧲'},
      {'word': 'Tren', 'emoji': '🚂'},
      {'word': 'Anne', 'emoji': '👩'},
    ],
    'L': [
      {'word': 'Limon', 'emoji': '🍋'},
      {'word': 'Lale', 'emoji': '🌷'},
      {'word': 'Leylek', 'emoji': '🪶'},
      {'word': 'Lamba', 'emoji': '💡'},
      {'word': 'Balon', 'emoji': '🎈'},
      {'word': 'Kale', 'emoji': '🏰'},
    ],
    'R': [
      {'word': 'Radyo', 'emoji': '📻'},
      {'word': 'Renk', 'emoji': '🎨'},
      {'word': 'Roket', 'emoji': '🚀'},
      {'word': 'Robot', 'emoji': '🤖'},
      {'word': 'Araba', 'emoji': '🚗'},
      {'word': 'Ördek', 'emoji': '🦆'},
    ],
    'Y': [
      {'word': 'Yumurta', 'emoji': '🥚'},
      {'word': 'Yaprak', 'emoji': '🍃'},
      {'word': 'Yıldız', 'emoji': '⭐'},
      {'word': 'Yılan', 'emoji': '🐍'},
      {'word': 'Ayı', 'emoji': '🐻'},
      {'word': 'Kayık', 'emoji': '⛵'},
    ],
  };

  @override
  void initState() {
    super.initState();
    _sparkleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _initPuzzle();
  }

  @override
  void dispose() {
    _sparkleController.dispose();
    super.dispose();
  }

  void _initPuzzle() {
    final cleanP = widget.phoneme.replaceAll('/', '').trim().toUpperCase();
    final items = _curatedWords[cleanP] ?? _curatedWords['P']!;

    _tiles = List.generate(6, (i) {
      final item = items[i % items.length];
      return _PuzzleTile(
        id: i,
        word: item['word']!,
        emoji: item['emoji']!,
      );
    });
  }

  bool _checkTileWordMatch(String cleanSpoken, String cleanTarget, String cleanPhoneme) {
    if (cleanSpoken.isEmpty || cleanTarget.isEmpty) return false;

    // 1. Birebir tam eşleşme
    if (cleanSpoken == cleanTarget) return true;

    // 2. Alt metin olarak içeriyorsa (örn: çocuk "bu pasta" veya "pastaa" dediyse)
    if (cleanSpoken.contains(cleanTarget)) return true;

    // 3. Hedef kelime söylenen kelimenin içinde geçiyorsa (en az 3 karakterli)
    if (cleanTarget.length >= 3 && cleanTarget.contains(cleanSpoken) && cleanSpoken.length >= (cleanTarget.length * 0.7).floor()) {
      return true;
    }

    // 4. Karakter benzerliği (en az %70 benzer olmalı)
    int matches = 0;
    int minLen = cleanSpoken.length < cleanTarget.length ? cleanSpoken.length : cleanTarget.length;
    for (int i = 0; i < minLen; i++) {
      if (cleanSpoken[i] == cleanTarget[i]) matches++;
    }
    int maxLen = cleanSpoken.length > cleanTarget.length ? cleanSpoken.length : cleanTarget.length;
    double ratio = matches / maxLen;
    if (ratio >= 0.70) return true;

    return false;
  }

  void _onTileTap(_PuzzleTile tile) async {
    if (tile.isRevealed) return;

    // Hemen kelimeyi çocuk dinlesin diye telaffuz ettir
    _audioService.speakTurkish(tile.word, phoneme: widget.phoneme);
    _sfx.playPopSound();

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogCtx) {
        bool isListening = false;
        String currentHeard = '';
        String? feedbackText;
        bool? isSuccess;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> startListening() async {
              // 1. Önce hoparlör sesini (TTS) hemen durdur ki mikrofona gitmesin
              _audioService.stopSpeaking();

              setDialogState(() {
                isListening = true;
                currentHeard = '';
                feedbackText = null;
                isSuccess = null;
              });
              _sfx.playPopSound();

              try {
                final spoken = await _audioService.listenToSpeech(
                  duration: const Duration(seconds: 5),
                  targetText: tile.word,
                  phoneme: widget.phoneme,
                  onInterimText: (interim) {
                    setDialogState(() {
                      currentHeard = interim;
                    });
                  },
                );

                final cleanSpoken = spoken.trim().toLowerCase().replaceAll(RegExp(r'[^a-zçğıöşü]'), '');
                final cleanTarget = tile.word.trim().toLowerCase().replaceAll(RegExp(r'[^a-zçğıöşü]'), '');
                final cleanP = widget.phoneme.replaceAll('/', '').trim().toLowerCase();

                final bool matched = _checkTileWordMatch(cleanSpoken, cleanTarget, cleanP);

                if (matched) {
                  setDialogState(() {
                    isListening = false;
                    isSuccess = true;
                    currentHeard = spoken.isNotEmpty ? spoken : tile.word;
                    feedbackText = '🎉 Harika Telaffuz! Doğru söyledin!';
                  });
                  _sfx.playSuccessDing();

                  await Future.delayed(const Duration(milliseconds: 900));
                  if (!mounted || !dialogCtx.mounted) return;
                  Navigator.pop(dialogCtx);
                  _revealTile(tile);
                } else {
                  setDialogState(() {
                    isListening = false;
                    isSuccess = false;
                    currentHeard = spoken;
                    if (spoken.isEmpty) {
                      feedbackText = '🎤 Ses algılanamadı. Mikrofona yaklaş ve tekrar dene!';
                    } else {
                      feedbackText = 'Duyulan: "$spoken"\nHedef: "${tile.word}". Tekrar dene!';
                    }
                  });
                  _sfx.playPopSound();
                }
              } catch (e) {
                setDialogState(() {
                  isListening = false;
                  isSuccess = false;
                  feedbackText = 'Mikrofon dinleme sırasında bir hata oluştu.';
                });
              }
            }

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              actionsPadding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFFE1F5FE),
                      shape: BoxShape.circle,
                    ),
                    child: Text(tile.emoji, style: const TextStyle(fontSize: 28)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Parça ${tile.id + 1}: "${tile.word}"',
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
                        ),
                        Text(
                          'Hedef Ses: [${widget.soundTitle}]',
                          style: const TextStyle(fontSize: 12, color: Colors.blueGrey, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                  if (!isListening)
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.grey),
                      onPressed: () {
                        _audioService.stopListening();
                        _audioService.stopSpeaking();
                        Navigator.pop(dialogCtx);
                      },
                    ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isListening) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFCE4EC),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFF06292), width: 2),
                      ),
                      child: Column(
                        children: [
                          const SizedBox(
                            width: 36,
                            height: 36,
                            child: CircularProgressIndicator(
                              strokeWidth: 3.5,
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE91E63)),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            '🎙️ SENİ DİNLİYORUM...',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                              color: Color(0xFFC2185B),
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Şimdi mikrofona açık ve net şekilde:\n"${tile.word}" de!',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Colors.black87),
                          ),
                          if (currentHeard.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                'Duyuluyor: "$currentHeard"',
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: Color(0xFF00897B)),
                              ),
                            ),
                          ],
                          const SizedBox(height: 10),
                          TextButton.icon(
                            icon: const Icon(Icons.stop_circle_rounded, color: Color(0xFFE91E63)),
                            label: const Text('Dinlemeyi Bitir', style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFFE91E63))),
                            onPressed: () => _audioService.stopListening(),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    if (feedbackText != null) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSuccess == true ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSuccess == true ? const Color(0xFF4CAF50) : const Color(0xFFFFB74D),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              isSuccess == true ? '🌟 HARİKA!' : '⚠️ TEKRAR DENE',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 13,
                                color: isSuccess == true ? const Color(0xFF2E7D32) : const Color(0xFFE65100),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              feedbackText!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                                color: isSuccess == true ? const Color(0xFF1B5E20) : const Color(0xFFBF360C),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ] else ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF8E1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFFFE082)),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '🎤 Bu parçayı açmak için "${tile.word}" kelimesini mikrofona söyle!',
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5, color: Color(0xFFE65100)),
                            ),
                            const SizedBox(height: 6),
                            OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Color(0xFFFFA000)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              ),
                              icon: const Icon(Icons.volume_up_rounded, size: 18, color: Color(0xFFE65100)),
                              label: const Text('Telaffuzu Dinle 🔊', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11.5, color: Color(0xFFE65100))),
                              onPressed: () => _audioService.speakTurkish(tile.word, phoneme: widget.phoneme),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE91E63),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 3,
                        ),
                        icon: const Icon(Icons.mic_rounded, size: 22),
                        label: Text(
                          feedbackText == null ? 'MİKROFONA SÖYLE 🎤' : 'YENİDEN SÖYLE 🎤',
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                        ),
                        onPressed: startListening,
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _revealTile(_PuzzleTile tile) {
    setState(() {
      tile.isRevealed = true;
      _sfx.playSuccessDing();
      _rewardState.addReward(earnedStars: 1, earnedXp: 20, earnedGems: 10);

      if (_tiles.every((t) => t.isRevealed)) {
        _isAllRevealed = true;
        _sfx.playVictoryFanfare();
        _rewardState.addReward(earnedStars: 5, earnedXp: 80, earnedGems: 40);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final revealedCount = _tiles.where((t) => t.isRevealed).length;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 540, maxHeight: 720),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: const Color(0xFFFF9800), width: 3),
          boxShadow: const [
            BoxShadow(color: Colors.black38, blurRadius: 24, offset: Offset(0, 10)),
          ],
        ),
        child: Column(
          children: [
            // Üst Başlık Barı
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: const BoxDecoration(
                color: Color(0xFFFF9800),
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Row(
                children: [
                  const Text('🧩', style: TextStyle(fontSize: 28)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Gizemli Ses Yapbozu',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900),
                        ),
                        Text(
                          'İlerleme: $revealedCount / 6 Parça Açıldı 🏆',
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Amacı Açıklayan Bant
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: const Color(0xFFFFF3E0),
              child: const Row(
                children: [
                  Text('💡', style: TextStyle(fontSize: 14)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Mavi parçalara dokun, hedef kelimeleri söyle ve arkadaki gizemli büyülü şatoyu aç!',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: Color(0xFFE65100)),
                    ),
                  ),
                ],
              ),
            ),

            // YAPBOZ SAHNESİ (Arka planda zengin büyülü illüstrasyon, üstte 6 karo)
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFFFB74D), width: 2.5),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Stack(
                    children: [
                      // 1. ZENGİN VE BÜYÜLÜ ARKA PLAN SAHNESİ
                      Positioned.fill(
                        child: _buildRichMagicalArtwork(),
                      ),

                      // 2. AÇILABİLİR 6 YAPBOZ PARÇASI (2 Satır x 3 Sütun)
                      GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 3,
                          mainAxisSpacing: 3,
                          childAspectRatio: 1.15,
                        ),
                        itemCount: _tiles.length,
                        itemBuilder: (ctx, idx) {
                          final tile = _tiles[idx];
                          if (tile.isRevealed) {
                            return const SizedBox.shrink(); // Parça açıldı! Alttaki resim pırıl pırıl görünüyor!
                          }

                          return InkWell(
                            onTap: () => _onTileTap(tile),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF29B6F6), Color(0xFF0288D1)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white, width: 2),
                                boxShadow: const [
                                  BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withAlpha(40),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(tile.emoji, style: const TextStyle(fontSize: 26)),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    tile.word,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                    decoration: BoxDecoration(
                                      color: Colors.black26,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.lock_rounded, size: 9, color: Colors.amberAccent),
                                        SizedBox(width: 2),
                                        Text('DOKUN', style: TextStyle(color: Colors.white, fontSize: 8.5, fontWeight: FontWeight.w900)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      // 3. TAMAMLANDI KUTLAMA OVERLAY'İ
                      if (_isAllRevealed)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withAlpha(50),
                            ),
                            child: Center(
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 20),
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(color: const Color(0xFFFFD54F), width: 3),
                                  boxShadow: const [
                                    BoxShadow(color: Colors.black38, blurRadius: 16, offset: Offset(0, 6)),
                                  ],
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text('👑 🏆 🎊', style: TextStyle(fontSize: 42)),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'YAPBOZ TAMAMLANDI!',
                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFFE65100)),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Tüm [${widget.soundTitle}] gizemli parçalarını açtın!\nBüyülü Galaksi Krallığı seninle gurur duyuyor!',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.blueGrey, height: 1.4),
                                    ),
                                    const SizedBox(height: 12),
                                    ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF58CC02),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                      ),
                                      icon: const Icon(Icons.star_rounded),
                                      label: const Text('HARİKA, ÖDÜLÜ AL 🚀', style: TextStyle(fontWeight: FontWeight.w900)),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // Alt Buton
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF58CC02),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 3,
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('KAPAT 🎯', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Zengin Büyülü İllüstrasyon Dünyası
  Widget _buildRichMagicalArtwork() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF0D47A1), // Gece Gökyüzü
            Color(0xFF1976D2),
            Color(0xFF64B5F6),
            Color(0xFFFFD54F), // Altın Vadi
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Stack(
        children: [
          // Yıldızlar ve Gezegenler
          const Positioned(top: 15, left: 20, child: Text('✨', style: TextStyle(fontSize: 22))),
          const Positioned(top: 30, right: 35, child: Text('🪐', style: TextStyle(fontSize: 28))),
          const Positioned(top: 80, left: 40, child: Text('⭐', style: TextStyle(fontSize: 18))),
          const Positioned(top: 100, right: 60, child: Text('🌟', style: TextStyle(fontSize: 20))),

          // Gökkuşağı ve Balon
          const Positioned(top: 20, left: 90, child: Text('🌈', style: TextStyle(fontSize: 48))),
          const Positioned(top: 45, right: 95, child: Text('🎈', style: TextStyle(fontSize: 34))),
          const Positioned(top: 75, left: 160, child: Text('🚀', style: TextStyle(fontSize: 36))),

          // Büyülü Şato & Ada Manzarası
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text('🏰', style: TextStyle(fontSize: 56)),
                    SizedBox(width: 8),
                    Text('👑🐼💎', style: TextStyle(fontSize: 48)),
                    SizedBox(width: 8),
                    Text('🎪', style: TextStyle(fontSize: 52)),
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(220),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.amber, width: 2),
                  ),
                  child: Text(
                    '🎉 [${widget.soundTitle.toUpperCase()}] BÜYÜLÜ KRALLIK SAHNESİ 🎉',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                      color: Color(0xFF0D47A1),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
