import 'package:flutter/material.dart';
import '../models/reward_state.dart';

/// 🔥 HAFTALIK GERÇEK SERİ TAKVİMİ VE ALIŞKANLIK ISI HARİTASI
class StreakCalendarDialog extends StatelessWidget {
  const StreakCalendarDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final rewardState = RewardState();
    final days = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
    final completedDays = rewardState.getWeeklyCompletedDays();

    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final currentDayIndex = now.weekday - 1;
    final isTodayDone = completedDays[currentDayIndex.clamp(0, 6)];

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      child: Container(
        width: 420,
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
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFE0B2),
                    shape: BoxShape.circle,
                  ),
                  child: const Text('🔥', style: TextStyle(fontSize: 28)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${rewardState.streakDays} Günlük Seri Ateşi!',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFFE65100)),
                      ),
                      Text(
                        isTodayDone
                            ? '🎉 Bugünkü pratik yapıldı, serin güvende!'
                            : '⚡ Bugünkü pratik henüz yapılmadı! Bir ses çalış ve serini koru.',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: isTodayDone ? const Color(0xFF2E7D32) : const Color(0xFFD84315),
                          fontWeight: FontWeight.w800,
                        ),
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

            // 7 GÜNLÜK SERİ KUTULARI (GÜNCEL GERÇEK TAKVİM)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (i) {
                final isDone = completedDays[i];
                final dayDate = monday.add(Duration(days: i));
                final isToday = i == currentDayIndex;

                return Column(
                  children: [
                    Text(
                      days[i],
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: isToday
                            ? const Color(0xFFE65100)
                            : (isDone ? const Color(0xFFF57F17) : Colors.grey),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${dayDate.day}',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: isToday ? const Color(0xFFE65100) : Colors.black45,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 42,
                      height: 52,
                      decoration: BoxDecoration(
                        color: isDone ? const Color(0xFFFF9800) : Colors.grey[100],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isToday
                              ? const Color(0xFFE65100)
                              : (isDone ? const Color(0xFFF57F17) : Colors.grey[300]!),
                          width: isToday ? 2.5 : 1.5,
                        ),
                        boxShadow: isDone
                            ? [
                                BoxShadow(
                                  color: const Color(0xFFFF9800).withValues(alpha: 0.35),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                )
                              ]
                            : [],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        isDone ? '🔥' : (isToday ? '🎯' : '·'),
                        style: TextStyle(fontSize: isDone ? 20 : (isToday ? 16 : 18)),
                      ),
                    ),
                    if (isToday)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFE0B2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('Bugün', style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w900, color: Color(0xFFE65100))),
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
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text('SERİYİ KORU & PRATİK YAP 🚀', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
            ),
          ],
        ),
      ),
    );
  }
}
