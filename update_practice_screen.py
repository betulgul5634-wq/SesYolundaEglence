with open('mobile/lib/screens/sound_practice_screen.dart', encoding='utf-8') as f:
    text = f.read()

# 1. Add state variables and helper functions in _SoundPracticeScreenState
old_state_decl = """  final AudioSpeechService _audioService = AudioSpeechService();
  bool _micTested = false;"""

new_state_decl = """  final AudioSpeechService _audioService = AudioSpeechService();
  bool _micTested = false;

  int _selectedWordSyllableFilter = 0; // 0: Tümü, 1: A. Tek Heceli, 2: B. İki Heceli, 3: C. Üç Heceli
  int _selectedPhraseFilter = 0; // 0: Tümü, 1: D. Başlayan, 2: E. İçeren
  int _selectedSentenceFilter = 0; // 0: Tümü, 1: F. Başlayan, 2: G. İçeren

  int _countSyllables(String word) {
    const vowels = 'aeıioöuüAEIİOÖUÜ';
    int count = 0;
    for (int i = 0; i < word.length; i++) {
      if (vowels.contains(word[i])) count++;
    }
    return count == 0 ? 1 : count;
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onSelected,
    required Color primaryColor,
  }) {
    return InkWell(
      onTap: onSelected,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : primaryColor.withAlpha(20),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? primaryColor : primaryColor.withAlpha(70),
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: isSelected ? Colors.white : const Color(0xFF37474F),
          ),
        ),
      ),
    );
  }"""

assert old_state_decl in text, "old_state_decl not found"
text = text.replace(old_state_decl, new_state_decl, 1)

# 2. Update TabBarView to use _buildPhrasesTab and _buildSentencesTab
old_tab_view = """            _buildSyllablesGrid(stage.content.syllables, primaryColor),
            _buildWordsPositionalView(stage.content, primaryColor),
            _buildSimpleList(stage.content.phrases, 'Sözceler', primaryColor),
            _buildSimpleList(stage.content.sentences, 'Cümleler', primaryColor),
            _buildStoryView(stage.content.storyTitle, stage.content.storyContent, primaryColor),"""

new_tab_view = """            _buildSyllablesGrid(stage.content.syllables, primaryColor),
            _buildWordsPositionalView(stage.content, primaryColor),
            _buildPhrasesTab(stage.content, primaryColor),
            _buildSentencesTab(stage.content, primaryColor),
            _buildStoryView(stage.content.storyTitle, stage.content.storyContent, primaryColor),"""

assert old_tab_view in text, "old_tab_view not found"
text = text.replace(old_tab_view, new_tab_view, 1)

# 3. Replace _buildWordsPositionalView and _buildWordListView, add _buildPhrasesTab and _buildSentencesTab
old_words_view_start = """  /// 2. Basamak: Kelimeler
  Widget _buildWordsPositionalView(SingleSoundLevel content, Color primaryColor) {"""

old_words_view_end = """  /// 3. ve 4. Basamak: Sözceler ve Cümleler"""

words_start_idx = text.find(old_words_view_start)
words_end_idx = text.find(old_words_view_end)

assert words_start_idx != -1 and words_end_idx != -1, "words section not found"

