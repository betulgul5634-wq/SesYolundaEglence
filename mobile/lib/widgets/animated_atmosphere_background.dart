import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/reward_state.dart';

class _AtmosphereParticle {
  double x;
  double y;
  final double speed;
  final double size;
  String char;
  final double opacity;

  _AtmosphereParticle({
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
    required this.char,
    required this.opacity,
  });
}

/// 🌈 CANLI ATMOSFERİK ARKA PLAN & DİNAMİK TEMA MOTORU
/// Gündüz, Gece Kozmosu, Şeker Dünyası ve Okyanus temalarına göre
/// renk paletini ve süzülen parçacıkları (yıldızlar, şekerler, baloncuklar) dönüştürür.
class AnimatedAtmosphereBackground extends StatefulWidget {
  final Widget child;

  const AnimatedAtmosphereBackground({
    super.key,
    required this.child,
  });

  @override
  State<AnimatedAtmosphereBackground> createState() => _AnimatedAtmosphereBackgroundState();
}

class _AnimatedAtmosphereBackgroundState extends State<AnimatedAtmosphereBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  final RewardState _rewardState = RewardState();
  final List<_AtmosphereParticle> _particles = [];
  final math.Random _rnd = math.Random();
  String _lastTheme = '';

  @override
  void initState() {
    super.initState();
    _lastTheme = _rewardState.worldTheme;
    _initParticles();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    _animController.addListener(() {
      for (final p in _particles) {
        p.y -= p.speed;
        p.x += (math.sin(p.y * 10) * 0.0003);
        if (p.y < -0.1) {
          p.y = 1.1;
          p.x = _rnd.nextDouble();
        }
      }
      if (mounted) setState(() {});
    });
  }

  void _initParticles() {
    _particles.clear();
    final symbols = _getThemeSymbols(_rewardState.worldTheme);
    for (int i = 0; i < 15; i++) {
      _particles.add(
        _AtmosphereParticle(
          x: _rnd.nextDouble(),
          y: _rnd.nextDouble(),
          speed: 0.0004 + _rnd.nextDouble() * 0.0008,
          size: 14.0 + _rnd.nextDouble() * 20.0,
          char: symbols[_rnd.nextInt(symbols.length)],
          opacity: 0.25 + _rnd.nextDouble() * 0.45,
        ),
      );
    }
  }

  List<String> _getThemeSymbols(String theme) {
    if (theme == 'night') {
      return ['✨', '⭐', '🌟', '🪐', '🚀', '🌌', '🌠', '🛸'];
    } else if (theme == 'candy') {
      return ['🍭', '🍬', '🧁', '🍩', '💖', '✨', '🍓', '🎂'];
    } else if (theme == 'ocean') {
      return ['🫧', '🌊', '🐠', '🐬', '🐙', '🐚', '🫧', '✨'];
    }
    return ['☁️', '✨', '⭐', '🎈', '🎵', '☁️', '🌸', '✨'];
  }

  List<Color> _getThemeGradient(String theme) {
    if (theme == 'night') {
      return const [
        Color(0xFF0F172A),
        Color(0xFF1E1B4B),
        Color(0xFF2E1065),
        Color(0xFF020617),
      ];
    } else if (theme == 'candy') {
      return const [
        Color(0xFFFFF0F5),
        Color(0xFFFCE4EC),
        Color(0xFFF8BBD0),
        Color(0xFFF48FB1),
      ];
    } else if (theme == 'ocean') {
      return const [
        Color(0xFFE0F7FA),
        Color(0xFFB2EBF2),
        Color(0xFF80DEEA),
        Color(0xFF0097A7),
      ];
    }
    return const [
      Color(0xFFE8F5E9),
      Color(0xFFC8E6C9),
      Color(0xFFA5D6A7),
      Color(0xFF81C784),
    ];
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _rewardState,
      builder: (context, _) {
        if (_rewardState.worldTheme != _lastTheme) {
          _lastTheme = _rewardState.worldTheme;
          _initParticles();
        }

        final colors = _getThemeGradient(_rewardState.worldTheme);

        return Stack(
          children: [
            // 1. Zemin Canlı Gradyan
            Positioned.fill(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: colors,
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),

            // 2. Yüzen Parçacıklar Katmanı
            Positioned.fill(
              child: IgnorePointer(
                child: LayoutBuilder(
                  builder: (ctx, constraints) {
                    final w = constraints.maxWidth;
                    final h = constraints.maxHeight;

                    return Stack(
                      children: _particles.map((p) {
                        return Positioned(
                          left: (p.x * w) % w,
                          top: p.y * h,
                          child: Opacity(
                            opacity: p.opacity,
                            child: Text(
                              p.char,
                              style: TextStyle(fontSize: p.size),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
            ),

            // 3. Ana İçerik
            Positioned.fill(child: widget.child),
          ],
        );
      },
    );
  }
}
