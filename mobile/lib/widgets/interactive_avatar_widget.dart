import 'animated_dancing_character.dart';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../services/sound_effects_service.dart';

/// 🌟 CANLI, KATMANLI VE ETKİLEŞİMLİ AVATAR MOTORU
/// - Aksesuarlar (şapka, gözlük, eşya, evcil hayvan) kafaya ve gövdeye TAM OTURUR.
/// - Nefes alma, süzülme ve dokunulduğunda 360° takla atıp zıplama animasyonu içerir.
/// - Altında parıldayan 3D podyum ve altın ışık halkası bulunur.
class InteractiveAvatarWidget extends StatefulWidget {
  final String avatar;
  final String? hat;
  final String? glasses;
  final String? prop;
  final String? pet;
  final double size;
  final bool showPedestal;
  final bool animate;
  final VoidCallback? onTap;

  const InteractiveAvatarWidget({
    super.key,
    required this.avatar,
    this.hat,
    this.glasses,
    this.prop,
    this.pet,
    this.size = 110.0,
    this.showPedestal = true,
    this.animate = true,
    this.onTap,
  });

  @override
  State<InteractiveAvatarWidget> createState() => _InteractiveAvatarWidgetState();
}

class _InteractiveAvatarWidgetState extends State<InteractiveAvatarWidget>
    with TickerProviderStateMixin {
  late AnimationController _idleController;
  late Animation<double> _breathAnimation;
  late Animation<double> _floatAnimation;

  late AnimationController _tapJumpController;
  late Animation<double> _jumpAnimation;
  late Animation<double> _spinAnimation;

  final SoundEffectsService _sfx = SoundEffectsService();

  @override
  void initState() {
    super.initState();

    // 1. Ritmik Nefes & Süzülme Animasyonu (2.2 saniye)
    _idleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _breathAnimation = Tween<double>(begin: 0.97, end: 1.03).animate(
      CurvedAnimation(parent: _idleController, curve: Curves.easeInOutSine),
    );

    _floatAnimation = Tween<double>(begin: -3.0, end: 3.0).animate(
      CurvedAnimation(parent: _idleController, curve: Curves.easeInOutSine),
    );

    if (widget.animate) {
      _idleController.repeat(reverse: true);
    }

    // 2. Dokunma / Zıplama & 360° Takla Animasyonu
    _tapJumpController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _jumpAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: -28.0).chain(CurveTween(curve: Curves.easeOutQuad)), weight: 45),
      TweenSequenceItem(tween: Tween<double>(begin: -28.0, end: 0.0).chain(CurveTween(curve: Curves.bounceOut)), weight: 55),
    ]).animate(_tapJumpController);

    _spinAnimation = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _tapJumpController, curve: Curves.easeInOutBack),
    );
  }

  @override
  void dispose() {
    _idleController.dispose();
    _tapJumpController.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (_tapJumpController.isAnimating) return;
    _sfx.playPopSound();
    _tapJumpController.forward(from: 0.0).then((_) {
    });
    widget.onTap?.call();
  }


  String _resolveCharacterId(String avatar) {
    final a = avatar.toLowerCase();
    if (a.contains('char_robo') || a.contains('🤖') || a.contains('robot')) return 'char_robo_b';
    if (a.contains('char_ninja') || a.contains('🥷') || a.contains('ninja')) return 'char_ninja';
    if (a.contains('char_prenses') || a.contains('👸') || a.contains('👑') || a.contains('kraliçe')) return 'char_prenses';
    if (a.contains('char_super') || a.contains('🦸') || a.contains('kahraman')) return 'char_superhero';
    if (a.contains('char_dino') || a.contains('🦖') || a.contains('dinozor')) return 'char_dino';
    if (a.contains('char_korsan') || a.contains('🏴‍☠️') || a.contains('korsan')) return 'char_korsan';
    if (a.contains('char_astronot') || a.contains('👩‍🚀') || a.contains('uzay')) return 'char_astronot';
    return 'char_skater_can';
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.size;

    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: Listenable.merge([_idleController, _tapJumpController]),
        builder: (context, _) {
          final floatOffset = widget.animate ? _floatAnimation.value : 0.0;
          final jumpOffset = _jumpAnimation.value;
          final breathScale = widget.animate ? _breathAnimation.value : 1.0;
          final spinAngle = _spinAnimation.value;

          return SizedBox(
            width: s * 1.35,
            height: s * 1.35,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                // 1. ZEMİN PODYUMU & GÖLGE (Pedestal)
                if (widget.showPedestal)
                  Positioned(
                    bottom: s * 0.06,
                    child: Container(
                      width: s * 0.95,
                      height: s * 0.24,
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFFFFD54F).withValues(alpha: 0.8),
                            const Color(0xFFFFB300).withValues(alpha: 0.35),
                            Colors.transparent,
                          ],
                          radius: 0.85,
                        ),
                        borderRadius: BorderRadius.all(Radius.elliptical(s * 0.95, s * 0.24)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.18),
                            blurRadius: 10 + (jumpOffset.abs() * 0.2),
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                    ),
                  ),

                // 2. PARILTI EFEKTLERİ (Karakter zıpladığında veya idle modda)
                if (_tapJumpController.isAnimating)
                  Positioned(
                    top: s * 0.02,
                    child: const Text('✨⭐✨', style: TextStyle(fontSize: 20)),
                  ),

                // 3. EVCİL HAYVAN / YOLDAŞ (Pet - Sol altta)
                if (widget.pet != null && widget.pet != '❌' && widget.pet!.isNotEmpty)
                  Positioned(
                    left: s * 0.02,
                    bottom: s * 0.12 + (floatOffset * 0.5),
                    child: Transform.scale(
                      scale: 0.9,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.85),
                          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                        ),
                        child: Text(
                          widget.pet!,
                          style: TextStyle(fontSize: s * 0.28),
                        ),
                      ),
                    ),
                  ),

                // 4. ANA KARAKTER & AKSESUAR KATMANLARI (Dikey hareket ve nefes alma)
                Transform.translate(
                  offset: Offset(0, floatOffset + jumpOffset),
                  child: Transform.rotate(
                    angle: spinAngle,
                    child: Transform.scale(
                      scale: breathScale,
                      child: SizedBox(
                        width: s,
                        height: s,
                        child: Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.center,
                          children: [
                            // A) ARKA AKSESUAR (Süpermen Pelerini / Kanat / Kaykay)
                            if (widget.prop == '🛹')
                              Positioned(
                                bottom: -s * 0.02,
                                child: Transform.rotate(
                                  angle: -0.12,
                                  child: Text('🛹', style: TextStyle(fontSize: s * 0.38)),
                                ),
                              ),

                            // B) CANLI DANS EDEN SUBWAY SURFERS KARAKTERİ (Bacakları, Kolları & Ayakkabıları Oynar)
                            Center(
                              child: AnimatedDancingCharacter(
                                characterId: _resolveCharacterId(widget.avatar),
                                size: s * 0.88,
                                isDancing: widget.animate,
                                showPedestal: false,
                                showShadow: false,
                                customHat: (widget.hat != null && widget.hat != '❌' && widget.hat != 'hat_none') ? widget.hat : null,
                                customProp: (widget.prop != null && widget.prop != '❌' && widget.prop != 'prop_none') ? widget.prop : null,
                              ),
                            ),

                            // C) GÖZLÜK / MASKE (Gözlerin tam hizasına mikro kalibreli oturur)
                            if (widget.glasses != null &&
                                widget.glasses != '❌' &&
                                widget.glasses != 'glass_none' &&
                                widget.glasses!.isNotEmpty)
                              Positioned(
                                top: s * 0.28,
                                child: _buildCalibratedGlasses(widget.glasses!, s),
                              ),

                            // D) ŞAPKA / TAÇ / KASK (Kafanın tam tepesine mükemmel oturur)
                            if (widget.hat != null &&
                                widget.hat != '❌' &&
                                widget.hat != 'hat_none' &&
                                widget.hat!.isNotEmpty)
                              Positioned(
                                top: _getHatTopOffset(widget.hat!, s),
                                child: _buildCalibratedHat(widget.hat!, s),
                              ),

                            // E) ELDE TUTULAN EŞYA (Sağ el hizası: Asa, Gitar, Kupa)
                            if (widget.prop != null &&
                                widget.prop != '❌' &&
                                widget.prop != 'prop_none' &&
                                widget.prop != '🛹' &&
                                widget.prop!.isNotEmpty)
                              Positioned(
                                right: -s * 0.06,
                                bottom: s * 0.16,
                                child: _buildCalibratedProp(widget.prop!, s),
                              ),
                          ],
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

  // --- HASSAS KALİBRE EDİLMİŞ AKSESUAR YERLEŞTİRİCİLERİ ---

  /// Şapka Yükseklik Kalibrasyonu
  double _getHatTopOffset(String hat, double s) {
    if (hat.contains('👑')) return -s * 0.14; // Taç biraz yukarıda parıldar
    if (hat.contains('🧢')) return -s * 0.06; // Kep alına tam oturur
    if (hat.contains('🎩')) return -s * 0.16; // Silindir şapka dik durur
    if (hat.contains('🪖')) return -s * 0.08; // Kask kafayı sarar
    if (hat.contains('🥳')) return -s * 0.12; // Parti şapkası
    return -s * 0.10;
  }

  /// Şapkanın Açı ve Ölçek Kalibrasyonu
  Widget _buildCalibratedHat(String hat, double s) {
    double angle = 0.0;
    double scale = 1.0;

    if (hat.contains('🧢')) {
      angle = -0.14; // Havalı yan kep duruşu
      scale = 0.95;
    } else if (hat.contains('👑')) {
      scale = 1.05;
    } else if (hat.contains('🎩')) {
      angle = 0.08;
    }

    return Transform.rotate(
      angle: angle,
      child: Transform.scale(
        scale: scale,
        child: Container(
          decoration: BoxDecoration(
            boxShadow: hat.contains('👑')
                ? [
                    BoxShadow(
                      color: Colors.amberAccent.withValues(alpha: 0.6),
                      blurRadius: 12,
                      spreadRadius: 2,
                    )
                  ]
                : null,
          ),
          child: Text(
            hat,
            style: TextStyle(fontSize: s * 0.42, height: 1.0),
          ),
        ),
      ),
    );
  }

  /// Gözlüklerin Göz Hizasına Kusursuz Yerleşimi
  Widget _buildCalibratedGlasses(String glass, double s) {
    // Özel stilize edilmiş gözlük modelleri veya platform emojisi
    if (glass.contains('🕶️') || glass == 'glass_sun') {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: s * 0.03, vertical: 2),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(s * 0.08),
          border: Border.all(color: Colors.amberAccent, width: 1.8),
          boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 4, offset: Offset(0, 2))],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: s * 0.14,
              height: s * 0.08,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Align(
                alignment: Alignment.topLeft,
                child: Container(
                  width: s * 0.05,
                  height: 2,
                  margin: const EdgeInsets.only(top: 2, left: 2),
                  color: Colors.white70,
                ),
              ),
            ),
            Container(width: s * 0.04, height: 2, color: Colors.amberAccent),
            Container(
              width: s * 0.14,
              height: s * 0.08,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Align(
                alignment: Alignment.topLeft,
                child: Container(
                  width: s * 0.05,
                  height: 2,
                  margin: const EdgeInsets.only(top: 2, left: 2),
                  color: Colors.white70,
                ),
              ),
            ),
          ],
        ),
      );
    } else if (glass.contains('👓') || glass == 'glass_nerd') {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: s * 0.02, vertical: 1),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: s * 0.13,
              height: s * 0.13,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFB8860B), width: 2),
                color: Colors.cyan.withValues(alpha: 0.15),
              ),
            ),
            Container(width: s * 0.03, height: 2, color: const Color(0xFFB8860B)),
            Container(
              width: s * 0.13,
              height: s * 0.13,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFB8860B), width: 2),
                color: Colors.cyan.withValues(alpha: 0.15),
              ),
            ),
          ],
        ),
      );
    } else if (glass.contains('🥽') || glass == 'glass_diver') {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: s * 0.04, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFF00E676).withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('🥽', style: TextStyle(fontSize: s * 0.28)),
          ],
        ),
      );
    }

    return Text(glass, style: TextStyle(fontSize: s * 0.32));
  }

  /// Elde Tutulan Eşyaların Doğal Tutuş Pozisyonu
  Widget _buildCalibratedProp(String prop, double s) {
    double angle = 0.15;
    if (prop.contains('🪄')) angle = 0.35; // Asa öne doğru yönelir
    if (prop.contains('🎸')) angle = -0.25; // Gitar vücuda çapraz asılır
    if (prop.contains('🏆')) angle = 0.05;

    return Transform.rotate(
      angle: angle,
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 6,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: Text(
          prop,
          style: TextStyle(fontSize: s * 0.36, height: 1.0),
        ),
      ),
    );
  }
}
