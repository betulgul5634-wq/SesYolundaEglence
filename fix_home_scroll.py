with open('mobile/lib/screens/home_screen.dart', encoding='utf-8') as f:
    text = f.read()

# 1. Clean up state variables in _HomeScreenState
old_decl = """  int _selectedStageIndex = 0;
  String _selectedCategoryFilter = 'Tümü';

  static const List<String> kCategories = [
    'Tümü',
    'Patlamalı - Durak Sesler',
    'Sürtünmeli Sesler',
    'Durak Sürtünmeli Sesler',
    'Genizsi Sesler',
    'Akıcı Sesler',
    'Daralmalı Sesler',
  ];"""

new_decl = """  int _selectedStageIndex = 0;
  final ScrollController _soundScrollController = ScrollController();"""

assert old_decl in text, "old_decl not found"
text = text.replace(old_decl, new_decl, 1)

# 2. Add controller disposal
old_dispose = """  @override
  void dispose() {
    _mascotBounceController.dispose();
    super.dispose();
  }"""

new_dispose = """  @override
  void dispose() {
    _soundScrollController.dispose();
    _mascotBounceController.dispose();
    super.dispose();
  }"""

assert old_dispose in text, "old_dispose not found"
text = text.replace(old_dispose, new_dispose, 1)

# 3. Replace _buildSoundSelectorBar
old_selector_start = "  /// KULLANICININ İSTEDİĞİ SESİ SERBESTÇE SEÇEBİLECEĞİ VE KATEGORİLERE GÖRE FİLTRELEYEBİLECEĞİ SEÇİM ÇUBUĞU"
old_selector_end = "  Widget _buildMascotGreetingCard() {"

start_idx = text.find(old_selector_start)
end_idx = text.find(old_selector_end)

assert start_idx != -1 and end_idx != -1, "selector bounds not found"

new_selector = """  /// KULLANICININ İSTEDİĞİ SESİ SERBESTÇE SEÇEBİLECEĞİ VE KOLAYCA KAYDIRABİLECEĞİ SEÇİM ÇUBUĞU
  Widget _buildSoundSelectorBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(10, 6, 10, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Text('🎯', style: TextStyle(fontSize: 16)),
              SizedBox(width: 6),
              Text(
                'Çalışmak İstediğin Sesi Seç:',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Color(0xFF37474F)),
              ),
              Spacer(),
              Text(
                '20 Ses (Sağa Kaydır 👉)',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: Colors.black45),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              // Sol Kaydırma Butonu
              Material(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    if (!_soundScrollController.hasClients) return;
                    final target = (_soundScrollController.offset - 180.0).clamp(
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
              // Yatay Kaydırılabilir Ses Listesi (Mouse Drag, Dokunma ve Ok Butonları ile Kaydırılabilir)
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: Scrollbar(
                    controller: _soundScrollController,
                    thumbVisibility: true,
                    child: ListView.separated(
                      controller: _soundScrollController,
                      physics: const BouncingScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      itemCount: _stages.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (ctx, index) {
                        final stage = _stages[index];
                        final bool isSelected = _selectedStageIndex == index;
                        final Color themeCol = Color(stage.colorHex);

                        return InkWell(
                          onTap: () {
                            setState(() => _selectedStageIndex = index);
                            _openPractice(stage, index);
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
                                Text(
                                  stage.phoneme,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 16,
                                    color: isSelected ? Colors.white : themeCol,
                                  ),
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
              // Sağ Kaydırma Butonu
              Material(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    if (!_soundScrollController.hasClients) return;
                    final target = (_soundScrollController.offset + 180.0).clamp(
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

"""

text = text[:start_idx] + new_selector + text[end_idx:]

with open('mobile/lib/screens/home_screen.dart', 'w', encoding='utf-8') as f:
    f.write(text)

print("Updated home_screen.dart with smooth scroll and removed içindekiler!")
