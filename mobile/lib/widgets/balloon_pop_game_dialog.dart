import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../services/audio_speech_service.dart';
import '../services/sound_effects_service.dart';
import '../models/reward_state.dart';
import '../utils/word_pictogram_helper.dart';

class _FloatingBalloon {
  final int id;
  final String word;
  final String emoji;
  final bool isTarget;
  final Color color;
  double x;
  double y;
  double speed;
  bool isPopped = false;

  _FloatingBalloon({
    required this.id,
    required this.word,
    required this.emoji,
    required this.isTarget,
    required this.color,
    required this.x,
    required this.y,
    required this.speed,
  });
}

/// 🎈 5. MİNİ OYUN: UÇAN BALON PATLATMA (SES AVCISI)
/// Çocuk ekranda yükselen balonlardan hedef sesi içerenleri bularak patlatır.
class BalloonPopGameDialog extends StatefulWidget {
  final String phoneme;
  final String soundTitle;
  final List<String> targetWords;
  final VoidCallback onGameWon;

  const BalloonPopGameDialog({
    super.key,
    required this.phoneme,
    required this.soundTitle,
    required this.targetWords,
    required this.onGameWon,
  });

  @override
  State<BalloonPopGameDialog> createState() => _BalloonPopGameDialogState();
}

class _BalloonPopGameDialogState extends State<BalloonPopGameDialog> {
  final AudioSpeechService _audioService = AudioSpeechService();
  final SoundEffectsService _sfx = SoundEffectsService();
  final RewardState _rewardState = RewardState();

  final List<_FloatingBalloon> _balloons = [];
  Timer? _gameLoop;
  int _score = 0;
  final int _targetGoal = 6;
  bool _isGameWon = false;
  final math.Random _rnd = math.Random();
  int _idCounter = 0;

  final List<Color> _colors = [
    const Color(0xFFFF5252),
    const Color(0xFFFF4081),
    const Color(0xFF7C4DFF),
    const Color(0xFF00E5FF),
    const Color(0xFF00E676),
    const Color(0xFFFFD600),
    const Color(0xFFFF9100),
  ];

  @override
  void initState() {
    super.initState();
    _startSpawner();
  }

  void _startSpawner() {
    _balloons.clear();
    for (int i = 0; i < 4; i++) {
      _spawnBalloon(initialY: 100.0 + i * 70.0);
    }

    _gameLoop = Timer.periodic(const Duration(milliseconds: 33), (_) {
      if (!mounted || _isGameWon) return;
      setState(() {
        for (final b in _balloons) {
          b.y -= b.speed;
        }

        // Ekranın tepesinden çıkanları temizle ve yenilerini üret
        _balloons.removeWhere((b) => b.y < -90 || b.isPopped);
        while (_balloons.length < 5) {
          _spawnBalloon();
        }
      });
    });
  }

  void _spawnBalloon({double? initialY}) {
    final isTarget = _rnd.nextBool() || _balloons.where((b) => b.isTarget).isEmpty;

    String word;
    if (isTarget && widget.targetWords.isNotEmpty) {
      word = widget.targetWords[_rnd.nextInt(widget.targetWords.length)];
    } else {
      final cleanP = widget.phoneme.toLowerCase();
      const candidatePool = [
        'Kedi', 'Masa', 'Güneş', 'Balık', 'Çiçek', 'Ev', 'Kuş',
        'Araba', 'Elma', 'Ağaç', 'Tavşan', 'Gözlük', 'Saat', 'Kalem',
        'Top', 'Ayı', 'Pasta', 'Limon', 'Yıldız', 'Dondurma', 'Bebek'
      ];
      final validDistractors = candidatePool.where((w) => !w.toLowerCase().contains(cleanP)).toList();
      word = validDistractors.isNotEmpty
          ? validDistractors[_rnd.nextInt(validDistractors.length)]
          : 'Mavi';
    }

    final emoji = WordPictogramHelper.getPictogram(word);
    final color = _colors[_rnd.nextInt(_colors.length)];
    final x = 30.0 + _rnd.nextDouble() * 260.0;
    final y = initialY ?? (360.0 + _rnd.nextDouble() * 50.0);
    final speed = 1.2 + _rnd.nextDouble() * 1.5;

    _balloons.add(
      _FloatingBalloon(
        id: _idCounter++,
        word: word,
        emoji: emoji,
        isTarget: isTarget,
        color: color,
        x: x,
        y: y,
        speed: speed,
      ),
    );
  }

