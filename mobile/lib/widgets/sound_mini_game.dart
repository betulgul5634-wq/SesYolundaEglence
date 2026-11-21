import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/audio_speech_service.dart';
import '../services/sound_effects_service.dart';
import '../models/reward_state.dart';
import 'subway_surfers_unlock_dialog.dart';

/// 🦁 SES CANAVARI: BÜYÜYEN KELİME AVI OYUNU
/// Orijinal Klinik Artikülasyon Oyunu
/// Çocuk canavarını klavye (⬅️ ➡️ ⬆️ ⬇️ / W A S D), D-Pad veya ekrana dokunarak yönlendirir.
/// Hedef sesi içeren doğru kelimeyi yedikçe ("HAM!") canavar katlanarak BÜYÜR!
/// 4 adımda devasa MEGA KAHRAMAN boyutuna ulaşınca doğrudan Efsane Avatar açılır!
class SoundMiniGameDialog extends StatefulWidget {
  final String phoneme; // örn: "/b/", "b"
  final String soundTitle; // örn: "/b/ Sesi"
  final List<String> targetWords;
  final List<String> distractorWords;
  final VoidCallback onGameWon;
  final int stageLevel;
  final String stageName;

  const SoundMiniGameDialog({
    super.key,
    required this.phoneme,
    required this.soundTitle,
    required this.targetWords,
    required this.distractorWords,
    required this.onGameWon,
    this.stageLevel = 1,
    this.stageName = 'Aşama',
  });

  @override
  State<SoundMiniGameDialog> createState() => _SoundMiniGameDialogState();
}

