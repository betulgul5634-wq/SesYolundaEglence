import 'package:flutter/material.dart';
import '../models/reward_state.dart';
import '../theme/app_theme.dart';

class BadgesSheet extends StatelessWidget {
  const BadgesSheet({super.key});

  static const List<Map<String, dynamic>> badges = [
    {
      'id': 'ilk_adim',
      'title': 'İlk Adım',
      'desc': 'İlk ses çalışmasını başarıyla tamamladın!',
      'icon': '🌱',
      'color': Color(0xFF4CAF50),
    },
    {
      'id': 'kelime_avcisi',
      'title': 'Kelime Avcısı',
      'desc': '20 kelimeyi doğru telaffuz ettin!',
      'icon': '🎯',
      'color': Color(0xFF2196F3),
    },
    {
      'id': 'yildiz_koleksiyoncusu',
      'title': 'Yıldız Koleksiyoncusu',
      'desc': 'Toplam 10 yıldız topladın!',
      'icon': '⭐',
      'color': Color(0xFFFFB300),
    },
    {
      'id': 'hikaye_kasifi',
      'title': 'Hikaye Kaşifi',
      'desc': 'Klinik hikayeleri dinleyip tamamladın!',
      'icon': '📖',
      'color': Color(0xFFAB47BC),
    },
    {
      'id': 'artikulasyon_ustasi',
      'title': 'Ses Ustası',
      'desc': 'Tüm ünsüz ses gruplarını bitirdin!',
      'icon': '👑',
      'color': Color(0xFFE91E63),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final rewardState = RewardState();

    return ListenableBuilder(
      listenable: rewardState,
      builder: (context, _) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text('🏆', style: TextStyle(fontSize: 28)),
                  SizedBox(width: 10),
                  Text(
                    'Kazanılan Rozetler',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF263238),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Sesleri söyledikçe yeni ödül rozetleri açılır!',
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
              const SizedBox(height: 20),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: badges.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (ctx, i) {
                    final b = badges[i];
                    final bool isUnlocked = rewardState.unlockedBadges.contains(b['id']);
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isUnlocked
                            ? (b['color'] as Color).withAlpha(20)
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isUnlocked
                              ? (b['color'] as Color).withAlpha(120)
                              : Colors.grey[300]!,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: isUnlocked
                                  ? (b['color'] as Color).withAlpha(50)
                                  : Colors.grey[300],
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                isUnlocked ? b['icon'] : '🔒',
                                style: const TextStyle(fontSize: 28),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  b['title'],
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: isUnlocked ? Colors.black87 : Colors.grey[500],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  b['desc'],
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isUnlocked ? Colors.black54 : Colors.grey[400],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isUnlocked)
                            const Icon(Icons.check_circle_rounded, color: AppTheme.primary, size: 28),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
