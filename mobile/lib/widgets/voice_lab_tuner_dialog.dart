import 'dart:async';
import 'package:flutter/material.dart';
import '../services/audio_speech_service.dart';
import '../services/sound_effects_service.dart';
import '../models/reward_state.dart';

/// 🎛️ SES LABORATUVARI & FREKANS DALGA SÖRFÜ (PITCH & DECIBEL TUNER)
/// Çocuğun ses tonunu (kalın/ince), ses şiddetini (fısıltı/güçlü) ve fonasyon süresini
/// (nefes kontrolüyle sesi uzatma) eğlenceli dalga sörfü oyunuyla eğitir.
class VoiceLabPitchTunerDialog extends StatefulWidget {
  final String phoneme;
  final String soundTitle;

  const VoiceLabPitchTunerDialog({
    super.key,
    required this.phoneme,
    required this.soundTitle,
  });

  @override
  State<VoiceLabPitchTunerDialog> createState() => _VoiceLabPitchTunerDialogState();
}

class _VoiceLabPitchTunerDialogState extends State<VoiceLabPitchTunerDialog>
    with SingleTickerProviderStateMixin {
  final AudioSpeechService _audioService = AudioSpeechService();
  final SoundEffectsService _sfx = SoundEffectsService();
  final RewardState _rewardState = RewardState();

  bool _isSurfing = false;
  int _currentVol = 0;
  double _surferHeight = 0.5; // 0.0 (en alt) - 1.0 (en üst)
  double _score = 0;
  int _streakSeconds = 0;
  Timer? _gameTimer;
  StreamSubscription<int>? _volumeSub;

  final List<double> _waveHistory = List.filled(30, 0.0);

  @override
  void initState() {
    super.initState();
    _startTuner();
  }

  void _startTuner() {
    _audioService.requestMicrophonePermission();
    _volumeSub?.cancel();
    _volumeSub = _audioService.onMicVolume.listen((vol) {
      if (!mounted) return;
      setState(() {
        _currentVol = vol;
        final normalized = (vol / 100.0).clamp(0.05, 1.0);
        _waveHistory.removeAt(0);
        _waveHistory.add(normalized);

        // Sörfçü yüksekliği ses seviyesine ve ritmine göre dengelenir
        _surferHeight = (_surferHeight * 0.7 + normalized * 0.3).clamp(0.1, 0.9);

        if (_isSurfing && vol >= 25) {
          _score += 1.5;
        }
      });
    });

    _gameTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_isSurfing) {
        if (_currentVol >= 25) {
          setState(() => _streakSeconds++);
          if (_streakSeconds % 5 == 0) {
            _sfx.playSuccessDing();
            _rewardState.addReward(earnedStars: 1, earnedXp: 15, earnedGems: 5);
          }
        } else {
          setState(() => _streakSeconds = 0);
        }
      }
    });
  }

  void _toggleSurfing() {
    setState(() {
      _isSurfing = !_isSurfing;
      if (_isSurfing) {
        _score = 0;
        _streakSeconds = 0;
        _sfx.playPopSound();
        final cleanP = widget.phoneme.replaceAll('/', '').trim();
        _audioService.speakTurkish(
          'Derin bir nefes al ve "$cleanP" sesini uzatarak sörf yap!',
          phoneme: widget.phoneme,
        );
      } else {
        _sfx.playVictoryFanfare();
      }
    });
  }

  @override
  void dispose() {
    _volumeSub?.cancel();
    _gameTimer?.cancel();
    _audioService.stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Ses Seviyesi İndikatörü
    String volumeLabel = '🤫 Sessiz / Fısıltı';
    Color volumeColor = Colors.grey;
    if (_currentVol >= 25 && _currentVol < 75) {
      volumeLabel = '🗣️ İdeal Terapi Sesi (Mükemmel!)';
      volumeColor = const Color(0xFF58CC02);
    } else if (_currentVol >= 75) {
      volumeLabel = '🦁 Güçlü & Yüksek Ses';
      volumeColor = const Color(0xFFFF9800);
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 660),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A), // Koyu bilim laboratuvarı teması
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: const Color(0xFF00E5FF), width: 2.5),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00E5FF).withValues(alpha: 0.3),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            // Üst Başlık
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: const BoxDecoration(
                color: Color(0xFF1E293B),
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Row(
                children: [
                  const Text('🎛️', style: TextStyle(fontSize: 26)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Klinik Ses Laboratuvarı & Sörf',
                          style: const TextStyle(
                            color: Color(0xFF00E5FF),
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          'Hedef: "${widget.soundTitle}" Sesini Uzat & Dengeyi Koru',
                          style: const TextStyle(color: Colors.white70, fontSize: 11.5, fontWeight: FontWeight.w700),
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
            ),

            // Skor ve Fonasyon Süresi Barı
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildMetricBadge('⏱️ Fonasyon', '${_streakSeconds}s', const Color(0xFF00E5FF)),
                  _buildMetricBadge('🏄 Sörf Skoru', '${_score.toInt()}', const Color(0xFFFFD54F)),
                  _buildMetricBadge('🔊 Desibel', '$_currentVol dB', volumeColor),
                ],
              ),
            ),

            // CANLI DALGA SÖRFÜ ALANI (Custom Wave Visualizer & Surfer)
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF021B33), Color(0xFF05355C), Color(0xFF011627)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFF0288D1), width: 1.5),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Stack(
                    children: [
                      // Dalgalar (Custom Canvas)
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _VoiceWavePainter(
                            waveHistory: _waveHistory,
                            activeColor: _isSurfing ? const Color(0xFF00E5FF) : Colors.cyanAccent.withValues(alpha: 0.5),
                          ),
                        ),
                      ),

                      // Sörf Yapan Maskot (Avatar)
                      LayoutBuilder(
                        builder: (ctx, constraints) {
                          final h = constraints.maxHeight;
                          final w = constraints.maxWidth;
                          final surferY = (1.0 - _surferHeight) * (h - 70);

                          return Positioned(
                            left: w * 0.45,
                            top: surferY.clamp(10.0, h - 70.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _rewardState.activeAvatar,
                                  style: const TextStyle(fontSize: 38),
                                ),
                                Transform.rotate(
                                  angle: (_currentVol > 25 ? -0.15 : 0.0),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFF6D00),
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 4)],
                                    ),
                                    child: const Text('🏄 SÖRF', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white)),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                      // Sörf Talimatı
                      if (!_isSurfing)
                        Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.75),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFF00E5FF)),
                            ),
                            child: const Text(
                              'Aşağıdaki "SÖRFÜ BAŞLAT" butonuna bas ve\nhedef sesi kesintisiz çıkararak sörf yap! 🌊',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // Ses Seviyesi İndikatörü Barı
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: volumeColor.withValues(alpha: 0.6)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          volumeLabel,
                          style: TextStyle(fontWeight: FontWeight.w900, color: volumeColor, fontSize: 13),
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: (_currentVol / 100.0).clamp(0.0, 1.0),
                            backgroundColor: Colors.white12,
                            valueColor: AlwaysStoppedAnimation<Color>(volumeColor),
                            minHeight: 8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Alt Başlat / Durdur Butonu
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isSurfing ? const Color(0xFFE53935) : const Color(0xFF00E5FF),
                    foregroundColor: _isSurfing ? Colors.white : const Color(0xFF0A192F),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 6,
                  ),
                  icon: Icon(_isSurfing ? Icons.stop_rounded : Icons.waves_rounded, size: 24),
                  label: Text(
                    _isSurfing ? 'SÖRFÜ TAMAMLA ⏹️' : 'DALGA SÖRFÜNÜ BAŞLAT 🏄',
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: 0.5),
                  ),
                  onPressed: _toggleSurfing,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricBadge(String title, String val, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Colors.white70)),
          const SizedBox(height: 2),
          Text(val, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: color)),
        ],
      ),
    );
  }
}

class _VoiceWavePainter extends CustomPainter {
  final List<double> waveHistory;
  final Color activeColor;

  _VoiceWavePainter({required this.waveHistory, required this.activeColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = activeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [activeColor.withValues(alpha: 0.4), activeColor.withValues(alpha: 0.0)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final path = Path();
    final stepX = size.width / (waveHistory.length - 1);

    path.moveTo(0, size.height * 0.7);

    for (int i = 0; i < waveHistory.length; i++) {
      final x = i * stepX;
      final val = waveHistory[i];
      final y = size.height * 0.75 - (val * size.height * 0.55);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    final fillPath = Path.from(path);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _VoiceWavePainter oldDelegate) => true;
}
