import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../services/sound_effects_service.dart';

/// 🛹 Subway Surfers Tarzı Canlı Dans Eden & Bacakları Oynayan 3D Karakter Motoru
/// Karakterler düz kutu veya emoji değil; kafası, gövdesi, sallanan kolları,
/// ritimle dans edip basan bacakları ve spor ayakkabıları olan zengin animasyonlu bir figürdür!
class AnimatedDancingCharacter extends StatefulWidget {
  final String characterId; // 'char_skater_can', 'char_robo_b', 'char_ninja', 'char_prenses', 'char_super_artikulo', 'char_dino', etc.
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
    this.size = 140.0,
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
  late AnimationController _danceController;
  late AnimationController _tapReactionController;
  final SoundEffectsService _sfx = SoundEffectsService();

  bool _isWinking = false;

  @override
  void initState() {
    super.initState();

    // 1. Canlı Dans & Bacak-Kol Ritim Döngüsü (1100ms - hip-hop temposu)
    _danceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    if (widget.isDancing) {
      _danceController.repeat();
    }

    // 2. Dokunulduğunda 360° Takla & Dans Zıplaması (650ms)
    _tapReactionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
  }

  @override
  void didUpdateWidget(covariant AnimatedDancingCharacter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isDancing && !_danceController.isAnimating) {
      _danceController.repeat();
    } else if (!widget.isDancing && _danceController.isAnimating) {
      _danceController.stop();
    }
  }

  @override
  void dispose() {
    _danceController.dispose();
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
        animation: Listenable.merge([_danceController, _tapReactionController]),
        builder: (context, _) {
          final t = _danceController.value; // 0.0 -> 1.0
          final tapProgress = _tapReactionController.value;

          // Ritmik Dans Hesaplamaları
          final bounceY = math.sin(t * 2 * math.pi) * (s * 0.04); // Gövde yukarı-aşağı yaylanma
          final bodyTilt = math.sin(t * 2 * math.pi) * 0.06; // Gövde hafif sağa-sola yatma

          // Bacak açıları: Sol ve sağ bacak karşıt fazda ileri-geri ve yukarı dans eder (Subway Surfers koşu/dans ritmi)
          final leftLegAngle = math.sin(t * 2 * math.pi) * 0.28;
          final rightLegAngle = -math.sin(t * 2 * math.pi) * 0.28;
          final leftLegLift = math.max(0.0, -math.sin(t * 2 * math.pi)) * (s * 0.05);
          final rightLegLift = math.max(0.0, math.sin(t * 2 * math.pi)) * (s * 0.05);

          // Kol açıları: Bacakların tersine karşıt fazda sallanır
          final leftArmAngle = -math.sin(t * 2 * math.pi) * 0.35 + 0.1;
          final rightArmAngle = math.sin(t * 2 * math.pi) * 0.35 - 0.1;

          // Dokunma zıplaması & takla
          final jumpY = tapProgress > 0
              ? -math.sin(tapProgress * math.pi) * (s * 0.32)
              : 0.0;
          final spinAngle = tapProgress > 0
              ? tapProgress * 2 * math.pi
              : 0.0;

          // Gölge ölçeği: Zıplayınca gölge küçülür, inince büyür
          final shadowScale = 1.0 - ((-jumpY - bounceY) / (s * 0.6)).clamp(0.0, 0.5);

          return SizedBox(
            width: s * 1.3,
            height: s * 1.5,
            child: Stack(
              alignment: Alignment.bottomCenter,
              clipBehavior: Clip.none,
              children: [
                // 1. ZEMİN PODYUMU (Opsiyonel)
                if (widget.showPedestal)
                  Positioned(
                    bottom: 0,
                    child: _buildPodium(s),
                  ),

                // 2. DİNAMİK YER GÖLGESİ (Bacakların altında ritimle nefes alır)
                if (widget.showShadow)
                  Positioned(
                    bottom: widget.showPedestal ? s * 0.12 : s * 0.04,
                    child: Transform.scale(
                      scaleX: shadowScale,
                      scaleY: shadowScale * 0.8,
                      child: Container(
                        width: s * 0.65,
                        height: s * 0.14,
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(50),
                          borderRadius: BorderRadius.all(Radius.elliptical(s * 0.65, s * 0.14)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(40),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // 3. YILDIZ / DOKUNMA EFEKTLERİ
                if (tapProgress > 0.1 && tapProgress < 0.9)
                  Positioned(
                    top: s * 0.05,
                    child: const Text('✨⭐🎉', style: TextStyle(fontSize: 22)),
                  ),

                // 4. ANA DANS EDEN KARAKTER (Tüm uzuvlar burada)
                Positioned(
                  bottom: (widget.showPedestal ? s * 0.14 : s * 0.06) + bounceY + jumpY,
                  child: Transform.rotate(
                    angle: spinAngle + bodyTilt,
                    child: _buildCharacterFigure(
                      s: s,
                      charId: widget.characterId,
                      leftLegAngle: leftLegAngle,
                      rightLegAngle: rightLegAngle,
                      leftLegLift: leftLegLift,
                      rightLegLift: rightLegLift,
                      leftArmAngle: leftArmAngle,
                      rightArmAngle: rightArmAngle,
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

  /// 3D Zemin Podyumu (Subway Surfers Menü Sahnesi Tarzı)
  Widget _buildPodium(double s) {
    return Container(
      width: s * 1.15,
      height: s * 0.24,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFFD54F),
            Color(0xFFFF9800),
            Color(0xFFE65100),
          ],
        ),
        borderRadius: BorderRadius.all(Radius.elliptical(s * 1.15, s * 0.24)),
        border: Border.all(color: const Color(0xFFFFF59D), width: 3),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF9800).withAlpha(120),
            blurRadius: 18,
            spreadRadius: 3,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: s * 0.9,
          height: s * 0.14,
          decoration: BoxDecoration(
            color: const Color(0xFFFFF9C4),
            borderRadius: BorderRadius.all(Radius.elliptical(s * 0.9, s * 0.14)),
          ),
          child: const Center(
            child: Icon(Icons.star_rounded, color: Color(0xFFF57C00), size: 18),
          ),
        ),
      ),
    );
  }

  /// Karakter Figürü (Bacaklar, Gövde, Kollar ve Kafa Katmanları)
  Widget _buildCharacterFigure({
    required double s,
    required String charId,
    required double leftLegAngle,
    required double rightLegAngle,
    required double leftLegLift,
    required double rightLegLift,
    required double leftArmAngle,
    required double rightArmAngle,
  }) {
    final style = _getCharacterStyle(charId);

    return SizedBox(
      width: s * 0.85,
      height: s * 1.25,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          // A. PELERİN / KANAT (Varsa gövdenin arkasında dalgalanır)
          if (style.hasCape)
            Positioned(
              top: s * 0.38,
              child: Transform.rotate(
                angle: math.sin(_danceController.value * 2 * math.pi) * 0.12,
                child: Container(
                  width: s * 0.44,
                  height: s * 0.48,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE53935), Color(0xFFB71C1C)],
                    ),
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                    boxShadow: [
                      BoxShadow(color: Colors.red.withAlpha(80), blurRadius: 6),
                    ],
                  ),
                ),
              ),
            ),

          // B. ARKA AKSESUAR (Kaykay, Kılıç vb.)
          if (style.backProp != null && style.backProp!.isNotEmpty)
            Positioned(
              left: -s * 0.08,
              bottom: s * 0.22,
              child: Transform.rotate(
                angle: -0.25,
                child: Text(style.backProp!, style: TextStyle(fontSize: s * 0.34)),
              ),
            ),

          // C. SOL BACAK & AYAKKABI (Dans eden sol bacak)
          Positioned(
            left: s * 0.22,
            bottom: s * 0.04 + leftLegLift,
            child: Transform.rotate(
              angle: leftLegAngle,
              origin: Offset(s * 0.04, 0),
              child: _buildLeg(
                s: s,
                pantColor: style.pantColor,
                shoeColor: style.shoeColor,
                shoeTrim: style.shoeTrim,
                shoeIcon: style.shoeIcon,
                isLeft: true,
              ),
            ),
          ),

          // D. SAĞ BACAK & AYAKKABI (Dans eden sağ bacak)
          Positioned(
            right: s * 0.22,
            bottom: s * 0.04 + rightLegLift,
            child: Transform.rotate(
              angle: rightLegAngle,
              origin: Offset(s * 0.04, 0),
              child: _buildLeg(
                s: s,
                pantColor: style.pantColor,
                shoeColor: style.shoeColor,
                shoeTrim: style.shoeTrim,
                shoeIcon: style.shoeIcon,
                isLeft: false,
              ),
            ),
          ),

          // E. SOL KOL & EL (Ritimle sallanır)
          Positioned(
            left: s * 0.08,
            top: s * 0.44,
            child: Transform.rotate(
              angle: leftArmAngle,
              origin: Offset(s * 0.04, 0),
              child: _buildArm(
                s: s,
                sleeveColor: style.jacketColor,
                skinColor: style.skinColor,
                heldItem: style.leftHandItem,
                isLeft: true,
              ),
            ),
          ),

          // F. SAĞ KOL & EL (Ritimle sallanır, prop tutabilir)
          Positioned(
            right: s * 0.08,
            top: s * 0.44,
            child: Transform.rotate(
              angle: rightArmAngle,
              origin: Offset(s * 0.04, 0),
              child: _buildArm(
                s: s,
                sleeveColor: style.jacketColor,
                skinColor: style.skinColor,
                heldItem: widget.customProp ?? style.rightHandItem,
                isLeft: false,
              ),
            ),
          ),

          // G. GÖVDE / CEKET / HOODIE (Subway Surfers sokak stili)
          Positioned(
            bottom: s * 0.32,
            child: _buildTorso(s: s, style: style),
          ),

          // H. KAFA, SAÇ, ŞAPKA VE İFADELİ YÜZ
          Positioned(
            top: s * 0.04,
            child: _buildHead(s: s, style: style),
          ),
        ],
      ),
    );
  }

  /// Dans Eden Bacak ve Özel Spor Ayakkabı (Sneaker)
  Widget _buildLeg({
    required double s,
    required Color pantColor,
    required Color shoeColor,
    required Color shoeTrim,
    required String? shoeIcon,
    required bool isLeft,
  }) {
    final legW = s * 0.12;
    final legH = s * 0.34;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Pantolon / Paça
        Container(
          width: legW,
          height: legH * 0.65,
          decoration: BoxDecoration(
            color: pantColor,
            borderRadius: BorderRadius.circular(legW * 0.3),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 3)],
          ),
        ),
        // Çorap bandı
        Container(
          width: legW * 0.9,
          height: 3,
          color: Colors.white,
        ),
        // Havalı Spor Ayakkabı (Subway Surfers High-Top Sneaker)
        Container(
          width: legW * 1.55,
          height: legH * 0.42,
          margin: EdgeInsets.only(left: isLeft ? 0 : 4, right: isLeft ? 4 : 0),
          decoration: BoxDecoration(
            color: shoeColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(legW * 0.4),
              topRight: Radius.circular(legW * 0.6),
              bottomLeft: const Radius.circular(8),
              bottomRight: const Radius.circular(8),
            ),
            border: Border.all(color: shoeTrim, width: 2),
            boxShadow: [
              BoxShadow(
                color: shoeColor.withAlpha(120),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Taban çizgisi
              Positioned(
                bottom: 1,
                child: Container(
                  width: legW * 1.45,
                  height: 3,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              if (shoeIcon != null)
                Text(shoeIcon, style: const TextStyle(fontSize: 9))
              else
                // Bağcık detayı
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(width: 4, height: 2, color: Colors.white70),
                    const SizedBox(width: 2),
                    Container(width: 4, height: 2, color: Colors.white70),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }

  /// Sallanan Kol ve El
  Widget _buildArm({
    required double s,
    required Color sleeveColor,
    required Color skinColor,
    required String? heldItem,
    required bool isLeft,
  }) {
    final armW = s * 0.11;
    final armH = s * 0.34;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Kol / Kol Manşeti
        Container(
          width: armW,
          height: armH * 0.7,
          decoration: BoxDecoration(
            color: sleeveColor,
            borderRadius: BorderRadius.circular(armW * 0.35),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 2)],
          ),
        ),
        // El (Eldivenli veya Ten Rengi)
        Container(
          width: armW * 1.1,
          height: armH * 0.32,
          decoration: BoxDecoration(
            color: skinColor,
            shape: BoxShape.circle,
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2)],
          ),
          child: heldItem != null && heldItem.isNotEmpty
              ? Center(child: Text(heldItem, style: TextStyle(fontSize: s * 0.22)))
              : null,
        ),
      ],
    );
  }

  /// Gövde / Tişört / Ceket Katmanı
  Widget _buildTorso({required double s, required _CharacterStyle style}) {
    final torsoW = s * 0.46;
    final torsoH = s * 0.38;

    return Container(
      width: torsoW,
      height: torsoH,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: style.jacketGradient,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withAlpha(60), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: style.jacketColor.withAlpha(100),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Kapüşon ipi veya ceket fermuarı
          Positioned(
            top: 0,
            bottom: 0,
            child: Container(
              width: 3,
              color: Colors.black26,
            ),
          ),
          // Göğüs Amblemi / Logosu
          Center(
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withAlpha(180),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 3)],
              ),
              child: Text(
                style.emblem,
                style: TextStyle(fontSize: s * 0.16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Kafa, Saç, Şapka ve Yüz İfadesi
  Widget _buildHead({required double s, required _CharacterStyle style}) {
    final headSize = s * 0.44;

    return SizedBox(
      width: headSize * 1.3,
      height: headSize * 1.25,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // 1. Şapka / Taç / Başlık
          if (widget.customHat != null || style.hatEmoji != null)
            Positioned(
              top: -headSize * 0.28,
              child: Text(
                widget.customHat ?? style.hatEmoji!,
                style: TextStyle(fontSize: headSize * 0.65),
              ),
            ),

          // 2. Kafa Yuvarlağı
          Container(
            width: headSize,
            height: headSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: style.skinColor,
              border: Border.all(color: Colors.white.withAlpha(90), width: 2),
              boxShadow: [
                BoxShadow(
                  color: style.skinColor.withAlpha(120),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Gözler (Canlı Kırpan / Göz Kırpan)
                Positioned(
                  top: headSize * 0.28,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Sol Göz
                      _buildEye(headSize * 0.18, _isWinking ? true : false, style.eyeColor),
                      SizedBox(width: headSize * 0.16),
                      // Sağ Göz
                      _buildEye(headSize * 0.18, false, style.eyeColor),
                    ],
                  ),
                ),

                // Gülümseyen Dudaklar (Artikülasyon / Neşe)
                Positioned(
                  bottom: headSize * 0.18,
                  child: Container(
                    width: headSize * 0.28,
                    height: headSize * 0.14,
                    decoration: const BoxDecoration(
                      color: Color(0xFFD81B60),
                      borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
                    ),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        width: headSize * 0.2,
                        height: 3,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                // Yanak allıkları
                Positioned(
                  bottom: headSize * 0.24,
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.pink.withAlpha(80),
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: headSize * 0.44),
                      Container(
                        width: 8,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.pink.withAlpha(80),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Kulaklık (Skater Can gibi karakterler için)
          if (style.hasHeadphones)
            Positioned(
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF212121),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text('🎧', style: TextStyle(fontSize: 14)),
              ),
            ),
        ],
      ),
    );
  }

  /// Canlı Göz Yapısı
  Widget _buildEye(double eyeSize, bool isWink, Color eyeColor) {
    if (isWink) {
      return Container(
        width: eyeSize,
        height: 4,
        decoration: BoxDecoration(
          color: const Color(0xFF212121),
          borderRadius: BorderRadius.circular(2),
        ),
      );
    }
    return Container(
      width: eyeSize,
      height: eyeSize * 1.25,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 2)],
      ),
      child: Center(
        child: Container(
          width: eyeSize * 0.65,
          height: eyeSize * 0.8,
          decoration: BoxDecoration(
            color: eyeColor,
            shape: BoxShape.circle,
          ),
          child: Align(
            alignment: const Alignment(-0.4, -0.4),
            child: Container(
              width: 3.5,
              height: 3.5,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 8 Subway Surfers Karakterinin Görsel Tasarım Haritası
  _CharacterStyle _getCharacterStyle(String id) {
    switch (id) {
      case 'char_robo_b':
        return _CharacterStyle(
          name: 'Robo-B',
          jacketColor: const Color(0xFF00B0FF),
          jacketGradient: [const Color(0xFF00E5FF), const Color(0xFF0091EA)],
          pantColor: const Color(0xFF263238),
          shoeColor: const Color(0xFF00E5FF),
          shoeTrim: const Color(0xFFFFF176),
          shoeIcon: '⚡',
          skinColor: const Color(0xFFCFD8DC),
          eyeColor: const Color(0xFF00E5FF),
          hatEmoji: '🤖',
          emblem: '⚡',
          leftHandItem: null,
          rightHandItem: '🔋',
          backProp: '🚀',
        );

      case 'char_ninja':
      case 'char_ninja_shadow':
        return _CharacterStyle(
          name: 'Ninja Kaan',
          jacketColor: const Color(0xFF311B92),
          jacketGradient: [const Color(0xFF512DA8), const Color(0xFF311B92)],
          pantColor: const Color(0xFF1A237E),
          shoeColor: const Color(0xFF212121),
          shoeTrim: const Color(0xFF7C4DFF),
          shoeIcon: null,
          skinColor: const Color(0xFFFFCC80),
          eyeColor: const Color(0xFF212121),
          hatEmoji: '🥷',
          emblem: '⭐',
          leftHandItem: null,
          rightHandItem: '🗡️',
          backProp: '⚔️',
        );

      case 'char_prenses':
      case 'char_princess_star':
        return _CharacterStyle(
          name: 'Prenses Yıldız',
          jacketColor: const Color(0xFFE91E63),
          jacketGradient: [const Color(0xFFFF4081), const Color(0xFFC2185B)],
          pantColor: const Color(0xFFF8BBD0),
          shoeColor: const Color(0xFFFF4081),
          shoeTrim: const Color(0xFFFFD54F),
          shoeIcon: '✨',
          skinColor: const Color(0xFFFFE0B2),
          eyeColor: const Color(0xFF880E4F),
          hatEmoji: '👑',
          emblem: '💖',
          leftHandItem: '🪄',
          rightHandItem: null,
          backProp: '🧚',
        );

      case 'char_superhero':
      case 'char_super_artikulo':
        return _CharacterStyle(
          name: 'Süper Artikülo',
          jacketColor: const Color(0xFF1565C0),
          jacketGradient: [const Color(0xFF1E88E5), const Color(0xFF0D47A1)],
          pantColor: const Color(0xFFD32F2F),
          shoeColor: const Color(0xFFFFD600),
          shoeTrim: const Color(0xFFE65100),
          shoeIcon: '⭐',
          skinColor: const Color(0xFFFFCC80),
          eyeColor: const Color(0xFF0D47A1),
          hatEmoji: '🦸',
          emblem: 'S',
          hasCape: true,
          leftHandItem: null,
          rightHandItem: '🏆',
          backProp: null,
        );

      case 'char_dino':
        return _CharacterStyle(
          name: 'Dino Rex',
          jacketColor: const Color(0xFF43A047),
          jacketGradient: [const Color(0xFF66BB6A), const Color(0xFF2E7D32)],
          pantColor: const Color(0xFF2E7D32),
          shoeColor: const Color(0xFF7CB342),
          shoeTrim: const Color(0xFFFDD835),
          shoeIcon: '🦖',
          skinColor: const Color(0xFFA5D6A7),
          eyeColor: const Color(0xFF1B5E20),
          hatEmoji: '🦖',
          emblem: '🐾',
          leftHandItem: null,
          rightHandItem: '🥚',
          backProp: null,
        );

      case 'char_korsan':
        return _CharacterStyle(
          name: 'Korsan Kaptan',
          jacketColor: const Color(0xFFB71C1C),
          jacketGradient: [const Color(0xFFD32F2F), const Color(0xFF880E4F)],
          pantColor: const Color(0xFF212121),
          shoeColor: const Color(0xFF4E342E),
          shoeTrim: const Color(0xFFFFD54F),
          shoeIcon: null,
          skinColor: const Color(0xFFFFCC80),
          eyeColor: const Color(0xFF3E2723),
          hatEmoji: '🏴‍☠️',
          emblem: '⚓',
          leftHandItem: '🦜',
          rightHandItem: '🗺️',
          backProp: null,
        );

      case 'char_astronot':
        return _CharacterStyle(
          name: 'Astronot Melis',
          jacketColor: const Color(0xFFECEFF1),
          jacketGradient: [const Color(0xFFFFFFFF), const Color(0xFFCFD8DC)],
          pantColor: const Color(0xFFECEFF1),
          shoeColor: const Color(0xFF78909C),
          shoeTrim: const Color(0xFF00E5FF),
          shoeIcon: '🚀',
          skinColor: const Color(0xFFFFE0B2),
          eyeColor: const Color(0xFF1A237E),
          hatEmoji: '👩‍🚀',
          emblem: '🪐',
          leftHandItem: null,
          rightHandItem: '📡',
          backProp: '🛰️',
        );

      case 'char_skater_can':
      case 'char_skater_jake':
      default:
        // Varsayılan: Süper Kaykaycı Can (Subway Surfers Jake Tarzı)
        return _CharacterStyle(
          name: 'Kaykaycı Can',
          jacketColor: const Color(0xFFFF6D00),
          jacketGradient: [const Color(0xFFFF9100), const Color(0xFFE65100)],
          pantColor: const Color(0xFF1565C0), // Kot pantolon
          shoeColor: const Color(0xFFE53935), // Kırmızı sokak sneaker'ı
          shoeTrim: Colors.white,
          shoeIcon: null,
          skinColor: const Color(0xFFFFCC80),
          eyeColor: const Color(0xFF3E2723),
          hatEmoji: '🧢', // Yan takılmış kep
          emblem: '🛹',
          hasHeadphones: true,
          leftHandItem: null,
          rightHandItem: null,
          backProp: '🛹', // Sırtta veya altta kaykay
        );
    }
  }
}

class _CharacterStyle {
  final String name;
  final Color jacketColor;
  final List<Color> jacketGradient;
  final Color pantColor;
  final Color shoeColor;
  final Color shoeTrim;
  final String? shoeIcon;
  final Color skinColor;
  final Color eyeColor;
  final String? hatEmoji;
  final String emblem;
  final bool hasHeadphones;
  final bool hasCape;
  final String? leftHandItem;
  final String? rightHandItem;
  final String? backProp;

  const _CharacterStyle({
    required this.name,
    required this.jacketColor,
    required this.jacketGradient,
    required this.pantColor,
    required this.shoeColor,
    required this.shoeTrim,
    required this.shoeIcon,
    required this.skinColor,
    required this.eyeColor,
    required this.hatEmoji,
    required this.emblem,
    this.hasHeadphones = false,
    this.hasCape = false,
    this.leftHandItem,
    this.rightHandItem,
    this.backProp,
  });
}
