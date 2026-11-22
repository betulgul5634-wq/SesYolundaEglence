import 'package:flutter/material.dart';
import '../models/reward_state.dart';
import '../services/sound_effects_service.dart';

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

/// 🏅 LİG KADEMELERİ VERİ MODELİ
class LeagueTier {
  final int level;
  final String name;
  final String emoji;
  final Color color;
  final Color lightBg;
  final int minXp;
  final int maxXp;
  final int rewardGems;
  final String nextLeagueName;
  final String nextLeagueEmoji;

  const LeagueTier({
    required this.level,
    required this.name,
    required this.emoji,
    required this.color,
    required this.lightBg,
    required this.minXp,
    required this.maxXp,
    required this.rewardGems,
    required this.nextLeagueName,
    required this.nextLeagueEmoji,
  });
}

const List<LeagueTier> kLeagueTiers = [
  LeagueTier(
    level: 1,
    name: 'Bronz Ligi',
    emoji: '🥉',
    color: Color(0xFFCD7F32),
    lightBg: Color(0xFFFFF3E0),
    minXp: 0,
    maxXp: 299,
    rewardGems: 80,
    nextLeagueName: 'Gümüş Ligi',
    nextLeagueEmoji: '🥈',
  ),
  LeagueTier(
    level: 2,
    name: 'Gümüş Ligi',
    emoji: '🥈',
    color: Color(0xFF78909C),
    lightBg: Color(0xFFECEFF1),
    minXp: 300,
    maxXp: 699,
    rewardGems: 150,
    nextLeagueName: 'Altın Ligi',
    nextLeagueEmoji: '🥇',
  ),
  LeagueTier(
    level: 3,
    name: 'Altın Ligi',
    emoji: '🥇',
    color: Color(0xFFFFA000),
    lightBg: Color(0xFFFFF8E1),
    minXp: 700,
    maxXp: 1199,
    rewardGems: 250,
    nextLeagueName: 'Safir Ligi',
    nextLeagueEmoji: '💎',
  ),
  LeagueTier(
    level: 4,
    name: 'Safir Ligi',
    emoji: '💎',
    color: Color(0xFF1E88E5),
    lightBg: Color(0xFFE3F2FD),
    minXp: 1200,
    maxXp: 1999,
    rewardGems: 400,
    nextLeagueName: 'Elmas Ligi',
    nextLeagueEmoji: '👑',
  ),
  LeagueTier(
    level: 5,
    name: 'Elmas Ligi',
    emoji: '👑',
    color: Color(0xFF8E24AA),
    lightBg: Color(0xFFF3E5F5),
    minXp: 2000,
    maxXp: 999999,
    rewardGems: 600,
    nextLeagueName: 'Şampiyonlar Zirvesi',
    nextLeagueEmoji: '🏆',
  ),
];

LeagueTier getLeagueForXp(int xp) {
  for (int i = kLeagueTiers.length - 1; i >= 0; i--) {
    if (xp >= kLeagueTiers[i].minXp) {
      return kLeagueTiers[i];
    }
  }
  return kLeagueTiers[0];
}

/// 🏆 SÜPER ARTİKÜLASYON LİGİ (DUOLINGO TARZI HAFTALIK SIRALAMA)
class LeaderboardLeagueSheet extends StatelessWidget {
  const LeaderboardLeagueSheet({super.key});

  String _getWeeklyCountdown() {
    final now = DateTime.now();
    // Duolingo ve ligler her Pazar gecesi 23:59:59'da sıfırlanır
    int daysUntilSunday = DateTime.sunday - now.weekday;
    if (daysUntilSunday < 0) daysUntilSunday += 7;
    final sundayMidnight = DateTime(now.year, now.month, now.day + daysUntilSunday, 23, 59, 59);
    final diff = sundayMidnight.difference(now);

    if (diff.isNegative) {
      return 'Yeni hafta başlıyor... ⏳';
    }
    final days = diff.inDays;
    final hours = diff.inHours % 24;
    final minutes = diff.inMinutes % 60;

    if (days > 0) {
      return 'Haftalık Sıralama • Bitişe: $days Gün $hours Saat ⏳';
    } else if (hours > 0) {
      return 'Haftalık Sıralama • Bitişe: $hours Saat $minutes Dakika ⏳';
    } else {
      return 'Haftalık Sıralama • Bitişe: $minutes Dakika ⏳';
    }
  }

