import 'package:flutter/material.dart';
import '../models/reward_state.dart';

class _DailyQuest {
  final String id;
  final String title;
  final String subtitle;
  final String icon;
  final int targetCount;
  final int currentCount;
  final int gemReward;
  final bool isClaimed;

  _DailyQuest({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.targetCount,
    required this.currentCount,
    required this.gemReward,
    this.isClaimed = false,
  });

  bool get isCompleted => currentCount >= targetCount;
}

/// 🎯 GÜNLÜK GÖREVLER VE GİZEMLİ HAZİNE SANDIĞI
/// Çocuğa günlük somut mini hedefler verir ve sadakati pekiştirir.
class DailyQuestsDialog extends StatefulWidget {
  const DailyQuestsDialog({super.key});

  @override
  State<DailyQuestsDialog> createState() => _DailyQuestsDialogState();
}

class _DailyQuestsDialogState extends State<DailyQuestsDialog> {
  final RewardState _rewardState = RewardState();

  late List<_DailyQuest> _quests;
  bool _chestOpened = false;

  @override
  void initState() {
    super.initState();
    _quests = [
      _DailyQuest(
        id: 'q1',
        title: '5 Kelimeyi Doğru Telaffuz Et',
        subtitle: 'Pratik ekranında mikrofona konuş',
        icon: '🗣️',
        targetCount: 5,
        currentCount: 4,
        gemReward: 30,
      ),
      _DailyQuest(
        id: 'q2',
        title: 'Bir Mini Oyun Tamamla',
        subtitle: 'Ses Canavarı veya Balon Avcısı oyna',
        icon: '🎮',
        targetCount: 1,
        currentCount: 1,
        gemReward: 40,
        isClaimed: true,
      ),
      _DailyQuest(
        id: 'q3',
        title: 'Canlı Aynada Dudaklarını İncele',
        subtitle: 'Konuşma aynasını aç ve izle',
        icon: '🪞',
        targetCount: 1,
        currentCount: 1,
        gemReward: 20,
        isClaimed: true,
      ),
    ];
  }

  void _claimChest() {
    if (_chestOpened) return;
    setState(() {
      _chestOpened = true;
    });
    _rewardState.addReward(earnedStars: 2, earnedXp: 80, earnedGems: 100);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🎉 TEBRİKLER! GÜNLÜK HAZİNE SANDIĞI AÇILDI: +100 💎, +2 ⭐'),
        backgroundColor: Color(0xFF2E7D32),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final completedCount = _quests.where((q) => q.isCompleted).length;
    final allCompleted = completedCount == _quests.length;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      child: Container(
        width: 420,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          color: Colors.white,
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
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Text('🎯', style: TextStyle(fontSize: 26)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'GÜNLÜK GÖREVLER',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFE65100),
                        ),
                      ),
                      Text(
                        'Bugün $completedCount / ${_quests.length} Görev Tamamlandı 🔥',
                        style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w700),
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
            const SizedBox(height: 14),

            // Görevler Listesi
            ..._quests.map((q) {
              final pct = (q.currentCount / q.targetCount).clamp(0.0, 1.0);

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: q.isCompleted ? const Color(0xFFF1F8E9) : const Color(0xFFFAFAFA),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: q.isCompleted ? const Color(0xFF81C784) : Colors.grey[300]!,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Text(q.icon, style: const TextStyle(fontSize: 28)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            q.title,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                          ),
                          Text(
                            q.subtitle,
                            style: TextStyle(fontSize: 10.5, color: Colors.grey[600], fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: pct,
                              backgroundColor: Colors.grey[200],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                q.isCompleted ? const Color(0xFF58CC02) : const Color(0xFFFF9800),
                              ),
                              minHeight: 6,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: q.isCompleted ? const Color(0xFF58CC02) : const Color(0xFFE1F5FE),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        q.isCompleted ? '✅' : '+${q.gemReward} 💎',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: q.isCompleted ? Colors.white : const Color(0xFF0277BD),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 12),

            // BÜYÜK GÜNLÜK HAZİNE SANDIĞI
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFF8E1), Color(0xFFFFECB3)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFFFB300), width: 2),
              ),
              child: Row(
                children: [
                  Text(_chestOpened ? '✨🎁✨' : '🎁', style: const TextStyle(fontSize: 36)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'GÜNÜN BÜYÜK HAZİNESİ',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFFE65100)),
                        ),
                        Text(
                          '3 görevi de bitir, dev hazineyi aç! (+100 💎, +2 ⭐)',
                          style: TextStyle(fontSize: 10.5, color: Colors.black54, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: allCompleted
                          ? (_chestOpened ? Colors.grey : const Color(0xFFFF9800))
                          : Colors.grey[300],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: (allCompleted && !_chestOpened) ? _claimChest : null,
                    child: Text(
                      _chestOpened ? 'AÇILDI' : 'AÇ 👑',
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