class _SoundMiniGameDialogState extends State<SoundMiniGameDialog>
    with TickerProviderStateMixin {
  final AudioSpeechService _audioService = AudioSpeechService();
  final SoundEffectsService _sfx = SoundEffectsService();
  final RewardState _rewardState = RewardState();
  final FocusNode _keyboardFocusNode = FocusNode();

  // Oyun Durumları
  bool _isStarted = false;
  int _countdownVal = 0;
  bool _isCountingDown = false;
  bool _isGameOver = false;
  bool _isGameWon = false;

  int _score = 0;
  int _lives = 3;
  int _collectedCount = 0;
  final int _targetGoal = 4; // 4 adımda devasa mega avatar olur!

  String _lastFeedback = '';
  Color _feedbackColor = Colors.transparent;
  bool _isCollisionCoolingDown = false; // Çoklu çarpışma önleme kilidi
  bool _isRoundTransitioning = false; // Yeni kelimeler çıkarken 1.2 saniye tam dokunulmazlık ve güvenli geçiş

  // Canavar Konumu ve Hareketi
  Offset _monsterPos = const Offset(190, 180);
  Offset _moveDir = Offset.zero; // Anlık hareket yönü
  double _monsterAngle = 0.0; // Yön açısı (radyan)

  // Ağız Açıp Kapatma Animasyonu (Chomp)
  late AnimationController _mouthController;
  late AnimationController _rayController;
  Timer? _gameTimer;

  // Arenadaki Kelime Yemleri ve Küçük Noktacıklar
  late List<_WordOrb> _wordOrbs;
  final List<Offset> _smallPellets = [];
  final math.Random _rnd = math.Random();

  Size _arenaSize = const Size(380, 360);

  String get _cleanTargetPhoneme => widget.phoneme.replaceAll('/', '').trim().toLowerCase();

  @override
  void initState() {
    super.initState();

    // 1. Ağız Chomp Animasyonu
    _mouthController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    )..repeat(reverse: true);

    // 2. Koca avatar açılışında dönen altın ışınlar
    _rayController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    // 3. Oyunda 0 gecikme (0ms Latency) için tüm kelimeleri önceden yükle
    _audioService.preloadWords(
      [...widget.targetWords, ...widget.distractorWords],
      phoneme: widget.phoneme,
    );

    _spawnNewWordOrbs();
    _spawnSmallPellets();

    // Otomatik klavye odağını al
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _keyboardFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _mouthController.dispose();
    _rayController.dispose();
    _keyboardFocusNode.dispose();
    super.dispose();
  }

  /// Boyut Seviyesi: Her doğru kelimede Canavar gözle görülür şekilde büyür!
  double get _currentMonsterRadius {
    switch (_collectedCount) {
      case 0:
        return 22.0; // Başlangıç (44px çap)
      case 1:
        return 29.0; // 1. Adım (58px çap - %32 daha büyük)
      case 2:
        return 38.0; // 2. Adım (76px çap - %72 daha büyük)
      case 3:
        return 49.0; // 3. Adım (98px çap - %122 daha büyük)
      case 4:
      default:
        return 62.0; // DEV KOCA MEGA AVATAR (124px çap!)
    }
  }

  String get _growthLevelTitle {
    switch (_collectedCount) {
      case 0:
        return 'Seviye 1: Minik Canavar 🦁';
      case 1:
        return 'Seviye 2: Büyüyen Canavar ⚡';
      case 2:
        return 'Seviye 3: Güçlü Canavar 🔥';
      case 3:
        return 'Seviye 4: Koca Canavar 💥';
      case 4:
      default:
        return 'Seviye 5: DEV MEGA EFSANE 👑';
    }
  }

  String _getSoundSpokenName(String cleanP) {
    switch (cleanP.toLowerCase()) {
      case 'z': return 'zz';
      case 's': return 'ss';
      case 'ş': return 'şş';
      case 'f': return 'ff';
      case 'v': return 'vv';
      case 'r': return 'rrrr';
      case 'm': return 'mmm';
      case 'n': return 'nnnn';
      case 'l': return 'llll';
      case 'b': return 'b';
      case 'p': return 'p';
      case 't': return 't';
      case 'd': return 'd';
      case 'k': return 'k';
      case 'g': return 'g';
      case 'c': return 'ccc';
      case 'ç': return 'ççç';
      case 'j': return 'jjjj';
      case 'y': return 'yyyy';
      case 'h': return 'Ha';
      default: return cleanP.toLowerCase();
    }
  }

  void _startGameWithCountdown() async {
    setState(() {
      _isCountingDown = true;
      _countdownVal = 3;
    });

    final spokenSound = _getSoundSpokenName(_cleanTargetPhoneme);
    _audioService.speakTurkish(
      'Hazır ol! İçinde $spokenSound sesi bulunan kelimeleri ye ve dev gibi büyü!',
      phoneme: widget.phoneme,
      mode: 'game',
    );

    for (int i = 3; i >= 1; i--) {
      if (!mounted) return;
      setState(() => _countdownVal = i);
      await Future.delayed(const Duration(milliseconds: 650));
    }

    if (!mounted) return;
    setState(() {
      _countdownVal = 0;
      _isCountingDown = false;
      _isStarted = true;
      _monsterPos = Offset(_arenaSize.width / 2, _arenaSize.height / 2);
    });

    _startGameLoop();
    _keyboardFocusNode.requestFocus();
  }

  void _startGameLoop() {
    _gameTimer?.cancel();
    // 55 FPS Akıcı Oyun Döngüsü (~18ms)
    _gameTimer = Timer.periodic(const Duration(milliseconds: 20), (timer) {
      if (!mounted || _isGameOver || _isGameWon || !_isStarted) return;
      _updateGame();
    });
  }

  void _updateGame() {
    if (_moveDir == Offset.zero) return;

    final speed = 4.2; // Hızlı, seri ve son derece akıcı kontrol hızı
    var newX = _monsterPos.dx + _moveDir.dx * speed;
    var newY = _monsterPos.dy + _moveDir.dy * speed;

    final r = _currentMonsterRadius;
    newX = newX.clamp(r + 6, _arenaSize.width - r - 6);
    newY = newY.clamp(r + 6, _arenaSize.height - r - 6);

    setState(() {
      _monsterPos = Offset(newX, newY);
    });

    // 1. Küçük Noktacıkları Yeme Kontrolü (Bonus yemler)
    _checkPelletCollisions();

    // 2. Kelime Yemi Kontrolü
    _checkWordOrbCollisions();
  }

  void _checkPelletCollisions() {
    final r = _currentMonsterRadius;
    _smallPellets.removeWhere((pellet) {
      if ((pellet - _monsterPos).distance < r + 6) {
        _score += 10;
        return true;
      }
      return false;
    });
  }

  void _checkWordOrbCollisions() {
    if (_isCollisionCoolingDown || _isRoundTransitioning) return;

    final monsterR = _currentMonsterRadius;
    final targetUpper = _cleanTargetPhoneme.toUpperCase();

    for (int i = 0; i < _wordOrbs.length; i++) {
      final orb = _wordOrbs[i];
      final dist = (orb.pos - _monsterPos).distance;

      // Çarpışma mesafesi: Canavar yarıçapı + Kelime orbu yarıçapı
      if (dist < monsterR + orb.radius) {
        // Çarpışma anında anında durdur (kaymayı önle)
        _moveDir = Offset.zero;
        _isCollisionCoolingDown = true;
        Future.delayed(const Duration(milliseconds: 600), () {
          if (mounted) _isCollisionCoolingDown = false;
        });

        // 🎯 KESİN MATEMATİKSEL KONTROL: Kelimede hedef harf var mı?
        final bool wordActuallyHasTarget = orb.word.toLowerCase().contains(_cleanTargetPhoneme);

        if (wordActuallyHasTarget) {
          // 🎉 DOĞRU KELİME YENDİ (HAM-HAM)!
          _score += 150;
          _collectedCount++;
          _lastFeedback = 'HAMM! 😋 "${orb.word.toUpperCase()}" YENDİ! BÜYÜDÜN! 🌟';
          _feedbackColor = const Color(0xFF2E7D32);
          _sfx.playSuccessDing();

          // Kelimeyi seslendir
          _audioService.speakTurkish(orb.word, phoneme: widget.phoneme, mode: 'game');

          if (_collectedCount >= _targetGoal) {
            // 4 DOĞRU YENDİ ➔ KOCA DEV MEGA AVATAR KAZANILDI!
            _sfx.playVictoryFanfare();
            setState(() {
              _isGameWon = true;
            });
            _gameTimer?.cancel();
            _audioService.speakTurkish(
              'Tebrikler! 4 kelimeyi yedin, dev gibi büyüdün ve Efsanevi Avatarı kazandın!',
              phoneme: widget.phoneme,
              mode: 'game',
            );
            widget.onGameWon();
            return;
          }

          // 🛡️ DOKUNULMAZLIK VE GÜVENLİ MERKEZE GEÇİŞ:
          // Canavar hemen arenanın güvenli merkezine (hiçbir kelimenin olmadığı yere) alınır.
          // 1.2 saniye tam dokunulmazlık verilir; böylece yeni çıkan kelime dibinde kalsa bile ASLA CAN GİTMEZ!
          _isRoundTransitioning = true;
          _moveDir = Offset.zero;

          final w = _arenaSize.width > 100 ? _arenaSize.width : 380.0;
          final h = _arenaSize.height > 100 ? _arenaSize.height : 360.0;
          _monsterPos = Offset(w / 2, h / 2); // Merkeze al

          _spawnNewWordOrbs();

          Future.delayed(const Duration(milliseconds: 1200), () {
            if (mounted) {
              setState(() {
                _isRoundTransitioning = false;
                _lastFeedback = 'Hazır! Yeni kelimeler belirdi, doğru olana yönel! 🎯';
              });
            }
          });
        } else {
          // ⚠️ YANLIŞ KELİMEYE DEĞDİ
          _lives--;
          _sfx.playPop();
          _lastFeedback = 'DİKKAT! 😮 "${orb.word}" içinde [$targetUpper] sesi yok!';
          _feedbackColor = const Color(0xFFC62828);

          // Canavarı orbdan 45 piksel uzağa güvenli yere it (tekrar çarpışmasın)
          final pushDir = (_monsterPos - orb.pos);
          final pushOffset = pushDir == Offset.zero ? const Offset(0, -45) : (pushDir / pushDir.distance) * 45;
          _monsterPos += pushOffset;

          if (_lives <= 0) {
            setState(() {
              _isGameOver = true;
            });
            _gameTimer?.cancel();
            return;
          }
        }
        setState(() {});
        break;
      }
    }
  }

  void _spawnNewWordOrbs() {
    // 1. Hedef kelime listesini tara: KESİNLİKLE hedef harfi içeren kelimeleri filtrele!
    final validTargets = widget.targetWords
        .where((w) => w.toLowerCase().contains(_cleanTargetPhoneme))
        .toList();

    final targetWord = validTargets.isNotEmpty
        ? (validTargets..shuffle(_rnd)).first
        : (widget.targetWords.isNotEmpty ? widget.targetWords.first : 'Balık');

    // 2. Yanıltıcı kelimeleri tara: KESİNLİKLE hedef harfi İÇERMEYEN kelimeler seç!
    final bool isSyllableMode = targetWord.trim().length <= 3;
    final List<String> rawDistractors = isSyllableMode
        ? ['ta', 'ka', 'ma', 'sa', 'pa', 'da', 'la', 'na', 'ze', 'li']
        : widget.distractorWords;

    final safeDistractors = rawDistractors
        .where((w) => !w.toLowerCase().contains(_cleanTargetPhoneme))
        .toList()..shuffle(_rnd);

    final distractor1 = safeDistractors.isNotEmpty ? safeDistractors[0] : 'Kedi';
    final distractor2 = safeDistractors.length > 1 ? safeDistractors[1] : 'Masa';

    // 3 kelimeyi arenanın 3 farklı bölgesine ferahça dağıt
    final w = _arenaSize.width > 100 ? _arenaSize.width : 380.0;
    final h = _arenaSize.height > 100 ? _arenaSize.height : 360.0;

    final candidatePositions = [
      Offset(w * 0.24, h * 0.28), // Sol Üst
      Offset(w * 0.76, h * 0.28), // Sağ Üst
      Offset(w * 0.50, h * 0.76), // Alt Orta
    ]..shuffle(_rnd);

    _wordOrbs = [
      _WordOrb(
        word: targetWord,
        pos: candidatePositions[0],
        radius: 38.0,
      ),
      _WordOrb(
        word: distractor1,
        pos: candidatePositions[1],
        radius: 38.0,
      ),
      _WordOrb(
        word: distractor2,
        pos: candidatePositions[2],
        radius: 38.0,
      ),
    ];
  }

  void _spawnSmallPellets() {
    _smallPellets.clear();
    final w = _arenaSize.width > 100 ? _arenaSize.width : 380.0;
    final h = _arenaSize.height > 100 ? _arenaSize.height : 360.0;

    // Arenaya 12 adet parlak sarı bonus noktacığı ekle
    for (int col = 1; col <= 4; col++) {
      for (int row = 1; row <= 3; row++) {
        _smallPellets.add(Offset(w * (col / 5.0), h * (row / 4.0)));
      }
    }
  }

  void _changeDirection(Offset dir, double angle) {
    if (_isGameOver || _isGameWon || !_isStarted) return;
    setState(() {
      _moveDir = dir;
      _monsterAngle = angle;
    });
  }

  /// Ekranda herhangi bir yere veya orba dokunulduğunda canavarı oraya doğru yürütür
  void _moveTowardsTap(Offset tapPos) {
    if (_isGameOver || _isGameWon || !_isStarted) return;

    final delta = tapPos - _monsterPos;
    if (delta.distance < 10) return;

    final normalized = delta / delta.distance;
    final angle = math.atan2(delta.dy, delta.dx);

    setState(() {
      _moveDir = normalized;
      _monsterAngle = angle;
    });
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return;

    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.arrowLeft || key == LogicalKeyboardKey.keyA) {
      _changeDirection(const Offset(-1, 0), math.pi); // Sola bak
    } else if (key == LogicalKeyboardKey.arrowRight || key == LogicalKeyboardKey.keyD) {
      _changeDirection(const Offset(1, 0), 0.0); // Sağa bak
    } else if (key == LogicalKeyboardKey.arrowUp || key == LogicalKeyboardKey.keyW) {
      _changeDirection(const Offset(0, -1), -math.pi / 2); // Yukarı bak
    } else if (key == LogicalKeyboardKey.arrowDown || key == LogicalKeyboardKey.keyS) {
      _changeDirection(const Offset(0, 1), math.pi / 2); // Aşağı bak
    } else if (key == LogicalKeyboardKey.space) {
      // Space tuşu ile durdur/devam et
      setState(() => _moveDir = Offset.zero);
    }
  }

  void _restartGame() {
    setState(() {
      _score = 0;
      _lives = 3;
      _collectedCount = 0;
      _isGameOver = false;
      _isGameWon = false;
      _isStarted = false;
      _moveDir = Offset.zero;
      _lastFeedback = '';
    });
    _spawnNewWordOrbs();
    _spawnSmallPellets();
    _startGameWithCountdown();
  }

  @override
  Widget build(BuildContext context) {
    if (_isGameWon) {
      return _buildGiantAvatarUnlockScreen();
    }

    return KeyboardListener(
      focusNode: _keyboardFocusNode,
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        elevation: 0,
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 440, maxHeight: 720),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF0F172A)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: const Color(0xFFFFB300), width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.amber.withValues(alpha: 0.35),
                  blurRadius: 28,
                  spreadRadius: 3,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(29),
              child: _isGameOver
                  ? _buildGameOverScreen()
                  : (!_isStarted ? _buildStartTutorialScreen() : _buildMonsterGameScreen()),
            ),
          ),
        ),
      ),
    );
  }

  /// 📖 BAŞLANGIÇ REHBERİ (Ses Canavarı: Büyüyen Kelime Avcısı)
  Widget _buildStartTutorialScreen() {
    final targetUpper = _cleanTargetPhoneme.toUpperCase();

    return Stack(
      children: [
        Positioned(
          top: 8,
          right: 8,
          child: IconButton(
            icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 28),
            tooltip: 'Oyundan Çık',
            onPressed: () => Navigator.pop(context),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
          // Başlık
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFFFB300), Color(0xFFFF6F00)]),
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 8)],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🦁', style: TextStyle(fontSize: 26)),
                const SizedBox(width: 8),
                Text(
                  'SES CANAVARI ($targetUpper Sesi)',
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w900,
                    fontSize: 16.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Görev Açıklama Kutusu
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.amberAccent.withValues(alpha: 0.6), width: 1.5),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Text('😋', style: TextStyle(fontSize: 30)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.4),
                          children: [
                            const TextSpan(text: 'Arenada gezin ve içinde '),
                            TextSpan(
                              text: '[$targetUpper]',
                              style: const TextStyle(
                                color: Color(0xFFFFD700),
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                              ),
                            ),
                            const TextSpan(text: ' sesi bulunan kelime yemini HAM yap ve ye!'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD700).withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('🌟', style: TextStyle(fontSize: 18)),
                      SizedBox(width: 8),
                      Text(
                        'Her doğru kelimede CANAVARIN BÜYÜR!',
                        style: TextStyle(
                          color: Color(0xFFFFD700),
                          fontWeight: FontWeight.w900,
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Klavye & Kontroller Kılavuzu
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Text('⌨️', style: TextStyle(fontSize: 18)),
                    SizedBox(width: 8),
                    Text(
                      'YÖNETİM KONTROLLERİ:',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12.5),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _TutorialKeyBadge(keyLabel: '⬅️ / A', desc: 'Sola'),
                    _TutorialKeyBadge(keyLabel: '⬆️ / W', desc: 'Yukarı'),
                    _TutorialKeyBadge(keyLabel: '⬇️ / S', desc: 'Aşağı'),
                    _TutorialKeyBadge(keyLabel: '➡️ / D', desc: 'Sağa'),
                  ],
                ),
                const SizedBox(height: 8),
                const Center(
                  child: Text(
                    '📱 Dokunmatik: İstediğin kelimeye doğrudan dokunarak da gidebilirsin!',
                    style: TextStyle(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // BAŞLA BUTONU VEYA GERİ SAYIM
          if (_isCountingDown)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFD700),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: Colors.amber.withValues(alpha: 0.6), blurRadius: 20),
                ],
              ),
              child: Text(
                '$_countdownVal',
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  color: Colors.black87,
                ),
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF58CC02),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 8,
                ),
                icon: const Text('🦁', style: TextStyle(fontSize: 24)),
                label: const Text(
                  'BAŞLA VE BÜYÜMEYE BAŞLA! 🚀',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15.5, letterSpacing: 0.5),
                ),
                onPressed: _startGameWithCountdown,
              ),
            ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Şimdilik Vazgeç', style: TextStyle(color: Colors.white54, fontSize: 12)),
          ),
        ],
      ),
    ),
    ],
    );
  }

  /// 🎮 SES CANAVARI OYUN ARENASI & CANLI BÜYÜME SİSTEMİ
  Widget _buildMonsterGameScreen() {
    final activeEmoji = _rewardState.activeAvatar;

    return Column(
      children: [
        // 1. Üst Bar: Canlar, Hedef Ses, Skor ve Çıkış Butonu
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.55),
            border: const Border(bottom: BorderSide(color: Color(0xFFFFB300), width: 2)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Canlar
              Row(
                children: List.generate(3, (i) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 3),
                    child: Text(
                      i < _lives ? '❤️' : '🖤',
                      style: const TextStyle(fontSize: 17),
                    ),
                  );
                }),
              ),
              // Hedef Fonem Rozeti
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFFFFB300), Color(0xFFFF6F00)]),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'Hedef: ${widget.soundTitle}',
                  style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w900, fontSize: 12),
                ),
              ),
              // Skor
              Text(
                '⭐ $_score',
                style: const TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.w900, fontSize: 15),
              ),
              // Oyundan Çık Butonu
              InkWell(
                onTap: () {
                  _gameTimer?.cancel();
                  Navigator.pop(context);
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.redAccent, width: 1.5),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.close_rounded, color: Colors.white, size: 16),
                      SizedBox(width: 3),
                      Text(
                        'Çıkış',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Avatar Büyüme Durumu Göstergesi
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          color: Colors.black38,
          child: Row(
            children: [
              Text(
                _growthLevelTitle,
                style: const TextStyle(color: Colors.amberAccent, fontSize: 11, fontWeight: FontWeight.w900),
              ),
              const Spacer(),
              Text(
                '$_collectedCount/$_targetGoal Kelime',
                style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w800, fontSize: 11),
              ),
            ],
          ),
        ),

        // 2. ANA OYUN ARENASI (LayoutBuilder & Dokunarak Gitme)
        Expanded(
          child: LayoutBuilder(
            builder: (ctx, constraints) {
              _arenaSize = Size(constraints.maxWidth, constraints.maxHeight);

              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: (details) => _moveTowardsTap(details.localPosition),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // A) Neon Grid Arka Planı
                    CustomPaint(
                      size: _arenaSize,
                      painter: _ArenaGridPainter(pellets: _smallPellets),
                    ),

                    // B) Arenadaki 3 Kelime Yemi (Tümü Eşit Şık Görünümde - Cevap Önceden Açığa Çıkmaz!)
                    ..._wordOrbs.map((orb) => _buildWordOrbWidget(orb)),

                    // C) BÜYÜYEN SES CANAVARI (Ağzını Açıp Kapatır, Boyutu Katlanarak Büyür!)
                    _buildAnimatedMonster(activeEmoji),

                    // D) Geri Bildirim Pop-up Banner'ı
                    if (_lastFeedback.isNotEmpty)
                      Positioned(
                        top: 10,
                        left: 16,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _feedbackColor.withValues(alpha: 0.94),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 6)],
                          ),
                          child: Text(
                            _lastFeedback,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),

        // 3. Alt Kontroller: 4 Yönlü D-Pad & Dokunma/Klavye Bilgisi
        Container(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.75),
            border: const Border(top: BorderSide(color: Colors.white24, width: 1.5)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Klavye & Dokunmatik Bilgisi
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '🎮 Yönetim Seçenekleri:',
                    style: TextStyle(color: Colors.amberAccent, fontSize: 11, fontWeight: FontWeight.w900),
                  ),
                  SizedBox(height: 2),
                  Text(
                    '• Klavye: Ok Tuşları veya W-A-S-D\n• Ekrana dokunarak da yönlendirebilirsin!',
                    style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w600),
                  ),
                ],
              ),

              // Dokunmatik 4'lü D-Pad Yön Butonları
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Sol
                  _buildDpadButton(
                    icon: Icons.arrow_back_rounded,
                    onTap: () => _changeDirection(const Offset(-1, 0), math.pi),
                  ),
                  const SizedBox(width: 4),
                  // Yukarı ve Aşağı
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildDpadButton(
                        icon: Icons.arrow_upward_rounded,
                        onTap: () => _changeDirection(const Offset(0, -1), -math.pi / 2),
                      ),
                      const SizedBox(height: 4),
                      _buildDpadButton(
                        icon: Icons.arrow_downward_rounded,
                        onTap: () => _changeDirection(const Offset(0, 1), math.pi / 2),
                      ),
                    ],
                  ),
                  const SizedBox(width: 4),
                  // Sağ
                  _buildDpadButton(
                    icon: Icons.arrow_forward_rounded,
                    onTap: () => _changeDirection(const Offset(1, 0), 0.0),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDpadButton({required IconData icon, required VoidCallback onTap}) {
    return SizedBox(
      width: 44,
      height: 40,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1E293B),
          foregroundColor: const Color(0xFFFFD700),
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFFFFD700), width: 1.5),
          ),
          elevation: 4,
        ),
        onPressed: onTap,
        child: Icon(icon, size: 22),
      ),
    );
  }

  /// Arenadaki Kelime Yemi Baloncuğu (Ferah hap kutusu, dokununca da canavar gider)
  Widget _buildWordOrbWidget(_WordOrb orb) {
    // Kelimenin uzunluğuna göre dinamik genişlik: Kelime asla "..." ile kesilmez!
    final double orbWidth = (orb.word.length > 4)
        ? (orb.word.length * 11.0 + 26.0).clamp(84.0, 135.0)
        : 80.0;

    return Positioned(
      left: orb.pos.dx - (orbWidth / 2),
      top: orb.pos.dy - 28,
      child: GestureDetector(
        onTap: () => _moveTowardsTap(orb.pos),
        child: Container(
          width: orbWidth,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0D47A1), Color(0xFF1976D2), Color(0xFF00B0FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00E5FF).withValues(alpha: 0.5),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🍬', style: TextStyle(fontSize: 13)),
              const SizedBox(height: 2),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  orb.word,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14.5,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🦁 BÜYÜYEN SES CANAVARI ÇİZİMİ
  Widget _buildAnimatedMonster(String avatarEmoji) {
    final r = _currentMonsterRadius;

    return Positioned(
      left: _monsterPos.dx - r,
      top: _monsterPos.dy - r,
      child: AnimatedBuilder(
        animation: _mouthController,
        builder: (ctx, _) {
          return SizedBox(
            width: r * 2,
            height: r * 2,
            child: CustomPaint(
              painter: _MonsterPainter(
                mouthProgress: _mouthController.value,
                angle: _monsterAngle,
                radius: r,
                growthLevel: _collectedCount,
                avatarEmoji: avatarEmoji,
              ),
            ),
          );
        },
      ),
    );
  }

  /// 🏆 KAZANINCA DİREKT AÇILAN DEV KOCA AVATAR KARTI
  Widget _buildGiantAvatarUnlockScreen() {
    final char = SubwaySurfersUnlockDialog.getCharacterForLevel(widget.stageLevel);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
      elevation: 0,
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 420),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFF0F3460)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(36),
            border: Border.all(color: const Color(0xFFFFD700), width: 3.5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFD700).withValues(alpha: 0.5),
                blurRadius: 35,
                spreadRadius: 4,
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ÜST BAŞLIK
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFF8C00)]),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 6, offset: Offset(0, 3))],
                ),
                child: const Text(
                  '🎉 YENİ DEV AVATAR KİLİDİ AÇILDI! 🔓',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.black87),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${widget.stageName} Ses Canavarı Şampiyonu!',
                style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 14),

              // DEVASA DÖNEN GÜNEŞ IŞIĞI & KOCA 220x220 AVATAR KARTI
              SizedBox(
                height: 220,
                width: 220,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Dönen Altın Işık Huzmeleri
                    RotationTransition(
                      turns: _rayController,
                      child: Container(
                        width: 215,
                        height: 215,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: SweepGradient(
                            colors: [
                              Colors.amber.withValues(alpha: 0.0),
                              Colors.amber.withValues(alpha: 0.45),
                              Colors.orange.withValues(alpha: 0.0),
                              Colors.amber.withValues(alpha: 0.45),
                              Colors.orange.withValues(alpha: 0.0),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // KOCA DEV AVATAR KUTUSU
                    Container(
                      width: 175,
                      height: 175,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: char.gradientColors,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4.5),
                        boxShadow: [
                          BoxShadow(
                            color: char.gradientColors.first.withValues(alpha: 0.65),
                            blurRadius: 25,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        char.avatarEmoji,
                        style: const TextStyle(fontSize: 82),
                      ),
                    ),

                    // Rozet
                    Positioned(
                      bottom: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD700),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 4)],
                        ),
                        child: const Text(
                          '⚡ DEV MEGA V.I.P',
                          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Colors.black87),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Karakter İsmi ve Yeteneği
              Text(
                char.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFFFD700),
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                char.title,
                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Colors.white),
              ),
              const SizedBox(height: 8),

              // Özel Yetenek Rozeti
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('⚡', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 6),
                    Text(
                      char.ability,
                      style: const TextStyle(color: Colors.amberAccent, fontSize: 11.5, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 🔥 "HEMEN KUŞAN! 🚀" DEV BUTONU
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF9800),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 8,
                    shadowColor: Colors.orangeAccent.withValues(alpha: 0.7),
                  ),
                  icon: const Text('👑', style: TextStyle(fontSize: 24)),
                  label: const Text(
                    'HEMEN KUŞAN VE PARLA! 🚀',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: 0.8),
                  ),
                  onPressed: () {
                    _rewardState.equipCharacter(char.id, char.name, char.avatarEmoji);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('🎉 ${char.name} KUŞANILDI! Profilinde ve oyunlarda seninle! ⭐'),
                        backgroundColor: const Color(0xFF2E7D32),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Kapat', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 💔 CANLAR BİTTİ EKRANI
  Widget _buildGameOverScreen() {
    final targetUpper = _cleanTargetPhoneme.toUpperCase();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('💥', style: TextStyle(fontSize: 58)),
          const SizedBox(height: 12),
          const Text(
            'Canların Bitti!',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFFFF5252)),
          ),
          const SizedBox(height: 8),
          Text(
            'İçinde [$targetUpper] sesi bulunmayan yemlere değdin. Tekrar dene, doğru kelimeleri ye ve dev gibi büyü!',
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.white70),
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF9800),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              ),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Tekrar Oyna! 🦁', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
              onPressed: _restartGame,
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Oyundan Çık', style: TextStyle(color: Colors.white54)),
          ),
        ],
      ),
    );
  }
}

