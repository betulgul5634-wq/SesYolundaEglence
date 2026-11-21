import 'dart:async';
import 'package:flutter/material.dart';
import '../services/audio_speech_service.dart';

/// 🌊 CANLI MİKROFON SES DALGASI GÖRSELLEŞTİRİCİSİ (EQUALIZER DANCE)
/// Çocuğun mikrofona çıkardığı ses seviyesine göre gerçek zamanlı dans eden,
/// renk değiştiren ve zıplayan ses çubukları.
class LiveSoundwaveVisualizer extends StatefulWidget {
  final double height;
  final String label;

  const LiveSoundwaveVisualizer({
    super.key,
    this.height = 48,
    this.label = 'Sesini Dinliyorum',
  });

  @override
  State<LiveSoundwaveVisualizer> createState() => _LiveSoundwaveVisualizerState();
}

class _LiveSoundwaveVisualizerState extends State<LiveSoundwaveVisualizer>
    with SingleTickerProviderStateMixin {
  final AudioSpeechService _audioService = AudioSpeechService();
  StreamSubscription<int>? _volSub;
  int _volume = 0;

  late AnimationController _idleWaveController;

  @override
  void initState() {
    super.initState();
    _idleWaveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _volSub = _audioService.onMicVolume.listen((vol) {
      if (mounted) {
        setState(() => _volume = vol);
      }
    });
  }

  @override
  void dispose() {
    _volSub?.cancel();
    _idleWaveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool hasSound = _volume > 5;
    final Color activeColor = _volume > 40
        ? const Color(0xFF00E676)
        : (_volume > 15 ? const Color(0xFFFFD600) : const Color(0xFF00E5FF));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: hasSound ? activeColor : const Color(0xFF334155),
          width: 2,
        ),
        boxShadow: [
          if (hasSound)
            BoxShadow(
              color: activeColor.withValues(alpha: 0.35),
              blurRadius: 12,
              spreadRadius: 2,
            ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Mikrofon / Ses İkonu
          Text(hasSound ? '🗣️' : '🎙️', style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 10),

          // Canlı Ekolayzır Çubukları (7 Adet)
          SizedBox(
            height: widget.height,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: List.generate(7, (i) {
                return AnimatedBuilder(
                  animation: _idleWaveController,
                  builder: (ctx, _) {
                    double barHeight;
                    if (hasSound) {
                      // Çocuğun ses seviyesine göre orantılı dalga
                      final multiplier = [0.4, 0.7, 1.0, 0.85, 0.95, 0.6, 0.35][i];
                      barHeight = (widget.height * (_volume / 100.0) * multiplier)
                          .clamp(6.0, widget.height);
                    } else {
                      // Sessizlikte hafif nefes dalgası
                      final offset = [0.2, 0.4, 0.6, 0.8, 0.6, 0.4, 0.2][i];
                      barHeight = (6.0 + (_idleWaveController.value * 8.0 * offset));
                    }

                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: 5,
                      height: barHeight,
                      decoration: BoxDecoration(
                        color: hasSound ? activeColor : const Color(0xFF64748B),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    );
                  },
                );
              }),
            ),
          ),
          const SizedBox(width: 12),

          // Durum Yazısı
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                hasSound ? 'Ses Algılanıyor! ⚡' : widget.label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: hasSound ? activeColor : Colors.white70,
                ),
              ),
              Text(
                hasSound ? 'Desibel: %$_volume' : 'Yüksek sesle konuş 🎤',
                style: const TextStyle(fontSize: 9.5, color: Colors.white54, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