  @override
  void dispose() {
    _gameLoop?.cancel();
    super.dispose();
  }

  void _popBalloon(_FloatingBalloon b) {
    if (b.isPopped) return;

    _sfx.playPop();
    _audioService.speakTurkish(b.word, phoneme: widget.phoneme);

    setState(() {
      b.isPopped = true;
    });

    if (b.isTarget) {
      _sfx.playSuccessDing();
      _score++;
      if (_score >= _targetGoal) {
        _onVictory();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('⚠️ Dikkat! "${b.word}" hedef "${widget.phoneme}" sesini içermiyor.'),
          duration: const Duration(milliseconds: 800),
          backgroundColor: const Color(0xFFE65100),
        ),
      );
    }
  }

  void _onVictory() {
    _gameLoop?.cancel();
    setState(() => _isGameWon = true);
    _sfx.playVictoryFanfare();
    _rewardState.addReward(earnedStars: 4, earnedXp: 60, earnedGems: 25);
    widget.onGameWon();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          gradient: const LinearGradient(
            colors: [Color(0xFFE1F5FE), Color(0xFFB3E5FC), Color(0xFFE0F7FA)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          border: Border.all(color: const Color(0xFF03A9F4), width: 3),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Üst Başlık & Skor
            Row(
              children: [
                const Text('🎈', style: TextStyle(fontSize: 28)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Uçan Balon Avcısı (${widget.soundTitle})',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF01579B),
                        ),
                      ),
                      Text(
                        'Hedef sesi taşıyan balonları patlat! ($_score / $_targetGoal)',
                        style: const TextStyle(fontSize: 11, color: Colors.black54, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.grey),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // OYUN GÖKYÜZÜ ARENASI
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Container(
                width: 360,
                height: 340,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF81D4FA), Color(0xFFB3E5FC), Color(0xFFE1F5FE)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Stack(
                  children: [
                    // Bulutlar
                    const Positioned(left: 20, top: 20, child: Text('☁️', style: TextStyle(fontSize: 34))),
                    const Positioned(right: 30, top: 60, child: Text('⛅', style: TextStyle(fontSize: 38))),

                    // Yükselen Balonlar
                    for (final b in _balloons)
                      if (!b.isPopped)
                        Positioned(
                          left: b.x,
                          top: b.y,
                          child: GestureDetector(
                            onTap: () => _popBalloon(b),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 66,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: b.color,
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(33),
                                      bottom: Radius.circular(28),
                                    ),
                                    border: Border.all(color: Colors.white, width: 2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: b.color.withValues(alpha: 0.4),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(b.emoji, style: const TextStyle(fontSize: 24)),
                                      const SizedBox(height: 2),
                                      Text(
                                        b.word,
                                        maxLines: 1,
                                        style: const TextStyle(
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white,
                                          shadows: [Shadow(color: Colors.black45, blurRadius: 2)],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Balon İpi
                                Container(width: 1.5, height: 16, color: Colors.black45),
                              ],
                            ),
                          ),
                        ),

                    // Zafer Ekranı
                    if (_isGameWon)
                      Container(
                        color: Colors.black.withValues(alpha: 0.7),
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('🎈👑🎉', style: TextStyle(fontSize: 48)),
                            const SizedBox(height: 8),
                            const Text(
                              'GÖREV TAMAMLANDI!',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFFFFD700)),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Tüm "${widget.phoneme}" balonlarını avladın! 🌟',
                              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 14),
                            const Text('⭐ +4 Yıldız | ⚡ +60 XP | 💎 +25 Elmas',
                                style: TextStyle(color: Color(0xFF00E676), fontWeight: FontWeight.w900, fontSize: 13)),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF58CC02),
                                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                              ),
                              onPressed: () => Navigator.pop(context),
                              child: const Text('ÖDÜLLERİ AL & DEVAM ET 🏆',
                                  style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white)),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
