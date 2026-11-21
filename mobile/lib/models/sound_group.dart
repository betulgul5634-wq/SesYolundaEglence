class SingleSoundLevel {
  final List<String> syllables; // Hece tabloları (Kitap sf. 12-13, 20-21 vb.)
  final List<String> wordsBeginning; // Kelime Başta
  final List<String> wordsMiddle; // Kelime Ortada
  final List<String> wordsEnding; // Kelime Sonda
  final List<String> phrases; // Tüm Sözceler
  final List<String> sentences; // Tüm Cümleler
  final String storyTitle; // Hikaye Başlığı
  final String storyContent; // Hikaye Metni

  // Kitaptaki kesin klinik bölümler (A - H):
  final List<String> words1Syllable; // A. Tek Heceli Kelimeler
  final List<String> words2Syllables; // B. İki Heceli Kelimeler
  final List<String> words3Syllables; // C. Üç Heceli Kelimeler
  final List<String> phrasesBeginning; // D. Sesi ile Başlayan Sözceler
  final List<String> phrasesContaining; // E. Sesi İçeren Sözceler
  final List<String> sentencesBeginning; // F. Sesi ile Başlayan Cümleler
  final List<String> sentencesContaining; // G. Sesi İçeren Cümleler

  const SingleSoundLevel({
    required this.syllables,
    required this.wordsBeginning,
    required this.wordsMiddle,
    required this.wordsEnding,
    required this.phrases,
    required this.sentences,
    required this.storyTitle,
    required this.storyContent,
    this.words1Syllable = const [],
    this.words2Syllables = const [],
    this.words3Syllables = const [],
    this.phrasesBeginning = const [],
    this.phrasesContaining = const [],
    this.sentencesBeginning = const [],
    this.sentencesContaining = const [],
  });
}

class SoundStage {
  final String id; // örn: "sound_p", "sound_b"
  final String phoneme; // örn: "/p/"
  final String soundLetter; // "P"
  final String categoryTitle; // örn: "Çift Dudak Patlamalı - Durak Sesler"
  final String mainCategory; // örn: "Patlamalı - Durak Sesler", "Sürtünmeli Sesler" vb.
  final String emoji;
  final int colorHex;
  final String articulationHint; // Ağız/dil pozisyonu tarifi
  final SingleSoundLevel content;
  final int unlockedLevelIndex; // 0: Heceler, 1: Kelimeler, 2: Sözceler, 3: Cümleler, 4: Hikaye, 5: Tamamlandı
  final int starsCollected;
  final bool isCompleted;

  const SoundStage({
    required this.id,
    required this.phoneme,
    required this.soundLetter,
    required this.categoryTitle,
    this.mainCategory = 'Patlamalı - Durak Sesler',
    required this.emoji,
    required this.colorHex,
    required this.articulationHint,
    required this.content,
    this.unlockedLevelIndex = 0,
    this.starsCollected = 0,
    this.isCompleted = false,
  });

  SoundStage copyWith({
    String? id,
    String? phoneme,
    String? soundLetter,
    String? categoryTitle,
    String? mainCategory,
    String? emoji,
    int? colorHex,
    String? articulationHint,
    SingleSoundLevel? content,
    int? unlockedLevelIndex,
    int? starsCollected,
    bool? isCompleted,
  }) {
    return SoundStage(
      id: id ?? this.id,
      phoneme: phoneme ?? this.phoneme,
      soundLetter: soundLetter ?? this.soundLetter,
      categoryTitle: categoryTitle ?? this.categoryTitle,
      mainCategory: mainCategory ?? this.mainCategory,
      emoji: emoji ?? this.emoji,
      colorHex: colorHex ?? this.colorHex,
      articulationHint: articulationHint ?? this.articulationHint,
      content: content ?? this.content,
      unlockedLevelIndex: unlockedLevelIndex ?? this.unlockedLevelIndex,
      starsCollected: starsCollected ?? this.starsCollected,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
