import 'package:flutter/material.dart';
import '../models/reward_state.dart';

/// 🔥 HAFTALIK SERİ TAKVİMİ VE ALIŞKANLIK ISI HARİTASI
class StreakCalendarDialog extends StatelessWidget {
  const StreakCalendarDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final rewardState = RewardState();
    final days = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
    // Son 4 gün tamamlanmış seri
    final completedDays = [true, true, true, true, false, false, false];

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          gradient: const LinearGradient(
            colors: [Color(0xFFFFF3E0), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          border: Border.all(color: const Color(0xFFFF9800), width: 2.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Üst Başlık
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFE0B2),
                    shape: BoxShape.circle,
                  ),
                  child: const Text('🔥', style: TextStyle(fontSize: 26)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${rewardState.streakDays} Günlük Seri Ateşi!',
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: Color(0xFFE65100)),
                      ),
                      const Text(
                        'Her gün pratik yap, serini sakın kaybetme!',
                        style: TextStyle(fontSize: 11, color: Colors.black54, fontWeight: FontWeight.w700),
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
            const SizedBox(height: 18),

            // 7 GÜNLÜK SERİ KUTULARI
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (i) {
                final isDone = completedDays[i];
                return Column(
                  children: [
                    Text(
                      days[i],
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: isDone ? const Color(0xFFE65100) : Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 40,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isDone ? const Color(0xFFFF9800) : Colors.grey[200],
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDone ? const Color(0xFFF57F17) : Colors.grey[300]!,
                          width: 1.5,
                        ),
                        boxShadow: isDone
                            ? [
                                BoxShadow(
                                  color: const Color(0xFFFF9800).withValues(alpha: 0.4),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                )
                              ]
                            : [],
                      ),
                      alignment: Alignment.center,
                      child: Text(isDone ? '🔥' : '·', style: const TextStyle(fontSize: 20)),
                    ),
                  ],
                );
              }),
            ),
            const SizedBox(height: 20),

            // Klinik Alışkanlık İpucu
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF81C784)),
              ),
              child: const Row(
                children: [
                  Text('🧠', style: TextStyle(fontSize: 22)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Günde sadece 10 dakika pratik yapmak, dil ve dudak kas hafızasının 3 kat daha kalıcı olmasını sağlar!',
                      style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF1B5E20), height: 1.3),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF9800),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 11),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text('SERİYİ KORU & DEVAM ET 🚀', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
            ),
          ],
        ),
      ),
    );
  }
}
