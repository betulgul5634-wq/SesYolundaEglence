import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../services/sound_effects_service.dart';
import '../models/reward_state.dart';

class _WheelSlice {
  final String label;
  final String icon;
  final Color color;
  final String detailDesc;
  final VoidCallback onWon;

  const _WheelSlice({
    required this.label,
    required this.icon,
    required this.color,
    required this.detailDesc,
    required this.onWon,
  });
}

/// 🎡 GÜNLÜK ŞANS ÇARKIFELEĞİ (DUOLINGO TARZI GERÇEK ÖDÜL SİSTEMİ)
class LuckySpinDialog extends StatefulWidget {
  const LuckySpinDialog({super.key});

  @override
  State<LuckySpinDialog> createState() => _LuckySpinDialogState();
}

class _LuckySpinDialogState extends State<LuckySpinDialog>
    with SingleTickerProviderStateMixin {
  final RewardState _rewardState = RewardState();
  final SoundEffectsService _sfx = SoundEffectsService();
  late AnimationController _spinAnimController;
  late Animation<double> _spinAnimation;

  bool _isSpinning = false;
  bool _hasWon = false;
  String _wonPrizeText = '';
  String _wonPrizeIcon = '';
  String _wonPrizeDetail = '';
  double _currentAngle = 0.0;
  final math.Random _rnd = math.Random();

  late final List<_WheelSlice> _slices;

  @override
  void initState() {
    super.initState();
    _slices = [
      _WheelSlice(
        label: '+50 Elmas',
        icon: '💎',
        color: const Color(0xFF00BCD4),
        detailDesc: '+50 💎 hesabına yüklendi!',
        onWon: () => _rewardState.addReward(earnedStars: 0, earnedXp: 25, earnedGems: 50),
      ),
      _WheelSlice(
        label: '+3 Yıldız',
        icon: '⭐',
        color: const Color(0xFFFFB300),
        detailDesc: '+3 ⭐ yıldız koleksiyonuna eklendi!',
        onWon: () => _rewardState.addReward(earnedStars: 3, earnedXp: 40, earnedGems: 15),
      ),
      _WheelSlice(
        label: 'Kral Tacı',
        icon: '👑',
        color: const Color(0xFFE91E63),
        detailDesc: '👑 Kral Tacı açıldı ve karakterine takıldı!',
        onWon: () {
          _rewardState.unlockAndEquipFree(
            itemId: 'hat_crown',
            category: 'hat',
            emoji: '👑',
          );
          _rewardState.addReward(earnedStars: 1, earnedXp: 50, earnedGems: 25);
        },
      ),
      _WheelSlice(
        label: '+100 XP',
        icon: '⚡',
        color: const Color(0xFF58CC02),
        detailDesc: '+100 ⚡ XP kazanarak ligde yükseldin!',
        onWon: () => _rewardState.addReward(earnedStars: 0, earnedXp: 100, earnedGems: 20),
      ),
      _WheelSlice(
        label: '+100 Elmas',
        icon: '💎',
        color: const Color(0xFF7B1FA2),
        detailDesc: '+100 💎 dev elmas hazinesi hesabında!',
        onWon: () => _rewardState.addReward(earnedStars: 2, earnedXp: 60, earnedGems: 100),
      ),
      _WheelSlice(
        label: 'Altın Kaykay',
        icon: '🛹',
        color: const Color(0xFFFF5722),
        detailDesc: '🛹 Altın Kaykay aksesuarı kuşandın!',
        onWon: () {
          _rewardState.unlockAndEquipFree(
            itemId: 'prop_gold_skateboard',
            category: 'prop',
            emoji: '🛹',
          );
          _rewardState.addReward(earnedStars: 1, earnedXp: 50, earnedGems: 25);
        },
      ),
      _WheelSlice(
        label: 'Can Dolumu',
        icon: '❤️',
        color: const Color(0xFFF44336),
        detailDesc: '❤️ Canların tamamen dolduruldu (5/5)!',
        onWon: () {
          if (_rewardState.hearts < 5) {
            _rewardState.gainHeart(5);
          } else {
            // Can zaten doluysa 50 elmas bonus hediye et
            _rewardState.addReward(earnedStars: 1, earnedXp: 30, earnedGems: 50);
          }
        },
      ),
      _WheelSlice(
        label: 'Sihirbaz Şapkası',
        icon: '🎩',
        color: const Color(0xFF3F51B5),
        detailDesc: '🎩 Sihirbaz Şapkası açıldı ve kuşandın!',
        onWon: () {
          _rewardState.unlockAndEquipFree(
            itemId: 'hat_wizard',
            category: 'hat',
            emoji: '🎩',
          );
          _rewardState.addReward(earnedStars: 1, earnedXp: 50, earnedGems: 25);
        },
      ),
    ];

    _spinAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3800),
    );
  }

  @override
  void dispose() {
    _spinAnimController.dispose();
    super.dispose();
  }

  void _spinWheel() {
    if (_isSpinning) return;

    final isFree = _rewardState.isDailyFreeSpinAvailable;
    if (!isFree) {
      if (_rewardState.gems < 25) {
        _sfx.playPopSound();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚠️ Yetersiz elmas! Tekrar çevirmek için 25 💎 gerekir. Pratik yaparak elmas toplayabilirsin 🎯'),
            backgroundColor: Color(0xFFD32F2F),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
      _rewardState.spendGemsForSpin(25);
    } else {
      _rewardState.recordDailyFreeSpin();
    }

    _sfx.playPopSound();
    final int targetIndex = _rnd.nextInt(_slices.length);
    final sliceAngle = (2 * math.pi) / _slices.length;
    final extraTurns = 5 + _rnd.nextInt(3); // 5 ila 7 tam tur
    final targetAngle = (extraTurns * 2 * math.pi) +
        (3 * math.pi / 2) -
        (targetIndex * sliceAngle) -
        (sliceAngle / 2);

    setState(() {
      _isSpinning = true;
      _hasWon = false;
    });

    _spinAnimation = Tween<double>(begin: _currentAngle, end: targetAngle).animate(
      CurvedAnimation(parent: _spinAnimController, curve: Curves.easeOutCubic),
    )..addListener(() {
        setState(() => _currentAngle = _spinAnimation.value);
      });

    _spinAnimController.reset();
    _spinAnimController.forward().then((_) {
      final wonSlice = _slices[targetIndex];
      wonSlice.onWon();
      _sfx.playVictoryFanfare();

      setState(() {
        _isSpinning = false;
        _hasWon = true;
        _wonPrizeText = wonSlice.label;
        _wonPrizeIcon = wonSlice.icon;
        _wonPrizeDetail = wonSlice.detailDesc;
      });
    });
  }

  Widget _buildLiveStat(String icon, String value, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(icon, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.w900, color: color, fontSize: 13),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      child: ListenableBuilder(
        listenable: _rewardState,
        builder: (context, _) {
          final isFree = _rewardState.isDailyFreeSpinAvailable;

          return Container(
            width: 420,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              gradient: const LinearGradient(
                colors: [Color(0xFF2C3E50), Color(0xFF1A252F)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              border: Border.all(color: const Color(0xFFFFD700), width: 3),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Üst Başlık & Kapatma
                  Row(
                    children: [
                      const Text('🎡', style: TextStyle(fontSize: 28)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'GÜNLÜK ŞANS ÇARKI',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFFFFD700),
                                letterSpacing: 0.8,
                              ),
                            ),
                            Text(
                              isFree
                                  ? '🎁 Bugün 1 Ücretsiz Çevirme Hakkın Var!'
                                  : 'Ücretsiz hak kullanıldı • Tekrar çevir: 25 💎',
                              style: TextStyle(
                                fontSize: 11.5,
                                color: isFree ? const Color(0xFF69F0AE) : Colors.white70,
                                fontWeight: FontWeight.w700,
                              ),
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
                  const SizedBox(height: 10),

                  // CANLI BAKİYE VE İSTATİSTİK ÇUBUĞU
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildLiveStat('💎', '${_rewardState.gems}', const Color(0xFF00E5FF)),
                        _buildLiveStat('❤️', '${_rewardState.hearts}/5', const Color(0xFFFF5252)),
                        _buildLiveStat('⭐', '${_rewardState.totalStars}', const Color(0xFFFFD600)),
                        _buildLiveStat('⚡', '${_rewardState.xp} XP', const Color(0xFF69F0AE)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ÇARK VE İBRE
                  SizedBox(
                    width: 260,
                    height: 260,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Dönen Çark
                        Transform.rotate(
                          angle: _currentAngle,
                          child: CustomPaint(
                            size: const Size(260, 260),
                            painter: _WheelPainter(slices: _slices),
                          ),
                        ),

                        // Merkez Altın Rozet
                        Container(
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFFFD700),
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: const [
                              BoxShadow(color: Colors.black45, blurRadius: 6),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: const Text('🌟', style: TextStyle(fontSize: 24)),
                        ),

                        // Tepe İbresi (Kırmızı Ok)
                        Positioned(
                          top: -2,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Color(0xFFD50000),
                              shape: BoxShape.circle,
                              boxShadow: [BoxShadow(color: Colors.black45, blurRadius: 4)],
                            ),
                            child: const Icon(Icons.arrow_drop_down_rounded, color: Colors.white, size: 28),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // KAZANDI BİLDİRİM KARTI
                  if (_hasWon)
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B5E20).withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFF00E676), width: 2),
                        boxShadow: const [
                          BoxShadow(color: Color(0x3300E676), blurRadius: 8, offset: Offset(0, 3)),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(_wonPrizeIcon, style: const TextStyle(fontSize: 24)),
                              const SizedBox(width: 8),
                              Text(
                                'Tebrikler! $_wonPrizeText Kazandın! 🎉',
                                style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFFB9F6CA), fontSize: 14),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _wonPrizeDetail,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 11.5),
                          ),
                        ],
                      ),
                    ),

                  // ÇEVİR BUTONU
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isSpinning
                            ? Colors.grey
                            : (isFree ? const Color(0xFFFF9800) : const Color(0xFF00C853)),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        elevation: 4,
                      ),
                      icon: Text(isFree ? '🎁' : '🎲', style: const TextStyle(fontSize: 20)),
                      label: Text(
                        _isSpinning
                            ? 'ÇARK DÖNÜYOR... 💫'
                            : (isFree ? 'GÜNLÜK ÜCRETSİZ ÇEVİR! ⚡' : '25 💎 İLE TEKRAR ÇEVİR 🎡'),
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13.5, letterSpacing: 0.5),
                      ),
                      onPressed: _isSpinning ? null : _spinWheel,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _WheelPainter extends CustomPainter {
  final List<_WheelSlice> slices;

  const _WheelPainter({required this.slices});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final sweepAngle = (2 * math.pi) / slices.length;

    final paint = Paint()..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.white
      ..strokeWidth = 2.0;

    for (int i = 0; i < slices.length; i++) {
      paint.color = slices[i].color;
      final startAngle = i * sweepAngle;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        borderPaint,
      );

      // İkon ve Yazı Çizimi
      final textAngle = startAngle + sweepAngle / 2;
      final textRadius = radius * 0.68;
      final x = center.dx + textRadius * math.cos(textAngle);
      final y = center.dy + textRadius * math.sin(textAngle);

      final textSpan = TextSpan(
        text: '${slices[i].icon}\n${slices[i].label}',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          height: 1.1,
          shadows: [Shadow(color: Colors.black54, blurRadius: 3)],
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(textAngle + math.pi / 2);
      textPainter.paint(
        canvas,
        Offset(-textPainter.width / 2, -textPainter.height / 2),
      );
      canvas.restore();
    }

    // Dış Altın Halka
    final goldRing = Paint()
      ..style = PaintingStyle.stroke
      ..color = const Color(0xFFFFD700)
      ..strokeWidth = 6.0;
    canvas.drawCircle(center, radius - 3, goldRing);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
