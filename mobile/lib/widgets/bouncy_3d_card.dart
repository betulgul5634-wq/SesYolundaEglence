import 'package:flutter/material.dart';
import '../services/sound_effects_service.dart';

/// 🎨 3D POFUDUK ÇOCUK KELİME KARTI (BOUNCY FLASHCARD & KARAOKE GLOW)
/// Dokunulduğunda yaylanan, ses çalınırken etrafından ses halkaları saçan,
/// heceleri renklenen Duolingo tarzı tombul 3D oyuncak kart.
class Bouncy3DCard extends StatefulWidget {
  final String word;
  final String emoji;
  final String syllableLabel;
  final String position;
  final Color primaryColor;
  final bool isSpeakingNow;
  final VoidCallback onListen;
  final VoidCallback onSpeak;
  final VoidCallback? onSlowListen;
  final VoidCallback? onOpenMirror;

  const Bouncy3DCard({
    super.key,
    required this.word,
    required this.emoji,
    required this.syllableLabel,
    required this.position,
    required this.primaryColor,
    this.isSpeakingNow = false,
    required this.onListen,
    required this.onSpeak,
    this.onSlowListen,
    this.onOpenMirror,
  });

  @override
  State<Bouncy3DCard> createState() => _Bouncy3DCardState();
}

class _Bouncy3DCardState extends State<Bouncy3DCard>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    if (widget.isSpeakingNow) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant Bouncy3DCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSpeakingNow && !oldWidget.isSpeakingNow) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.isSpeakingNow && oldWidget.isSpeakingNow) {
      _pulseController.stop();
      _pulseController.animateTo(0.0);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (ctx, child) {
        final double pulseScale = widget.isSpeakingNow
            ? 1.0 + (0.025 * _pulseController.value)
            : 1.0;

        return Transform.scale(
          scale: pulseScale,
          child: child,
        );
      },
      child: GestureDetector(
        onTapDown: (_) {
          SoundEffectsService().playPop();
          setState(() => _isPressed = true);
        },
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onListen,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          transform: Matrix4.translationValues(0, _isPressed ? 3 : 0, 0),
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: widget.isSpeakingNow ? const Color(0xFFFFFDE7) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: widget.isSpeakingNow
                  ? const Color(0xFFFFB300)
                  : widget.primaryColor.withValues(alpha: 0.35),
              width: widget.isSpeakingNow ? 3.0 : 2.0,
            ),
            boxShadow: [
              // 3D Taban Çökme Efekti
              BoxShadow(
                color: widget.isSpeakingNow
                    ? const Color(0xFFFF8F00).withValues(alpha: 0.5)
                    : (_isPressed
                        ? Colors.transparent
                        : widget.primaryColor.withValues(alpha: 0.2)),
                blurRadius: _isPressed ? 1 : 6,
                offset: Offset(0, _isPressed ? 1 : 4),
              ),
              if (widget.isSpeakingNow)
                BoxShadow(
                  color: const Color(0xFFFFD54F).withValues(alpha: 0.4),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
            ],
          ),
          child: Row(
            children: [
              // 1. BÜYÜK RESİMLİ GÖRSEL KARTUŞU
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      widget.primaryColor.withValues(alpha: 0.15),
                      widget.primaryColor.withValues(alpha: 0.28),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: widget.primaryColor.withValues(alpha: 0.5),
                    width: 1.8,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(widget.emoji, style: const TextStyle(fontSize: 34)),
              ),
              const SizedBox(width: 14),

              // 2. KELİME BAŞLIĞI VE HECE ETİKETİ
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            widget.word,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: widget.isSpeakingNow
                                  ? const Color(0xFFE65100)
                                  : const Color(0xFF263238),
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                        if (widget.isSpeakingNow) ...[
                          const SizedBox(width: 6),
                          const Text('🔊🎶', style: TextStyle(fontSize: 16)),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        // Hece Bilgisi Rozeti
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: widget.primaryColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            widget.syllableLabel,
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              color: widget.primaryColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Konum: ${widget.position}',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 3. 3D FİZİKSEL OYUNCAK BUTONLAR (KAPLUMBAĞA, AYNA, DİNLE, SÖYLE)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 🐢 Kaplumbağa Modu (Yavaş / Hece Hece Dinleme)
                  if (widget.onSlowListen != null) ...[
                    _build3DButton(
                      icon: Icons.hourglass_bottom_rounded,
                      emoji: '🐢',
                      color: const Color(0xFFFF9800),
                      shadowColor: const Color(0xFFE65100),
                      tooltip: 'Yavaş Dinle 🐢',
                      onTap: widget.onSlowListen!,
                    ),
                    const SizedBox(width: 6),
                  ],

                  // 🪞 Canlı Konuşma Aynası
                  if (widget.onOpenMirror != null) ...[
                    _build3DButton(
                      icon: Icons.face_rounded,
                      emoji: '🪞',
                      color: const Color(0xFF9C27B0),
                      shadowColor: const Color(0xFF6A1B9A),
                      tooltip: 'Canlı Ayna 🪞',
                      onTap: widget.onOpenMirror!,
                    ),
                    const SizedBox(width: 6),
                  ],

                  // Dinle Butonu (Mavi 3D Pill)
                  _build3DButton(
                    icon: Icons.volume_up_rounded,
                    color: const Color(0xFF0288D1),
                    shadowColor: const Color(0xFF01579B),
                    tooltip: 'Yalnızca Dinle 🔊',
                    onTap: widget.onListen,
                  ),
                  const SizedBox(width: 6),

                  // Söyle Butonu (Yeşil Büyük 3D Pill)
                  _build3DButton(
                    icon: Icons.mic_rounded,
                    color: const Color(0xFF58CC02),
                    shadowColor: const Color(0xFF2E7D32),
                    tooltip: 'Dinle ve Söyle 🎤',
                    isLarge: true,
                    onTap: widget.onSpeak,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _build3DButton({
    required IconData icon,
    String? emoji,
    required Color color,
    required Color shadowColor,
    required String tooltip,
    required VoidCallback onTap,
    bool isLarge = false,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.all(isLarge ? 9 : 7),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: shadowColor, offset: const Offset(0, 3)),
            ],
          ),
          child: emoji != null
              ? Text(emoji, style: TextStyle(fontSize: isLarge ? 20 : 16))
              : Icon(icon, color: Colors.white, size: isLarge ? 22 : 18),
        ),
      ),
    );
  }
}
