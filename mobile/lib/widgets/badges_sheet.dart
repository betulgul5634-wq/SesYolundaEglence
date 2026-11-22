import 'package:flutter/material.dart';
import '../models/reward_state.dart';
import '../services/sound_effects_service.dart';
import '../theme/app_theme.dart';

class BadgeItem {
  final String id;
  final String title;
  final String category;
  final Color categoryColor;
  final String icon;
  final String desc;
  final String requirementDesc;
  final int target;
  final String unit;
  final List<Color> gradient;
  final int Function(RewardState state) getCurrentValue;
  final String motivationalQuote;

  const BadgeItem({
    required this.id,
    required this.title,
    required this.category,
    required this.categoryColor,
    required this.icon,
    required this.desc,
    required this.requirementDesc,
    required this.target,
    required this.unit,
    required this.gradient,
    required this.getCurrentValue,
    required this.motivationalQuote,
  });
}

class BadgesSheet extends StatelessWidget {
  const BadgesSheet({super.key});

  static final List<BadgeItem> allBadges = [
    BadgeItem(
      id: 'ses_roket',
      title: 'Ses Roketi',
      category: 'İlk Başarı',
      categoryColor: const Color(0xFFFF9800),
      icon: '🚀',
      desc: 'Klinik mikrofonuna ilk doğru sesini ürettin!',
      requirementDesc: '1 kelimeyi başarıyla söyle',
      target: 1,
      unit: 'Kelime',
      gradient: [const Color(0xFFFF6D00), const Color(0xFFFFAB40)],
      getCurrentValue: (s) => s.totalPracticedSuccesses,
      motivationalQuote: 'İlk sesinle artikülasyon yolculuğun başladı! Roketin göklere yükseliyor!',
    ),
    BadgeItem(
      id: 'keskin_nisanci',
      title: 'Artikülasyon Avcısı',
      category: 'Klinik Telaffuz',
      categoryColor: const Color(0xFF2196F3),
      icon: '🎯',
      desc: '50 kelimeyi klinik düzeyinde doğru telaffuz ettin!',
      requirementDesc: '50 kelimeyi doğru söyle',
      target: 50,
      unit: 'Kelime',
      gradient: [const Color(0xFF1976D2), const Color(0xFF42A5F5)],
      getCurrentValue: (s) => s.totalPracticedSuccesses,
      motivationalQuote: 'Tam isabet! Kelimeleri bir ok gibi hedefe kusursuzca gönderiyorsun!',
    ),
    BadgeItem(
      id: 'yildiz_sampiyonu',
      title: 'Yıldızlar Şampiyonu',
      category: 'Altın Yıldız',
      categoryColor: const Color(0xFFFFC107),
      icon: '👑',
      desc: 'Pratik ve mini oyunlardan 25 Altın Yıldız topladın!',
      requirementDesc: '25 Altın Yıldız topla',
      target: 25,
      unit: 'Yıldız',
      gradient: [const Color(0xFFFFA000), const Color(0xFFFFD54F)],
      getCurrentValue: (s) => s.totalStars,
      motivationalQuote: 'Gökyüzünün en parlak altın yıldızları senin dilinde parıldıyor!',
    ),
    BadgeItem(
      id: 'atesli_seri',
      title: 'Alevli Konuşma Serisi',
      category: 'Günlük Seri',
      categoryColor: const Color(0xFFFF5722),
      icon: '🔥',
      desc: 'Her gün aralıksız pratik yaparak 5 günlük seri yakaladın!',
      requirementDesc: '5 gün aralıksız pratik yap',
      target: 5,
      unit: 'Gün',
      gradient: [const Color(0xFFE64A19), const Color(0xFFFF7043)],
      getCurrentValue: (s) => s.streakDays,
      motivationalQuote: 'Konuşma azmin ve disiplinin bir meşale gibi hiç sönmüyor! Süpersin!',
    ),
    BadgeItem(
      id: 'elmas_zengini',
      title: 'Elmas Zengini',
      category: 'Klinik Hazine',
      categoryColor: const Color(0xFF00BCD4),
      icon: '💎',
      desc: 'Klinik cüzdanında 300 parıldayan elmas biriktirdin!',
      requirementDesc: '300 Elmas biriktir',
      target: 300,
      unit: 'Elmas',
      gradient: [const Color(0xFF0097A7), const Color(0xFF4DD0E1)],
      getCurrentValue: (s) => s.gems,
      motivationalQuote: 'Zengin bir ses hazinesine sahipsin, çaban paha biçilemez!',
    ),
    BadgeItem(
      id: 'cikartma_koleksiyoneri',
      title: 'Koleksiyon Ustası',
      category: 'Klinik Albüm',
      categoryColor: const Color(0xFF9C27B0),
      icon: '📖',
      desc: 'Klinik Çıkartma Albümünde 8 parlak çıkartmayı açtın!',
      requirementDesc: '8 çıkartma topla',
      target: 8,
      unit: 'Çıkartma',
      gradient: [const Color(0xFF7B1FA2), const Color(0xFFBA68C8)],
      getCurrentValue: (s) => s.unlockedStickers.length,
      motivationalQuote: 'Albümünün sayfaları rengarenk ses çıkartmalarıyla parıldıyor!',
    ),
    BadgeItem(
      id: 'lig_sampiyonu',
      title: 'Gümüş Ligi Yarışçısı',
      category: 'Lig Sıralaması',
      categoryColor: const Color(0xFF3F51B5),
      icon: '⚡',
      desc: '400 XP kazanarak lig sıralamasında zirveye yükseldin!',
      requirementDesc: '400 XP kazan',
      target: 400,
      unit: 'XP',
      gradient: [const Color(0xFF303F9F), const Color(0xFF7986CB)],
      getCurrentValue: (s) => s.xp,
      motivationalQuote: 'Ligin en parlak ses yıldızısın, podyum senin için ışıldıyor!',
    ),
    BadgeItem(
      id: 'ayna_kasifi',
      title: 'Konuşma Aynası Kaşifi',
      category: 'Görsel Farkındalık',
      categoryColor: const Color(0xFF009688),
      icon: '🪞',
      desc: 'Canlı aynada dudak ve dil motor hareketlerini inceledin!',
      requirementDesc: 'Ayna modunu aç ve dudaklarını incele',
      target: 1,
      unit: 'Çalışma',
      gradient: [const Color(0xFF00796B), const Color(0xFF4DB6AC)],
      getCurrentValue: (s) => (s.questMirrorCount > 0 || s.unlockedAccessories.isNotEmpty) ? 1 : 0,
      motivationalQuote: 'Aynadaki yansımanla konuşma kaslarını ustalıkla keşfettin!',
    ),
    BadgeItem(
      id: 'gardirob_tasarimcisi',
      title: 'Avatar Stil İkonu',
      category: 'Gardırop',
      categoryColor: const Color(0xFFE91E63),
      icon: '🎩',
      desc: 'Avatarın için 4 farklı harika giysi ve aksesuar edindin!',
      requirementDesc: '4 aksesuar veya giysi edin',
      target: 4,
      unit: 'Aksesuar',
      gradient: [const Color(0xFFC2185B), const Color(0xFFF06292)],
      getCurrentValue: (s) => s.unlockedAccessories.length,
      motivationalQuote: 'Karakterin sahnedeki en havalı ve şık konuşmacı oldu!',
    ),
    BadgeItem(
      id: 'buyuk_usta',
      title: 'Büyük Artikülasyon Ustası',
      category: 'Klinik Uzmanlık',
      categoryColor: const Color(0xFF43A047),
      icon: '🌟',
      desc: '%80 üzeri genel doğrulukla 50 klinik kelimesini tamamladın!',
      requirementDesc: '50 kelimede %80+ başarı sağla',
      target: 50,
      unit: 'Kelime',
      gradient: [const Color(0xFF2E7D32), const Color(0xFF81C784)],
      getCurrentValue: (s) => s.overallAccuracy >= 80
          ? s.totalPracticedAttempts
          : (s.totalPracticedAttempts * s.overallAccuracy ~/ 80),
      motivationalQuote: 'Klinik standartlarında gerçek bir telaffuz ve artikülasyon ustasısın!',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final rewardState = RewardState();

    return ListenableBuilder(
      listenable: rewardState,
      builder: (context, _) {
        int unlockedCount = 0;
        for (final b in allBadges) {
          final current = b.getCurrentValue(rewardState);
          final bool isUnlocked = rewardState.isBadgeUnlocked(b.id) || current >= b.target;
          if (isUnlocked) unlockedCount++;
        }
        final double overallRatio = (unlockedCount / allBadges.length).clamp(0.0, 1.0);

        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.88,
          ),
          decoration: const BoxDecoration(
            color: Color(0xFFF8FAFC),
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Üst Sürükleme Çubuğu & Başlık
              Container(
                padding: const EdgeInsets.only(top: 14, left: 20, right: 16, bottom: 8),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x0A000000),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Center(
                      child: Container(
                        width: 44,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFFD54F), Color(0xFFFFA000)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFFA000).withAlpha(80),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Text('🏆', style: TextStyle(fontSize: 22)),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Kazanılan Rozetler',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF1E293B),
                                  letterSpacing: -0.3,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Sesleri söyledikçe efsanevi rozetler açılır!',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B), size: 24),
                          tooltip: 'Kapat',
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Ana Kaydırılabilir İçerik
              Flexible(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  children: [
                    // Canlı İlerleme Özeti Kartı
                    Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFFBEB), Color(0xFFFEF3C7)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: const Color(0xFFFDE68A), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFF59E0B).withAlpha(25),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF59E0B),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '$unlockedCount / ${allBadges.length} Rozet Açıldı',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '%${(overallRatio * 100).round()} Tamamlandı',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFFB45309),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: overallRatio,
                              minHeight: 10,
                              backgroundColor: Colors.white,
                              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFF59E0B)),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Text('✨', style: TextStyle(fontSize: 13)),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  unlockedCount >= 7
                                      ? 'Müthişsin! Efsanevi artikülasyon şampiyonluğuna çok az kaldı!'
                                      : 'Pratik yaptıkça ve doğru konuştukça rozetlerin parıldayacak!',
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF92400E),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Rozet Listesi
                    ...allBadges.map((badge) {
                      final current = badge.getCurrentValue(rewardState);
                      final bool isUnlocked = rewardState.isBadgeUnlocked(badge.id) || current >= badge.target;
                      final double progressRatio = (current / badge.target).clamp(0.0, 1.0);

                      return _buildBadgeCard(
                        context: context,
                        badge: badge,
                        isUnlocked: isUnlocked,
                        current: current,
                        progressRatio: progressRatio,
                      );
                    }),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBadgeCard({
    required BuildContext context,
    required BadgeItem badge,
    required bool isUnlocked,
    required int current,
    required double progressRatio,
  }) {
    final Color mainColor = badge.gradient[0];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isUnlocked ? Colors.white : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isUnlocked ? mainColor.withAlpha(90) : const Color(0xFFE2E8F0),
          width: isUnlocked ? 2 : 1.5,
        ),
        boxShadow: isUnlocked
            ? [
                BoxShadow(
                  color: mainColor.withAlpha(20),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () {
            SoundEffectsService().playPopSound();
            _showBadgeDetailModal(context, badge, isUnlocked, current, progressRatio);
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // İkon & Madalya Görseli
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: isUnlocked
                        ? LinearGradient(
                            colors: badge.gradient,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : const LinearGradient(
                            colors: [Color(0xFFCBD5E1), Color(0xFF94A3B8)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                    shape: BoxShape.circle,
                    boxShadow: isUnlocked
                        ? [
                            BoxShadow(
                              color: mainColor.withAlpha(80),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : null,
                    border: Border.all(
                      color: Colors.white,
                      width: 2.5,
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        badge.icon,
                        style: TextStyle(
                          fontSize: 28,
                          color: isUnlocked ? null : Colors.white.withAlpha(120),
                        ),
                      ),
                      if (!isUnlocked)
                        Positioned(
                          bottom: 2,
                          right: 2,
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              color: Color(0xFF475569),
                              shape: BoxShape.circle,
                            ),
                            child: const Text('🔒', style: TextStyle(fontSize: 10)),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),

                // Bilgiler ve Canlı İlerleme Çubuğu
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: isUnlocked
                                  ? badge.categoryColor.withAlpha(30)
                                  : Colors.grey.withAlpha(40),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              badge.category,
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: isUnlocked ? badge.categoryColor : const Color(0xFF64748B),
                              ),
                            ),
                          ),
                          const Spacer(),
                          if (isUnlocked)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981).withAlpha(30),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 14),
                                  SizedBox(width: 4),
                                  Text(
                                    'Kazanıldı',
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF047857),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            Text(
                              '$current / ${badge.target} ${badge.unit}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF64748B),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        badge.title,
                        style: TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w800,
                          color: isUnlocked ? const Color(0xFF1E293B) : const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isUnlocked ? badge.desc : badge.requirementDesc,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          color: isUnlocked ? const Color(0xFF475569) : const Color(0xFF94A3B8),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // İlerleme Çubuğu
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: isUnlocked ? 1.0 : progressRatio,
                          minHeight: 6,
                          backgroundColor: isUnlocked ? mainColor.withAlpha(30) : const Color(0xFFE2E8F0),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isUnlocked ? const Color(0xFF10B981) : mainColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showBadgeDetailModal(
    BuildContext context,
    BadgeItem badge,
    bool isUnlocked,
    int current,
    double progressRatio,
  ) {
    if (isUnlocked) {
      SoundEffectsService().playSuccessDing();
    }

    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Büyük Parıltılı Madalya
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    gradient: isUnlocked
                        ? LinearGradient(
                            colors: badge.gradient,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : const LinearGradient(
                            colors: [Color(0xFFCBD5E1), Color(0xFF94A3B8)],
                          ),
                    shape: BoxShape.circle,
                    boxShadow: isUnlocked
                        ? [
                            BoxShadow(
                              color: badge.gradient[0].withAlpha(100),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ]
                        : null,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: Center(
                    child: Text(
                      badge.icon,
                      style: const TextStyle(fontSize: 42),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Kategori ve Durum Rozeti
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: badge.categoryColor.withAlpha(25),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        badge.category,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: badge.categoryColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: isUnlocked
                            ? const Color(0xFF10B981).withAlpha(25)
                            : const Color(0xFF64748B).withAlpha(25),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        isUnlocked ? '✨ AÇILDI' : '🔒 KİLİTLİ',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: isUnlocked ? const Color(0xFF047857) : const Color(0xFF475569),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Başlık
                Text(
                  badge.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 8),

                // Açıklama
                Text(
                  badge.desc,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF475569),
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 16),

                // İlerleme Kutusu
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Hedef İlerlemesi',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          Text(
                            isUnlocked
                                ? 'Tamamlandı (%100)'
                                : '$current / ${badge.target} ${badge.unit} (%${(progressRatio * 100).round()})',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: isUnlocked ? const Color(0xFF10B981) : const Color(0xFF1E293B),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: isUnlocked ? 1.0 : progressRatio,
                          minHeight: 8,
                          backgroundColor: const Color(0xFFE2E8F0),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isUnlocked ? const Color(0xFF10B981) : badge.gradient[0],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Motivasyon Cümlesi
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: badge.categoryColor.withAlpha(15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Text('💬', style: TextStyle(fontSize: 18)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          badge.motivationalQuote,
                          style: TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF334155),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Buton
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isUnlocked ? const Color(0xFF10B981) : AppTheme.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: Text(
                      isUnlocked ? 'Harika! 🌟' : 'Pratiğe Devam Et! 🚀',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
