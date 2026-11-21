import 'package:flutter/material.dart';
import '../models/reward_state.dart';

class _LeagueUser {
  final String name;
  final String avatar;
  final int xp;
  final bool isCurrentUser;
  final String badge;

  _LeagueUser({
    required this.name,
    required this.avatar,
    required this.xp,
    this.isCurrentUser = false,
    this.badge = '',
  });
}

/// 🏆 SÜPER ARTİKÜLASYON LİGİ
/// Duolingo tarzı haftalık sıralama ve lig terfi sistemi.
class LeaderboardLeagueSheet extends StatelessWidget {
  const LeaderboardLeagueSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final rewardState = RewardState();
    final userXp = rewardState.xp;

    // Sanal rakipler ve kullanıcının gerçek XP'sine göre sıralama
    final List<_LeagueUser> competitors = [
      _LeagueUser(name: 'Kerem E.', avatar: '🚀👦', xp: 510, badge: 'Hızlı Okur'),
      _LeagueUser(name: 'Elif Su', avatar: '🐱👧', xp: 470, badge: 'Ses Avcısı'),
      _LeagueUser(
        name: '${rewardState.activeCharacterName} (Sen)',
        avatar: rewardState.activeAvatar,
        xp: userXp,
        isCurrentUser: true,
        badge: 'Yükselen Yıldız ⭐',
      ),
      _LeagueUser(name: 'Robotik', avatar: '🤖', xp: 390, badge: 'Tekno Ses'),
      _LeagueUser(name: 'Aslan Ali', avatar: '🦁', xp: 340, badge: 'Kükreyen'),
      _LeagueUser(name: 'Zeynep K.', avatar: '🦄👧', xp: 310, badge: 'Masalcı'),
      _LeagueUser(name: 'Mert B.', avatar: '🦖👦', xp: 260, badge: 'Dinozor'),
      _LeagueUser(name: 'Selin Y.', avatar: '🦩👧', xp: 210, badge: 'Flamingo'),
      _LeagueUser(name: 'Kaan T.', avatar: '🐼👦', xp: 170, badge: 'Panda'),
      _LeagueUser(name: 'Duru A.', avatar: '🌸👧', xp: 120, badge: 'Çiçek'),
    ];

    // XP'ye göre büyükten küçüğe sırala
    competitors.sort((a, b) => b.xp.compareTo(a.xp));

    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          // Çekme Barı
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 48,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(3),
            ),
          ),

          // Üst Başlık & Lig Rozeti
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFFFD54F), width: 1.5),
                  ),
                  child: const Text('🥈', style: TextStyle(fontSize: 26)),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Gümüş Ligi (Seviye 2)',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF455A64),
                        ),
                      ),
                      Text(
                        'Haftalık Sıralama • Bitişe: 2 Gün 14 Saat ⏳',
                        style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600),
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
          ),
          const Divider(height: 1),

          // TERFİ BİLGİ KARTI
          Container(
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF81C784)),
            ),
            child: Row(
              children: const [
                Text('🚀', style: TextStyle(fontSize: 22)),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'İlk 3 sıradaki konuşma ustaları Altın Ligi\'ne (🥇) yükselir ve 150 Elmas ödülü kazanır!',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF2E7D32)),
                  ),
                ),
              ],
            ),
          ),

          // SIRALAMA LİSTESİ
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: competitors.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (ctx, i) {
                final user = competitors[i];
                final rank = i + 1;
                final isTop3 = rank <= 3;

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: user.isCurrentUser
                        ? const Color(0xFFFFF9C4)
                        : (isTop3 ? Colors.white : const Color(0xFFFAFAFA)),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: user.isCurrentUser
                          ? const Color(0xFFFBC02D)
                          : (isTop3 ? const Color(0xFFFFD54F) : Colors.grey[200]!),
                      width: user.isCurrentUser ? 2.5 : 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: user.isCurrentUser
                            ? const Color(0x33FBC02D)
                            : Colors.black.withValues(alpha: 0.04),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Sıralama Numarası veya Madalya
                      SizedBox(
                        width: 34,
                        child: Text(
                          rank == 1 ? '🥇' : (rank == 2 ? '🥈' : (rank == 3 ? '🥉' : '#$rank')),
                          style: TextStyle(
                            fontSize: isTop3 ? 20 : 14,
                            fontWeight: FontWeight.w900,
                            color: isTop3 ? Colors.amber[800] : Colors.grey[600],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Avatar
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: user.isCurrentUser
                            ? const Color(0xFFFFE082)
                            : const Color(0xFFEDE7F6),
                        child: Text(user.avatar, style: const TextStyle(fontSize: 22)),
                      ),
                      const SizedBox(width: 12),

                      // İsim ve Unvan
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    user.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 13.5,
                                      color: user.isCurrentUser
                                          ? const Color(0xFFF57F17)
                                          : const Color(0xFF263238),
                                    ),
                                  ),
                                ),
                                if (user.isCurrentUser) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF57F17),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text(
                                      'SEN',
                                      style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              user.badge,
                              style: TextStyle(fontSize: 11, color: Colors.grey[600], fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),

                      // XP Skoru
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF58CC02).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Text('⚡', style: TextStyle(fontSize: 13)),
                            const SizedBox(width: 4),
                            Text(
                              '${user.xp} XP',
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 13,
                                color: Color(0xFF2E7D32),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