class _WordOrb {
  final String word;
  final Offset pos;
  final double radius;

  _WordOrb({
    required this.word,
    required this.pos,
    required this.radius,
  });
}

class _TutorialKeyBadge extends StatelessWidget {
  final String keyLabel;
  final String desc;

  const _TutorialKeyBadge({required this.keyLabel, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white12,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white38),
          ),
          child: Text(
            keyLabel,
            style: const TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.w900, fontSize: 11),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          desc,
          style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

/// 🦁 SES CANAVARI ÇİZİCİSİ (Ağız Açıp Kapatma + Büyüyen Halka + Avatar Yüzü)
class _MonsterPainter extends CustomPainter {
  final double mouthProgress; // 0.0 (kapalı) -> 1.0 (tam açık)
  final double angle; // Yön açısı
  final double radius; // Büyüyen yarıçap
  final int growthLevel;
  final String avatarEmoji;

  _MonsterPainter({
    required this.mouthProgress,
    required this.angle,
    required this.radius,
    required this.growthLevel,
    required this.avatarEmoji,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // 1. Dış Büyüme Halesi (Avatar büyüdükçe neon enerji halkası güçlenir)
    if (growthLevel > 0) {
      final auraPaint = Paint()
        ..color = (growthLevel >= 3 ? Colors.amberAccent : const Color(0xFF00E5FF))
            .withValues(alpha: 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5 + growthLevel * 1.5;
      canvas.drawCircle(Offset(cx, cy), radius + 4 + growthLevel * 2, auraPaint);
    }

    // 2. Canavar Sarı/Turuncu Gövdesi & Ağız Açısı
    final mouthAngle = (0.08 + mouthProgress * 0.42) * math.pi;

    final monsterPaint = Paint()
      ..color = const Color(0xFFFFB300)
      ..style = PaintingStyle.fill;

    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: radius);
    final startAngle = angle + mouthAngle;
    final sweepAngle = 2 * math.pi - (2 * mouthAngle);

    final path = Path()
      ..moveTo(cx, cy)
      ..arcTo(rect, startAngle, sweepAngle, false)
      ..close();

    canvas.drawPath(path, monsterPaint);

    // 3. Canavar Gözü
    final eyeDist = radius * 0.55;
    final eyeAngle = angle - 0.75;
    final eyeX = cx + math.cos(eyeAngle) * eyeDist;
    final eyeY = cy + math.sin(eyeAngle) * eyeDist;

    final eyePaint = Paint()..color = const Color(0xFF1E293B);
    canvas.drawCircle(Offset(eyeX, eyeY), radius * 0.16, eyePaint);

    // Göz ışıltısı
    final pupilPaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(eyeX - radius * 0.04, eyeY - radius * 0.04), radius * 0.06, pupilPaint);

    // 4. ÇOCUĞUN SEÇTİĞİ AVATAR EMOJİSİ (Gövdede BÜYÜYEREK görünür)
    final emojiSize = radius * 0.85;
    final textPainter = TextPainter(
      text: TextSpan(
        text: avatarEmoji,
        style: TextStyle(fontSize: emojiSize),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(cx - textPainter.width / 2, cy - textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant _MonsterPainter oldDelegate) => true;
}

/// 🌌 NEON ARENA IZGARASI & BONUS YEM NOKTACIKLARI ÇİZİCİSİ
class _ArenaGridPainter extends CustomPainter {
  final List<Offset> pellets;

  _ArenaGridPainter({required this.pellets});

  @override
  void paint(Canvas canvas, Size size) {
    // Koyu Izgara Çizgileri
    final gridPaint = Paint()
      ..color = const Color(0xFF1E3A8A).withValues(alpha: 0.22)
      ..strokeWidth = 1.0;

    for (double x = 0; x < size.width; x += 30) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += 30) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Dış Sınır Neon Çerçevesi
    final borderPaint = Paint()
      ..color = const Color(0xFF38BDF8).withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(2, 2, size.width - 4, size.height - 4), const Radius.circular(16)),
      borderPaint,
    );

    // Yenebilir Küçük Altın Noktacıklar
    final pelletPaint = Paint()..color = const Color(0xFFFFD54F);
    for (final p in pellets) {
      canvas.drawCircle(p, 3.5, pelletPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ArenaGridPainter oldDelegate) => true;
}
