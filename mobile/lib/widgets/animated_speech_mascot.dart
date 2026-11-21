import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

/// 👄 CANLI KONUŞAN ÇOCUK DOSTU MASKOT (LIP-SYNC & İNTERAKTİF ANİMASYON)
/// Ses çalındığında ağzı hecelerin ritmine göre açılıp kapanır,
/// göz kırpar, başı ritimle sallanır ve etrafından parıltılar saçar.
class AnimatedSpeechMascot extends StatefulWidget {
  final bool isSpeaking;
  final String phoneme;
  final double size;
  final VoidCallback? onTap;

  const AnimatedSpeechMascot({
    super.key,
    required this.isSpeaking,
    this.phoneme = '',
    this.size = 90,
    this.onTap,
  });

  @override
  State<AnimatedSpeechMascot> createState() => _AnimatedSpeechMascotState();
}

class _AnimatedSpeechMascotState extends State<AnimatedSpeechMascot>
    with TickerProviderStateMixin {
  late AnimationController _idleBreatheController;
  late AnimationController _mouthMasticateController;
  late AnimationController _sparkleSpinController;

  bool _isBlinking = false;
  Timer? _blinkTimer;

  @override
  void initState() {
    super.initState();
    // 1. Nefes Alma & Hafif Süzülme Animasyonu (Idle Float)
    _idleBreatheController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    // 2. Ağız Açılıp Kapanma / Konuşma Ritim Animasyonu (Lip-Sync)
    _mouthMasticateController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );

    // 3. Etraftaki Parıltıların Dönüşü
    _sparkleSpinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();

    // Rastgele Göz Kırpma Döngüsü
    _blinkTimer = Timer.periodic(const Duration(milliseconds: 2800), (_) {
      if (mounted) {
        setState(() => _isBlinking = true);
        Future.delayed(const Duration(milliseconds: 150), () {
          if (mounted) setState(() => _isBlinking = false);
        });
      }
    });

    if (widget.isSpeaking) {
      _mouthMasticateController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedSpeechMascot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSpeaking && !oldWidget.isSpeaking) {
      _mouthMasticateController.repeat(reverse: true);
    } else if (!widget.isSpeaking && oldWidget.isSpeaking) {
      _mouthMasticateController.stop();
      _mouthMasticateController.animateTo(0.0);
    }
  }

  @override
  void dispose() {
    _blinkTimer?.cancel();
    _idleBreatheController.dispose();
    _mouthMasticateController.dispose();
    _sparkleSpinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: SizedBox(
        width: widget.size * 1.3,
        height: widget.size * 1.3,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Dönen Parıltı Efekti (Konuşurken aktif)
            if (widget.isSpeaking)
              AnimatedBuilder(
                animation: _sparkleSpinController,
                builder: (ctx, _) {
                  return Transform.rotate(
                    angle: _sparkleSpinController.value * 2 * math.pi,
                    child: Container(
                      width: widget.size * 1.25,
                      height: widget.size * 1.25,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFFFD54F).withValues(alpha: 0.6),
                          width: 2.5,
                        ),
                      ),
                    ),
                  );
                },
              ),

            // Süzülen Gövde
            AnimatedBuilder(
              animation: _idleBreatheController,
              builder: (ctx, child) {
                final hoverY = -4.0 * _idleBreatheController.value;
                final scale = 1.0 + (0.02 * _idleBreatheController.value);
                return Transform.translate(
                  offset: Offset(0, hoverY),
                  child: Transform.scale(
                    scale: scale,
                    child: child,
                  ),
                );
              },
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFEE58), Color(0xFFFFB300), Color(0xFFF57F17)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(color: Colors.white, width: 3.5),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFB300).withValues(alpha: widget.isSpeaking ? 0.6 : 0.35),
                      blurRadius: widget.isSpeaking ? 18 : 10,
                      spreadRadius: widget.isSpeaking ? 3 : 1,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Yanak Kızarıklıkları (Allık)
                    Positioned(
                      left: widget.size * 0.12,
                      top: widget.size * 0.52,
                      child: Container(
                        width: widget.size * 0.18,
                        height: widget.size * 0.10,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF5252).withValues(alpha: 0.45),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    Positioned(
                      right: widget.size * 0.12,
                      top: widget.size * 0.52,
                      child: Container(
                        width: widget.size * 0.18,
                        height: widget.size * 0.10,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF5252).withValues(alpha: 0.45),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    // Gözler (Kırpma Animasyonlu)
                    Positioned(
                      top: widget.size * 0.32,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildEye(),
                          SizedBox(width: widget.size * 0.24),
                          _buildEye(),
                        ],
                      ),
                    ),

                    // Dudaklar / Ağız (Konuşurken Lip-Sync ile Açılıp Kapanır)
                    Positioned(
                      bottom: widget.size * 0.18,
                      child: AnimatedBuilder(
                        animation: _mouthMasticateController,
                        builder: (ctx, _) {
                          // 0.0 kapalı, 1.0 tam açık
                          final openRatio = widget.isSpeaking
                              ? _mouthMasticateController.value
                              : 0.0;

                          final mouthHeight = widget.size * (0.10 + (openRatio * 0.16));
                          final mouthWidth = widget.size * (0.28 + (openRatio * 0.08));

                          return Container(
                            width: mouthWidth,
                            height: mouthHeight,
                            decoration: BoxDecoration(
                              color: openRatio > 0.3 ? const Color(0xFF880E4F) : const Color(0xFFD81B60),
                              borderRadius: BorderRadius.circular(openRatio > 0.4 ? 14 : 8),
                              border: Border.all(color: const Color(0xFF4A148C), width: 1.8),
                            ),
                            alignment: Alignment.bottomCenter,
                            child: openRatio > 0.4
                                ? Container(
                                    width: mouthWidth * 0.55,
                                    height: mouthHeight * 0.45,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFFF4081),
                                      borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                                    ),
                                  )
                                : null,
                          );
                        },
                      ),
                    ),

                    // Terapist Tacı
                    Positioned(
                      top: 2,
                      child: const Text('👑', style: TextStyle(fontSize: 18)),
                    ),
                  ],
                ),
              ),
            ),

            // Uçuşan Müzik Notaları
            if (widget.isSpeaking)
              Positioned(
                right: 0,
                top: 4,
                child: const Text('🎶', style: TextStyle(fontSize: 20)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEye() {
    final eyeSize = widget.size * 0.18;
    if (_isBlinking) {
      // Göz Kırpma Çizgisi
      return Container(
        width: eyeSize,
        height: 2.5,
        color: const Color(0xFF212121),
      );
    }

    return Container(
      width: eyeSize,
      height: eyeSize,
      decoration: const BoxDecoration(
        color: Color(0xFF212121),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.topLeft,
      child: Container(
        margin: const EdgeInsets.only(top: 2, left: 2),
        width: eyeSize * 0.38,
        height: eyeSize * 0.38,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
