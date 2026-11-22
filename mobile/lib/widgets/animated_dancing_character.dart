import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../services/sound_effects_service.dart';

/// 🛹 Subway Surfers Tarzı Kusursuz Simetrik & Canlı 3D Karakter Motoru
/// Karakterler parçalanmış kutu veya asimetrik şekillerden kurtarılmış;
/// anatomik olarak dengeli, simetrik, canlı göz kırpma ve nefes alma animasyonuna sahip,
/// oyun kalitesinde vektörel çizimle sunulmuştur!
class AnimatedDancingCharacter extends StatefulWidget {
  final String characterId; // 'char_skater_can', 'char_robo_b', 'char_ninja', 'char_prenses', 'char_superhero', 'char_dino'
  final double size;
  final bool isDancing;
  final bool showPedestal;
  final bool showShadow;
  final VoidCallback? onTap;
  final String? customHat;
  final String? customProp;

  const AnimatedDancingCharacter({
    super.key,
    this.characterId = 'char_skater_can',
    this.size = 150.0,
    this.isDancing = true,
    this.showPedestal = false,
    this.showShadow = true,
    this.onTap,
    this.customHat,
    this.customProp,
  });

  @override
  State<AnimatedDancingCharacter> createState() => _AnimatedDancingCharacterState();
}