  void _showAllLeaguesDialog(BuildContext context, RewardState rewardState, LeagueTier currentTier) {
    final sfx = SoundEffectsService();
    sfx.playPopSound();

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Container(
          width: 440,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            color: Colors.white,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('🏆', style: TextStyle(fontSize: 28)),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Konuşma Ligleri Kademesi',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF263238)),
                          ),
                          Text(
                            'Duolingo Tarzı Haftalık Terfi Sistemi',
                            style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.grey),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                ...kLeagueTiers.map((tier) {
                  final isCurrent = tier.level == currentTier.level;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isCurrent ? tier.lightBg : const Color(0xFFFAFAFA),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isCurrent ? tier.color : Colors.grey[300]!,
                        width: isCurrent ? 2.5 : 1,
                      ),
                      boxShadow: isCurrent
                          ? [
                              BoxShadow(
                                color: tier.color.withValues(alpha: 0.25),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              )
                            ]
                          : [],
                    ),
                    child: Row(
                      children: [
                        Text(tier.emoji, style: const TextStyle(fontSize: 32)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    tier.name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 15,
                                      color: tier.color,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '(Seviye ${tier.level})',
                                    style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.bold),
                                  ),
                                  if (isCurrent) ...[
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: tier.color,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Text(
                                        'ŞU ANKİ LİGİN 🎯',
                                        style: TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.w900),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text(
                                tier.maxXp > 90000 ? '2000+ XP' : '${tier.minXp} - ${tier.maxXp} XP',
                                style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF455A64)),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '🎁 Terfi Ödülü: ${tier.rewardGems} Elmas 💎',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF2E7D32)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCompetitorDialog(BuildContext context, _LeagueUser user, LeagueTier tier) {
    final sfx = SoundEffectsService();
    sfx.playPopSound();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: tier.lightBg,
              child: Text(user.avatar, style: const TextStyle(fontSize: 22)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                  ),
                  Text(
                    user.badge,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F8E9),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFAED581)),
              ),
              child: Row(
                children: [
                  const Text('⚡', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Text(
                    'Toplam Deneyim: ${user.xp} XP',
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Color(0xFF2E7D32)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              user.isCurrentUser
                ? 'Harika gidiyorsun! Pratik yaptıkça XP kazanacak ve sıralamada yükseleceksin ⭐'
                : '${user.name} ile tatlı bir rekabet içindesin! Şimdi pratik yaparak onu geçebilirsin 💪',
              style: const TextStyle(fontSize: 13, height: 1.4, color: Color(0xFF37474F)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Kapat', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rewardState = RewardState();
    final sfx = SoundEffectsService();

    return ListenableBuilder(
      listenable: rewardState,
      builder: (context, _) {
        final userXp = rewardState.xp;
        final currentTier = getLeagueForXp(userXp);

        // Sanal ve gerçek lig rakiplerinin XP'lerini lig kademesine göre kalibre et
        final double scale = currentTier.minXp == 0 ? 0.4 : (currentTier.minXp / 300.0);

        final List<_LeagueUser> competitors = [
          _LeagueUser(
            name: 'Kerem E.',
            avatar: '🚀👦',
            xp: (510 * scale).round(),
            badge: 'Hızlı Okur',
          ),
          _LeagueUser(
            name: 'Elif Su',
            avatar: '🐱👧',
            xp: (470 * scale).round(),
            badge: 'Ses Avcısı',
          ),
          _LeagueUser(
            name: '${rewardState.studentName} (Sen)',
            avatar: rewardState.activeAvatar,
            xp: userXp,
            isCurrentUser: true,
            badge: rewardState.streakDays >= 3
                ? '🔥 ${rewardState.streakDays} Gün Serisi'
                : 'Yükselen Yıldız ⭐',
          ),
          _LeagueUser(
            name: 'Robotik',
            avatar: '🤖',
            xp: (390 * scale).round(),
            badge: 'Tekno Ses',
          ),
          _LeagueUser(
            name: 'Aslan Ali',
            avatar: '🦁',
            xp: (340 * scale).round(),
            badge: 'Kükreyen',
          ),
          _LeagueUser(
            name: 'Zeynep K.',
            avatar: '🦄👧',
            xp: (310 * scale).round(),
            badge: 'Masalcı',
          ),
          _LeagueUser(
            name: 'Mert B.',
            avatar: '🦖👦',
            xp: (260 * scale).round(),
            badge: 'Dinozor',
          ),
          _LeagueUser(
            name: 'Selin Y.',
            avatar: '🦩👧',
            xp: (210 * scale).round(),
            badge: 'Flamingo',
          ),
          _LeagueUser(
            name: 'Kaan T.',
            avatar: '🐼👦',
            xp: (170 * scale).round(),
            badge: 'Panda',
          ),
          _LeagueUser(
            name: 'Duru A.',
            avatar: '🌸👧',
            xp: (120 * scale).round(),
            badge: 'Çiçek',
          ),
        ];

        // Varsa diğer gerçek öğrenci profillerini de yarışmaya dahil et
        for (final p in rewardState.profiles) {
          if (p.id != rewardState.activeProfileId && p.name.trim().isNotEmpty) {
            competitors.add(
              _LeagueUser(
                name: p.name,
                avatar: p.avatar,
                xp: p.xp > 0 ? p.xp : (currentTier.minXp + 45),
                badge: 'Klinik Arkadaşı 🤝',
              ),
            );
          }
        }

        // XP'ye göre büyükten küçüğe sırala
        competitors.sort((a, b) => b.xp.compareTo(a.xp));

        final userRank = competitors.indexWhere((u) => u.isCurrentUser) + 1;
        final isUserInTop3 = userRank <= 3;
        final isUserInDanger = userRank >= 9;

        final thirdPlaceXp = competitors.length >= 3 ? competitors[2].xp : 0;
        final xpNeededForTop3 = (thirdPlaceXp - userXp + 15).clamp(10, 800);

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

              // ÜST BAŞLIK & DİNAMİK LİG ROZETİ
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: currentTier.lightBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: currentTier.color, width: 2),
                      ),
                      child: Text(currentTier.emoji, style: const TextStyle(fontSize: 26)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                '${currentTier.name} (Seviye ${currentTier.level})',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF455A64),
                                ),
                              ),
                              const SizedBox(width: 6),
                              InkWell(
                                onTap: () => _showAllLeaguesDialog(context, rewardState, currentTier),
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEDE7F6),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text('🏅 Kademeler', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF673AB7))),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _getWeeklyCountdown(),
                            style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600),
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

              // DİNAMİK TERFİ & DURUM BİLGİ KARTI
              Container(
                margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isUserInTop3
                      ? const Color(0xFFE8F5E9)
                      : (isUserInDanger ? const Color(0xFFFFEBEE) : const Color(0xFFFFF8E1)),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isUserInTop3
                        ? const Color(0xFF81C784)
                        : (isUserInDanger ? const Color(0xFFEF9A9A) : const Color(0xFFFFD54F)),
                  ),
                ),
                child: Row(
                  children: [
                    Text(isUserInTop3 ? '🚀' : (isUserInDanger ? '⚠️' : '⚡'), style: const TextStyle(fontSize: 22)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        isUserInTop3
                            ? '🎉 Harika! Şu an #$userRank. sıradasın ve ${currentTier.nextLeagueName}\'ne (${currentTier.nextLeagueEmoji}) terfi bölgesindesin! Ödül: ${currentTier.rewardGems} Elmas 💎'
                            : (isUserInDanger
                                ? 'Düşme hattındasın! Alt lige düşmemek için kelime pratikleri yaparak XP topla.'
                                : 'İlk 3 sıradaki konuşma ustaları ${currentTier.nextLeagueName}\'ne (${currentTier.nextLeagueEmoji}) yükselir ve ${currentTier.rewardGems} Elmas kazanır! (İlk 3 için: $xpNeededForTop3 XP)'),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: isUserInTop3
                              ? const Color(0xFF2E7D32)
                              : (isUserInDanger ? const Color(0xFFC62828) : const Color(0xFFE65100)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // CANLI SIRALAMA LİSTESİ
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: competitors.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (ctx, i) {
                    final user = competitors[i];
                    final rank = i + 1;
                    final isTop3 = rank <= 3;
                    final isDanger = rank >= 9;

                    return InkWell(
                      onTap: () => _showCompetitorDialog(context, user, currentTier),
                      borderRadius: BorderRadius.circular(18),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: user.isCurrentUser
                              ? const Color(0xFFFFF9C4)
                              : (isTop3 ? Colors.white : (isDanger ? const Color(0xFFFFFDE7) : const Color(0xFFFAFAFA))),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: user.isCurrentUser
                                ? const Color(0xFFFBC02D)
                                : (isTop3 ? const Color(0xFFFFD54F) : (isDanger ? const Color(0xFFFFCCBC) : Colors.grey[200]!)),
                            width: user.isCurrentUser ? 2.5 : (isTop3 ? 1.5 : 1.0),
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
                                  : (isTop3 ? const Color(0xFFFFF3E0) : const Color(0xFFEDE7F6)),
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
                      ),
                    );
                  },
                ),
              ),

              // ALT AKSİYON BAR
              Container(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          sfx.playSuccessDing();
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('🎯 Haritadan bir ses seçip pratik yaparak XP kazan ve #$userRank. sıradan yüksel!'),
                              backgroundColor: const Color(0xFF1E88E5),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF58CC02),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          elevation: 3,
                        ),
                        icon: const Text('⚡', style: TextStyle(fontSize: 18)),
                        label: const Text(
                          'Hemen Pratik Yap & Sıralamada Yüksel',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
