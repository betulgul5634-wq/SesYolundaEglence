import 'dart:async';
import 'package:flutter/material.dart';
import '../services/audio_speech_service.dart';
import '../services/sound_effects_service.dart';
import '../models/reward_state.dart';

class _RhymeData {
  final String phoneme;
  final String title;
  final String rhyme;
  final String emoji;

  _RhymeData({
    required this.phoneme,
    required this.title,
    required this.rhyme,
    required this.emoji,
  });
}

/// 🎵 RİTİMLİ FONEM TEKERLEMELERİ & CANLI KARAOKE RİTİM MOTORU
/// Gerçek zamanlı Web Audio API davul/alkış/marimba altyapısıyla artikülasyonu hızlandırır.
class PhonemeRhymesDialog extends StatefulWidget {
  final String phoneme;

  const PhonemeRhymesDialog({
    super.key,
    required this.phoneme,
  });

  @override
  State<PhonemeRhymesDialog> createState() => _PhonemeRhymesDialogState();
}

class _PhonemeRhymesDialogState extends State<PhonemeRhymesDialog>
    with SingleTickerProviderStateMixin {
  final AudioSpeechService _audioService = AudioSpeechService();
  final SoundEffectsService _soundEffects = SoundEffectsService();
  final RewardState _rewardState = RewardState();
  late AnimationController _bounceController;
  
  bool _isPlaying = false;
  int _currentLineIndex = -1;
  int _beat = 0;
  int _bpm = 112; // Neşeli çocuk tekerlemesi temposu
  Timer? _beatTimer;

  late final _RhymeData _rhyme;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    )..repeat(reverse: true);

    _initRhyme();
  }

  void _initRhyme() {
    final cleanP = widget.phoneme.replaceAll('/', '').trim().toLowerCase();

    if (cleanP == 'r') {
      _rhyme = _RhymeData(
        phoneme: 'R',
        title: 'Renkli Robotun Rüzgarı 🤖',
        rhyme: 'Renkli robot rafta durur,\nRüzgar esince çarkı döner,\nRoket gibi göğe fırlar!',
        emoji: '🚀',
      );
    } else if (cleanP == 'y') {
      _rhyme = _RhymeData(
        phoneme: 'Y',
        title: 'Yavru Yavuz Yaylada ⛵',
        rhyme: 'Yaramaz yavru yeşil yelek giyer,\nYaylada yürür, yoğurt yer,\nYıldızlara el sallar!',
        emoji: '⭐',
      );
    } else if (cleanP == 'b') {
      _rhyme = _RhymeData(
        phoneme: 'B',
        title: 'Balıkçı Bilal’in Balonu 🎈',
        rhyme: 'Balıkçı Bilal balık tuttu,\nBalığı bardağa koydu,\nBüyük balonu göğe uçtu!',
        emoji: '🐟',
      );
    } else if (cleanP == 'm') {
      _rhyme = _RhymeData(
        phoneme: 'M',
        title: 'Maymun Memo’nun Muzları 🐵',
        rhyme: 'Maymun Memo masada muz buldu,\nMasmavi mindere oturdu,\nMısırları afiyetle yuttu!',
        emoji: '🍌',
      );
    } else if (cleanP == 's') {
      _rhyme = _RhymeData(
        phoneme: 'S',
        title: 'Sarı Sincabın Saati ⏰',
        rhyme: 'Sarı sincap saat sekizde uyandı,\nSandalyeye oturdu, simit aldı,\nSıcak sütünü yudumladı!',
        emoji: '🐿️',
      );
    } else if (cleanP == 't') {
      _rhyme = _RhymeData(
        phoneme: 'T',
        title: 'Tatlı Tavşanın Topu 🐰',
        rhyme: 'Tatlı tavşan tarlada koştu,\nTopu tuttu, taşa vurdu,\nTonton dede tebessümle baktı!',
        emoji: '🐇',
      );
    } else if (cleanP == 'd') {
      _rhyme = _RhymeData(
        phoneme: 'D',
        title: 'Dede ile Denizde Dondurma 🍦',
        rhyme: 'Dede torun denize daldı,\nDalgada neşeyle dans etti,\nDönüşte leziz dondurma aldı!',
        emoji: '🍧',
      );
    } else if (cleanP == 'k') {
      _rhyme = _RhymeData(
        phoneme: 'K',
        title: 'Kınalı Kedi ile Köpek 🐱',
        rhyme: 'Kurnaz kedi kapıya koştu,\nKemik bulan köpek şaştı,\nKutudan kırmızı kiraz çıktı!',
        emoji: '🐈',
      );
    } else if (cleanP == 'g') {
      _rhyme = _RhymeData(
        phoneme: 'G',
        title: 'Gülümseyen Güvercinin Gemisi 🕊️',
        rhyme: 'Güleryüzlü güvercin gökte uçtu,\nGemiye kondu, güneşi gördü,\nGüzel gözleriyle göz kırptı!',
        emoji: '🚢',
      );
    } else if (cleanP == 'l') {
      _rhyme = _RhymeData(
        phoneme: 'L',
        title: 'Leyleğin Limonlu Lolipopu 🍭',
        rhyme: 'Leylek leziz lokum buldu,\nLimonlu lolipopla neşelendi,\nLale bahçesinde leylekler uçtu!',
        emoji: '🍋',
      );
    } else if (cleanP == 'ş') {
      _rhyme = _RhymeData(
        phoneme: 'Ş',
        title: 'Şekerci Şirin Şapka Taktı 🎩',
        rhyme: 'Şirin şekerci şapkasını taktı,\nŞakacı şempanzeye şerbet sundu,\nŞen şakrak şakalar yaptı!',
        emoji: '👒',
      );
    } else if (cleanP == 'ç') {
      _rhyme = _RhymeData(
        phoneme: 'Ç',
        title: 'Çekirgenin Çilekli Çayı 🍓',
        rhyme: 'Çekirge çimende çaydanlık buldu,\nÇilekli çayını yudumladı,\nÇınar ağacında şarkı söyledi!',
        emoji: '🍵',
      );
    } else if (cleanP == 'z') {
      _rhyme = _RhymeData(
        phoneme: 'Z',
        title: 'Zeki Zebra Zıpzıp Zıpladı 🦓',
        rhyme: 'Zeki zebra zil çalınca zıpladı,\nZeytinli leziz ziyafet yaptı,\nZümrüt gibi ışıl ışıl parıldadı!',
        emoji: '🦓',
      );
    } else if (cleanP == 'f') {
      _rhyme = _RhymeData(
        phoneme: 'F',
        title: 'Fındıkçı Filin Feneri 🐘',
        rhyme: 'Fındıkçı fil feneri yaktı,\nFırtınada fısıldadı,\nFıstıklarla taze fidan dikti!',
        emoji: '🐘',
      );
    } else if (cleanP == 'v') {
      _rhyme = _RhymeData(
        phoneme: 'V',
        title: 'Vapurdaki Vizonun Viyolonseli 🎻',
        rhyme: 'Vapurda vizon viyolonsel çaldı,\nVızır vızır vızıldadı,\nVagonlara vizonlar bindi!',
        emoji: '🚢',
      );
    } else if (cleanP == 'c') {
      _rhyme = _RhymeData(
        phoneme: 'C',
        title: 'Cesur Ceylanın Cevizleri 🦌',
        rhyme: 'Cesur ceylan ceviz topladı,\nCamın önünde cıvıldadı,\nCeplerine cömertçe doldurdu!',
        emoji: '🥜',
      );
    } else if (cleanP == 'h') {
      _rhyme = _RhymeData(
        phoneme: 'H',
        title: 'Hızlı Havuçlu Horoz 🐓',
        rhyme: 'Hızlı horoz havuzda heyecanlandı,\nHavuçları harika paylaştı,\nHuzur dolu havada haykırdı!',
        emoji: '🥕',
      );
    } else if (cleanP == 'n') {
      _rhyme = _RhymeData(
        phoneme: 'N',
        title: 'Neşeli Ninemin Narları 🍎',
        rhyme: 'Narin nine nane ekti,\nNar tanelerini paylaştı,\nNinni söyleyip neşelendirdi!',
        emoji: '👵',
      );
    } else if (cleanP == 'j') {
      _rhyme = _RhymeData(
        phoneme: 'J',
        title: 'Jelibonlu Jandarma Jeti ✈️',
        rhyme: 'Jandarma jeti gökte süzüldü,\nJelibonlar neşeyle döküldü,\nJapon balığı hayranlıkla gördü!',
        emoji: '🍬',
      );
    } else {
      // Varsayılan /p/
      _rhyme = _RhymeData(
        phoneme: 'P',
        title: 'Piknikte Peynirli Pasta 🎂',
        rhyme: 'Piknikte pırasa pişirdik,\nPeynirli pastayı paylaştık,\nPapatyalarla neşeyle coştuk!',
        emoji: '🎈',
      );
    }
  }

  @override
  void dispose() {
    _stopRhyme();
    _bounceController.dispose();
    super.dispose();
  }

  void _stopRhyme() {
    _audioService.pauseAudio();
    _soundEffects.stopRhythmBeat();
    _beatTimer?.cancel();
    if (mounted) {
      setState(() {
        _isPlaying = false;
        _currentLineIndex = -1;
        _beat = 0;
      });
    }
  }

  Future<void> _playRhyme() async {
    if (_isPlaying) {
      _stopRhyme();
      return;
    }

    setState(() {
      _isPlaying = true;
      _currentLineIndex = -1;
      _beat = 0;
    });

    // 1. Canlı Web Audio API davul & melodi ritmini başlat
    _soundEffects.startRhythmBeat(bpm: _bpm.toDouble());

    // 2. Metronom vuruş sayacı (1-2-3-4 ritmi)
    final beatMs = (60000 / _bpm).round();
    _beatTimer?.cancel();
    _beatTimer = Timer.periodic(Duration(milliseconds: beatMs), (timer) {
      if (!mounted || !_isPlaying) {
        timer.cancel();
        return;
      }
      setState(() {
        _beat = (_beat + 1) % 4;
      });
    });

    // 3. Ritmik giriş esı (2 vuruş hazırlık)
    await Future.delayed(Duration(milliseconds: beatMs * 2));
    if (!_isPlaying || !mounted) return;

    // 4. Dizeleri ritimle tek tek senkronize oku
    final lines = _rhyme.rhyme
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    for (int i = 0; i < lines.length; i++) {
      if (!_isPlaying || !mounted) break;
      setState(() => _currentLineIndex = i);

      // Satırı neşeyle oku
      await _audioService.speakTurkish(lines[i], phoneme: _rhyme.phoneme);

      // Satırlar arası 2 vuruşluk ritmik nefes aralığı
      if (!_isPlaying || !mounted) break;
      await Future.delayed(Duration(milliseconds: (beatMs * 1.5).round()));
    }

    // 5. Bitiş ve Zafer Kutlaması
    if (_isPlaying && mounted) {
      await Future.delayed(Duration(milliseconds: beatMs * 2));
      _soundEffects.stopRhythmBeat();
      _soundEffects.playVictoryFanfare();
      _rewardState.addReward(earnedStars: 3, earnedXp: 50, earnedGems: 20);
      _beatTimer?.cancel();
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _currentLineIndex = -1;
          _beat = 0;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lines = _rhyme.rhyme
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      child: Container(
        width: 440,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          gradient: const LinearGradient(
            colors: [Color(0xFFFFF0F5), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          border: Border.all(color: const Color(0xFFFF4081), width: 2.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Üst Başlık & Kapat Butonu
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE4E1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Text('🥁', style: TextStyle(fontSize: 24)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _rhyme.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFC2185B),
                        ),
                      ),
                      Text(
                        'Ritimle söyle, artikülasyonu hızlandır! (${_rhyme.phoneme} Sesi)',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.black54,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.grey),
                  onPressed: () {
                    _stopRhyme();
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Ritim Metronom Göstergesi (1 - 2 - 3 - 4 Vuruşları)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF5F7),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFFC1D6)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.music_note_rounded, size: 18, color: Color(0xFFE91E63)),
                      const SizedBox(width: 4),
                      Text(
                        _isPlaying ? 'RİTİM AKTİF' : 'RİTİM MODU',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFC2185B),
                        ),
                      ),
                    ],
                  ),
                  // 4 Vuruşlu Canlı Metronom Lambaları
                  Row(
                    children: List.generate(4, (index) {
                      final isActive = _isPlaying && _beat == index;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 120),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: isActive ? 24 : 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: isActive ? const Color(0xFFFF007A) : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: isActive
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFFFF007A).withValues(alpha: 0.5),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  )
                                ]
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: isActive ? Colors.white : Colors.black45,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Ritmik Tekerleme Kartı (Satır Satır Vurgulanan Karaoke)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFFF80AB), width: 2),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1AFF4081),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_rhyme.emoji, style: const TextStyle(fontSize: 30)),
                      const SizedBox(width: 8),
                      AnimatedBuilder(
                        animation: _bounceController,
                        builder: (ctx, child) {
                          return Transform.translate(
                            offset: Offset(0, -6 * _bounceController.value),
                            child: const Text('🎶 🥁 🎵', style: TextStyle(fontSize: 22)),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...List.generate(lines.length, (idx) {
                    final isCurrent = _currentLineIndex == idx;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? const Color(0xFFFFE0EB)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isCurrent
                              ? const Color(0xFFFF4081)
                              : Colors.transparent,
                          width: 1.5,
                        ),
                        boxShadow: isCurrent
                            ? [
                                BoxShadow(
                                  color: const Color(0xFFFF4081).withValues(alpha: 0.25),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                )
                              ]
                            : null,
                      ),
                      child: Row(
                        children: [
                          if (isCurrent)
                            const Padding(
                              padding: EdgeInsets.only(right: 8),
                              child: Text('▶', style: TextStyle(color: Color(0xFFE91E63), fontSize: 13)),
                            ),
                          Expanded(
                            child: Text(
                              lines[idx],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: isCurrent ? 16 : 14.5,
                                fontWeight: isCurrent ? FontWeight.w900 : FontWeight.w700,
                                color: isCurrent ? const Color(0xFFC2185B) : const Color(0xFF4A148C),
                                height: 1.4,
                              ),
                            ),
                          ),
                          if (isCurrent)
                            const Padding(
                              padding: EdgeInsets.only(left: 8),
                              child: Text('🎵', style: TextStyle(fontSize: 13)),
                            ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Canlı Tempo Seçici (Yavaş / Neşeli / Hızlı)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Tempo: ',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54),
                ),
                _buildTempoChip(label: '96 BPM 🐢', bpm: 96),
                const SizedBox(width: 6),
                _buildTempoChip(label: '112 BPM 🎵', bpm: 112),
                const SizedBox(width: 6),
                _buildTempoChip(label: '128 BPM 🚀', bpm: 128),
              ],
            ),
            const SizedBox(height: 14),

            // Seslendir / Birlikte Söyle Butonu
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isPlaying ? const Color(0xFFD81B60) : const Color(0xFF58CC02),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 4,
                ),
                icon: Icon(
                  _isPlaying ? Icons.stop_rounded : Icons.play_arrow_rounded,
                  size: 26,
                ),
                label: Text(
                  _isPlaying ? '⏹️ RİTİMİ DURDUR' : '🥁 RİTİMLE BAŞLAT & DİNLE 🎵',
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                ),
                onPressed: _playRhyme,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTempoChip({required String label, required int bpm}) {
    final isSelected = _bpm == bpm;
    return GestureDetector(
      onTap: _isPlaying
          ? null
          : () {
              setState(() => _bpm = bpm);
            },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE91E63) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFFC2185B) : Colors.grey.shade300,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFE91E63).withValues(alpha: 0.3),
                    blurRadius: 4,
                  )
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: isSelected ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }
}