new_words_and_tabs_block = """  /// 2. Basamak: Kelimeler (Kitap A, B, C Bölümlendirmesi)
  Widget _buildWordsPositionalView(SingleSoundLevel content, Color primaryColor) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          // ── KİTAP BÖLÜM FİLTRESİ: A (Tek Heceli), B (İki Heceli), C (Üç Heceli) ──
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip(
                    label: '⭐ Tümü',
                    isSelected: _selectedWordSyllableFilter == 0,
                    onSelected: () => setState(() => _selectedWordSyllableFilter = 0),
                    primaryColor: primaryColor,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    label: '🅰️ A. Tek Heceli Kelimeler',
                    isSelected: _selectedWordSyllableFilter == 1,
                    onSelected: () => setState(() => _selectedWordSyllableFilter = 1),
                    primaryColor: primaryColor,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    label: '🅱️ B. İki Heceli Kelimeler',
                    isSelected: _selectedWordSyllableFilter == 2,
                    onSelected: () => setState(() => _selectedWordSyllableFilter = 2),
                    primaryColor: primaryColor,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    label: '🅲️ C. Üç Heceli Kelimeler',
                    isSelected: _selectedWordSyllableFilter == 3,
                    onSelected: () => setState(() => _selectedWordSyllableFilter = 3),
                    primaryColor: primaryColor,
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),

          // ── KONUM SEKMELERİ: Başta / Ortada / Sonda ──
          Container(
            color: Colors.white,
            child: TabBar(
              indicatorColor: primaryColor,
              indicatorWeight: 3,
              labelColor: primaryColor,
              unselectedLabelColor: Colors.black54,
              labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
              tabs: const [
                Tab(text: 'Başta Pozisyon'),
                Tab(text: 'Ortada Pozisyon'),
                Tab(text: 'Sonda Pozisyon'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildWordListView(content.wordsBeginning, 'Başta', primaryColor),
                _buildWordListView(content.wordsMiddle, 'Ortada', primaryColor),
                _buildWordListView(content.wordsEnding, 'Sonda', primaryColor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWordListView(List<String> words, String position, Color primaryColor) {
    if (words.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue.withAlpha(15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.blue.withAlpha(60), width: 1.5),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.menu_book_rounded, color: Color(0xFF0288D1), size: 48),
                const SizedBox(height: 12),
                const Text(
                  'Klinik Sesbilgisi Kuralı (Ötümsüzleşme)',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF01579B)),
                ),
                const SizedBox(height: 10),
                Text(
                  'Türkçe fonoloji kuralları gereği ötümlü patlamalı ünsüzler (örneğin /b/ sesi) kelime sonunda yer almaz; ötümsüzleşerek /p/ sesine dönüşür (Örn: kitap, sebep, kebap).\\n\\nBu nedenle klinik artikülasyon kitabında da /b/ sesi için $position pozisyonu boş bırakılmıştır.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, height: 1.6, fontWeight: FontWeight.w600, color: Color(0xFF37474F)),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Hece filtrelemesi (Kitap A, B, C Bölümleri)
    final filteredWords = words.where((w) {
      if (_selectedWordSyllableFilter == 0) return true;
      final sylCount = _countSyllables(w);
      if (_selectedWordSyllableFilter == 1) return sylCount == 1;
      if (_selectedWordSyllableFilter == 2) return sylCount == 2;
      return sylCount >= 3;
    }).toList();

    if (filteredWords.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            'Bu konumda (${position}) seçili hece grubuna ait kelime bulunmamaktadır.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.grey),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: filteredWords.length + 1,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (ctx, i) {
        if (i == filteredWords.length) {
          return _buildStageEndGameBanner(2, 'Kelimeler', primaryColor);
        }
        final word = filteredWords[i];
        final sylCount = _countSyllables(word);
        final sylLabel = sylCount == 1 ? 'A. 1 Heceli' : (sylCount == 2 ? 'B. 2 Heceli' : 'C. 3+ Heceli');

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.grey[200]!, width: 1.5),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            leading: CircleAvatar(
              backgroundColor: primaryColor.withAlpha(25),
              child: Text(
                '${i + 1}',
                style: TextStyle(fontWeight: FontWeight.w900, color: primaryColor),
              ),
            ),
            title: Text(
              word,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF263238)),
            ),
            subtitle: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: primaryColor.withAlpha(20),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    sylLabel,
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: primaryColor),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'Konum: $position',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey[600]),
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.volume_up_rounded, color: Color(0xFF2196F3), size: 24),
                  tooltip: 'Yalnızca Dinle (Kadın Sesi)',
                  onPressed: () => _onlyListen(word),
                ),
                IconButton(
                  icon: const Icon(Icons.mic_rounded, color: Color(0xFF58CC02), size: 28),
                  tooltip: 'Dinle ve Söyle',
                  onPressed: () => _listenThenSpeak(word),
                ),
              ],
            ),
            onTap: () => _listenThenSpeak(word),
          ),
        );
      },
    );
  }

  /// 3. Basamak: Sözceler (Kitap D ve E Bölümlendirmesi)
  Widget _buildPhrasesTab(SingleSoundLevel content, Color primaryColor) {
    List<String> displayList;
    if (_selectedPhraseFilter == 1) {
      displayList = content.phrasesBeginning.isNotEmpty
          ? content.phrasesBeginning
          : content.phrases.sublist(0, (content.phrases.length / 2).floor());
    } else if (_selectedPhraseFilter == 2) {
      displayList = content.phrasesContaining.isNotEmpty
          ? content.phrasesContaining
          : content.phrases.sublist((content.phrases.length / 2).floor());
    } else {
      displayList = content.phrases;
    }

    final begCount = content.phrasesBeginning.isNotEmpty
        ? content.phrasesBeginning.length
        : (content.phrases.length / 2).floor();
    final contCount = content.phrasesContaining.isNotEmpty
        ? content.phrasesContaining.length
        : content.phrases.length - begCount;

    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  label: '💬 Tümü (${content.phrases.length})',
                  isSelected: _selectedPhraseFilter == 0,
                  onSelected: () => setState(() => _selectedPhraseFilter = 0),
                  primaryColor: primaryColor,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: '🚀 D. Sesi İle Başlayan Sözceler ($begCount)',
                  isSelected: _selectedPhraseFilter == 1,
                  onSelected: () => setState(() => _selectedPhraseFilter = 1),
                  primaryColor: primaryColor,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: '🔍 E. Sesi İçeren Sözceler ($contCount)',
                  isSelected: _selectedPhraseFilter == 2,
                  onSelected: () => setState(() => _selectedPhraseFilter = 2),
                  primaryColor: primaryColor,
                ),
              ],
            ),
          ),
        ),
        const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
        Expanded(child: _buildSimpleList(displayList, 'Sözceler', primaryColor)),
      ],
    );
  }

  /// 4. Basamak: Cümleler (Kitap F ve G Bölümlendirmesi)
  Widget _buildSentencesTab(SingleSoundLevel content, Color primaryColor) {
    List<String> displayList;
    if (_selectedSentenceFilter == 1) {
      displayList = content.sentencesBeginning.isNotEmpty
          ? content.sentencesBeginning
          : content.sentences.sublist(0, (content.sentences.length / 2).floor());
    } else if (_selectedSentenceFilter == 2) {
      displayList = content.sentencesContaining.isNotEmpty
          ? content.sentencesContaining
          : content.sentences.sublist((content.sentences.length / 2).floor());
    } else {
      displayList = content.sentences;
    }

    final begCount = content.sentencesBeginning.isNotEmpty
        ? content.sentencesBeginning.length
        : (content.sentences.length / 2).floor();
    final contCount = content.sentencesContaining.isNotEmpty
        ? content.sentencesContaining.length
        : content.sentences.length - begCount;

    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  label: '📝 Tümü (${content.sentences.length})',
                  isSelected: _selectedSentenceFilter == 0,
                  onSelected: () => setState(() => _selectedSentenceFilter = 0),
                  primaryColor: primaryColor,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: '🚀 F. Sesi İle Başlayan Cümleler ($begCount)',
                  isSelected: _selectedSentenceFilter == 1,
                  onSelected: () => setState(() => _selectedSentenceFilter = 1),
                  primaryColor: primaryColor,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: '🔍 G. Sesi İçeren Cümleler ($contCount)',
                  isSelected: _selectedSentenceFilter == 2,
                  onSelected: () => setState(() => _selectedSentenceFilter = 2),
                  primaryColor: primaryColor,
                ),
              ],
            ),
          ),
        ),
        const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
        Expanded(child: _buildSimpleList(displayList, 'Cümleler', primaryColor)),
      ],
    );
  }

"""

text = text[:words_start_idx] + new_words_and_tabs_block + text[words_end_idx:]

# 4. In _buildStoryView, add H. Sesi İçeren Hikaye badge
old_story_row = """            Row(
              children: [
                const Text('📖', style: TextStyle(fontSize: 30)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,"""

new_story_row = """            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: primaryColor.withAlpha(25),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'H. SESİ İÇEREN TERAPİ HİKAYESİ',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: primaryColor),
              ),
            ),
            Row(
              children: [
                const Text('📖', style: TextStyle(fontSize: 30)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,"""

assert old_story_row in text, "old_story_row not found"
text = text.replace(old_story_row, new_story_row, 1)

with open('mobile/lib/screens/sound_practice_screen.dart', 'w', encoding='utf-8') as f:
    f.write(text)

print("Updated mobile/lib/screens/sound_practice_screen.dart successfully!")
