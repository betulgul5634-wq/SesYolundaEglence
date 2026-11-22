import '../widgets/subway_character_hub_dialog.dart';
import '../widgets/student_profiles_dialog.dart';
import '../widgets/therapist_portal_dialog.dart';
import '../services/therapist_state_service.dart';
import 'package:flutter/material.dart';
import '../data/sound_groups_data.dart';
import '../models/sound_group.dart';
import '../models/reward_state.dart';
import '../widgets/badges_sheet.dart';
import '../widgets/lucky_spin_dialog.dart';
import '../widgets/daily_quests_dialog.dart';
import '../widgets/leaderboard_league_sheet.dart';
import '../widgets/articulation_screening_dialog.dart';
import '../widgets/avatar_wardrobe_sheet.dart';
import '../widgets/sticker_book_sheet.dart';
import '../widgets/streak_calendar_dialog.dart';
import '../widgets/gems_shop_dialog.dart';
import '../widgets/hearts_refill_dialog.dart';
import '../services/audio_speech_service.dart';
import 'sound_practice_screen.dart';
import '../widgets/interactive_avatar_widget.dart';
import '../widgets/animated_atmosphere_background.dart';
import '../services/sound_effects_service.dart';

/// Anasayfa — Duolingo Tarzı 3D Macera Haritası & Kitap Bölümlendirmeli Ses Seçimi
class HomeScreen extends StatefulWidget {
  final bool openTherapistPortalOnStart;

