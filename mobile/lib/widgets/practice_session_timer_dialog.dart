import 'dart:async';
import 'package:flutter/material.dart';
import '../services/sound_effects_service.dart';
import '../models/reward_state.dart';

/// ⏰ KULLANICI AYARLI KLİNİK SEANS ZAMANLAYICISI
/// Ebeveyn ve terapistin seans süresini dilediği gibi (3, 5, 10, 15, 20, 30 dk veya +/- 1 dk)
/// ayarlamasını sağlayan interaktif klinik terapi saati.
class PracticeSessionTimerDialog extends StatefulWidget {
  const PracticeSessionTimerDialog({super.key});

  @override
  State<PracticeSessionTimerDialog> createState() => _PracticeSessionTimerDialogState();
}

class _PracticeSessionTimerDialogState extends State<PracticeSessionTimerDialog> {
  final SoundEffectsService _sfx = SoundEffectsService();
  final RewardState _rewardState = RewardState();

  int _selectedMinutes = 10; // Varsayılan 10 dakika
  late int _remainingSeconds;
  bool _isRunning = false;
  Timer? _timer;

  static const List<int> kPresetMinutes = [3, 5, 10, 15, 20, 30];

  @override
  void initState() {
    super.initState();
    _remainingSeconds = _selectedMinutes * 60;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _setMinutes(int mins) {
    if (mins < 1 || mins > 60) return;
    _timer?.cancel();
    setState(() {
      _selectedMinutes = mins;
      _remainingSeconds = mins * 60;
      _isRunning = false;
    });
    _sfx.playPopSound();
  }

  void _adjustMinutes(int delta) {
    _setMinutes(_selectedMinutes + delta);
  }

  void _toggleTimer() {
    if (_isRunning) {
      _timer?.cancel();
      setState(() => _isRunning = false);
    } else {
      if (_remainingSeconds <= 0) {
        _remainingSeconds = _selectedMinutes * 60;
      }
      setState(() => _isRunning = true);
      _sfx.playSuccessDing();
      _timer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (!mounted) return;
        if (_remainingSeconds > 0) {
          setState(() => _remainingSeconds--);
        } else {
          _timer?.cancel();
          setState(() => _isRunning = false);
          _sfx.playVictoryFanfare();
          _rewardState.addReward(earnedStars: 3, earnedXp: 60, earnedGems: 25);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('🎉 Tebrikler! $_selectedMinutes dakikalık klinik seans başarıyla tamamlandı!'),
              backgroundColor: const Color(0xFF2E7D32),
              duration: const Duration(seconds: 4),
            ),
          );
        }
      });
    }
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _remainingSeconds = _selectedMinutes * 60;
    });
    _sfx.playPopSound();
  }

  @override
  Widget build(BuildContext context) {
    final mins = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final secs = (_remainingSeconds % 60).toString().padLeft(2, '0');
    final totalSecs = _selectedMinutes * 60;
    final progress = totalSecs > 0 ? (totalSecs - _remainingSeconds) / totalSecs.toDouble() : 0.0;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          color: Colors.white,
          boxShadow: const [
            BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, 8)),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Üst Başlık
            Row(
              children: [
                const Text('⏰', style: TextStyle(fontSize: 26)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$_selectedMinutes Dk Klinik Seans Sayacı',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF1565C0)),
                      ),
                      const Text(
                        'Kullanıcı ayarlı günlük klinik odaklanma süresi',
                        style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.grey),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // SÜRE AYARLAMA SEÇENEKLERİ (PRESETS)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F9FF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFBBDEFB)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Süre Ayarla:', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11.5, color: Color(0xFF0D47A1))),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline_rounded, size: 20, color: Color(0xFF1976D2)),
                            constraints: const BoxConstraints(),
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            tooltip: '1 Dakika Azalt',
                            onPressed: _isRunning ? null : () => _adjustMinutes(-1),
                          ),
                          Text(
                            '$_selectedMinutes dk',
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Color(0xFF0D47A1)),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline_rounded, size: 20, color: Color(0xFF1976D2)),
                            constraints: const BoxConstraints(),
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            tooltip: '1 Dakika Artır',
                            onPressed: _isRunning ? null : () => _adjustMinutes(1),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: kPresetMinutes.map((p) {
                      final isSel = p == _selectedMinutes;
                      return ChoiceChip(
                        label: Text('$p Dk', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: isSel ? Colors.white : const Color(0xFF1565C0))),
                        selected: isSel,
                        selectedColor: const Color(0xFF1976D2),
                        backgroundColor: Colors.white,
                        showCheckmark: false,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        onSelected: _isRunning ? null : (_) => _setMinutes(p),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Dairesel İlerleme ve Süre Göstergesi
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 155,
                  height: 155,
                  child: CircularProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    strokeWidth: 10,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _isRunning ? const Color(0xFF00C853) : const Color(0xFF2196F3),
                    ),
                  ),
                ),
                Column(
                  children: [
                    Text(
                      '$mins:$secs',
                      style: const TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0D47A1),
                        letterSpacing: 1.5,
                      ),
                    ),
                    Text(
                      _isRunning ? 'Seans Sürüyor... ⚡' : 'Duraklatıldı',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _isRunning ? const Color(0xFF2E7D32) : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Kontrol Butonları: BAŞLAT / DURAKLAT / SIFIRLA
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isRunning ? const Color(0xFFFF9800) : const Color(0xFF58CC02),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 3,
                  ),
                  icon: Icon(_isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded),
                  label: Text(
                    _isRunning ? 'DURAKLAT' : 'BAŞLAT',
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                  ),
                  onPressed: _toggleTimer,
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    side: const BorderSide(color: Colors.blueGrey, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: _resetTimer,
                  child: const Text('SIFIRLA', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: Colors.blueGrey)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
