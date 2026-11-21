import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../services/audio_speech_service.dart';
import '../services/sound_effects_service.dart';
import '../models/reward_state.dart';

class _FloatingStar {
  double x;
  double y;
  bool isCollected = false;
  final double size = 28;

  _FloatingStar({
    required this.x,
    required this.y,
  });
}

class _FloatingCloud {
  double x;
  double y;
  final double speed;
  final String emoji;

  _FloatingCloud({
    required this.x,
    required this.y,
    required this.speed,
    required this.emoji,
  });
}

/// 🚀 SÜPER UÇAN ROKET: SES GÜCÜYLE UÇUŞ OYUNU
/// Çocuk hedef sesi uzatarak söyledikçe (örneğin "rrrrr", "sssss", "mmmmm", "yyyyy")
/// canlı mikrofon ses gücü rokete yakıt basar ve roketi gökyüzüne havalandırır!
class VoiceFlightMiniGameDialog extends StatefulWidget {
  final String phoneme;
  final String soundTitle;
  final VoidCallback onGameWon;

  const VoiceFlightMiniGameDialog({
    super.key,
    required this.phoneme,
    required this.soundTitle,
    required this.onGameWon,
  });

  @override
  State<VoiceFlightMiniGameDialog> createState() => _VoiceFlightMiniGameDialogState();
}

