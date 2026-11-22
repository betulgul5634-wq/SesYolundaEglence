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

                // 3. EVCİL HAYVAN / YOLDAŞ (Pedestalin yanında yerde duran sevimli dost)
                if (widget.pet != null &&
                    widget.pet != '❌' &&
                    widget.pet != 'pet_none' &&
                    widget.pet!.isNotEmpty)
                  Positioned(
                    right: -s * 0.08,
                    bottom: (widget.showPedestal ? s * 0.06 : s * 0.02) + (floatOffset * 0.4),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.pet!,
                          style: TextStyle(fontSize: s * 0.32, height: 1.0),
                        ),
                        const SizedBox(height: 1),
                        Container(
                          width: s * 0.24,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.black26,
                            borderRadius: BorderRadius.all(Radius.elliptical(s * 0.24, 5)),
                          ),
                        ),
                      ],
                    ),
                  ),

                // 4. ANA KARAKTER & KUSURSUZ KALİBRELİ AKSESUARLAR (Dikey hareket ve zıplama)
                Transform.translate(
                  offset: Offset(0, floatOffset + jumpOffset),
                  child: Transform.rotate(
                    angle: spinAngle,
                    child: Transform.scale(
                      scale: breathScale,
                      child: Center(
                        child: AnimatedDancingCharacter(
                          characterId: _resolveCharacterId(widget.avatar),
                          size: s * 0.88,
                          isDancing: widget.animate,
                          showPedestal: false,
                          showShadow: false,
                          customHat: (widget.hat != null && widget.hat != '❌' && widget.hat != 'hat_none') ? widget.hat : null,
                          customGlasses: (widget.glasses != null && widget.glasses != '❌' && widget.glasses != 'glass_none') ? widget.glasses : null,
                          customProp: (widget.prop != null && widget.prop != '❌' && widget.prop != 'prop_none') ? widget.prop : null,
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
}
