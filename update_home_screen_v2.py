import re

code = '''import 'package:flutter/material.dart';
import '../data/sound_groups_data.dart';
import '../models/sound_group.dart';
import '../state/reward_state.dart';
import '../widgets/subway_surfers_widgets.dart';
import 'sound_practice_screen.dart';

/// Anasayfa — Duolingo Tarzı 3D Macera Haritası & Kitap Bölümlendirmeli Ses Seçimi
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late List<SoundStage> _stages;
  final RewardState _rewardState = RewardState();
  late AnimationController _mascotBounceController;
  late Animation<double> _mascotBounce;
  int _selectedStageIndex = 0;
  final ScrollController _soundScrollController = ScrollController();

  String _selectedCategory = 'Tümü (20)';

  static const List<String> kCategories = [
    'Tümü (20)',
    'Patlamalı - Durak (6)',
    'Sürtünmeli (7)',
    'Durak Sürtünmeli (2)',
    'Genizsi (2)',
    'Akıcı (2)',
    'Daralmalı (1)',
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
  }

  @override
  void dispose() {
    _soundScrollController.dispose();
    _mascotBounceController.dispose();
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
    if (_selectedCategory.startsWith('Tümü')) {
      return _stages;
    }
    final prefix = _selectedCategory.split(' ')[0]; // 'Patlamalı', 'Sürtünmeli', vb.
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

            // 3. Duolingo Tarzı Canlı Oyun Haritası (Kitap Bölümleriyle Ayrılmış)
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9), Color(0xFFA5D6A7)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
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
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2E7D32), width: 2.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x332E7D32),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('📚', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Text(
                'BÖLÜM $sectionNumber',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF58CC02),
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1B5E20),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: ListenableBuilder(
        listenable: _rewardState,
        builder: (context, _) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTopStat('🔥', '${_rewardState.streakDays}', const Color(0xFFFF9600)),
              _buildTopStat('💎', '${_rewardState.gems}', const Color(0xFF1CB0F6)),
              _buildTopStat('❤️', '${_rewardState.hearts}', const Color(0xFFFF4B4B)),
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
            height: 32,
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
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF58CC02) : Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF45A202) : Colors.grey[300]!,
                        width: 1.2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        cat,
                        style: TextStyle(
                          fontSize: 11,
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
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF58CC02), width: 3),
        boxShadow: const [
          BoxShadow(color: Color(0xFF58CC02), offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _mascotBounce,
            builder: (ctx, child) {
              return Transform.translate(
                offset: Offset(0, _mascotBounce.value),
                child: child,
              );
            },
            child: Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: Color(0xFFE8F5E9),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('🦉', style: TextStyle(fontSize: 40)),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Merhaba Küçük Ses Ustası! 👋',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Color(0xFF2E7D32)),
                ),
                const SizedBox(height: 3),
                Text(
                  'İstediğin sesi yukarıdaki kategorilerden seçebilirsin! Şu an ${activeStage.phoneme} sesindeyiz.',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
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
            width: 86,
            height: 94,
            child: Stack(
              children: [
                Positioned(
                  bottom: 0,
                  left: 3,
                  right: 3,
                  child: Container(
                    height: 80,
                    decoration: BoxDecoration(color: bottomShadow, shape: BoxShape.circle),
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 3,
                  right: 3,
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
                    top: -4,
                    right: 4,
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
              ],
            ),
          ),
          const SizedBox(height: 4),
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
'''

with open('mobile/lib/screens/home_screen.dart', 'w', encoding='utf-8') as f:
    f.write(code)

print('home_screen.dart successfully rewritten!')