class _AnimatedDancingCharacterState extends State<AnimatedDancingCharacter>
    with TickerProviderStateMixin {
  late AnimationController _idleController;
  late AnimationController _tapReactionController;
  final SoundEffectsService _sfx = SoundEffectsService();

  bool _isWinking = false;

  @override
  void initState() {
    super.initState();

    // 1. Doğal Nefes Alma & Ritmik Yaylanma Döngüsü (1400ms - Yumuşak ve Akıcı)
    _idleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    if (widget.isDancing) {
      _idleController.repeat();
    }

    // 2. Dokunulduğunda 360° Takla & Sevinç Zıplaması (600ms)
    _tapReactionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void didUpdateWidget(covariant AnimatedDancingCharacter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isDancing && !_idleController.isAnimating) {
      _idleController.repeat();
    } else if (!widget.isDancing && _idleController.isAnimating) {
      _idleController.stop();
    }
  }

  @override
  void dispose() {
    _idleController.dispose();
    _tapReactionController.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (_tapReactionController.isAnimating) return;
    _sfx.playPopSound();

    setState(() {
      _isWinking = true;
    });

    _tapReactionController.forward(from: 0.0).then((_) {
      if (mounted) {
        setState(() {
          _isWinking = false;
        });
      }
    });

    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.size;

    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: Listenable.merge([_idleController, _tapReactionController]),
        builder: (context, _) {
          final t = _idleController.value;
          final tapProgress = _tapReactionController.value;

          // Ritmik Yumuşak Salınım (Kusursuz Simetrik Dikey Yaylanma)
          final bounceY = math.sin(t * 2 * math.pi) * (s * 0.04);
          final breathingScaleY = 1.0 + math.cos(t * 2 * math.pi) * 0.02;
          final breathingScaleX = 1.0 - math.cos(t * 2 * math.pi) * 0.015;

          // Dokunma zıplaması ve dönüşü
          final jumpY = tapProgress > 0 ? -math.sin(tapProgress * math.pi) * (s * 0.35) : 0.0;
          final spinAngle = tapProgress > 0 ? tapProgress * 2 * math.pi : 0.0;

          // Zemin gölgesi ölçeği (Karakter yükseldikçe gölge hafifçe küçülür)
          final shadowFactor = (1.0 - ((-jumpY - bounceY) / (s * 0.5))).clamp(0.6, 1.1);

          return SizedBox(
            width: s * 1.35,
            height: s * 1.55,
            child: Stack(
              alignment: Alignment.bottomCenter,
              clipBehavior: Clip.none,
              children: [
                // 1. ZEMİN PODYUMU (Simetrik 3D Sahne)
                if (widget.showPedestal)
                  Positioned(
                    bottom: 0,
                    child: _buildPodium(s, t),
                  ),

                // 2. YER GÖLGESİ (Podyumun üstünde kusursuz simetrik elips)
                if (widget.showShadow)
                  Positioned(
                    bottom: widget.showPedestal ? s * 0.16 : s * 0.04,
                    child: Transform.scale(
                      scaleX: shadowFactor,
                      scaleY: shadowFactor * 0.8,
                      child: Container(
                        width: s * 0.75,
                        height: s * 0.16,
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(55),
                          borderRadius: BorderRadius.all(Radius.elliptical(s * 0.75, s * 0.16)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(45),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // 3. DOKUNMA YILDIZ EFEKTLERİ
                if (tapProgress > 0.1 && tapProgress < 0.9)
                  Positioned(
                    top: s * 0.02,
                    child: const Text('✨ ⭐ 💫', style: TextStyle(fontSize: 24)),
                  ),

                // 4. KUSURSUZ SİMETRİK 3D KARAKTER FİGÜRÜ
                Positioned(
                  bottom: (widget.showPedestal ? s * 0.18 : s * 0.06) + bounceY + jumpY,
                  child: Transform.rotate(
                    angle: spinAngle,
                    child: Transform.scale(
                      scaleX: breathingScaleX,
                      scaleY: breathingScaleY,
                      alignment: Alignment.bottomCenter,
                      child: SizedBox(
                        width: s * 0.95,
                        height: s * 1.35,
                        child: CustomPaint(
                          size: Size(s * 0.95, s * 1.35),
                          painter: _SymmetricCharacterPainter(
                            charId: widget.characterId,
                            isWinking: _isWinking,
                            customHat: widget.customHat,
                            customProp: widget.customProp,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// 3D Simetrik Neon Sahne Podyumu
  Widget _buildPodium(double s, double t) {
    final glowPulse = 0.5 + 0.5 * math.sin(t * 2 * math.pi);

    return Container(
      width: s * 1.25,
      height: s * 0.28,
      decoration: BoxDecoration(
        gradient: const RadialGradient(
          center: Alignment(0.0, -0.2),
          radius: 0.9,
          colors: [
            Color(0xFFFFF9C4),
            Color(0xFFFFB300),
            Color(0xFFE65100),
          ],
        ),
        borderRadius: BorderRadius.all(Radius.elliptical(s * 1.25, s * 0.28)),
        border: Border.all(color: const Color(0xFFFFD54F), width: 3.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF9800).withValues(alpha: 0.3 + 0.2 * glowPulse),
            blurRadius: 16,
            spreadRadius: 3,
            offset: const Offset(0, 4),
          ),
          const BoxShadow(
            color: Colors.black38,
            blurRadius: 10,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: s * 0.95,
          height: s * 0.16,
          decoration: BoxDecoration(
            color: const Color(0xFFFFFDE7),
            borderRadius: BorderRadius.all(Radius.elliptical(s * 0.95, s * 0.16)),
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: const Center(
            child: Icon(Icons.star_rounded, color: Color(0xFFF57C00), size: 22),
          ),
        ),
      ),
    );
  }
}

/// 🎨 KUSURSUZ SİMETRİK VE OYUN KALİTESİNDE VEKTÖR ÇİZİM MOTORU
class _SymmetricCharacterPainter extends CustomPainter {
  final String charId;
  final bool isWinking;
  final String? customHat;
  final String? customProp;

  _SymmetricCharacterPainter({
    required this.charId,
    required this.isWinking,
    this.customHat,
    this.customProp,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final w = size.width;
    final h = size.height;

    switch (charId) {
      case 'char_robo_b':
        _drawRoboB(canvas, cx, w, h);
        break;
      case 'char_ninja':
      case 'char_ninja_shadow':
        _drawNinja(canvas, cx, w, h);
        break;
      case 'char_prenses':
      case 'char_princess_star':
        _drawPrincess(canvas, cx, w, h);
        break;
      case 'char_superhero':
      case 'char_super_artikulo':
        _drawSuperhero(canvas, cx, w, h);
        break;
      case 'char_dino':
        _drawDinoRex(canvas, cx, w, h);
        break;
      case 'char_skater_can':
      default:
        _drawSkaterCan(canvas, cx, w, h);
        break;
    }
  }

  // ==========================================
  // 1. 🛹 KAYKAYCI CAN (Subway Surfers Jake Tarzı)
  // ==========================================
  void _drawSkaterCan(Canvas canvas, double cx, double w, double h) {
    // A. ZEMİNDE SİMETRİK KAYKAY (Her iki ayağın altında yatay dengeli durur)
    final boardY = h * 0.92;
    final boardW = w * 0.82;
    final boardH = h * 0.08;

    // Kaykay gölgesi
    final boardShadow = Paint()..color = Colors.black38;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, boardY + 6), width: boardW * 0.95, height: boardH * 0.6),
        const Radius.circular(8),
      ),
      boardShadow,
    );

    // Kaykay tekerlekleri (Sol ve Sağ simetrik 2 çift tekerlek)
    final wheelPaint = Paint()..color = const Color(0xFFFF5252);
    final wheelRim = Paint()..color = Colors.white;
    for (final wx in [cx - boardW * 0.35, cx + boardW * 0.35]) {
      canvas.drawCircle(Offset(wx, boardY + 4), 6, wheelPaint);
      canvas.drawCircle(Offset(wx, boardY + 4), 2.5, wheelRim);
    }

    // Kaykay Gövdesi (Pro Street Skateboard)
    final boardPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF212121), Color(0xFF424242), Color(0xFF212121)],
      ).createShader(Rect.fromCenter(center: Offset(cx, boardY), width: boardW, height: boardH));

    final boardRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, boardY), width: boardW, height: boardH),
      const Radius.circular(10),
    );
    canvas.drawRRect(boardRect, boardPaint);

    // Kaykay çift yarış şeridi
    final stripePaint = Paint()..color = const Color(0xFFFF9100);
    canvas.drawRect(Rect.fromCenter(center: Offset(cx - 5, boardY), width: 3, height: boardH * 0.8), stripePaint);
    canvas.drawRect(Rect.fromCenter(center: Offset(cx + 5, boardY), width: 3, height: boardH * 0.8), stripePaint);

    // B. BACAKLAR & SNEAKER AYAKKABILAR (Simetrik yerleşim)
    final legW = w * 0.14;
    final legH = h * 0.22;
    final legY = h * 0.68;
    final legSpacing = w * 0.16;

    final pantPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF1976D2), Color(0xFF0D47A1)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(cx - legSpacing - legW, legY, legSpacing * 2 + legW * 2, legH));

    // Sol ve Sağ Kot Bacaklar
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(cx - legSpacing - legW / 2, legY, legW, legH), const Radius.circular(8)),
      pantPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(cx + legSpacing - legW / 2, legY, legW, legH), const Radius.circular(8)),
      pantPaint,
    );

    // Kırmızı & Beyaz Street Sneaker Ayakkabılar
    final shoeY = boardY - 6;
    final shoeW = legW * 1.35;
    final shoeH = h * 0.085;
    final shoePaint = Paint()..color = const Color(0xFFE53935);
    final solePaint = Paint()..color = Colors.white;

    for (final sx in [cx - legSpacing, cx + legSpacing]) {
      // Ayakkabı gövdesi
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(sx, shoeY), width: shoeW, height: shoeH), const Radius.circular(7)),
        shoePaint,
      );
      // Beyaz taban
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(sx, shoeY + shoeH * 0.35), width: shoeW * 0.98, height: 4), const Radius.circular(2)),
        solePaint,
      );
      // Burun detayı
      canvas.drawCircle(Offset(sx + (sx < cx ? -shoeW * 0.3 : shoeW * 0.3), shoeY), 4, solePaint);
    }

    // C. GÖVDE & CEKET / HOODIE (Kusursuz Simetrik Turuncu Streetwear)
    final torsoW = w * 0.48;
    final torsoH = h * 0.34;
    final torsoY = h * 0.38;

    final jacketPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFF9800), Color(0xFFE65100)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(cx - torsoW / 2, torsoY, torsoW, torsoH));

    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(cx - torsoW / 2, torsoY, torsoW, torsoH), const Radius.circular(18)),
      jacketPaint,
    );

    // Ceket fermuarı ve orta şerit
    final zipperPaint = Paint()
      ..color = Colors.black26
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(cx, torsoY + 4), Offset(cx, torsoY + torsoH - 4), zipperPaint);

    // Göğüs Rozeti (Kaykay Yıldızı Amblemi)
    final badgeBg = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(cx, torsoY + torsoH * 0.45), 14, badgeBg);
    final badgeBorder = Paint()
      ..color = const Color(0xFFFF9800)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(Offset(cx, torsoY + torsoH * 0.45), 14, badgeBorder);

    // D. KOLLAR & ELLER (Simetrik Doğal Duruş)
    final armW = w * 0.12;
    final armH = h * 0.28;
    final armY = torsoY + 6;
    final armOffset = torsoW * 0.48;

    final armPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFFA726), Color(0xFFE65100)],
      ).createShader(Rect.fromLTWH(0, armY, w, armH));

    final skinPaint = Paint()..color = const Color(0xFFFFCC80);

    // Sol ve Sağ Kol
    for (final isLeft in [true, false]) {
      final sign = isLeft ? -1 : 1;
      final ax = cx + sign * (armOffset + armW * 0.4);

      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(ax - armW / 2, armY, armW, armH * 0.75), const Radius.circular(8)),
        armPaint,
      );
      // El yumruğu / eldiven
      canvas.drawCircle(Offset(ax, armY + armH * 0.8), armW * 0.55, skinPaint);
    }

    // E. SİMETRİK KULAKLIK (Boyunda asılı)
    final hpY = torsoY + 4;
    final hpW = torsoW * 0.75;
    final hpPaint = Paint()..color = const Color(0xFF263238);
    // Boyun bandı
    canvas.drawArc(
      Rect.fromCenter(center: Offset(cx, hpY), width: hpW, height: 18),
      0,
      math.pi,
      false,
      Paint()
        ..color = const Color(0xFF263238)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5,
    );
    // Kulaklık yastıkları
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx - hpW * 0.45, hpY + 2), width: 10, height: 14), const Radius.circular(4)), hpPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx + hpW * 0.45, hpY + 2), width: 10, height: 14), const Radius.circular(4)), hpPaint);

    // F. KAFA, ŞAPKA & GÜLEN YÜZ (Kusursuz Simetrik)
    final headRadius = w * 0.22;
    final headCenterY = h * 0.24;

    // Yüz Çemberi
    canvas.drawCircle(Offset(cx, headCenterY), headRadius, skinPaint);

    // Yanak Allıkları
    final blushPaint = Paint()..color = Colors.pinkAccent.withAlpha(90);
    canvas.drawCircle(Offset(cx - headRadius * 0.55, headCenterY + 12), 7, blushPaint);
    canvas.drawCircle(Offset(cx + headRadius * 0.55, headCenterY + 12), 7, blushPaint);

    // Canlı Parlak Gözler
    _drawPixarEyes(canvas, cx, headCenterY - 4, headRadius * 0.22, isWinking);

    // Sevecen Geniş Gülümseme (Diş ve Dil detaylı)
    _drawHappyMouth(canvas, cx, headCenterY + 18, headRadius * 0.45);

    // Havalı Sokak Kepi (Geriye/Öne takılmış Kep)
    final capPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF29B6F6), Color(0xFF0288D1)],
      ).createShader(Rect.fromLTWH(cx - headRadius, headCenterY - headRadius, headRadius * 2, headRadius));

    // Kep Kubbesi
    canvas.drawArc(
      Rect.fromCenter(center: Offset(cx, headCenterY - 4), width: headRadius * 2.05, height: headRadius * 1.8),
      math.pi,
      math.pi,
      true,
      capPaint,
    );
    // Kep Siperliği (Sırt veya ön kavis)
    final visorPaint = Paint()..color = const Color(0xFF01579B);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, headCenterY - headRadius * 0.8), width: headRadius * 2.2, height: 8),
        const Radius.circular(4),
      ),
      visorPaint,
    );
    // Kep Tepe Düğmesi
    canvas.drawCircle(Offset(cx, headCenterY - headRadius * 0.95), 4, visorPaint);
  }

  // ==========================================
  // 2. 🤖 FÜTÜRİSTİK ROBO-B
  // ==========================================
  void _drawRoboB(Canvas canvas, double cx, double w, double h) {
    final metalPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF00E5FF), Color(0xFF0091EA), Color(0xFF01579B)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    final cyanGlow = Paint()..color = const Color(0xFF00E5FF);

    // İyon İtici Ayaklar (Yerden süzülür)
    final footY = h * 0.88;
    for (final fx in [cx - w * 0.18, cx + w * 0.18]) {
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(fx, footY), width: w * 0.18, height: h * 0.08), const Radius.circular(8)), metalPaint);
      // İyon ateşi
      canvas.drawCircle(Offset(fx, footY + 8), 6, cyanGlow);
    }

    // Gövde (Titanyum Kasa)
    final torsoW = w * 0.52;
    final torsoH = h * 0.36;
    final torsoY = h * 0.44;
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx, torsoY + torsoH / 2), width: torsoW, height: torsoH), const Radius.circular(16)), metalPaint);

    // Göğüs Reaktörü (Ses Dalgası Ekranı)
    final reactorBg = Paint()..color = const Color(0xFF102027);
    canvas.drawCircle(Offset(cx, torsoY + torsoH * 0.5), 18, reactorBg);
    canvas.drawCircle(Offset(cx, torsoY + torsoH * 0.5), 18, Paint()..color = const Color(0xFF00E5FF)..style = PaintingStyle.stroke..strokeWidth = 2.5);
    // Ses dalgası çizgisi
    final waveP = Paint()..color = const Color(0xFF00E5FF)..strokeWidth = 2.5..style = PaintingStyle.stroke;
    final p = Path();
    p.moveTo(cx - 10, torsoY + torsoH * 0.5);
    p.lineTo(cx - 5, torsoY + torsoH * 0.5 - 6);
    p.lineTo(cx, torsoY + torsoH * 0.5 + 6);
    p.lineTo(cx + 5, torsoY + torsoH * 0.5 - 6);
    p.lineTo(cx + 10, torsoY + torsoH * 0.5);
    canvas.drawPath(p, waveP);

    // Kollar
    for (final sign in [-1, 1]) {
      final ax = cx + sign * (torsoW * 0.58);
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(ax, torsoY + torsoH * 0.4), width: w * 0.12, height: h * 0.24), const Radius.circular(8)), metalPaint);
      canvas.drawCircle(Offset(ax, torsoY + torsoH * 0.6), 8, cyanGlow);
    }

    // Kafa (Kare-Yuvarlak Robot Kafası)
    final headW = w * 0.46;
    final headH = h * 0.28;
    final headY = h * 0.16;
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx, headY + headH / 2), width: headW, height: headH), const Radius.circular(14)), metalPaint);

    // Tepe Anteni
    canvas.drawLine(Offset(cx, headY), Offset(cx, headY - 14), Paint()..color = const Color(0xFF00E5FF)..strokeWidth = 3);
    canvas.drawCircle(Offset(cx, headY - 14), 6, cyanGlow);

    // LED Vizör (Gözlük Ekranı)
    final visorBg = Paint()..color = const Color(0xFF001E3C);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx, headY + headH * 0.42), width: headW * 0.78, height: headH * 0.42), const Radius.circular(8)), visorBg);
    // Parlayan Mavi LED Gözler
    for (final ex in [cx - headW * 0.22, cx + headW * 0.22]) {
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(ex, headY + headH * 0.42), width: 14, height: 8), const Radius.circular(3)), cyanGlow);
    }
  }

  // ==========================================
  // 3. 🥷 GÖLGE NİNJA KAAN
  // ==========================================
  void _drawNinja(Canvas canvas, double cx, double w, double h) {
    final ninjaDark = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF311B92), Color(0xFF1A237E), Color(0xFF0D0D15)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    final goldPaint = Paint()..color = const Color(0xFFFFD700);

    // Çapraz Kılıçlar (Sırtında simetrik)
    final swordPaint = Paint()..color = const Color(0xFFB0BEC5)..strokeWidth = 3;
    canvas.drawLine(Offset(cx - w * 0.35, h * 0.25), Offset(cx + w * 0.35, h * 0.65), swordPaint);
    canvas.drawLine(Offset(cx + w * 0.35, h * 0.25), Offset(cx - w * 0.35, h * 0.65), swordPaint);

    // Bacaklar & Ninja Çizmeleri
    final footY = h * 0.88;
    for (final fx in [cx - w * 0.16, cx + w * 0.16]) {
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(fx, footY), width: w * 0.15, height: h * 0.18), const Radius.circular(6)), ninjaDark);
      canvas.drawRect(Rect.fromCenter(center: Offset(fx, footY + 4), width: w * 0.14, height: 3), goldPaint);
    }

    // Gövde & Kuşak
    final torsoW = w * 0.48;
    final torsoH = h * 0.34;
    final torsoY = h * 0.42;
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx, torsoY + torsoH / 2), width: torsoW, height: torsoH), const Radius.circular(14)), ninjaDark);
    // Altın Kuşak
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx, torsoY + torsoH * 0.8), width: torsoW * 0.95, height: 8), const Radius.circular(4)), goldPaint);

    // Kollar & Bileklikler
    for (final sign in [-1, 1]) {
      final ax = cx + sign * (torsoW * 0.55);
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(ax, torsoY + torsoH * 0.45), width: w * 0.12, height: h * 0.26), const Radius.circular(7)), ninjaDark);
      canvas.drawCircle(Offset(ax, torsoY + torsoH * 0.6), 5, goldPaint);
    }

    // Başlık & Ninja Maskesi
    final headRadius = w * 0.21;
    final headY = h * 0.25;
    canvas.drawCircle(Offset(cx, headY), headRadius, ninjaDark);

    // Altın Alın Bandı
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx, headY - headRadius * 0.4), width: headRadius * 1.8, height: 10), const Radius.circular(4)), goldPaint);
    canvas.drawCircle(Offset(cx, headY - headRadius * 0.4), 6, Paint()..color = const Color(0xFFD50000));

    // Göz Açıklığı & Keskin Kararlı Gözler
    final skinPaint = Paint()..color = const Color(0xFFFFCC80);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx, headY + 2), width: headRadius * 1.3, height: 14), const Radius.circular(4)), skinPaint);
    _drawPixarEyes(canvas, cx, headY + 2, headRadius * 0.2, isWinking);
  }

  // ==========================================
  // 4. 👸 PRENSES YILDIZ
  // ==========================================
  void _drawPrincess(Canvas canvas, double cx, double w, double h) {
    final gownPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFF4081), Color(0xFFE91E63), Color(0xFF880E4F)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    final skinPaint = Paint()..color = const Color(0xFFFFE0B2);
    final goldPaint = Paint()..color = const Color(0xFFFFD700);

    // Görkemli Balo Eteği (Simetrik Çan Etek)
    final skirtPath = Path();
    skirtPath.moveTo(cx - w * 0.18, h * 0.52);
    skirtPath.quadraticBezierTo(cx - w * 0.44, h * 0.85, cx - w * 0.4, h * 0.92);
    skirtPath.quadraticBezierTo(cx, h * 0.95, cx + w * 0.4, h * 0.92);
    skirtPath.quadraticBezierTo(cx + w * 0.44, h * 0.85, cx + w * 0.18, h * 0.52);
    skirtPath.close();
    canvas.drawPath(skirtPath, gownPaint);

    // Etek altın dantel detayı
    canvas.drawPath(
      skirtPath,
      Paint()
        ..color = const Color(0xFFFFD54F)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    // Korse & Üst Beden
    final torsoW = w * 0.36;
    final torsoH = h * 0.22;
    final torsoY = h * 0.36;
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx, torsoY + torsoH / 2), width: torsoW, height: torsoH), const Radius.circular(12)), gownPaint);

    // Kollar
    for (final sign in [-1, 1]) {
      final ax = cx + sign * (torsoW * 0.65);
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(ax, torsoY + torsoH * 0.45), width: w * 0.1, height: h * 0.22), const Radius.circular(6)), gownPaint);
      canvas.drawCircle(Offset(ax, torsoY + torsoH * 0.65), 5, skinPaint);
    }

    // Kafa & Yüz
    final headRadius = w * 0.21;
    final headY = h * 0.24;
    canvas.drawCircle(Offset(cx, headY), headRadius, skinPaint);

    // Saçlar (Simetrik Sarı Bukleler)
    final hairPaint = Paint()..color = const Color(0xFFFFB300);
    canvas.drawCircle(Offset(cx - headRadius * 0.85, headY + 2), 12, hairPaint);
    canvas.drawCircle(Offset(cx + headRadius * 0.85, headY + 2), 12, hairPaint);

    // Gözler & Gülümseme
    _drawPixarEyes(canvas, cx, headY - 4, headRadius * 0.22, isWinking);
    _drawHappyMouth(canvas, cx, headY + 16, headRadius * 0.4);

    // Altın Kristal Taç
    final crownPath = Path();
    final crownY = headY - headRadius * 0.85;
    crownPath.moveTo(cx - 24, crownY + 8);
    crownPath.lineTo(cx - 20, crownY - 14);
    crownPath.lineTo(cx - 10, crownY);
    crownPath.lineTo(cx, crownY - 20); // Orta sivri uç
    crownPath.lineTo(cx + 10, crownY);
    crownPath.lineTo(cx + 20, crownY - 14);
    crownPath.lineTo(cx + 24, crownY + 8);
    crownPath.close();
    canvas.drawPath(crownPath, goldPaint);
    canvas.drawCircle(Offset(cx, crownY - 20), 3.5, Paint()..color = const Color(0xFF00E5FF));
  }

  // ==========================================
  // 5. 🦸 SÜPER ARTİKÜLO
  // ==========================================
  void _drawSuperhero(Canvas canvas, double cx, double w, double h) {
    final suitPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF1E88E5), Color(0xFF0D47A1)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    final capePaint = Paint()..color = const Color(0xFFD50000);
    final goldPaint = Paint()..color = const Color(0xFFFFD700);
    final skinPaint = Paint()..color = const Color(0xFFFFCC80);

    // Kırmızı Pelerin (Gövdenin arkasında simetrik dalgalanır)
    final capePath = Path();
    capePath.moveTo(cx - w * 0.26, h * 0.38);
    capePath.lineTo(cx - w * 0.44, h * 0.88);
    capePath.quadraticBezierTo(cx, h * 0.92, cx + w * 0.44, h * 0.88);
    capePath.lineTo(cx + w * 0.26, h * 0.38);
    capePath.close();
    canvas.drawPath(capePath, capePaint);

    // Bacaklar & Kırmızı Süper Kahraman Çizmeleri
    final footY = h * 0.86;
    for (final fx in [cx - w * 0.16, cx + w * 0.16]) {
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(fx, footY), width: w * 0.15, height: h * 0.2), const Radius.circular(7)), suitPaint);
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(fx, footY + 8), width: w * 0.16, height: h * 0.09), const Radius.circular(5)), capePaint);
    }

    // Gövde & 'S' Amblemi
    final torsoW = w * 0.48;
    final torsoH = h * 0.34;
    final torsoY = h * 0.4;
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx, torsoY + torsoH / 2), width: torsoW, height: torsoH), const Radius.circular(16)), suitPaint);

    // Altın Kemer
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx, torsoY + torsoH * 0.85), width: torsoW * 0.95, height: 7), const Radius.circular(3)), goldPaint);
    canvas.drawCircle(Offset(cx, torsoY + torsoH * 0.85), 6, Paint()..color = const Color(0xFFD50000));

    // Göğüs Kalkanı
    final shieldPath = Path();
    final sy = torsoY + torsoH * 0.42;
    shieldPath.moveTo(cx - 16, sy - 12);
    shieldPath.lineTo(cx + 16, sy - 12);
    shieldPath.lineTo(cx + 12, sy + 4);
    shieldPath.lineTo(cx, sy + 16);
    shieldPath.lineTo(cx - 12, sy + 4);
    shieldPath.close();
    canvas.drawPath(shieldPath, goldPaint);

    // Kollar (Güçlü simetrik duruş)
    for (final sign in [-1, 1]) {
      final ax = cx + sign * (torsoW * 0.58);
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(ax, torsoY + torsoH * 0.4), width: w * 0.12, height: h * 0.25), const Radius.circular(7)), suitPaint);
      canvas.drawCircle(Offset(ax, torsoY + torsoH * 0.6), 8, capePaint);
    }

    // Kafa & Maske
    final headRadius = w * 0.21;
    final headY = h * 0.24;
    canvas.drawCircle(Offset(cx, headY), headRadius, skinPaint);

    // Gözler & Güvenli Kahraman Gülüşü
    _drawPixarEyes(canvas, cx, headY - 4, headRadius * 0.22, isWinking);
    _drawHappyMouth(canvas, cx, headY + 16, headRadius * 0.42);

    // Kahraman Saçı (Siyah Dalgalı)
    canvas.drawArc(Rect.fromCenter(center: Offset(cx, headY - 8), width: headRadius * 2.1, height: headRadius * 1.5), math.pi, math.pi, true, Paint()..color = const Color(0xFF212121));
  }

  // ==========================================
  // 6. 🦖 DİNO REX (Sevimli Dansçı Bebek Dinozor)
  // ==========================================
  void _drawDinoRex(Canvas canvas, double cx, double w, double h) {
    final dinoGreen = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF66BB6A), Color(0xFF43A047), Color(0xFF2E7D32)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    final bellyPaint = Paint()..color = const Color(0xFFC8E6C9);
    final orangeSpikes = Paint()..color = const Color(0xFFFF9800);

    // Sırt Dikenleri (Kafadan sırta simetrik dizili)
    for (int i = 0; i < 4; i++) {
      final spikeY = h * 0.16 + i * 16;
      final p = Path();
      p.moveTo(cx - 7, spikeY);
      p.lineTo(cx, spikeY - 12);
      p.lineTo(cx + 7, spikeY);
      p.close();
      canvas.drawPath(p, orangeSpikes);
    }

    // Tombik Sevimli Gövde
    final torsoW = w * 0.58;
    final torsoH = h * 0.44;
    final torsoY = h * 0.46;
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx, torsoY + torsoH / 2), width: torsoW, height: torsoH), const Radius.circular(24)), dinoGreen);

    // Sarımsı Yumuşak Göbek
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx, torsoY + torsoH * 0.55), width: torsoW * 0.6, height: torsoH * 0.65), const Radius.circular(18)), bellyPaint);

    // Sevimli Dino Bacakları & Sneaker Ayakkabıları
    final footY = h * 0.90;
    for (final fx in [cx - w * 0.18, cx + w * 0.18]) {
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(fx, footY), width: w * 0.16, height: h * 0.08), const Radius.circular(8)), Paint()..color = const Color(0xFFE53935));
      canvas.drawCircle(Offset(fx, footY - 4), 6, Paint()..color = Colors.white);
    }

    // Minik Sevimli Dino Kolları
    for (final sign in [-1, 1]) {
      final ax = cx + sign * (torsoW * 0.48);
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(ax, torsoY + torsoH * 0.35), width: w * 0.12, height: h * 0.16), const Radius.circular(8)), dinoGreen);
    }

    // Sevimli Tombul Dino Kafası
    final headRadius = w * 0.24;
    final headY = h * 0.26;
    canvas.drawCircle(Offset(cx, headY), headRadius, dinoGreen);

    // Kocaman Sevimli Gözler
    _drawPixarEyes(canvas, cx, headY - 6, headRadius * 0.26, isWinking);

    // Sevimli Gülümseyen Ağız & Minik Sevimli Dişler
    _drawHappyMouth(canvas, cx, headY + 18, headRadius * 0.45);
  }

  // ==========================================
  // ORTAK PARLAK GÖZLER & GÜLÜMSEME ÇİZİMİ
  // ==========================================
  void _drawPixarEyes(Canvas canvas, double cx, double eyeY, double eyeRadius, bool isWink) {
    final eyeSpacing = eyeRadius * 1.6;

    for (final isLeft in [true, false]) {
      final ex = cx + (isLeft ? -eyeSpacing : eyeSpacing);

      if (isLeft && isWink) {
        // Göz Kırpma Çizgisi
        final winkPaint = Paint()
          ..color = const Color(0xFF212121)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.5
          ..strokeCap = StrokeCap.round;
        final wp = Path();
        wp.moveTo(ex - eyeRadius * 0.7, eyeY + 2);
        wp.quadraticBezierTo(ex, eyeY - 4, ex + eyeRadius * 0.7, eyeY + 2);
        canvas.drawPath(wp, winkPaint);
      } else {
        // Beyaz Göz Küresi
        canvas.drawCircle(Offset(ex, eyeY), eyeRadius, Paint()..color = Colors.white);

        // Koyu Göz Bebeği
        canvas.drawCircle(Offset(ex, eyeY), eyeRadius * 0.65, Paint()..color = const Color(0xFF263238));

        // Büyük Parlama (Specular Reflection)
        canvas.drawCircle(Offset(ex - eyeRadius * 0.22, eyeY - eyeRadius * 0.22), eyeRadius * 0.28, Paint()..color = Colors.white);

        // Küçük Parlama
        canvas.drawCircle(Offset(ex + eyeRadius * 0.18, eyeY + eyeRadius * 0.18), eyeRadius * 0.12, Paint()..color = Colors.white);
      }
    }
  }

  void _drawHappyMouth(Canvas canvas, double cx, double mouthY, double mouthW) {
    // Ağız Boşluğu (Gülümseme)
    final mouthPath = Path();
    mouthPath.moveTo(cx - mouthW / 2, mouthY);
    mouthPath.quadraticBezierTo(cx, mouthY + mouthW * 0.75, cx + mouthW / 2, mouthY);
    mouthPath.close();

    canvas.drawPath(mouthPath, Paint()..color = const Color(0xFFC2185B));

    // Beyaz Diş Çizgisi
    final teethPath = Path();
    teethPath.moveTo(cx - mouthW * 0.38, mouthY);
    teethPath.lineTo(cx + mouthW * 0.38, mouthY);
    teethPath.lineTo(cx + mouthW * 0.3, mouthY + 5);
    teethPath.lineTo(cx - mouthW * 0.3, mouthY + 5);
    teethPath.close();
    canvas.drawPath(teethPath, Paint()..color = Colors.white);

    // Pembe Dil
    canvas.drawCircle(Offset(cx, mouthY + mouthW * 0.45), mouthW * 0.22, Paint()..color = const Color(0xFFFF80AB));
  }

  @override
  bool shouldRepaint(covariant _SymmetricCharacterPainter oldDelegate) =>
      oldDelegate.charId != charId ||
      oldDelegate.isWinking != isWinking ||
      oldDelegate.customHat != customHat ||
      oldDelegate.customProp != customProp;
}
