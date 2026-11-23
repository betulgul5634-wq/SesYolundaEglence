import 'package:flutter/material.dart';
import '../models/reward_state.dart';
import '../services/sound_effects_service.dart';
import '../theme/app_theme.dart';

class BadgeItem {
  final String id;
  final String title;
  final String category;
  final String categoryType; // 'speech', 'stars', 'habits', 'rewards'
  final String tier; // 'Bronz', 'Gümüş', 'Altın', 'Elmas'
  final Color categoryColor;
  final String icon;
  final String desc;
  final String requirementDesc;
  final int target;
  final String unit;
  final List<Color> gradient;
  final int Function(RewardState state) getCurrentValue;
  final String motivationalQuote;
  final String clinicalTip;

  const BadgeItem({
    required this.id,
    required this.title,
    required this.category,
    required this.categoryType,
    required this.tier,
    required this.categoryColor,
    required this.icon,
    required this.desc,
    required this.requirementDesc,
    required this.target,
    required this.unit,
    required this.gradient,
    required this.getCurrentValue,
    required this.motivationalQuote,
    required this.clinicalTip,
  });
}

class BadgesSheet extends StatefulWidget {
  const BadgesSheet({super.key});

  static final List<BadgeItem> allBadges = [
    // 🗣️ KONUŞMA & TELAFFUZ
    BadgeItem(
      id: 'ses_roket',
      title: 'Ses Roketi',
      category: 'Konuşma',
      categoryType: 'speech',
      tier: 'Bronz',
      categoryColor: const Color(0xFFFF9800),
      icon: '🚀',
      desc: 'Klinik mikrofonuna ilk doğru sesini ürettin!',
      requirementDesc: '1 kelime veya sesi doğru söyle',
      target: 1,
      unit: 'Kelime',
      gradient: [const Color(0xFFFF6D00), const Color(0xFFFFAB40)],
      getCurrentValue: (s) => s.effectivePracticedWords,
      motivationalQuote: 'İlk sesinle artikülasyon yolculuğun başladı! Roketin göklere yükseliyor!',
      clinicalTip: 'İlk sesin doğru çıkarılması, dil ve dudak kaslarının gelişimi için en değerli başlangıç adımıdır.',
    ),
    BadgeItem(
      id: 'kelime_ciragi',
      title: 'Kelime Çırağı',
      category: 'Konuşma',
      categoryType: 'speech',
      tier: 'Gümüş',
      categoryColor: const Color(0xFF0284C7),
      icon: '🗣️',
      desc: '10 kelimeyi başarıyla telaffuz ederek ses dağarcığını geliştirdin!',
      requirementDesc: '10 kelimeyi başarıyla tamamla',
      target: 10,
      unit: 'Kelime',
      gradient: [const Color(0xFF0284C7), const Color(0xFF38BDF8)],
      getCurrentValue: (s) => s.effectivePracticedWords,
      motivationalQuote: 'Kelimeler artık dudaklarından çok daha rahat ve akıcı dökülüyor!',
      clinicalTip: 'Kelimeleri tekrar etmek, heceleri birleştirmeyi ve konuşmanın akıcı hale gelmesini sağlar.',
    ),
    BadgeItem(
      id: 'artikulasyon_avcisi',
      title: 'Artikülasyon Avcısı',
      category: 'Konuşma',
      categoryType: 'speech',
      tier: 'Altın',
      categoryColor: const Color(0xFF2563EB),
      icon: '🎯',
      desc: '30 kelimeyi klinik düzeyinde doğru telaffuz ettin!',
      requirementDesc: '30 kelimeyi doğru söyle',
      target: 30,
      unit: 'Kelime',
      gradient: [const Color(0xFF1D4ED8), const Color(0xFF60A5FA)],
      getCurrentValue: (s) => s.effectivePracticedWords,
      motivationalQuote: 'Tam isabet! Kelimeleri bir ok gibi hedefe kusursuzca gönderiyorsun!',
      clinicalTip: 'Sesi kelimenin başında, ortasında ve sonunda söylemek, günlük konuşmada kalıcı olmasını sağlar.',
    ),
    BadgeItem(
      id: 'buyuk_usta',
      title: 'Büyük Konuşma Ustası',
      category: 'Konuşma',
      categoryType: 'speech',
      tier: 'Elmas',
      categoryColor: const Color(0xFF7C3AED),
      icon: '🌟',
      desc: 'Klinik standartlarında 60 kelimeyi başarıyla konuştun!',
      requirementDesc: '60 kelimeyi başarıyla tamamla',
      target: 60,
      unit: 'Kelime',
      gradient: [const Color(0xFF6D28D9), const Color(0xFFA78BFA)],
      getCurrentValue: (s) => s.effectivePracticedWords,
      motivationalQuote: 'Gerçek bir artikülasyon ustasısın, konuşman berrak ve pırıl pırıl!',
      clinicalTip: 'Zengin kelimeleri doğru telaffuz etmek, çocuğun özgüvenini ve kendini rahat ifade etmesini sağlar.',
    ),

    // ⭐ YILDIZ & HARİTA
    BadgeItem(
      id: 'ilk_yildiz',
      title: 'İlk Yıldız Kaşifi',
      category: 'Yıldız & Harita',
      categoryType: 'stars',
      tier: 'Bronz',
      categoryColor: const Color(0xFFF59E0B),
      icon: '⭐',
      desc: 'Haritadaki aşamalardan ilk 3 altın yıldızını parıldattın!',
      requirementDesc: '3 Altın Yıldız topla',
      target: 3,
      unit: 'Yıldız',
      gradient: [const Color(0xFFD97706), const Color(0xFFFCD34D)],
      getCurrentValue: (s) => s.totalStars,
      motivationalQuote: 'Yıldızların gökyüzünde ışıl ışıl parıldamaya başladı!',
      clinicalTip: 'Kazanılan her yıldız, çocuğun hevesini ve konuşma pratiği yapma isteğini artırır.',
    ),
    BadgeItem(
      id: 'yildiz_koleksiyoncusu',
      title: 'Yıldız Koleksiyoncusu',
      category: 'Yıldız & Harita',
      categoryType: 'stars',
      tier: 'Gümüş',
      categoryColor: const Color(0xFFEAB308),
      icon: '👑',
      desc: 'Harita ve oyunlardan tam 15 Altın Yıldız topladın!',
      requirementDesc: '15 Altın Yıldız topla',
      target: 15,
      unit: 'Yıldız',
      gradient: [const Color(0xFFCA8A04), const Color(0xFFFDE047)],
      getCurrentValue: (s) => s.totalStars,
      motivationalQuote: 'Harika bir yıldız koleksiyonu yapıyorsun, adımların çok güçlü!',
      clinicalTip: 'Adım adım ilerlemek, sesleri rahatça ve takılmadan söyleme becerisini pekiştirir.',
    ),
    BadgeItem(
      id: 'yildiz_sampiyonu',
      title: 'Yıldızlar Şampiyonu',
      category: 'Yıldız & Harita',
      categoryType: 'stars',
      tier: 'Altın',
      categoryColor: const Color(0xFFF59E0B),
      icon: '🏆',
      desc: 'Pratik ve mini oyunlardan 30 Altın Yıldız biriktirerek zirveye ulaştın!',
      requirementDesc: '30 Altın Yıldız topla',
      target: 30,
      unit: 'Yıldız',
      gradient: [const Color(0xFFB45309), const Color(0xFFFBBF24)],
      getCurrentValue: (s) => s.totalStars,
      motivationalQuote: 'Podyumun en tepesindesin, altın yıldızlar senin için parıldıyor!',
      clinicalTip: 'Bol pratik yapmak ve ödüller kazanmak, doğru konuşmayı kalıcı bir alışkanlığa dönüştürür.',
    ),
    BadgeItem(
      id: 'ses_yolcusu',
      title: 'Ses Yolcusu',
      category: 'Yıldız & Harita',
      categoryType: 'stars',
      tier: 'Bronz',
      categoryColor: const Color(0xFF059669),
      icon: '🗺️',
      desc: 'Ses haritasında 3 farklı ses durağını başarıyla geçtin!',
      requirementDesc: 'Haritada 3 ses durağını tamamla',
      target: 3,
      unit: 'Durak',
      gradient: [const Color(0xFF047857), const Color(0xFF34D399)],
      getCurrentValue: (s) => s.completedStagesCount,
      motivationalQuote: 'Ses haritasında harika ilerliyorsun, yeni duraklar seni bekliyor!',
      clinicalTip: 'Dudak, diş ve damak seslerini ayrı ayrı keşfetmek, konuşma kaslarını ustalıkla yönetmeyi öğretir.',
    ),
    BadgeItem(
      id: 'harita_fatihi',
      title: 'Harita Fatihi',
      category: 'Yıldız & Harita',
      categoryType: 'stars',
      tier: 'Altın',
      categoryColor: const Color(0xFF10B981),
      icon: '🧭',
      desc: 'Ses Yolunda tam 7 kritik fonem durağını fethettin!',
      requirementDesc: 'Haritada 7 ses durağını tamamla',
      target: 7,
      unit: 'Durak',
      gradient: [const Color(0xFF059669), const Color(0xFF6EE7B7)],
      getCurrentValue: (s) => s.completedStagesCount,
      motivationalQuote: 'Hiçbir ses senin önünde duramaz, haritanın gerçek fatihisin!',
      clinicalTip: 'Farklı harflerde ve seslerde pratik yapmak, konuşmanın herkes tarafından net ve anlaşılır duyulmasını sağlar.',
    ),

    // 🔥 SERİ & ALIŞKANLIK
    BadgeItem(
      id: 'ilk_adim',
      title: 'İlk Gün Başlangıcı',
      category: 'Seri & Alışkanlık',
      categoryType: 'habits',
      tier: 'Bronz',
      categoryColor: const Color(0xFF10B981),
      icon: '🌱',
      desc: 'Konuşma serüvenine kararlı ve disiplinli bir başlangıç yaptın!',
      requirementDesc: 'İlk pratik gününü tamamla',
      target: 1,
      unit: 'Gün',
      gradient: [const Color(0xFF059669), const Color(0xFF34D399)],
      getCurrentValue: (s) => s.streakDays,
      motivationalQuote: 'En büyük başarılar ilk adımla başlar, yolun açık olsun!',
      clinicalTip: 'Her gün yapılan kısa alıştırmalar, konuşma kaslarının rahatlamasını ve esnemesini sağlar.',
    ),
    BadgeItem(
      id: 'atesli_seri',
      title: 'Alevli Konuşma Serisi',
      category: 'Seri & Alışkanlık',
      categoryType: 'habits',
      tier: 'Gümüş',
      categoryColor: const Color(0xFFEF4444),
      icon: '🔥',
      desc: '3 gün boyunca aralıksız pratik yaparak seriyi başlattın!',
      requirementDesc: '3 gün aralıksız pratik yap',
      target: 3,
      unit: 'Gün',
      gradient: [const Color(0xFFDC2626), const Color(0xFFF87171)],
      getCurrentValue: (s) => s.streakDays,
      motivationalQuote: 'Konuşma azmin ve disiplinin bir meşale gibi ışık saçıyor!',
      clinicalTip: 'Günde sadece 10 dakika pratik yapmak, konuşma gelişimini haftada bir çalışmaktan çok daha hızlı ilerletir.',
    ),
    BadgeItem(
      id: 'sonmeyen_mesale',
      title: 'Sönmeyen Meşale',
      category: 'Seri & Alışkanlık',
      categoryType: 'habits',
      tier: 'Altın',
      categoryColor: const Color(0xFFEA580C),
      icon: '⚡',
      desc: 'Tam 1 hafta boyunca aralıksız konuşma disiplinini korudun!',
      requirementDesc: '7 gün aralıksız pratik yap',
      target: 7,
      unit: 'Gün',
      gradient: [const Color(0xFFC2410C), const Color(0xFFFB923C)],
      getCurrentValue: (s) => s.streakDays,
      motivationalQuote: 'Muazzam bir disiplin! Kararlılığın herkese ilham veriyor!',
      clinicalTip: '7 gün boyunca düzenli alıştırma yapmak, doğru telaffuzu kalıcı ve doğal bir refleks haline getirir.',
    ),

    // 🏆 KOLEKSİYON & DİĞER BAŞARILAR
    BadgeItem(
      id: 'ayna_kasifi',
      title: 'Konuşma Aynası Kaşifi',
      category: 'Koleksiyon',
      categoryType: 'rewards',
      tier: 'Bronz',
      categoryColor: const Color(0xFF0D9488),
      icon: '🪞',
      desc: 'Canlı aynada dudak, dil ve çene hareketlerini gözlemledin!',
      requirementDesc: 'Ayna modunu aç ve dudaklarını incele',
      target: 1,
      unit: 'Seans',
      gradient: [const Color(0xFF0F766E), const Color(0xFF2DD4BF)],
      getCurrentValue: (s) => s.questMirrorCount > 0 ? 1 : 0,
      motivationalQuote: 'Aynadaki yansımanla konuşma kaslarını ustalıkla keşfettin!',
      clinicalTip: 'Aynada dudak ve dil hareketlerini izlemek, sesleri doğru şekillendirmeyi çok daha kolaylaştırır.',
    ),
    BadgeItem(
      id: 'cikartma_koleksiyoneri',
      title: 'Çıkartma Koleksiyoncusu',
      category: 'Koleksiyon',
      categoryType: 'rewards',
      tier: 'Gümüş',
      categoryColor: const Color(0xFF9333EA),
      icon: '🎨',
      desc: 'Doğru söylediğin kelimelerin çıkartmalarını albümüne ekledin!',
      requirementDesc: 'Ses albümünde 5 çıkartma topla',
      target: 5,
      unit: 'Çıkartma',
      gradient: [const Color(0xFF7E22CE), const Color(0xFFC084FC)],
      getCurrentValue: (s) => s.unlockedStickers.length,
      motivationalQuote: 'Albümün renk cümbüşü, ses yolunda harika anılar biriktiriyorsun!',
      clinicalTip: 'Resimli çıkartmalar, kelimeleri zihinde canlandırmayı ve telaffuz edilen sesleri akılda tutmayı kolaylaştırır.',
    ),
    BadgeItem(
      id: 'lig_sampiyonu',
      title: 'Lig Yarışçısı',
      category: 'Koleksiyon',
      categoryType: 'rewards',
      tier: 'Gümüş',
      categoryColor: const Color(0xFF4F46E5),
      icon: '🏅',
      desc: 'Pratik yaparak 150 XP topladın ve lig sıralamasında öne geçtin!',
      requirementDesc: '150 XP kazanarak ligde yüksel',
      target: 150,
      unit: 'XP',
      gradient: [const Color(0xFF4338CA), const Color(0xFF818CF8)],
      getCurrentValue: (s) => s.xp,
      motivationalQuote: 'Ligin en parlak ses yıldızısın, basamakları hızla tırmanıyorsun!',
      clinicalTip: 'Oyunlar, puanlar ve rozetler, çocuğun konuşma egzersizlerini hevesle ve severek sürdürmesini sağlar.',
    ),
    BadgeItem(
      id: 'elmas_zengini',
      title: 'Hazine Avcısı',
      category: 'Koleksiyon',
      categoryType: 'rewards',
      tier: 'Altın',
      categoryColor: const Color(0xFF0891B2),
      icon: '💎',
      desc: 'Klinik cüzdanında 250 parıldayan elmas biriktirdin!',
      requirementDesc: '250 Elmas biriktir',
      target: 250,
      unit: 'Elmas',
      gradient: [const Color(0xFF0E7490), const Color(0xFF22D3EE)],
      getCurrentValue: (s) => s.gems,
      motivationalQuote: 'Zengin bir ses hazinesine sahipsin, çaban paha biçilemez!',
      clinicalTip: 'Yıldız ve elmas biriktirmek, çocuğa hedef bilinci ve çaba göstermenin mutluluğunu kazandırır.',
    ),
  ];