  const HomeScreen({
    super.key,
    this.openTherapistPortalOnStart = false,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late List<SoundStage> _stages;
  final RewardState _rewardState = RewardState();
  final TherapistStateService _therapistState = TherapistStateService();
  final AudioSpeechService _audioService = AudioSpeechService();
  late AnimationController _mascotBounceController;
  late Animation<double> _mascotBounce;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  final SoundEffectsService _sfx = SoundEffectsService();
  int _mascotQuoteIndex = 0;
  final List<String> _mascotQuotes = [
    'Günün Harika Sesi Seni Bekliyor! ⭐',
    'Gardırobundaki yeni eşyaları denedin mi? 🛍️',
    'Şans Çarkıfeleğini çevirip elmas kazan! 🎡',
    'Bugün 3 yıldız daha toplayıp rekor kır! 🏆',
    'Sesleri tane tane çıkar, süper gidiyorsun! 🎯',
  ];
  int _selectedStageIndex = 0;
  final ScrollController _soundScrollController = ScrollController();

  String _selectedCategory = '⭐ Tümü (20)';

  static const List<String> kCategories = [
    '⭐ Tümü (20)',
    '👄 Dudak Sesleri (3)',
    '🦷 Diş - Dudak (2)',
    '👅 Dil & Diş Yuvası (5)',
    '🏰 Damak & Boğaz (7)',
    '🌊 Akıcı Sesler (3)',
    '💥 Patlamalı (6)',
    '💨 Sürtünmeli (7)',
  ];

  @override
  void initState() {
    super.initState();
    _stages = List.from(kBookStages);
    _mascotBounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _mascotBounce = Tween<double>(begin: -4, end: 4).animate(
      CurvedAnimation(parent: _mascotBounceController, curve: Curves.easeInOut),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.94, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Terapist Davet Kodu Kontrolü (?student=Ali+Yılmaz)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final studentParam = Uri.base.queryParameters['student'] ?? Uri.base.queryParameters['name'];
      if (studentParam != null && studentParam.trim().isNotEmpty) {
        final decoded = Uri.decodeComponent(studentParam.trim());
        _rewardState.setStudentName(decoded);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Text('🎉', style: TextStyle(fontSize: 22)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Hoş geldin $decoded! Terapist bağlantın kuruldu, egzersizlerin kaydediliyor.',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF2E7D32),
            duration: const Duration(seconds: 6),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

      if (widget.openTherapistPortalOnStart) {
        showDialog(
          context: context,
          builder: (_) => TherapistPortalDialog(
            initialLoggedIn: _therapistState.isLoggedIn,
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _soundScrollController.dispose();
    _mascotBounceController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _openPractice(SoundStage stage, int index) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => SoundPracticeScreen(
          stage: stage,
          stageIndex: index,
        ),
      ),
    );

    if (result == true) {
      setState(() {
        final current = _stages[index];
        int nextLevel = (current.unlockedLevelIndex + 1).clamp(0, 5);
        _stages[index] = current.copyWith(
          unlockedLevelIndex: nextLevel,
          isCompleted: nextLevel >= 4,
          starsCollected: (current.starsCollected + 3).clamp(0, 15),
        );
      });
    }
  }

  List<SoundStage> get _filteredStages {
    if (_selectedCategory.startsWith('⭐ Tümü') || _selectedCategory.startsWith('Tümü')) {
      return _stages;
    }
    if (_selectedCategory.contains('Dudak Sesleri')) {
      return _stages.where((s) => ['/p/', '/b/', '/m/'].contains(s.phoneme)).toList();
    }
    if (_selectedCategory.contains('Diş - Dudak')) {
      return _stages.where((s) => ['/f/', '/v/'].contains(s.phoneme)).toList();
    }
    if (_selectedCategory.contains('Dil & Diş Yuvası')) {
      return _stages.where((s) => ['/t/', '/d/', '/s/', '/z/', '/n/'].contains(s.phoneme)).toList();
    }
    if (_selectedCategory.contains('Damak & Boğaz')) {
      return _stages.where((s) => ['/k/', '/g/', '/c/', '/ç/', '/j/', '/ş/', '/h/'].contains(s.phoneme)).toList();
    }
    if (_selectedCategory.contains('Akıcı Sesler')) {
      return _stages.where((s) => ['/l/', '/r/', '/y/'].contains(s.phoneme)).toList();
    }
    final cleanCategory = _selectedCategory.replaceAll(RegExp(r'[^\w\sğüşöçıİĞÜŞÖÇ]'), '').trim();
    final prefix = cleanCategory.split(' ')[0]; // 'Patlamalı', 'Sürtünmeli', vb.
    return _stages.where((s) => s.mainCategory.contains(prefix)).toList();
  }

  void _showBookTableOfContents() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  children: [
                    const Text('📖', style: TextStyle(fontSize: 24)),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Klinik Kitap Ses Tablosu',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                          Text(
                            'Kitabın 6 ana kategorisi ve 20 sesi',
                            style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildBookTocCategoryCard(
                      '1. Patlamalı - Durak Sesler',
                      '💥',
                      const Color(0xFFE53935),
                      [
                        ('Çift Dudak Patlamalı - Durak Sesler', ['/p/', '/b/']),
                        ('Diş Yuvasıl Patlamalı - Durak Sesleri', ['/t/', '/d/']),
                        ('Yumuşak Damak Patlamalı - Durak Sesleri', ['/k/', '/g/']),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildBookTocCategoryCard(
                      '2. Sürtünmeli Sesler',
                      '💨',
                      const Color(0xFF8E24AA),
                      [
                        ('Diş - Dudak Sürtünmeli Sesleri', ['/f/', '/v/']),
                        ('Diş Yuvasıl Sürtünmeli Sesler', ['/s/', '/z/']),
                        ('Diş Yuvası Ardı Sürtünmeli Sesler', ['/ş/', '/j/']),
                        ('Gırtlak Sürtünmeli Ses', ['/h/']),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildBookTocCategoryCard(
                      '3. Durak Sürtünmeli Sesler',
                      '🛑',
                      const Color(0xFFD81B60),
                      [
                        ('Diş Yuvası Ardı Durak Sürtünmeli Sesler', ['/ç/', '/c/']),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildBookTocCategoryCard(
                      '4. Genizsi Sesler',
                      '👃',
                      const Color(0xFF00897B),
                      [
                        ('Çift Dudak Genizsi Ses', ['/m/']),
                        ('Diş Yuvasıl Genizsi Ses', ['/n/']),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildBookTocCategoryCard(
                      '5. Akıcı Sesler',
                      '🌊',
                      const Color(0xFF1E88E5),
                      [
                        ('Diş Yuvasıl Akıcı Sesler', ['/l/', '/r/']),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildBookTocCategoryCard(
                      '6. Daralmalı Sesler',
                      '✨',
                      const Color(0xFFF4511E),
                      [
                        ('Sert Damak Daralmalı Ses', ['/y/']),
                      ],
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

  Widget _buildBookTocCategoryCard(
    String categoryName,
    String icon,
    Color color,
    List<(String, List<String>)> subcategories,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: color.withAlpha(12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withAlpha(70), width: 1.5),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                categoryName,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          for (final sub in subcategories) ...[
            Padding(
              padding: const EdgeInsets.only(left: 4, top: 4, bottom: 6),
              child: Text(
                '• ${sub.$1}:',
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF37474F),
                ),
              ),
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: sub.$2.map((phoneme) {
                final stageIdx = _stages.indexWhere((s) => s.phoneme == phoneme);
                if (stageIdx == -1) return const SizedBox.shrink();
                final stage = _stages[stageIdx];
                return InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    setState(() => _selectedStageIndex = stageIdx);
                    _openPractice(stage, stageIdx);
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: color, width: 1.5),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 3, offset: Offset(0, 2)),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(stage.emoji, style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: 6),
                        Text(
                          stage.phoneme,
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF58CC02),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Üst Oyun Barı (Seri, Elmas, Can, Rozetler)
            _buildGameTopBar(),

            // 2. KULLANICININ İSTEDİĞİ SESİ KATEGORİLERLE SEÇEBİLECEĞİ SES SEÇİCİ ÇUBUĞU
            _buildSoundSelectorBar(),

            // 3. Duolingo Tarzı Canlı Oyun Haritası (Canlı Atmosfer & Yüzen Parçacıklar)
            Expanded(
              child: AnimatedAtmosphereBackground(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  itemCount: _stages.length + 1,
                  itemBuilder: (ctx, i) {
                    if (i == 0) {
                      return _buildMascotGreetingCard();
                    }
                    final stageIndex = i - 1;
                    final stage = _stages[stageIndex];

                    // Yeni kategori başlangıçlarında Bölüm Başlığı ekle
                    final bool isFirstOfCategory = (stageIndex == 0) ||
                        (_stages[stageIndex].mainCategory != _stages[stageIndex - 1].mainCategory);

                    // Kavisli yol deseni
                    final double alignmentX = (stageIndex % 4 == 1)
                        ? 0.55
                        : (stageIndex % 4 == 3)
                            ? -0.55
                            : 0.0;

                    return Column(
                      children: [
                        if (isFirstOfCategory)
                          _buildSectionBanner(stage.mainCategory, _getCategoryNumber(stage.mainCategory)),
                        if (stageIndex > 0 && !isFirstOfCategory)
                          _buildConnectorLine(
                            previousAlign: (stageIndex - 1) % 4 == 1
                                ? 0.55
                                : ((stageIndex - 1) % 4 == 3 ? -0.55 : 0.0),
                            currentAlign: alignmentX,
                          ),
                        Align(
                          alignment: Alignment(alignmentX, 0),
                          child: _buildGameNode(stage, stageIndex),
                        ),
                        if (stageIndex > 0 && stageIndex % 3 == 0)
                          _buildTreasureChest(),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _getCategoryNumber(String category) {
    if (category.contains('Patlamalı')) return 1;
    if (category.contains('Sürtünmeli') && !category.contains('Durak')) return 2;
    if (category.contains('Durak Sürtünmeli')) return 3;
    if (category.contains('Genizsi')) return 4;
    if (category.contains('Akıcı')) return 5;
    if (category.contains('Daralmalı')) return 6;
    return 1;
  }

  Widget _buildSectionBanner(String title, int sectionNumber) {
    String biomeName = '🌴 Tropik Ada & Mercan Sahili';
    String biomeSub = 'Patlamalı - Durak Sesler Bölgesi';
    Color biomeColor = const Color(0xFF00897B);
    Color bgTint = const Color(0xFFE0F2F1);

    if (sectionNumber == 2) {
      biomeName = '🌲 Büyülü Orman & Mantar Vadisi';
      biomeSub = 'Sürtünmeli Sesler Krallığı';
      biomeColor = const Color(0xFF5E35B1);
      bgTint = const Color(0xFFEDE7F6);
    } else if (sectionNumber == 3) {
      biomeName = '🏰 Kraliyet Şatosu & Zirve';
      biomeSub = 'Durak Sürtünmeli Sesler Kalesi';
      biomeColor = const Color(0xFFC2185B);
      bgTint = const Color(0xFFFCE4EC);
    } else if (sectionNumber == 4) {
      biomeName = '🌸 Çiçekli Vaha & Nehir';
      biomeSub = 'Genizsi Sesler Bahçesi';
      biomeColor = const Color(0xFF00897B);
      bgTint = const Color(0xFFE0F2F1);
    } else if (sectionNumber == 5) {
      biomeName = '🌊 Mavi Çağlayan & Akıcı Kristal';
      biomeSub = 'Akıcı Sesler Şelalesi';
      biomeColor = const Color(0xFF1565C0);
      bgTint = const Color(0xFFE3F2FD);
    } else if (sectionNumber == 6) {
      biomeName = '🚀 Uzay Limanı & Yıldız Gezegeni';
      biomeSub = 'Daralmalı Sesler Kozmosu';
      biomeColor = const Color(0xFFE65100);
      bgTint = const Color(0xFFFFF3E0);
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: biomeColor, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: biomeColor.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: bgTint,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'DÜNYA $sectionNumber: $biomeSub',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w900,
                    color: biomeColor,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            biomeName,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: biomeColor,
            ),
          ),
        ],
      ),
    );
  }

  /// Üst İstatistik Barı
  Widget _buildGameTopBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: ListenableBuilder(
        listenable: _rewardState,
        builder: (context, _) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // 👥 Öğrenci Profili / Değiştirici Butonu
                InkWell(
                  onTap: () {
                    _sfx.playPopSound();
                    showDialog(
                      context: context,
                      builder: (_) => const StudentProfilesDialog(),
                    );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF4CAF50), width: 1.5),
                      boxShadow: const [
                        BoxShadow(color: Color(0x10000000), blurRadius: 4, offset: Offset(0, 2)),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_rewardState.activeAvatar, style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: 5),
                        Text(
                          _rewardState.studentName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 12.5,
                            color: Color(0xFF1B5E20),
                          ),
                        ),
                        const SizedBox(width: 2),
                        const Icon(Icons.arrow_drop_down_rounded, size: 20, color: Color(0xFF2E7D32)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // 🗣️ / 👨‍⚕️ DKT Portalı & Girişi Butonu (Giriş ile Tam Entegre)
                ListenableBuilder(
                  listenable: _therapistState,
                  builder: (context, _) {
                    final isLoggedIn = _therapistState.isLoggedIn;
                    final name = _therapistState.therapistName;
                    final displayName = isLoggedIn
                        ? (name.startsWith('Uzm.') ? name : 'DKT: $name')
                        : 'DKT Girişi';

                    return InkWell(
                      onTap: () {
                        _sfx.playPopSound();
                        showDialog(
                          context: context,
                          builder: (_) => TherapistPortalDialog(
                            initialLoggedIn: isLoggedIn,
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: isLoggedIn ? const Color(0xFFE0F2FE) : const Color(0xFFF0F9FF),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isLoggedIn ? const Color(0xFF0284C7) : const Color(0xFF38BDF8),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isLoggedIn ? const Color(0x250284C7) : const Color(0x10000000),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(isLoggedIn ? '👨‍⚕️' : '🗣️', style: const TextStyle(fontSize: 15)),
                            const SizedBox(width: 5),
                            Text(
                              displayName,
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 11.5,
                                color: isLoggedIn ? const Color(0xFF0369A1) : const Color(0xFF0284C7),
                              ),
                            ),
                            if (isLoggedIn) ...[
                              const SizedBox(width: 6),
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF10B981),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () {
                    _sfx.playPopSound();
                    showDialog(
                      context: context,
                      builder: (_) => const StreakCalendarDialog(),
                    );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: _buildTopStat('🔥', '${_rewardState.streakDays}', const Color(0xFFFF9600)),
                ),
                const SizedBox(width: 6),
                InkWell(
                  onTap: () {
                    _sfx.playPopSound();
                    showDialog(
                      context: context,
                      builder: (_) => const GemsShopDialog(),
                    );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: _buildTopStat('💎', '${_rewardState.gems}', const Color(0xFF1CB0F6)),
                ),
                const SizedBox(width: 6),
                InkWell(
                  onTap: () {
                    _sfx.playPopSound();
                    showDialog(
                      context: context,
                      builder: (_) => const HeartsRefillDialog(),
                    );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: _buildTopStat('❤️', '${_rewardState.hearts}', const Color(0xFFFF4B4B)),
                ),
                const SizedBox(width: 6),
                // 🌌 Dünya Teması Seçici (Gündüz ☀️, Kozmos 🌌, Şeker 🍭, Okyanus 🌊)
                InkWell(
                  onTap: () {
                    final themes = ['day', 'night', 'candy', 'ocean'];
                    final currentIdx = themes.indexOf(_rewardState.worldTheme);
                    final nextTheme = themes[(currentIdx + 1) % themes.length];
                    _rewardState.setWorldTheme(nextTheme);
                    _sfx.playSuccessDing();

                    final names = {
                      'day': '☀️ Tropik Gündüz',
                      'night': '🌌 Gece Kozmosu',
                      'candy': '🍭 Şeker Dünyası',
                      'ocean': '🌊 Mavi Okyanus',
                    };

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('🎨 Dünya Teması Değişti: ${names[nextTheme]}!'),
                        duration: const Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: const Color(0xFF673AB7),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDE7F6),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF673AB7), width: 1.5),
                      boxShadow: const [
                        BoxShadow(color: Color(0x1A000000), offset: Offset(0, 2), blurRadius: 2),
                      ],
                    ),
                    child: Row(
                      children: [
                        Text(
                          _rewardState.worldTheme == 'night'
                              ? '🌌'
                              : (_rewardState.worldTheme == 'candy'
                                  ? '🍭'
                                  : (_rewardState.worldTheme == 'ocean' ? '🌊' : '☀️')),
                          style: const TextStyle(fontSize: 15),
                        ),
                        const SizedBox(width: 3),
                        const Text(
                          'Tema',
                          style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF512DA8), fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 6),
              // 🏆 Süper Lig Butonu
              InkWell(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => const LeaderboardLeagueSheet(),
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFFFD54F), width: 1.5),
                    boxShadow: const [
                      BoxShadow(color: Color(0x1A000000), offset: Offset(0, 2), blurRadius: 2),
                    ],
                  ),
                  child: Row(
                    children: const [
                      Text('🏆', style: TextStyle(fontSize: 15)),
                      SizedBox(width: 3),
                      Text(
                        'Lig',
                        style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFFF57F17), fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ),
              // 🔍 2 Dk Hızlı Tarama Testi Butonu
              InkWell(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => ArticulationScreeningDialog(
                      onSelectRecommendedSound: (recPhoneme) {
                        final idx = _stages.indexWhere((s) => s.phoneme.toLowerCase() == recPhoneme.toLowerCase());
                        if (idx != -1) {
                          _openPractice(_stages[idx], idx);
                        }
                      },
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF2196F3), width: 1.5),
                    boxShadow: const [
                      BoxShadow(color: Color(0x1A000000), offset: Offset(0, 2), blurRadius: 2),
                    ],
                  ),
                  child: Row(
                    children: const [
                      Text('🔍', style: TextStyle(fontSize: 15)),
                      SizedBox(width: 3),
                      Text(
                        'Tarama',
                        style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF1565C0), fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ),
              // 🎯 Günlük Görevler Butonu
              InkWell(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => const DailyQuestsDialog(),
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF4CAF50), width: 1.5),
                    boxShadow: const [
                      BoxShadow(color: Color(0x1A000000), offset: Offset(0, 2), blurRadius: 2),
                    ],
                  ),
                  child: Row(
                    children: const [
                      Text('🎯', style: TextStyle(fontSize: 15)),
                      SizedBox(width: 3),
                      Text(
                        'Görevler',
                        style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF2E7D32), fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ),
              // 🎡 Şans Çarkı Butonu
              InkWell(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => const LuckySpinDialog(),
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFFF9800), width: 1.5),
                    boxShadow: const [
                      BoxShadow(color: Color(0x1A000000), offset: Offset(0, 2), blurRadius: 2),
                    ],
                  ),
                  child: Row(
                    children: const [
                      Text('🎡', style: TextStyle(fontSize: 15)),
                      SizedBox(width: 3),
                      Text(
                        'Çark',
                        style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFFE65100), fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ),
              // 🚇 Subway Surfers Karakter Arenası
              InkWell(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => SubwayCharacterHubDialog(rewardState: _rewardState),
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF9800), Color(0xFFFF5722)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFFFD54F), width: 1.5),
                    boxShadow: const [
                      BoxShadow(color: Color(0x33FF9800), offset: Offset(0, 2), blurRadius: 4),
                    ],
                  ),
                  child: Row(
                    children: const [
                      Text('🛹', style: TextStyle(fontSize: 15)),
                      SizedBox(width: 4),
                      Text(
                        'Karakterler',
                        style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),
              // 🛍️ Gardırop & Dükkan
              InkWell(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => const AvatarWardrobeSheet(),
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3E5F5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF8E24AA), width: 1.5),
                    boxShadow: const [
                      BoxShadow(color: Color(0x1A000000), offset: Offset(0, 2), blurRadius: 2),
                    ],
                  ),
                  child: Row(
                    children: const [
                      Text('🛍️', style: TextStyle(fontSize: 15)),
                      SizedBox(width: 3),
                      Text(
                        'Gardırop',
                        style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF6A1B9A), fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ),
              // 📖 Çıkartma Albümü
              InkWell(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => const StickerBookSheet(),
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF9C4),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFFBC02D), width: 1.5),
                    boxShadow: const [
                      BoxShadow(color: Color(0x1A000000), offset: Offset(0, 2), blurRadius: 2),
                    ],
                  ),
                  child: Row(
                    children: const [
                      Text('📖', style: TextStyle(fontSize: 15)),
                      SizedBox(width: 3),
                      Text(
                        'Albüm',
                        style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFFF57F17), fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => const BadgesSheet(),
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD900),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(color: Color(0xFFCC9900), offset: Offset(0, 3)),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Text('🏆', style: TextStyle(fontSize: 18)),
                      const SizedBox(width: 4),
                      Text(
                        '${_rewardState.unlockedBadges.length}',
                        style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF5D4037)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
      ),
    );
  }

  Widget _buildTopStat(String icon, String count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 5),
          Text(
            count,
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: color),
          ),
        ],
      ),
    );
  }

  /// KULLANICININ İSTEDİĞİ SESİ KATEGORİLERLE SEÇEBİLECEĞİ SES SEÇİCİ ÇUBUĞU
  Widget _buildSoundSelectorBar() {
    final displayStages = _filteredStages;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(10, 6, 10, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık ve Şema Butonu
          Row(
            children: [
              const Text('🎯', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              const Text(
                'Çalışmak İstediğin Sesi Seç:',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Color(0xFF37474F)),
              ),
              const Spacer(),
              InkWell(
                onTap: _showBookTableOfContents,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF58CC02), width: 1.2),
                  ),
                  child: const Row(
                    children: [
                      Text('📑', style: TextStyle(fontSize: 13)),
                      SizedBox(width: 4),
                      Text(
                        'Tüm Sesler',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Kategori Filtre Butonları (Tek dokunuşla kategoriye geçiş)
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: kCategories.length,
              separatorBuilder: (_, _) => const SizedBox(width: 6),
              itemBuilder: (ctx, idx) {
                final cat = kCategories[idx];
                final isSelected = _selectedCategory == cat;
                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedCategory = cat;
                    });
                    if (_soundScrollController.hasClients) {
                      _soundScrollController.jumpTo(0.0);
                    }
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF58CC02) : Colors.grey[100],
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF45A202) : Colors.grey[300]!,
                        width: 1.2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        cat,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w900,
                          color: isSelected ? Colors.white : const Color(0xFF455A64),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          // Seçili Kategorideki Ses Kartları (Kaydırılabilir ve Tıklanabilir)
          Row(
            children: [
              // Sol Kaydır
              Material(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    if (!_soundScrollController.hasClients) return;
                    final target = (_soundScrollController.offset - 200.0).clamp(
                      0.0,
                      _soundScrollController.position.maxScrollExtent,
                    );
                    _soundScrollController.animateTo(
                      target,
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOutCubic,
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                    child: Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: Color(0xFF455A64)),
                  ),
                ),
              ),
              const SizedBox(width: 6),

              Expanded(
                child: SizedBox(
                  height: 52,
                  child: Scrollbar(
                    controller: _soundScrollController,
                    thumbVisibility: true,
                    child: ListView.separated(
                      controller: _soundScrollController,
                      physics: const BouncingScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      itemCount: displayStages.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (ctx, index) {
                        final stage = displayStages[index];
                        final globalIndex = _stages.indexWhere((s) => s.id == stage.id);
                        final bool isSelected = _selectedStageIndex == globalIndex;
                        final Color themeCol = Color(stage.colorHex);

                        return InkWell(
                          onTap: () {
                            setState(() => _selectedStageIndex = globalIndex);
                            _openPractice(stage, globalIndex);
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isSelected ? themeCol : themeCol.withAlpha(25),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: themeCol,
                                width: isSelected ? 2.5 : 1.5,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: themeCol.withAlpha(100),
                                        blurRadius: 6,
                                        offset: const Offset(0, 3),
                                      )
                                    ]
                                  : [],
                            ),
                            child: Row(
                              children: [
                                Text(stage.emoji, style: const TextStyle(fontSize: 18)),
                                const SizedBox(width: 6),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      stage.phoneme,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 15,
                                        color: isSelected ? Colors.white : themeCol,
                                      ),
                                    ),
                                    Text(
                                      stage.categoryTitle.split(' ')[0], // Çift, Diş, Yumuşak vs.
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        color: isSelected ? Colors.white70 : themeCol.withAlpha(180),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),

              // Sağ Kaydır
              Material(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    if (!_soundScrollController.hasClients) return;
                    final target = (_soundScrollController.offset + 200.0).clamp(
                      0.0,
                      _soundScrollController.position.maxScrollExtent,
                    );
                    _soundScrollController.animateTo(
                      target,
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOutCubic,
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                    child: Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Color(0xFF455A64)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMascotGreetingCard() {
    final activeStage = _stages[_selectedStageIndex];
    final currentQuote = _mascotQuotes[_mascotQuoteIndex % _mascotQuotes.length];

    return InkWell(
      onTap: () {
        setState(() {
          _mascotQuoteIndex++;
        });
        _sfx.playSuccessDing();
        _audioService.speakTurkish(
          'Harika gidiyorsun Küçük Ses Ustası! ${_mascotQuotes[_mascotQuoteIndex % _mascotQuotes.length]}',
          phoneme: activeStage.soundLetter,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🦉 Bilge Baykuş: "$currentQuote"'),
            duration: const Duration(seconds: 2),
            backgroundColor: const Color(0xFF2E7D32),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      borderRadius: BorderRadius.circular(24),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFF58CC02), width: 3),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF58CC02).withValues(alpha: 0.35),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Zıplayan Maskot ve Parıltı
            AnimatedBuilder(
              animation: _mascotBounce,
              builder: (ctx, child) {
                return Transform.translate(
                  offset: Offset(0, _mascotBounce.value),
                  child: child,
                );
              },
              child: Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  gradient: const RadialGradient(
                    colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF58CC02), width: 2),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
                  ],
                ),
                child: const Center(
                  child: Text('🦉', style: TextStyle(fontSize: 42)),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Bilge Baykuş Diyor ki: 💭',
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13.5, color: Color(0xFF2E7D32)),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('DOKUN 👆', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Color(0xFF2E7D32))),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    currentQuote,
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Color(0xFF1B5E20)),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Aktif macera: ${activeStage.phoneme} Sesi Dünyası 🌟',
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: Colors.black54),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF58CC02),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 2,
                      ),
                      icon: const Icon(Icons.play_arrow_rounded, size: 20),
                      label: Text(
                        'Kaldığın Yerden Başla: ${activeStage.phoneme} 🚀',
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
                      ),
                      onPressed: () {
                        _openPractice(activeStage, _selectedStageIndex);
                      },
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

  /// 3D Oyun Butonu
  Widget _buildGameNode(SoundStage stage, int index) {
    final Color nodeColor = Color(stage.colorHex);
    final Color bottomShadow = HSLColor.fromColor(nodeColor).withLightness(0.32).toColor();

    return GestureDetector(
      onTap: () {
        setState(() => _selectedStageIndex = index);
        _openPractice(stage, index);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: nodeColor, width: 2),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  stage.phoneme,
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: nodeColor),
                ),
                const SizedBox(width: 6),
                Text(
                  '⭐ ${stage.starsCollected}/15',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: Color(0xFFFF9600)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          SizedBox(
            width: 110,
            height: 110,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                // Aktif Seviye Etrafındaki Dönen/Nabız Atan Canlı Altın Halka
                if (index == _selectedStageIndex)
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (ctx, _) {
                      return Transform.scale(
                        scale: _pulseAnimation.value,
                        child: Container(
                          width: 102,
                          height: 102,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFFFD54F), width: 3.5),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFFB300).withValues(alpha: 0.6),
                                blurRadius: 16,
                                spreadRadius: 3,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                Positioned(
                  bottom: 0,
                  left: 12,
                  right: 12,
                  child: Container(
                    height: 80,
                    decoration: BoxDecoration(color: bottomShadow, shape: BoxShape.circle),
                  ),
                ),
                Positioned(
                  top: 4,
                  left: 12,
                  right: 12,
                  child: Container(
                    height: 80,
                    decoration: BoxDecoration(
                      color: nodeColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: nodeColor.withAlpha(120),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Center(
                      child: Text(stage.emoji, style: const TextStyle(fontSize: 42)),
                    ),
                  ),
                ),
                if (stage.isCompleted)
                  Positioned(
                    top: 0,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFD700),
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                      ),
                      child: const Text('👑', style: TextStyle(fontSize: 14)),
                    ),
                  ),
                // 🌟 AKTİF SEVİYEDE DURAN CANLI VE NEFES ALAN ETKİLEŞİMLİ AVATAR
                if (index == _selectedStageIndex)
                  Positioned(
                    top: -62,
                    child: ListenableBuilder(
                      listenable: _rewardState,
                      builder: (ctx, _) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            InteractiveAvatarWidget(
                              avatar: _rewardState.activeCharacterId,
                              hat: _rewardState.equippedHat,
                              glasses: _rewardState.equippedGlasses,
                              prop: _rewardState.equippedProp,
                              pet: _rewardState.equippedPet,
                              size: 54,
                              showPedestal: false,
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (_) => SubwayCharacterHubDialog(rewardState: _rewardState),
                                );
                              },
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF58CC02),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.white, width: 1.5),
                                boxShadow: const [
                                  BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
                                ],
                              ),
                              child: const Text(
                                'BURADASIN 🚩',
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 9.5,
                                  color: Colors.white,
                                  letterSpacing: 0.6,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 2),
          // Seviye Yıldızları (1-3 Yıldız)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (starIdx) {
              final earnedStars = _rewardState.getStageStars(stage.id);
              final hasStar = starIdx < earnedStars;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1),
                child: Text(
                  hasStar ? '⭐' : '☆',
                  style: TextStyle(
                    fontSize: 13,
                    color: hasStar ? const Color(0xFFFFB300) : Colors.black26,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 3),
          SizedBox(
            width: 140,
            child: Text(
              stage.categoryTitle,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF2E7D32)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectorLine({
    required double previousAlign,
    required double currentAlign,
  }) {
    return SizedBox(
      height: 38,
      width: double.infinity,
      child: CustomPaint(
        painter: _DuolingoPathPainter(
          startAlignment: previousAlign,
          endAlignment: currentAlign,
        ),
      ),
    );
  }

  Widget _buildTreasureChest() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE082),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFB300), width: 3),
        boxShadow: const [
          BoxShadow(color: Color(0xFFFF8F00), offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Text('🎁', style: TextStyle(fontSize: 28)),
          SizedBox(width: 8),
          Text(
            'Tebrikler! Mini Hazine Sandığı',
            style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF5D4037), fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _DuolingoPathPainter extends CustomPainter {
  final double startAlignment;
  final double endAlignment;

  _DuolingoPathPainter({required this.startAlignment, required this.endAlignment});

  @override
  void paint(Canvas canvas, Size size) {
    final startX = size.width / 2 + (startAlignment * size.width * 0.35);
    final endX = size.width / 2 + (endAlignment * size.width * 0.35);

    final path = Path();
    path.moveTo(startX, 0);
    path.cubicTo(startX, size.height * 0.5, endX, size.height * 0.5, endX, size.height);

    final paintShadow = Paint()
      ..color = const Color(0xFF81C784)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    final paintLine = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, paintShadow);
    canvas.drawPath(path, paintLine);
  }

  @override
  bool shouldRepaint(covariant _DuolingoPathPainter oldDelegate) =>
      oldDelegate.startAlignment != startAlignment || oldDelegate.endAlignment != endAlignment;
}