class _VoiceFlightMiniGameDialogState extends State<VoiceFlightMiniGameDialog>
    with SingleTickerProviderStateMixin {
  final AudioSpeechService _audioService = AudioSpeechService();
  final SoundEffectsService _sfx = SoundEffectsService();
  final RewardState _rewardState = RewardState();
  final FocusNode _focusNode = FocusNode();

  // Oyun Durumları
  bool _isStarted = false;
  bool _isGameWon = false;

  int _starsCollected = 0;
  final int _targetStars = 8;
  int _currentMicVolume = 0;
  StreamSubscription<int>? _volumeSub;
  Timer? _gameLoop;

  // Fizik: Roket konumu ve dikey hız
  double _rocketY = 160.0; // 0 (üst) ile 320 (alt) arası
  double _velocity = 0.0;
  final double _gravity = 1.6;
  final double _arenaWidth = 380;
  final double _arenaHeight = 340;

  // Objeler
  final List<_FloatingStar> _stars = [];
  final List<_FloatingCloud> _clouds = [];
  final math.Random _rnd = math.Random();

  late AnimationController _flameAnimController;

  @override
  void initState() {
    super.initState();
    _flameAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..repeat(reverse: true);

    _initScenicElements();
  }

  void _initScenicElements() {
    _clouds.clear();
    _clouds.add(_FloatingCloud(x: 50, y: 30, speed: 0.6, emoji: '☁️'));
    _clouds.add(_FloatingCloud(x: 220, y: 70, speed: 0.9, emoji: '⛅'));
    _clouds.add(_FloatingCloud(x: 340, y: 20, speed: 0.5, emoji: '☁️'));

    _stars.clear();
    for (int i = 0; i < 5; i++) {
      _spawnStar(initialX: 200.0 + (i * 90.0));
    }
  }

  void _spawnStar({double? initialX}) {
    final x = initialX ?? (_arenaWidth + _rnd.nextDouble() * 80);
    final y = 40.0 + _rnd.nextDouble() * (_arenaHeight - 100);
    _stars.add(_FloatingStar(x: x, y: y));
  }

  @override
  void dispose() {
    _gameLoop?.cancel();
    _volumeSub?.cancel();
    _audioService.stopListening();
    _flameAnimController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _startGame() async {
    setState(() {
      _isStarted = true;
            _isGameWon = false;
      _starsCollected = 0;
      _rocketY = 160.0;
      _velocity = 0.0;
    });

    // Canlı Mikrofon Seviyesi Dinleyicisi
    _audioService.requestMicrophonePermission();
    _volumeSub?.cancel();
    _volumeSub = _audioService.onMicVolume.listen((vol) {
      if (mounted) {
        setState(() => _currentMicVolume = vol);
      }
    });

    // Dinlemeyi başlat (mikrofon desibel metre çalışsın)
    _audioService.listenToSpeech(
      duration: const Duration(seconds: 120),
      continuous: true,
    );

    // 60 FPS Oyun Döngüsü
    _gameLoop?.cancel();
    _gameLoop = Timer.periodic(const Duration(milliseconds: 33), (timer) {
      if (!mounted || !_isStarted || _isGameWon) return;
      _updatePhysics();
    });
  }

  void _boostRocketManually() {
    _sfx.playPop();
    setState(() {
      _velocity = -6.5;
      _currentMicVolume = 85;
    });
  }

  void _updatePhysics() {
    setState(() {
      // Mikrofon ses gücü itiş kuvveti üretir
      if (_currentMicVolume > 15) {
        // Ses seviyesine göre yukarı ivme
        final thrust = (_currentMicVolume / 100.0) * 4.2;
        _velocity -= thrust;
      } else {
        // Yerçekimi aşağı çeker
        _velocity += _gravity * 0.45;
      }

      // Hız sınırları
      _velocity = _velocity.clamp(-8.0, 6.0);
      _rocketY += _velocity;

      // Ekran sınırları
      if (_rocketY < 15) {
        _rocketY = 15;
        _velocity = 0;
      } else if (_rocketY > _arenaHeight - 55) {
        _rocketY = _arenaHeight - 55;
        _velocity = 0;
      }

      // Bulutların Hareketi
      for (final cloud in _clouds) {
        cloud.x -= cloud.speed;
        if (cloud.x < -60) {
          cloud.x = _arenaWidth + 40;
          cloud.y = 20.0 + _rnd.nextDouble() * 80;
        }
      }

      // Yıldızların Hareketi ve Çarpışma Testi
      const rocketX = 50.0;
      final rocketCenter = Offset(rocketX + 25, _rocketY + 25);

      for (final star in _stars) {
        star.x -= 3.0; // Yıldızlar sağdan sola akar

        if (!star.isCollected) {
          final starCenter = Offset(star.x + 14, star.y + 14);
          final dist = (rocketCenter - starCenter).distance;

          if (dist < 36) {
            // Yıldız Yakalandı!
            star.isCollected = true;
            _starsCollected++;
            _sfx.playCoinChime();

            if (_starsCollected >= _targetStars) {
              _onMissionVictory();
              return;
            }
          }
        }
      }

      // Ekrandan çıkan yıldızları temizle ve yenilerini ekle
      _stars.removeWhere((s) => s.x < -40 || s.isCollected);
      while (_stars.length < 5) {
        _spawnStar();
      }
    });
  }

  void _onMissionVictory() {
    _gameLoop?.cancel();
    _volumeSub?.cancel();
    _audioService.stopListening();
    _sfx.playVictoryFanfare();

    setState(() {
      _isGameWon = true;
      _isStarted = false;
    });

    _rewardState.addReward(earnedStars: 5, earnedXp: 80, earnedGems: 35);
    widget.onGameWon();
  }

  @override
  Widget build(BuildContext context) {
    final cleanP = widget.phoneme.replaceAll('/', '').trim();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      child: Container(
        width: 440,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          gradient: const LinearGradient(
            colors: [Color(0xFF0D47A1), Color(0xFF1976D2), Color(0xFF42A5F5)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Üst Bar
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Text('🚀', style: TextStyle(fontSize: 24)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Süper Uçan Roket 🚀',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Sesini uzat ("$cleanP$cleanP$cleanP"), roket havalansın!',
                        style: const TextStyle(fontSize: 11.5, color: Colors.white70, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white70),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Skor ve Canlı Desibel Seviyesi Çubuğu
            Row(
              children: [
                // Toplanan Yıldız Sayacı
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Text('⭐', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 6),
                      Text(
                        '$_starsCollected / $_targetStars',
                        style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                // Canlı Ses Gücü / Yakıt Göstergesi
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white30),
                    ),
                    child: Row(
                      children: [
                        const Text('🎙️', style: TextStyle(fontSize: 14)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: (_currentMicVolume / 100).clamp(0.0, 1.0),
                              backgroundColor: Colors.white24,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _currentMicVolume > 40 ? const Color(0xFF00E676) : const Color(0xFFFFD600),
                              ),
                              minHeight: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '%$_currentMicVolume',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // OYUN ARENASI (Gökyüzü)
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Container(
                width: _arenaWidth,
                height: _arenaHeight,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0A192F), Color(0xFF172A45), Color(0xFF203A43)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  border: Border.all(color: Colors.white30, width: 2),
                ),
                child: Stack(
                  children: [
                    // Arka Plan Bulutları
                    for (final c in _clouds)
                      Positioned(
                        left: c.x,
                        top: c.y,
                        child: Text(c.emoji, style: const TextStyle(fontSize: 32)),
                      ),

                    // Yıldızlar
                    for (final s in _stars)
                      if (!s.isCollected)
                        Positioned(
                          left: s.x,
                          top: s.y,
                          child: const Text('⭐', style: TextStyle(fontSize: 28)),
                        ),

                    // Roket ve Alev
                    Positioned(
                      left: 50,
                      top: _rocketY,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Roket Gövdesi
                          const Text('🚀', style: TextStyle(fontSize: 42)),
                          // Ses Gücü Alevi (Ses çıktıkça parlar)
                          if (_currentMicVolume > 15)
                            AnimatedBuilder(
                              animation: _flameAnimController,
                              builder: (ctx, _) {
                                final flameScale = 0.8 + (_currentMicVolume / 100.0) * 0.8;
                                return Transform.scale(
                                  scale: flameScale,
                                  child: const Text('🔥', style: TextStyle(fontSize: 22)),
                                );
                              },
                            ),
                        ],
                      ),
                    ),

                    // Başlangıç Ekranı
                    if (!_isStarted && !_isGameWon)
                      Container(
                        color: Colors.black.withValues(alpha: 0.65),
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('🧑‍🚀', style: TextStyle(fontSize: 54)),
                            const SizedBox(height: 10),
                            const Text(
                              'GÖKYÜZÜ SES UÇUŞU',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFFFFD600),
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              child: Text(
                                'Mikrofona "$cleanP$cleanP$cleanP" sesini uzatarak üfle veya söyle! Sesin roketi yukarı uçuracak ve yıldızları toplayacak!',
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w600, height: 1.4),
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00E676),
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              ),
                              icon: const Icon(Icons.play_arrow_rounded, size: 28),
                              label: const Text(
                                'GÖREVİ BAŞLAT! 🚀',
                                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                              ),
                              onPressed: _startGame,
                            ),
                          ],
                        ),
                      ),

                    // Zafer Ekranı
                    if (_isGameWon)
                      Container(
                        color: Colors.black.withValues(alpha: 0.75),
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('👑', style: TextStyle(fontSize: 56)),
                            const SizedBox(height: 8),
                            const Text(
                              'GÖREV BAŞARILI! 🌟',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFFFFD600),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Harika nefes kontrolü! "$cleanP" sesini muhteşem uzattın!',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 14),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Text('⭐ +5 Yıldız  |  ⚡ +80 XP  |  💎 +35 Elmas',
                                    style: TextStyle(color: Color(0xFF00E676), fontWeight: FontWeight.w900, fontSize: 13)),
                              ],
                            ),
                            const SizedBox(height: 18),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF58CC02),
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              ),
                              onPressed: () => Navigator.pop(context),
                              child: const Text(
                                'ÖDÜLLERİ AL & DEVAM ET 🏆',
                                style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Alt Manuel Yedek Gaz Butonu
            if (_isStarted)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white54, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  icon: const Icon(Icons.touch_app_rounded, size: 20),
                  label: const Text(
                    'Ekrana Dokunarak da Gaz Verebilirsin 👆 (Yedek İtiş)',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                  ),
                  onPressed: _boostRocketManually,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