  @override
  State<BadgesSheet> createState() => _BadgesSheetState();
}

class _BadgesSheetState extends State<BadgesSheet> {
  String _selectedFilter = 'all'; // 'all', 'unlocked', 'locked', 'speech', 'stars', 'habits'

  @override
  Widget build(BuildContext context) {
    final rewardState = RewardState();

    return ListenableBuilder(
      listenable: rewardState,
      builder: (context, _) {
        int unlockedCount = 0;
        for (final b in BadgesSheet.allBadges) {
          final current = b.getCurrentValue(rewardState);
          final bool isUnlocked = rewardState.isBadgeUnlocked(b.id) || current >= b.target;
          if (isUnlocked) unlockedCount++;
        }
        final double overallRatio = (unlockedCount / BadgesSheet.allBadges.length).clamp(0.0, 1.0);

        // Seviye Unvanı
        String levelTitle;
        Color levelColor;
        if (unlockedCount < 4) {
          levelTitle = '🌱 Çırak Hatip';
          levelColor = const Color(0xFF10B981);
        } else if (unlockedCount < 8) {
          levelTitle = '⭐ Parlayan Ses Kaşifi';
          levelColor = const Color(0xFF0284C7);
        } else if (unlockedCount < 13) {
          levelTitle = '🏆 Usta Artikülatör';
          levelColor = const Color(0xFFF59E0B);
        } else {
          levelTitle = '👑 Efsanevi Konuşma Şampiyonu';
          levelColor = const Color(0xFF8B5CF6);
        }

        // Filtrelenmiş Rozetler
        final filteredBadges = BadgesSheet.allBadges.where((b) {
          final current = b.getCurrentValue(rewardState);
          final isUnlocked = rewardState.isBadgeUnlocked(b.id) || current >= b.target;
          if (_selectedFilter == 'unlocked') return isUnlocked;
          if (_selectedFilter == 'locked') return !isUnlocked;
          if (_selectedFilter == 'speech') return b.categoryType == 'speech';
          if (_selectedFilter == 'stars') return b.categoryType == 'stars';
          if (_selectedFilter == 'habits') return b.categoryType == 'habits';
          return true; // 'all'
        }).toList();

        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.90,
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
                padding: const EdgeInsets.only(top: 14, left: 20, right: 16, bottom: 12),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x08000000),
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
                          padding: const EdgeInsets.all(9),
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
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    'Kazanılan Rozetler',
                                    style: TextStyle(
                                      fontSize: 19,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF1E293B),
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: levelColor.withAlpha(25),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: levelColor.withAlpha(80)),
                                    ),
                                    child: Text(
                                      levelTitle,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        color: levelColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Sesleri söyledikçe ve pratik yaptıkça gerçek rozetlerin parıldar!',
                                style: TextStyle(
                                  fontSize: 11.5,
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
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  children: [
                    // 📊 GERÇEK İSTATİSTİK ÖZETİ KARTI
                    Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 12),
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
                                  '$unlockedCount / ${BadgesSheet.allBadges.length} Rozet Açıldı',
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
                                  fontSize: 13.5,
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
                          const SizedBox(height: 14),

                          // 4-GRİD GERÇEK VERİLER
                          Row(
                            children: [
                              _buildMiniStatBox(
                                icon: '⭐',
                                label: 'Toplam Yıldız',
                                value: '${rewardState.totalStars}',
                                color: const Color(0xFFB45309),
                              ),
                              const SizedBox(width: 8),
                              _buildMiniStatBox(
                                icon: '🗣️',
                                label: 'Pratik Kelime',
                                value: '${rewardState.effectivePracticedWords}',
                                color: const Color(0xFF0369A1),
                              ),
                              const SizedBox(width: 8),
                              _buildMiniStatBox(
                                icon: '🗺️',
                                label: 'Ses Durağı',
                                value: '${rewardState.completedStagesCount} Durak',
                                color: const Color(0xFF047857),
                              ),
                              const SizedBox(width: 8),
                              _buildMiniStatBox(
                                icon: '🔥',
                                label: 'Gün Serisi',
                                value: '${rewardState.streakDays} Gün',
                                color: const Color(0xFFB91C1C),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // 🏷️ KATEGORİ FİLTRELEME SEKMELERİ
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          _buildFilterChip('all', '🌟 Tümü (${BadgesSheet.allBadges.length})'),
                          const SizedBox(width: 6),
                          _buildFilterChip('unlocked', '🏆 Açılanlar ($unlockedCount)'),
                          const SizedBox(width: 6),
                          _buildFilterChip('locked', '🔒 Kilitli (${BadgesSheet.allBadges.length - unlockedCount})'),
                          const SizedBox(width: 6),
                          _buildFilterChip('speech', '🗣️ Konuşma'),
                          const SizedBox(width: 6),
                          _buildFilterChip('stars', '⭐ Yıldız & Harita'),
                          const SizedBox(width: 6),
                          _buildFilterChip('habits', '🔥 Seri & Alışkanlık'),
                        ],
                      ),
                    ),

                    // ROZET LİSTESİ
                    if (filteredBadges.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(28),
                        alignment: Alignment.center,
                        child: const Column(
                          children: [
                            Text('🎯', style: TextStyle(fontSize: 36)),
                            SizedBox(height: 8),
                            Text(
                              'Bu kategoride henüz rozet bulunmuyor.',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      )
                    else
                      ...filteredBadges.map((badge) {
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

  Widget _buildMiniStatBox({
    required String icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(220),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFFDE68A)),
        ),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 15)),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF78716C),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String filterKey, String label) {
    final bool isSelected = _selectedFilter == filterKey;
    return InkWell(
      onTap: () {
        SoundEffectsService().playPopSound();
        setState(() {
          _selectedFilter = filterKey;
        });
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0F172A) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0),
            width: 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withAlpha(20),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF475569),
          ),
        ),
      ),
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
                  width: 58,
                  height: 58,
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
                          fontSize: 27,
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
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: isUnlocked
                                  ? badge.categoryColor.withAlpha(30)
                                  : Colors.grey.withAlpha(40),
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: Text(
                              badge.category,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: isUnlocked ? badge.categoryColor : const Color(0xFF64748B),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE2E8F0),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              badge.tier.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF475569),
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
                          fontSize: 15,
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

                      // İlerleme Çubuğu & Kalan Bilgisi
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
                      if (!isUnlocked && badge.target > current) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Kalan: ${badge.target - current} ${badge.unit} (%${(progressRatio * 100).round()})',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ],
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
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420),
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Büyük Parıltılı Madalya
                Container(
                  width: 80,
                  height: 80,
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
                      style: const TextStyle(fontSize: 40),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

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
                        '${badge.category} • ${badge.tier}',
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
                        isUnlocked ? '✨ KAZANILDI' : '🔒 KİLİTLİ',
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
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 6),

                // Açıklama
                Text(
                  isUnlocked ? badge.desc : badge.requirementDesc,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF475569),
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 14),

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
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          Text(
                            isUnlocked
                                ? '$current / ${badge.target} ${badge.unit} Tamamlandı! ✨'
                                : '$current / ${badge.target} ${badge.unit} (%${(progressRatio * 100).round()})',
                            style: TextStyle(
                              fontSize: 11.5,
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
                const SizedBox(height: 12),

                // 🌱 Gelişim Faydası Notu
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFBFDBFE)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('🌱', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Gelişimsel Faydası',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF1E40AF),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              badge.clinicalTip,
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1E3A8A),
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // 💬 Tebrik Mesajı
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: badge.categoryColor.withAlpha(15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Text('💬', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Tebrik Notu',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF475569),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              badge.motivationalQuote,
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF334155),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Buton
                SizedBox(
                  width: double.infinity,
                  height: 44,
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
                        fontSize: 14.5,
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
