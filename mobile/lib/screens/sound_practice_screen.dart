import 'dart:async';
import 'package:flutter/material.dart';
import '../models/sound_group.dart';
import '../models/reward_state.dart';
import '../widgets/mouth_anatomy_widget.dart';
import '../widgets/sound_mini_game.dart';
import '../widgets/speech_mirror_dialog.dart';
import '../widgets/therapy_certificate_dialog.dart';
import '../widgets/bouncy_3d_card.dart';
import '../widgets/animated_speech_mascot.dart';
import '../widgets/live_soundwave_visualizer.dart';
import '../widgets/balloon_pop_game_dialog.dart';
import '../widgets/flash_practice_dialog.dart';
import '../widgets/voice_postcard_dialog.dart';
import '../widgets/practice_session_timer_dialog.dart';
import '../widgets/voice_lab_tuner_dialog.dart';
import '../widgets/mystery_puzzle_dialog.dart';
import '../widgets/printable_worksheet_dialog.dart';
import '../widgets/memory_match_game_dialog.dart';
import '../widgets/minimal_pairs_dialog.dart';
import '../utils/word_pictogram_helper.dart';
import '../widgets/subway_surfers_unlock_dialog.dart';
import '../widgets/avatar_showcase_widget.dart';
import '../widgets/hearts_refill_dialog.dart';
import '../widgets/gems_shop_dialog.dart';
import '../services/audio_speech_service.dart';

class SoundPracticeScreen extends StatefulWidget {
  final SoundStage stage;
  final int stageIndex;

  const SoundPracticeScreen({
    super.key,
    required this.stage,
    required this.stageIndex,
  });

  @override
  State<SoundPracticeScreen> createState() => _SoundPracticeScreenState();
}

class _SoundPracticeScreenState extends State<SoundPracticeScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final RewardState _rewardState = RewardState();
  final AudioSpeechService _audioService = AudioSpeechService();
  bool _micTested = false;
  bool _isTurtlePacingMode = false; // 🐢 Kaplumbağa Yavaş & Tane Tane Artikülasyon Modu
  String? _currentlySpeakingWord; // Canlı ses-görsel senkronizasyonu için anlık konuşulan kelime

  int _selectedWordSyllableFilter = 0; // 0: Tümü, 1: A. Tek Heceli, 2: B. İki Heceli, 3: C. Üç Heceli
  int _selectedWordPack = 1; // 1: 1. Paket (1-8), 2: 2. Paket (9-16), 0: Tümü
  final Set<String> _completedWordsInSession = {};
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
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 5,
      vsync: this,
      initialIndex: 0, // Her zaman 1. basamak olan '1. Heceler' ile başlar!
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _testMicrophone() async {
    final granted = await _audioService.requestMicrophonePermission();
    setState(() => _micTested = granted);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(granted
            ? '🎤 Harika! Mikrofon hazır ve dinliyor.'
            : '⚠️ Mikrofon izni onaylanmadı! Lütfen Chrome adres çubuğundaki kilit simgesinden izin verin.'),
        backgroundColor: granted ? const Color(0xFF2E7D32) : const Color(0xFFD32F2F),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _onlyListen(String text, {String mode = 'natural'}) {
    setState(() => _currentlySpeakingWord = text);
    final effectiveMode = _isTurtlePacingMode ? 'syllable' : mode;
    _audioService.speakTurkish(
      text,
      phoneme: widget.stage.soundLetter,
      mode: effectiveMode,
      withInstruction: mode == 'explain',
      onAudioCompleted: () {
        if (mounted) setState(() => _currentlySpeakingWord = null);
      },
    );
  }

  void _listenThenSpeak(String targetText) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (modalCtx) {
        return _SpeechInteractiveSheet(
          targetText: targetText,
          phoneme: widget.stage.phoneme,
          soundLetter: widget.stage.soundLetter,
          audioService: _audioService,
          isTurtleMode: _isTurtlePacingMode,
          onComplete: (SpeechEvaluationResult result) {
            Navigator.pop(modalCtx);
            _handleEvaluationResult(result);
          },
        );
      },
    );
  }

  void _openMiniGame({int stageLevel = 1, String stageName = 'Heceler'}) {
    // Aşama seviyesine göre hedef kelimeler ve yanıltıcılar
    List<String> targets = widget.stage.content.wordsBeginning;
    if (stageLevel == 1) {
      targets = widget.stage.content.syllables;
    } else if (stageLevel == 3) {
      targets = widget.stage.content.phrases;
    } else if (stageLevel == 4) {
      targets = widget.stage.content.wordsMiddle.isNotEmpty 
          ? widget.stage.content.wordsMiddle 
          : widget.stage.content.wordsBeginning;
    }

    final cleanP = widget.stage.soundLetter.toLowerCase();
    const candidateDistractors = [
      'Güneş', 'Kedi', 'Köpek', 'Elma', 'Ağaç', 'Çiçek', 'Tavşan',
      'Kuş', 'Gözlük', 'Saat', 'Kalem', 'Kitap', 'Masa', 'Sandalye',
      'Balık', 'Ev', 'Araba', 'Gemi', 'Uçak', 'Top', 'Ayı', 'Pasta',
      'Tava', 'Bebek', 'Dondurma', 'Yıldız', 'Limon', 'Portakal'
    ];
    final distractorList = candidateDistractors
        .where((w) => !w.toLowerCase().contains(cleanP))
        .take(8)
        .toList();
    if (distractorList.length < 6) {
      distractorList.addAll(const ['Mavi', 'Sarı', 'Yeşil', 'Mor', 'Beyaz']);
    }

    showDialog(
      context: context,
      builder: (ctx) => SoundMiniGameDialog(
        phoneme: widget.stage.soundLetter,
        soundTitle: widget.stage.phoneme,
        targetWords: targets,
        distractorWords: distractorList,
        stageLevel: stageLevel,
        stageName: stageName,
        onGameWon: () {
          _rewardState.recordPracticeToday();
          _rewardState.recordQuestMiniGame();
          final char = SubwaySurfersUnlockDialog.getCharacterForLevel(stageLevel);
          _rewardState.unlockCharacter(char.id);
          _rewardState.addReward(earnedStars: 2 + stageLevel, earnedXp: 40 * stageLevel, earnedGems: 15 * stageLevel);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('🎉 Tebrikler! ${char.name} KİLİDİ AÇILDI! Vitrinde seni bekliyor! ⭐'),
              backgroundColor: const Color(0xFF2E7D32),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ),
    );
  }

  List<String> _resolveTargetWordsForGames() {
    List<String> targets = List.from(widget.stage.content.wordsBeginning);
    if (targets.isEmpty) targets = List.from(widget.stage.content.wordsMiddle);
    if (targets.isEmpty) targets = List.from(widget.stage.content.wordsEnding);
    if (targets.isEmpty) targets = List.from(widget.stage.content.syllables);
    return targets;
  }

  void _openMemoryGame() {
    final targets = _resolveTargetWordsForGames();

    showDialog(
      context: context,
      builder: (ctx) => MemoryMatchGameDialog(
        phoneme: widget.stage.soundLetter,
        soundTitle: widget.stage.phoneme,
        targetWords: targets,
        onGameWon: () {
          _rewardState.recordPracticeToday();
          _rewardState.recordQuestMiniGame();
          _rewardState.addReward(earnedStars: 4, earnedXp: 40, earnedGems: 20);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🎉 Tebrikler! Tüm hafıza kartlarını eşleştirdin! +4 ⭐ +20 💎'),
              backgroundColor: Color(0xFF2E7D32),
            ),
          );
        },
      ),
    );
  }

  void _openMinimalPairs() {
    showDialog(
      context: context,
      builder: (ctx) => MinimalPairsDialog(
        phoneme: widget.stage.soundLetter,
      ),
    );
  }

  void _openBalloonGame() {
    final targets = _resolveTargetWordsForGames();

    showDialog(
      context: context,
      builder: (ctx) => BalloonPopGameDialog(
        phoneme: widget.stage.soundLetter,
        soundTitle: widget.stage.phoneme,
        targetWords: targets,
        onGameWon: () {
          _rewardState.recordPracticeToday();
          _rewardState.recordQuestMiniGame();
          _rewardState.addReward(earnedStars: 4, earnedXp: 40, earnedGems: 20);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🎉 Tebrikler! Hedef sesli balonları patlattın! +4 ⭐ +20 💎'),
              backgroundColor: Color(0xFF2E7D32),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ),
    );
  }

  void _openFlashPractice() {
    final targets = _resolveTargetWordsForGames();

    showDialog(
      context: context,
      builder: (ctx) => FlashPracticeDialog(
        phoneme: widget.stage.soundLetter,
        words: targets,
      ),
    );
  }

  void _openVoicePostcard() {
    showDialog(
      context: context,
      builder: (ctx) => VoicePostcardDialog(
        phoneme: widget.stage.soundLetter,
      ),
    );
  }

  void _openSessionTimer() {
    showDialog(
      context: context,
      builder: (ctx) => const PracticeSessionTimerDialog(),
    );
  }

  void _openVoiceLab() {
    showDialog(
      context: context,
      builder: (ctx) => VoiceLabPitchTunerDialog(
        phoneme: widget.stage.soundLetter,
        soundTitle: widget.stage.phoneme,
      ),
    );
  }

  void _openMysteryPuzzle() {
    List<String> targets = widget.stage.content.wordsBeginning;
    if (targets.isEmpty) targets = widget.stage.content.syllables;

    showDialog(
      context: context,
      builder: (ctx) => PhonemeMysteryPuzzleDialog(
        phoneme: widget.stage.soundLetter,
        soundTitle: widget.stage.phoneme,
        words: targets,
      ),
    );
  }

  void _openPrintableWorksheet() {
    List<String> targets = widget.stage.content.wordsBeginning;
    if (targets.isEmpty) targets = widget.stage.content.syllables;

    showDialog(
      context: context,
      builder: (ctx) => PrintableWorksheetDialog(
        phoneme: widget.stage.soundLetter,
        soundTitle: widget.stage.phoneme,
        words: targets,
      ),
    );
  }

  void _handleEvaluationResult(SpeechEvaluationResult result) {
    final String activePos = _tabController.index == 0
        ? 'Hece'
        : (_tabController.index == 1 ? 'Kelime' : (_tabController.index == 2 ? 'Sözce' : 'Cümle'));
    _rewardState.recordAttempt(
      phoneme: widget.stage.soundLetter,
      position: activePos,
      isCorrect: result.isMatched,
    );
    if (result.isMatched) {
      setState(() {
        _completedWordsInSession.add(result.targetText.trim());
      });
    }
    if (result.isMatched) {
      _rewardState.unlockSticker(result.targetText);
      _rewardState.recordPracticeToday();
      _rewardState.recordQuestWord();
      _rewardState.gainHeart(1);
      _rewardState.setStageStars(widget.stage.id, (_rewardState.getStageStars(widget.stage.id) + 1).clamp(1, 3));
      _rewardState.addReward(earnedStars: 3, earnedXp: 50, earnedGems: 25);

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => _CelebrationConfettiDialog(
          result: result,
          onContinue: () => Navigator.pop(ctx),
        ),
      );
    } else {
      _rewardState.loseHeart();
      // Hatalı sesletim: Detaylı klinik artikülasyon ve hata teşhis diyaloğu
      showDialog(
        context: context,
        builder: (ctx) => _DiagnosticErrorDialog(
          result: result,
          onRetry: () {
            Navigator.pop(ctx);
            _listenThenSpeak(result.targetText);
          },
          onListenCorrection: () {
            _audioService.speakTurkish(
              result.targetText,
              phoneme: widget.stage.soundLetter,
              withInstruction: true,
            );
          },
        ),
      ).then((_) {
        if (_rewardState.hearts <= 0 && mounted) {
          showDialog(
            context: context,
            builder: (_) => const HeartsRefillDialog(),
          );
        }
      });
    }
  }

  void _readStoryWithAI(String title, String story, Color primaryColor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalCtx) {
        return _StorySpeechInteractiveSheet(
          title: title,
          story: story,
          phoneme: widget.stage.phoneme,
          soundLetter: widget.stage.soundLetter,
          primaryColor: primaryColor,
          audioService: _audioService,
          onComplete: (StoryEvaluationData data) {
            Navigator.pop(modalCtx);
            _showStoryEvaluationReport(data, primaryColor);
          },
        );
      },
    );
  }

  void _showStoryEvaluationReport(StoryEvaluationData data, Color primaryColor) {
    _rewardState.recordPracticeToday();
    if (data.starsEarned > 0) {
      _rewardState.addReward(
        earnedStars: data.starsEarned * 2,
        earnedXp: 120,
        earnedGems: 40,
      );
    }

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Container(
          width: 480,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            color: Colors.white,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🤖', style: TextStyle(fontSize: 44)),
                const SizedBox(height: 8),
                const Text(
                  'Yapay Zeka Hikaye Analizi & Karne',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF1E88E5)),
                ),
                const SizedBox(height: 12),
                // Skor & Yıldızlar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Başarı Skoru: %${data.accuracyScore}',
                        style: TextStyle(fontWeight: FontWeight.w900, color: primaryColor, fontSize: 16),
                      ),
                      const SizedBox(width: 12),
                      Row(
                        children: List.generate(3, (i) {
                          return Text(
                            i < data.starsEarned ? '⭐' : '☆',
                            style: const TextStyle(fontSize: 20),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                // Terapist Geri Bildirim Mesajı
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F8E9),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF81C784)),
                  ),
                  child: Text(
                    data.feedbackMessage,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF2E7D32), height: 1.5),
                  ),
                ),
                const SizedBox(height: 16),
                // Hatalı Kelimeler Listesi ve Birlikte Düzelttirme
                if (data.targetPhonemeErrorWords.isNotEmpty) ...[
                  Row(
                    children: [
                      const Text('🎯', style: TextStyle(fontSize: 18)),
                      const SizedBox(width: 6),
                      Text(
                        'Düzeltmemiz Gereken Kelimeler (${widget.stage.phoneme}):',
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Color(0xFFC62828)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: data.targetPhonemeErrorWords.map((word) {
                      return ActionChip(
                        avatar: const Icon(Icons.volume_up_rounded, size: 16, color: Colors.white),
                        backgroundColor: const Color(0xFFE53935),
                        label: Text(
                          word,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
                        ),
                        onPressed: () {
                          _audioService.speakTurkish(word, phoneme: widget.stage.soundLetter);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Terapist okuyor: "$word" - Dinle ve tekrar et!'),
                              duration: const Duration(seconds: 1),
                              backgroundColor: const Color(0xFF1E88E5),
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                ],
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Kapat', style: TextStyle(fontWeight: FontWeight.w800)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF58CC02),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: () {
                          Navigator.pop(ctx);
                          _openMiniGame(stageLevel: 5, stageName: 'Hikaye');
                        },
                        child: const Text('Şampiyonluk Oyunu 🏆', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openTherapistBagModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Text('🎒', style: TextStyle(fontSize: 26)),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Uzman & Terapist Çantası',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF1B5E20)),
                        ),
                        Text(
                          'Klinik araçlar, sayaç, yazdırılabilir form ve diploma',
                          style: TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.w600),
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
              const SizedBox(height: 18),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _buildTherapistBagItem(
                    icon: '🎓',
                    title: 'Başarı Diploması',
                    desc: 'Öğrenciye özel sertifika',
                    color: const Color(0xFFFFB300),
                    onTap: () {
                      Navigator.pop(ctx);
                      showDialog(
                        context: context,
                        builder: (c) => TherapyCertificateDialog(
                          phoneme: widget.stage.soundLetter,
                          soundTitle: widget.stage.phoneme,
                        ),
                      );
                    },
                  ),
                  _buildTherapistBagItem(
                    icon: '⏰',
                    title: 'Seans Sayacı',
                    desc: '15/30/45 dk süre takibi',
                    color: const Color(0xFF00ACC1),
                    onTap: () {
                      Navigator.pop(ctx);
                      _openSessionTimer();
                    },
                  ),
                  _buildTherapistBagItem(
                    icon: '🖨️',
                    title: 'Ödev Formu Yazdır',
                    desc: 'Veliye ev ödevi kağıdı',
                    color: const Color(0xFF0288D1),
                    onTap: () {
                      Navigator.pop(ctx);
                      _openPrintableWorksheet();
                    },
                  ),
                  _buildTherapistBagItem(
                    icon: '🎛️',
                    title: 'Ses Laboratuvarı',
                    desc: 'Akustik spektrum & perde',
                    color: const Color(0xFF00E5FF),
                    onTap: () {
                      Navigator.pop(ctx);
                      _openVoiceLab();
                    },
                  ),
                  _buildTherapistBagItem(
                    icon: '💌',
                    title: 'Ses Kartpostalı',
                    desc: 'Aileye sesli tebrik',
                    color: const Color(0xFFE91E63),
                    onTap: () {
                      Navigator.pop(ctx);
                      _openVoicePostcard();
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTherapistBagItem({
    required String icon,
    required String title,
    required String desc,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 155,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(icon, style: const TextStyle(fontSize: 26)),
            const SizedBox(height: 6),
            Text(
              title,
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: color),
            ),
            const SizedBox(height: 2),
            Text(
              desc,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stage = widget.stage;
    final primaryColor = Color(stage.colorHex);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 10,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                '${stage.emoji}  ${stage.phoneme}',
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                _audioService.speakTurkish(
                  stage.soundLetter,
                  phoneme: stage.soundLetter,
                  mode: 'phoneme',
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    duration: const Duration(seconds: 2),
                    backgroundColor: const Color(0xFF1E88E5),
                    content: Text('Terapist "${stage.phoneme}" sesini canlı seslendiriyor! Dinle ve tekrar et 🎯'),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.volume_up_rounded, color: primaryColor, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'Dinle',
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          Builder(
            builder: (ctx) {
              final screenW = MediaQuery.of(ctx).size.width;
              final maxActionsW = screenW > 600 ? screenW * 0.70 : screenW - 130;
              return ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxActionsW.clamp(140.0, 1000.0)),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
          // 🐢 Kaplumbağa Yavaş & Tane Tane Modu Butonu
          InkWell(
            onTap: () {
              setState(() => _isTurtlePacingMode = !_isTurtlePacingMode);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_isTurtlePacingMode
                      ? '🐢 Kaplumbağa Modu Aktif: Heceler tane tane ve yavaş seslendirilecek!'
                      : '🐇 Tavşan Modu Aktif: Normal konuşma temposuna dönüldü.'),
                  duration: const Duration(seconds: 2),
                  backgroundColor: _isTurtlePacingMode ? const Color(0xFF2E7D32) : const Color(0xFF1976D2),
                ),
              );
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              margin: const EdgeInsets.only(right: 6),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: _isTurtlePacingMode ? const Color(0xFFC8E6C9) : Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _isTurtlePacingMode ? const Color(0xFF2E7D32) : Colors.white70,
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Text(_isTurtlePacingMode ? '🐢' : '🐇', style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 3),
                  Text(
                    _isTurtlePacingMode ? 'Yavaş' : 'Hız',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: _isTurtlePacingMode ? const Color(0xFF1B5E20) : Colors.white,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 🪞 Canlı Konuşma Aynası Butonu
          InkWell(
            onTap: () {
              showDialog(
                context: context,
                builder: (ctx) => SpeechMirrorDialog(
                  phoneme: widget.stage.phoneme,
                  hint: widget.stage.articulationHint,
                ),
              );
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              margin: const EdgeInsets.only(right: 6),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFFD54F),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white, width: 1.5),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
                ],
              ),
              child: const Row(
                children: [
                  Text('🪞', style: TextStyle(fontSize: 16)),
                  SizedBox(width: 4),
                  Text(
                    'Ayna',
                    style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF5D4037), fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          // 🎒 UZMAN & TERAPİST ÇANTASI (Klinik Sayaç, Diploma, Lab, Ödev Formu)
          InkWell(
            onTap: () => _openTherapistBagModal(context),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              margin: const EdgeInsets.only(right: 6),
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00E676), Color(0xFF00B0FF)],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white, width: 1.5),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
                ],
              ),
              child: const Row(
                children: [
                  Text('🎒', style: TextStyle(fontSize: 15)),
                  SizedBox(width: 3),
                  Text(
                    'Uzman',
                    style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 11.5),
                  ),
                ],
              ),
            ),
          ),
          // Can & Elmas Canlı İstatistik Göstergesi
          ListenableBuilder(
            listenable: _rewardState,
            builder: (ctx, _) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => const HeartsRefillDialog(),
                      );
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white70, width: 1),
                      ),
                      child: Row(
                        children: [
                          const Text('❤️', style: TextStyle(fontSize: 13)),
                          const SizedBox(width: 3),
                          Text(
                            '${_rewardState.hearts}',
                            style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 12.5),
                          ),
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => const GemsShopDialog(),
                      );
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white70, width: 1),
                      ),
                      child: Row(
                        children: [
                          const Text('💎', style: TextStyle(fontSize: 13)),
                          const SizedBox(width: 3),
                          Text(
                            '${_rewardState.gems}',
                            style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 12.5),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          // Çocuğun Kuşandığı Subway Surfers Avatarı
          ListenableBuilder(
            listenable: _rewardState,
            builder: (ctx, _) {
              return GestureDetector(
                onTap: () {
                  final char = SubwaySurfersUnlockDialog.getCharacterForLevel(_tabController.index + 1);
                  showDialog(
                    context: context,
                    builder: (ctx) => SubwaySurfersUnlockDialog(
                      character: char,
                      stageName: 'Aşama ${_tabController.index + 1}',
                      onEquip: () {
                        _rewardState.equipCharacter(char.id, char.name, char.avatarEmoji);
                      },
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.amberAccent, width: 1.5),
                  ),
                  child: Row(
                    children: [
                      Text(_rewardState.activeAvatar, style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 4),
                      const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                    ],
                  ),
                ),
              );
            },
          ),
                    ],
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(
              _micTested ? Icons.mic_rounded : Icons.mic_none_rounded,
              color: _micTested ? Colors.lightGreenAccent : Colors.white,
            ),
            tooltip: 'Mikrofon İzni / Test',
            onPressed: _testMicrophone,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 4,
          isScrollable: true,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
          tabs: const [
            Tab(icon: Text('🔤', style: TextStyle(fontSize: 16)), text: '1. Heceler'),
            Tab(icon: Text('🎯', style: TextStyle(fontSize: 16)), text: '2. Kelimeler'),
            Tab(icon: Text('💬', style: TextStyle(fontSize: 16)), text: '3. Sözceler'),
            Tab(icon: Text('📝', style: TextStyle(fontSize: 16)), text: '4. Cümleler'),
            Tab(icon: Text('📖', style: TextStyle(fontSize: 16)), text: '5. Hikaye'),
          ],
        ),
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  // Canlı Kesit Animasyonu
                  MouthAnatomyWidget(
                    phoneme: stage.soundLetter,
                    articulationHint: stage.articulationHint,
                  ),

                  // 🏆 EFSANE AVATAR VİTRİNİ & KOLEKSİYONU (Kocaman, Hareketli ve Renkli/Gri Podyum)
                  AvatarShowcaseWidget(
                    onOpenMiniGame: () => _openMiniGame(
                      stageLevel: _tabController.index + 1,
                      stageName: 'Aşama ${_tabController.index + 1}',
                    ),
                    onSelectStage: (stIdx) {
                      _tabController.animateTo(stIdx);
                    },
                  ),

                  // 🎮 CANLI OYUN BANNER'I (Ses Temalı Mini Oyun)
                  _buildTopGameBanner(stage),
                ],
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildSyllablesGrid(stage.content.syllables, primaryColor),
            _buildWordsPositionalView(stage.content, primaryColor),
            _buildPhrasesTab(stage.content, primaryColor),
            _buildSentencesTab(stage.content, primaryColor),
            _buildStoryView(stage.content.storyTitle, stage.content.storyContent, primaryColor),
          ],
        ),
      ),
    );
  }

  Widget _buildTopGameBanner(SoundStage stage) {
    const gameEmoji = '🦁';
    final gameName = '🦁 SES CANAVARI: ${stage.phoneme} Kelime Avı!';
    const gameGrad = [Color(0xFFFFD54F), Color(0xFFFF9800)];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 6, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: gameGrad,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gameGrad.first.withValues(alpha: 0.35),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: const Text(gameEmoji, style: TextStyle(fontSize: 26)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  gameName,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Canavarla hedef "${stage.phoneme}" kelimelerini ye, dev gibi BÜYÜ! 🌟',
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: gameGrad.first,
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            onPressed: () => _openMiniGame(
              stageLevel: _tabController.index + 1,
              stageName: 'Aşama ${_tabController.index + 1}',
            ),
            child: const Text('OYNA 🚀', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _buildStageEndGameBanner(int stageLevel, String stageName, Color primaryColor) {
    return Container(
      margin: const EdgeInsets.only(top: 14, bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFFFF9800).withValues(alpha: 0.16), primaryColor.withValues(alpha: 0.06)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFFF9800).withValues(alpha: 0.5), width: 2),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Text('🦁', style: TextStyle(fontSize: 32)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🦁 SES CANAVARI: Aşama $stageLevel ($stageName)',
                      style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w900, color: Color(0xFFE65100)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Hedef "${widget.stage.phoneme}" kelimelerini HAM yap, dev gibi büyü! 👑',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.black87),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF9800),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Text('🦁', style: TextStyle(fontSize: 16)),
                  label: const Text('Ses Canavarı', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11.5)),
                  onPressed: () => _openMiniGame(stageLevel: stageLevel, stageName: stageName),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7B1FA2),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Text('🃏', style: TextStyle(fontSize: 16)),
                  label: const Text('Hafıza Kartı', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11.5)),
                  onPressed: _openMemoryGame,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00897B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Text('👂', style: TextStyle(fontSize: 16)),
                  label: const Text('Kulak Eğitimi', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11.5)),
                  onPressed: _openMinimalPairs,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE91E63),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Text('🎈', style: TextStyle(fontSize: 16)),
                  label: const Text('Balon Avcısı', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11.5)),
                  onPressed: _openBalloonGame,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6D00),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Text('⚡', style: TextStyle(fontSize: 16)),
                  label: const Text('Hızlı Rulet', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11.5)),
                  onPressed: _openFlashPractice,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF9800),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Text('🧩', style: TextStyle(fontSize: 16)),
                  label: const Text('Gizli Yapboz', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11.5)),
                  onPressed: _openMysteryPuzzle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0288D1),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 11),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              icon: const Text('🖨️', style: TextStyle(fontSize: 16)),
              label: const Text('Ödev Yazdır & İndir (PDF)', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
              onPressed: _openPrintableWorksheet,
            ),
          ),
        ],
      ),
    );
  }

  /// 1. Basamak: Heceler
  Widget _buildSyllablesGrid(List<String> syllables, Color primaryColor) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.1,
          ),
          itemCount: syllables.length,
          itemBuilder: (ctx, i) {
            final syl = syllables[i];
            return InkWell(
              onTap: () => _listenThenSpeak(syl),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: primaryColor.withAlpha(80), width: 2),
                  boxShadow: [
                    BoxShadow(color: primaryColor.withAlpha(30), blurRadius: 4, offset: const Offset(0, 3)),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      syl,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.volume_up_rounded, size: 14, color: Color(0xFF2196F3)),
                        SizedBox(width: 4),
                        Icon(Icons.mic_none_rounded, size: 14, color: Color(0xFF58CC02)),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        _buildStageEndGameBanner(1, 'Heceler', primaryColor),
      ],
    );
  }

  /// 2. Basamak: Kelimeler (Kitap A, B, C Bölümlendirmesi)
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
                    onSelected: () => setState(() {
                      _selectedWordSyllableFilter = 0;
                      _selectedWordPack = 1;
                    }),
                    primaryColor: primaryColor,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    label: '1️⃣ Tek Heceli Kelimeler',
                    isSelected: _selectedWordSyllableFilter == 1,
                    onSelected: () => setState(() {
                      _selectedWordSyllableFilter = 1;
                      _selectedWordPack = 1;
                    }),
                    primaryColor: primaryColor,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    label: '2️⃣ İki Heceli Kelimeler',
                    isSelected: _selectedWordSyllableFilter == 2,
                    onSelected: () => setState(() {
                      _selectedWordSyllableFilter = 2;
                      _selectedWordPack = 1;
                    }),
                    primaryColor: primaryColor,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    label: '3️⃣ Üç+ Heceli Kelimeler',
                    isSelected: _selectedWordSyllableFilter == 3,
                    onSelected: () => setState(() {
                      _selectedWordSyllableFilter = 3;
                      _selectedWordPack = 1;
                    }),
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
              onTap: (tabIdx) {
                setState(() => _selectedWordPack = 1);
              },
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
                  'Türkçe fonoloji kuralları gereği ötümlü ünsüzler (örneğin ${widget.stage.phoneme} sesi) kelime sonunda yer almaz; ötümsüzleşerek sert karşılığına dönüşür.\n\nBu nedenle klinik artikülasyon kitabında da ${widget.stage.phoneme} sesi için $position pozisyonu boş bırakılmıştır.',
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
            'Bu konumda ($position) seçili hece grubuna ait kelime bulunmamaktadır.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.grey),
          ),
        ),
      );
    }

    const int packSize = 8;
    final int totalPacks = (filteredWords.length / packSize).ceil();
    final int currentPack = _selectedWordPack.clamp(0, totalPacks);

    List<String> displayWords;
    if (currentPack == 0 || filteredWords.length <= packSize) {
      displayWords = filteredWords;
    } else {
      final startIdx = ((currentPack - 1) * packSize).clamp(0, filteredWords.length);
      final endIdx = (startIdx + packSize).clamp(startIdx, filteredWords.length);
      displayWords = filteredWords.sublist(startIdx, endIdx);
    }

    final int completedCount = displayWords.where((w) => _completedWordsInSession.contains(w.trim())).length;
    final bool isPackFinished = displayWords.isNotEmpty && completedCount >= displayWords.length;

    return Column(
      children: [
        // ── 📦 MİNİ-PAKET SEÇİCİ (Bilişsel Yükü Düşüren 8'erli Lokma Setler) ──
        if (filteredWords.length > packSize)
          Container(
            color: const Color(0xFFF1F8E9),
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ...List.generate(totalPacks, (idx) {
                    final packNum = idx + 1;
                    final isSel = currentPack == packNum;
                    final pStart = (idx * packSize).clamp(0, filteredWords.length);
                    final pEnd = (pStart + packSize).clamp(pStart, filteredWords.length);
                    final pWords = filteredWords.sublist(pStart, pEnd);
                    final pDone = pWords.where((w) => _completedWordsInSession.contains(w.trim())).length;
                    final isFullDone = pDone >= pWords.length && pWords.isNotEmpty;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(
                          isFullDone
                              ? '⭐ Paket $packNum (Tamam!)'
                              : '📦 Paket $packNum ($pDone/${pWords.length})',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                            color: isSel ? Colors.white : (isFullDone ? const Color(0xFF2E7D32) : Colors.black87),
                          ),
                        ),
                        selected: isSel,
                        selectedColor: isFullDone ? const Color(0xFF43A047) : const Color(0xFF58CC02),
                        backgroundColor: Colors.white,
                        onSelected: (val) {
                          if (val) setState(() => _selectedWordPack = packNum);
                        },
                      ),
                    );
                  }),
                  ChoiceChip(
                    label: Text(
                      'Tümü (${filteredWords.length})',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                        color: currentPack == 0 ? Colors.white : Colors.black87,
                      ),
                    ),
                    selected: currentPack == 0,
                    selectedColor: primaryColor,
                    backgroundColor: Colors.white,
                    onSelected: (val) {
                      if (val) setState(() => _selectedWordPack = 0);
                    },
                  ),
                ],
              ),
            ),
          ),

        // ── 🎯 HEDEF & MOTİVASYON BANNER'I ──
        if (currentPack > 0 && filteredWords.length > packSize)
          Container(
            margin: const EdgeInsets.fromLTRB(16, 10, 16, 2),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isPackFinished
                    ? const [Color(0xFF43A047), Color(0xFF2E7D32)]
                    : const [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF81C784)),
            ),
            child: Row(
              children: [
                Text(isPackFinished ? '🏆' : '🎯', style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isPackFinished
                            ? 'Harikasın! Paket $currentPack Başarıyla Tamamlandı! ⭐'
                            : 'Paket $currentPack Hedefi: $completedCount / ${displayWords.length} Kelime',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                          color: isPackFinished ? Colors.white : const Color(0xFF1B5E20),
                        ),
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: displayWords.isEmpty ? 0 : (completedCount / displayWords.length).clamp(0.0, 1.0),
                          backgroundColor: Colors.black12,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isPackFinished ? Colors.amberAccent : const Color(0xFF2E7D32),
                          ),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isPackFinished && currentPack < totalPacks) ...[
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF2E7D32),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      setState(() => _selectedWordPack = currentPack + 1);
                    },
                    child: const Text('Sonraki ➔', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11)),
                  ),
                ],
              ],
            ),
          ),

        // Kelime Kartları
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: displayWords.length + 1,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (ctx, i) {
              if (i == displayWords.length) {
                return _buildStageEndGameBanner(2, 'Kelimeler', primaryColor);
              }
              final word = displayWords[i];
              final sylCount = _countSyllables(word);
              final sylLabel = sylCount == 1 ? '1 Heceli' : (sylCount == 2 ? '2 Heceli' : '3+ Heceli');
              final picEmoji = WordPictogramHelper.getPictogram(word);
              final isSpeaking = _currentlySpeakingWord != null &&
                  _currentlySpeakingWord!.trim().toLowerCase() == word.trim().toLowerCase();

              return Bouncy3DCard(
                word: word,
                emoji: picEmoji,
                syllableLabel: sylLabel,
                position: position,
                primaryColor: primaryColor,
                isSpeakingNow: isSpeaking,
                onListen: () => _onlyListen(word),
                onSpeak: () => _listenThenSpeak(word),
              );
            },
          ),
        ),
      ],
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
                  label: '🚀 ${widget.stage.phoneme} İle Başlayan Sözceler ($begCount)',
                  isSelected: _selectedPhraseFilter == 1,
                  onSelected: () => setState(() => _selectedPhraseFilter = 1),
                  primaryColor: primaryColor,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: '🔍 ${widget.stage.phoneme} İçeren Sözceler ($contCount)',
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
                  label: '🚀 ${widget.stage.phoneme} İle Başlayan Cümleler ($begCount)',
                  isSelected: _selectedSentenceFilter == 1,
                  onSelected: () => setState(() => _selectedSentenceFilter = 1),
                  primaryColor: primaryColor,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: '🔍 ${widget.stage.phoneme} İçeren Cümleler ($contCount)',
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

  /// 3. ve 4. Basamak: Sözceler ve Cümleler
  Widget _buildSimpleList(List<String> items, String category, Color primaryColor) {
    final stageLevel = (category == 'Sözceler') ? 3 : 4;
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length + 1,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (ctx, i) {
        if (i == items.length) {
          return _buildStageEndGameBanner(stageLevel, category, primaryColor);
        }
        final text = items[i];
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.grey[200]!, width: 1.5),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: primaryColor.withAlpha(25),
              child: Text(
                '${i + 1}',
                style: TextStyle(fontWeight: FontWeight.w900, color: primaryColor),
              ),
            ),
            title: Text(
              text,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF263238)),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.volume_up_rounded, color: Color(0xFF2196F3)),
                  tooltip: 'Dinle (Kadın Sesi)',
                  onPressed: () => _onlyListen(text),
                ),
                IconButton(
                  icon: const Icon(Icons.mic_rounded, color: Color(0xFF58CC02)),
                  tooltip: 'Söyle',
                  onPressed: () => _listenThenSpeak(text),
                ),
              ],
            ),
            onTap: () => _listenThenSpeak(text),
          ),
        );
      },
    );
  }

  /// 5. Basamak: Hikaye (Karaoke & Cümle Cümle Takip Deneyimi)
  Widget _buildStoryView(String title, String story, Color primaryColor) {
    final rawSentences = story
        .split(RegExp(r'(?<=[.!?])\s+'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    final sentences = rawSentences.isNotEmpty ? rawSentences : [story];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: primaryColor.withAlpha(80), width: 2),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: primaryColor.withAlpha(25),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${widget.stage.phoneme} SESİ İÇEREN TERAPİ HİKAYESİ',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: primaryColor),
              ),
            ),
            Row(
              children: [
                const Text('📖', style: TextStyle(fontSize: 30)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: primaryColor),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Cümlelerin üzerine dokunarak tek tek dinle ve takip et! 🎈',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24, thickness: 1.5),

            // ── CÜMLE CÜMLE KARAOKE & TAKİP LİSTESİ ──
            ...List.generate(sentences.length, (sIdx) {
              final sentence = sentences[sIdx];
              final isPlayingThis = _currentlySpeakingWord != null &&
                  _currentlySpeakingWord!.trim().toLowerCase() == sentence.trim().toLowerCase();

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: InkWell(
                  onTap: () => _onlyListen(sentence),
                  borderRadius: BorderRadius.circular(16),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isPlayingThis ? const Color(0xFFFFF9C4) : const Color(0xFFFAFAFA),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isPlayingThis ? const Color(0xFFFFB300) : Colors.grey[200]!,
                        width: isPlayingThis ? 2 : 1,
                      ),
                      boxShadow: isPlayingThis
                          ? const [BoxShadow(color: Color(0x33FFB300), blurRadius: 8, offset: Offset(0, 3))]
                          : null,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: isPlayingThis ? const Color(0xFFFFB300) : primaryColor.withAlpha(30),
                          child: Text(
                            '${sIdx + 1}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: isPlayingThis ? Colors.black87 : primaryColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildHighlightedSentence(sentence, widget.stage.soundLetter, primaryColor),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: Icon(
                            isPlayingThis ? Icons.volume_up_rounded : Icons.play_circle_fill_rounded,
                            color: isPlayingThis ? const Color(0xFFE65100) : primaryColor,
                            size: 24,
                          ),
                          onPressed: () => _onlyListen(sentence),
                          tooltip: 'Bu cümleyi dinle',
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),

            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: primaryColor, width: 2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    icon: Icon(Icons.volume_up_rounded, color: primaryColor),
                    label: Text(
                      'Tümünü Dinle',
                      style: TextStyle(fontWeight: FontWeight.w900, color: primaryColor),
                    ),
                    onPressed: () => _onlyListen(story),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF58CC02),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    icon: const Icon(Icons.mic_rounded, color: Colors.white),
                    label: const Text(
                      'Sen Oku 🏆',
                      style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white),
                    ),
                    onPressed: () => _readStoryWithAI(title, story, primaryColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildStageEndGameBanner(5, 'Hikaye', primaryColor),
          ],
        ),
      ),
    );
  }

  Widget _buildHighlightedSentence(String text, String soundLetter, Color primaryColor) {
    final cleanL = soundLetter.toLowerCase();
    final List<TextSpan> spans = [];

    for (int i = 0; i < text.length; i++) {
      final char = text[i];
      final isTarget = char.toLowerCase() == cleanL;

      if (isTarget) {
        spans.add(
          TextSpan(
            text: char,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: primaryColor,
              decoration: TextDecoration.underline,
              decorationColor: primaryColor,
              backgroundColor: primaryColor.withAlpha(25),
            ),
          ),
        );
      } else {
        spans.add(
          TextSpan(
            text: char,
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF37474F),
            ),
          ),
        );
      }
    }

    return RichText(text: TextSpan(children: spans));
  }
}

/// "Önce Dinle 🔊 ➔ Sonra Sen Söyle 🎤" İnteraktif Canlı Modal
class _SpeechInteractiveSheet extends StatefulWidget {
  final String targetText;
  final String phoneme;
  final String soundLetter;
  final AudioSpeechService audioService;
  final bool isTurtleMode;
  final ValueChanged<SpeechEvaluationResult> onComplete;

  const _SpeechInteractiveSheet({
    required this.targetText,
    required this.phoneme,
    required this.soundLetter,
    required this.audioService,
    this.isTurtleMode = false,
    required this.onComplete,
  });

  @override
  State<_SpeechInteractiveSheet> createState() => _SpeechInteractiveSheetState();
}

class _SpeechInteractiveSheetState extends State<_SpeechInteractiveSheet> {
  bool _isPlayingAudio = false;
  bool _isListeningMic = false;
  bool _isEvaluating = false;
  String _liveTranscript = '';
  int _secondsLeft = 10;
  Timer? _countdownTimer;
  @override
  void initState() {
    super.initState();
    _playTts(withInstruction: false); // Normalde doğrudan canlı ve sıcak söyle
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    widget.audioService.stopListening();
    super.dispose();
  }

  void _playTts({bool withInstruction = false}) async {
    setState(() {
      _isPlayingAudio = true;
      _isListeningMic = false;
    });

    final effectiveMode = widget.isTurtleMode ? 'syllable' : 'natural';
    await widget.audioService.speakTurkish(
      widget.targetText,
      phoneme: widget.soundLetter,
      mode: effectiveMode,
      withInstruction: withInstruction,
    );

    if (!mounted) return;
    setState(() {
      _isPlayingAudio = false;
    });
  }

  void _startMicRecording() async {
    // 1. Mikrofon iznini kontrol et; izin verilmediyse kapatma, kullanıcıyı uyar!
    final hasPerm = await widget.audioService.requestMicrophonePermission();
    if (!hasPerm) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚠️ Lütfen tarayıcı adres çubuğundaki kilit simgesinden mikrofona İZİN VERİN!'),
            backgroundColor: Color(0xFFD32F2F),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    setState(() {
      _isPlayingAudio = false;
      _isListeningMic = true;
      _isEvaluating = false;
      _liveTranscript = '';
      _secondsLeft = 10;
    });

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_secondsLeft <= 1) {
        t.cancel();
      } else {
        setState(() => _secondsLeft--);
      }
    });

    final result = await widget.audioService.listenAndEvaluate(
      targetText: widget.targetText,
      phoneme: widget.phoneme,
      duration: const Duration(seconds: 10),
      onLiveSpeech: (text) {
        if (mounted) {
          setState(() => _liveTranscript = text);
        }
      },
    );

    _countdownTimer?.cancel();

    if (mounted) {
      setState(() {
        _isListeningMic = false;
        _isEvaluating = true;
      });
      widget.onComplete(result);
    }
  }

  void _stopMicAndEvaluate() {
    _countdownTimer?.cancel();
    widget.audioService.stopListening();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(24, 20, 24, MediaQuery.of(context).viewInsets.bottom + 28),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
          Container(
            width: 48,
            height: 5,
            decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
          ),
          const SizedBox(height: 10),
          // Canlı Konuşan Maskot (Dudak Senkronu & Nefes)
          AnimatedSpeechMascot(
            isSpeaking: _isPlayingAudio,
            phoneme: widget.soundLetter,
            size: 76,
          ),
          const SizedBox(height: 10),
          Text(
            widget.targetText,
            style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: Color(0xFF1B5E20)),
          ),
          const SizedBox(height: 6),
          Text(
            _isPlayingAudio
                ? 'Öğretmen seslendiriyor, dikkatle dinle... 👩‍🏫'
                : (_isListeningMic
                    ? 'Seni dinliyorum, rahatça söyle! Bitince butona bas 🎙️'
                    : 'Hazırsan yeşil butona bas ve söyle!'),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: _isPlayingAudio
                  ? const Color(0xFF1976D2)
                  : (_isListeningMic ? const Color(0xFFD32F2F) : Colors.black87),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),

          // Canlı Ekolayzır Ses Dalgası (Dans Eden Çubuklar)
          if (_isListeningMic) ...[
            const LiveSoundwaveVisualizer(label: 'Seni Dinliyorum 🎙️'),
            const SizedBox(height: 12),
          ],

          // Canlı Konuşma Metni Kutusu
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: _isListeningMic ? const Color(0xFFFFF8E1) : Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _isListeningMic ? const Color(0xFFFFB300) : Colors.grey[300]!,
                width: 2,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _isListeningMic ? Icons.mic_rounded : Icons.hearing_rounded,
                  color: _isListeningMic ? const Color(0xFFFF8F00) : Colors.grey,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _liveTranscript.isEmpty
                        ? (_isListeningMic ? 'Konuştuğunda kelimeler burada belirecek...' : 'Dinlemeye hazır')
                        : _liveTranscript,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: _liveTranscript.isEmpty ? Colors.grey : const Color(0xFF263238),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Butonlar: "Tekrar Dinle 🔊", "Nasıl Söylenir? 🗣️", "ŞİMDİ SÖYLE 🎤"
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: Color(0xFF2196F3), width: 2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  icon: const Icon(Icons.volume_up_rounded, color: Color(0xFF2196F3), size: 22),
                  label: const Text(
                    'Kelimeyi Dinle',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Color(0xFF2196F3)),
                  ),
                  onPressed: _isPlayingAudio ? null : () => _playTts(withInstruction: false),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: Color(0xFFFF9800), width: 2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  icon: const Icon(Icons.record_voice_over_rounded, color: Color(0xFFFF9800), size: 22),
                  label: const Text(
                    'Ağız Kuralı',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Color(0xFFE65100)),
                  ),
                  onPressed: _isPlayingAudio ? null : () => _playTts(withInstruction: true),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: _isEvaluating
                ? Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFF58CC02), width: 2),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5, color: Color(0xFF2E7D32))),
                        SizedBox(width: 12),
                        Text(
                          'Yapay Zeka Analiz Ediyor... 🤖',
                          style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF2E7D32), fontSize: 15),
                        ),
                      ],
                    ),
                  )
                : ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isListeningMic ? const Color(0xFFFF9800) : const Color(0xFF58CC02),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      elevation: 4,
                    ),
                    icon: Icon(
                      _isListeningMic ? Icons.stop_circle_rounded : Icons.mic_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                    label: Text(
                      _isListeningMic
                          ? (_liveTranscript.isNotEmpty
                              ? 'BİTTİ, ANALİZ ET! 🚀 ($_secondsLeft s)'
                              : 'Dinliyorum... Söyle veya Durdur ⏹️ ($_secondsLeft s)')
                          : 'ŞİMDİ SÖYLE 🎤',
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.white),
                    ),
                    onPressed: _isPlayingAudio ? null : (_isListeningMic ? _stopMicAndEvaluate : _startMicRecording),
                  ),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () {
              widget.audioService.stopListening();
              Navigator.pop(context);
            },
            child: const Text('Kapat', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    ),
  );
  }
}

/// 🎉 EĞLENCELİ, HAREKETLİ VE KONFETİLİ KUTLAMA DİYALOĞU
class _CelebrationConfettiDialog extends StatefulWidget {
  final SpeechEvaluationResult result;
  final VoidCallback onContinue;

  const _CelebrationConfettiDialog({
    required this.result,
    required this.onContinue,
  });

  @override
  State<_CelebrationConfettiDialog> createState() => _CelebrationConfettiDialogState();
}

class _CelebrationConfettiDialogState extends State<_CelebrationConfettiDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _bounceAnimation;
  bool _isPlayingVoice = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _bounceAnimation = Tween<double>(begin: -8.0, end: 8.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      elevation: 16,
      backgroundColor: Colors.transparent,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Konfeti ve Yıldız Parçacıkları (Etrafta uçuşan)
          ...List.generate(12, (index) {
            final emojis = ['⭐', '🎉', '✨', '🎈', '🌟', '🎊', '💎', '🔥'];
            final dist = 145.0 + (index % 3) * 22;
            return AnimatedBuilder(
              animation: _animController,
              builder: (ctx, child) {
                final shift = _bounceAnimation.value * (index % 2 == 0 ? 1 : -1);
                return Transform.translate(
                  offset: Offset(
                    (dist + shift) * 0.9 * (index % 2 == 0 ? 1 : -1) * (index > 6 ? 0.8 : 1),
                    (dist + shift) * (index % 3 == 0 ? -1 : 1) * 0.7,
                  ),
                  child: Text(
                    emojis[index % emojis.length],
                    style: TextStyle(fontSize: 20 + (index % 3) * 6),
                  ),
                );
              },
            );
          }),

          // Ana Kart
          Container(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF58CC02).withValues(alpha: 0.3),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Zıplayan Maskot ve Başlık
                AnimatedBuilder(
                  animation: _animController,
                  builder: (ctx, child) {
                    return Transform.translate(
                      offset: Offset(0, _bounceAnimation.value),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFE8F5E9),
                          border: Border.all(color: const Color(0xFF58CC02), width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF58CC02).withValues(alpha: 0.25),
                              blurRadius: 16,
                            ),
                          ],
                        ),
                        child: const Text('🥳', style: TextStyle(fontSize: 52)),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 14),
                const Text(
                  'MÜKEMMEL SÖYLEDİN!',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF2E7D32),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF58CC02), width: 2),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.verified_rounded, color: Color(0xFF2E7D32), size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Artikülasyon Skoru: %${widget.result.score}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF2E7D32),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  widget.result.feedback,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    'Duyulan: "${widget.result.recognizedText}"',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.blueGrey),
                  ),
                ),
                const SizedBox(height: 18),

                // Kazanılan Ödüller Rozeti
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildRewardMini('⭐', '+3', 'Yıldız', const Color(0xFFFFB300)),
                    _buildRewardMini('⚡', '+50', 'XP', const Color(0xFF58CC02)),
                    _buildRewardMini('💎', '+25', 'Elmas', const Color(0xFF00BCD4)),
                  ],
                ),
                const SizedBox(height: 22),

                // Kendi Sesini Dinle Butonu (Canlı, dolgulu ve net durum geri bildirimli)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: _isPlayingVoice ? const Color(0xFF00C853) : const Color(0xFF7B1FA2),
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shadowColor: _isPlayingVoice ? const Color(0x6600C853) : const Color(0x667B1FA2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    ),
                    icon: Icon(
                      _isPlayingVoice ? Icons.volume_up_rounded : Icons.headphones_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                    label: Text(
                      _isPlayingVoice ? 'SESİN ÇALINIYOR... 🔊' : '🎧 KENDİ SESİNİ DİNLE 🎧',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        fontSize: 14,
                        letterSpacing: 0.5,
                      ),
                    ),
                    onPressed: _isPlayingVoice ? null : () {
                      setState(() => _isPlayingVoice = true);
                      Future.delayed(const Duration(seconds: 5), () {
                        if (mounted && _isPlayingVoice) {
                          setState(() => _isPlayingVoice = false);
                        }
                      });
                      final ok = AudioSpeechService().playLastRecordedAudio(
                        onEnded: () {
                          if (mounted) setState(() => _isPlayingVoice = false);
                        },
                      );
                      if (!ok && mounted) {
                        setState(() => _isPlayingVoice = false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Ses kaydı çalınamadı. Lütfen mikrofona konuşup tekrar deneyin! 🎙️'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(height: 12),

                // Devam Et Butonu
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF58CC02),
                      elevation: 4,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    onPressed: widget.onContinue,
                    child: const Text(
                      'HARİKA, DEVAM ET! 🚀',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardMini(String icon, String val, String title, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.6), width: 1.5),
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 22)),
          Text(val, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: color)),
          Text(title, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.grey[700])),
        ],
      ),
    );
  }
}

/// 🔍 KLİNİK HATA ANALİZİ VE HARF HARF ARTIKÜLASYON RAPORU DİYALOĞU
class _DiagnosticErrorDialog extends StatefulWidget {
  final SpeechEvaluationResult result;
  final VoidCallback onRetry;
  final VoidCallback onListenCorrection;

  const _DiagnosticErrorDialog({
    required this.result,
    required this.onRetry,
    required this.onListenCorrection,
  });

  @override
  State<_DiagnosticErrorDialog> createState() => _DiagnosticErrorDialogState();
}

class _DiagnosticErrorDialogState extends State<_DiagnosticErrorDialog> {
  bool _isKidMode = true; // Varsayılan olarak çocuk modu aktiftir (pozitif teşvik & sıcak maskot)
  bool _isPlayingVoice = false;

  @override
  Widget build(BuildContext context) {
    final int score = widget.result.score;
    final int errorPct = widget.result.errorPercentage > 0 ? widget.result.errorPercentage : (100 - score);

    return Dialog(
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
              // ── MOD GEÇİŞ BUTONU: [🎈 Çocuk Modu] / [🔬 Uzman Modu] ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.all(3),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: () => setState(() => _isKidMode = true),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: _isKidMode ? const Color(0xFF58CC02) : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Text('🎈', style: TextStyle(fontSize: 13)),
                                const SizedBox(width: 4),
                                Text(
                                  'Çocuk',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 12,
                                    color: _isKidMode ? Colors.white : Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () => setState(() => _isKidMode = false),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: !_isKidMode ? const Color(0xFF1E88E5) : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Text('🔬', style: TextStyle(fontSize: 13)),
                                const SizedBox(width: 4),
                                Text(
                                  'Uzman',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 12,
                                    color: !_isKidMode ? Colors.white : Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
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
              const SizedBox(height: 12),

              // ══════════════════════════════════════════════════════════════
              // 1. ÇOCUK GÖRÜNÜMÜ: SICAK, POZİTİF VE TEŞVİK EDİCİ
              // ══════════════════════════════════════════════════════════════
              if (_isKidMode) ...[
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF8E1),
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFFFB300), width: 2.5),
                        ),
                        child: const Text('🦁', style: TextStyle(fontSize: 44)),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Harika Bir Deneme! 🎈',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFE65100),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Hedef: "${widget.result.targetText}"',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF2E7D32)),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF81C784)),
                        ),
                        child: Text(
                          'Gayret Puanın: %$score ⭐ (Çok Yaklaştın!)',
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Color(0xFF2E7D32)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFDE7),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFFFFF176)),
                        ),
                        child: Text(
                          widget.result.feedback.isNotEmpty
                              ? widget.result.feedback
                              : 'Birlikte tekrar dinleyelim ve biraz daha kuvvetli söyleyelim! 🚀',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 13.5, height: 1.5, fontWeight: FontWeight.w700, color: Color(0xFF5D4037)),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // ══════════════════════════════════════════════════════════════
                // 2. TERAPİST / UZMAN GÖRÜNÜMÜ: KLİNİK FONETİK ANALİZ
                // ══════════════════════════════════════════════════════════════
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEBEE),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text('🔬', style: TextStyle(fontSize: 24)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Klinik Fonetik Rapor',
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: Color(0xFFC62828)),
                          ),
                          Text(
                            'Hedef: "${widget.result.targetText}"',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // 1. NE KADAR HATA YAPILDI? (YÜZDELİK METRE)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAFAFA),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Text('✅ ', style: TextStyle(fontSize: 13)),
                              Text(
                                'Doğruluk: %$score',
                                style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF2E7D32), fontSize: 12),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              const Text('⚠️ ', style: TextStyle(fontSize: 13)),
                              Text(
                                'Hata Oranı: %$errorPct',
                                style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFFD32F2F), fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Row(
                          children: [
                            Expanded(
                              flex: score.clamp(1, 100),
                              child: Container(height: 10, color: const Color(0xFF58CC02)),
                            ),
                            Expanded(
                              flex: errorPct.clamp(1, 100),
                              child: Container(height: 10, color: const Color(0xFFFF5252)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // 2. HARF HARF GÖRSEL KARŞILAŞTIRMA (DIFF)
                if (widget.result.letterAnalysis.isNotEmpty) ...[
                  const Text(
                    '🔤 Harf Harf Telaffuz Karşılaştırması:',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const SizedBox(
                              width: 65,
                              child: Text(
                                'Hedef:',
                                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: Colors.black54),
                              ),
                            ),
                            Expanded(
                              child: Wrap(
                                spacing: 6,
                                children: widget.result.letterAnalysis.map((item) {
                                  return Container(
                                    width: 30,
                                    height: 30,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: item.isMatch ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: item.isMatch ? const Color(0xFF58CC02) : const Color(0xFFE53935),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Text(
                                      item.targetChar,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 13,
                                        color: item.isMatch ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const SizedBox(
                              width: 65,
                              child: Text(
                                'Duyulan:',
                                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: Colors.black54),
                              ),
                            ),
                            Expanded(
                              child: Wrap(
                                spacing: 6,
                                children: widget.result.letterAnalysis.map((item) {
                                  return Container(
                                    width: 30,
                                    height: 30,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: item.isMatch ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: item.isMatch ? const Color(0xFF58CC02) : const Color(0xFFE53935),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Text(
                                      item.spokenChar,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 13,
                                        color: item.isMatch ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // 3. KLİNİK HATA TEŞHİSİ VE ÇÖZÜMÜ
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFFFB300), width: 1.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.psychology_alt_rounded, color: Color(0xFFE65100), size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              widget.result.errorType.isNotEmpty ? widget.result.errorType : 'Fonetik Analiz',
                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Color(0xFFE65100)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.result.errorDetail.isNotEmpty ? widget.result.errorDetail : widget.result.feedback,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF424242), height: 1.3),
                      ),
                      if (widget.result.articulatoryCorrection.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFFFD54F)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('🗣️ ', style: TextStyle(fontSize: 14)),
                              Expanded(
                                child: Text(
                                  'Ağız Pozisyonu: ${widget.result.articulatoryCorrection}',
                                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFFE65100)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 18),

              // ── 4. BUTONLAR: Kendi Sesini Dinle, Doğrusunu Dinle, Tekrar Söyle ──
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    backgroundColor: _isPlayingVoice ? const Color(0xFF00C853) : const Color(0xFF7B1FA2),
                    foregroundColor: Colors.white,
                    elevation: 3,
                    shadowColor: _isPlayingVoice ? const Color(0x6600C853) : const Color(0x667B1FA2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  icon: Icon(
                    _isPlayingVoice ? Icons.volume_up_rounded : Icons.headphones_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  label: Text(
                    _isPlayingVoice ? 'SESİN ÇALINIYOR... 🔊' : '🎧 KENDİ SESİNİ DİNLE 🎧',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      fontSize: 13.5,
                      letterSpacing: 0.5,
                    ),
                  ),
                  onPressed: _isPlayingVoice ? null : () {
                    setState(() => _isPlayingVoice = true);
                    Future.delayed(const Duration(seconds: 5), () {
                      if (mounted && _isPlayingVoice) {
                        setState(() => _isPlayingVoice = false);
                      }
                    });
                    final ok = AudioSpeechService().playLastRecordedAudio(
                      onEnded: () {
                        if (mounted) setState(() => _isPlayingVoice = false);
                      },
                    );
                    if (!ok && mounted) {
                      setState(() => _isPlayingVoice = false);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Ses kaydı çalınamadı. Lütfen tekrar söyleyin! 🎙️'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        side: const BorderSide(color: Color(0xFF0288D1), width: 2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      icon: const Icon(Icons.volume_up_rounded, color: Color(0xFF0288D1), size: 20),
                      label: const Text(
                        'Doğrusunu Dinle',
                        style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF0288D1), fontSize: 12),
                      ),
                      onPressed: widget.onListenCorrection,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF58CC02),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 3,
                      ),
                      icon: const Icon(Icons.mic_rounded, color: Colors.white, size: 20),
                      label: const Text(
                        'Tekrar Söyle 🎤',
                        style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 13),
                      ),
                      onPressed: widget.onRetry,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 📖 Hikaye Sesli Okuma ve Yapay Zeka Canlı Dinleme Modalı
class _StorySpeechInteractiveSheet extends StatefulWidget {
  final String title;
  final String story;
  final String phoneme;
  final String soundLetter;
  final Color primaryColor;
  final AudioSpeechService audioService;
  final ValueChanged<StoryEvaluationData> onComplete;

  const _StorySpeechInteractiveSheet({
    required this.title,
    required this.story,
    required this.phoneme,
    required this.soundLetter,
    required this.primaryColor,
    required this.audioService,
    required this.onComplete,
  });

  @override
  State<_StorySpeechInteractiveSheet> createState() => _StorySpeechInteractiveSheetState();
}

class _StorySpeechInteractiveSheetState extends State<_StorySpeechInteractiveSheet> {
  bool _isEvaluating = false;
  String _spokenText = '';

  @override
  void initState() {
    super.initState();
    _startRecording();
  }

  @override
  void dispose() {
    widget.audioService.stopListening();
    super.dispose();
  }

  void _startRecording() async {
    setState(() {
      _isEvaluating = false;
      _spokenText = '';
    });

    final text = await widget.audioService.listenToSpeech(
      duration: const Duration(minutes: 10),
      continuous: true,
      onInterimText: (interim) {
        if (mounted) {
          setState(() => _spokenText = interim);
        }
      },
    );
    if (mounted) {
      _spokenText = text;
    }
  }

  void _finishAndEvaluate() async {
    widget.audioService.stopListening();

    setState(() {
      _isEvaluating = true;
    });

    final result = await widget.audioService.evaluateStory(
      storyText: widget.story,
      targetPhoneme: widget.phoneme,
      spokenText: _spokenText,
    );

    if (mounted) {
      widget.onComplete(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 15, offset: Offset(0, -4))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 5,
            decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Text('🎙️', style: TextStyle(fontSize: 26)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Hikayeyi Sesli Oku: ${widget.title}',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: widget.primaryColor),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFA5D6A7)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.mic_rounded, color: Color(0xFF2E7D32), size: 14),
                    SizedBox(width: 4),
                    Text(
                      'Süresiz Dinleme',
                      style: TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.w900, fontSize: 11.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '💡 Kendi hızında, rahatça oku. Bitirince aşağıdaki yeşil butona bas!',
              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFFE65100)),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            height: 160,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F9FC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: SingleChildScrollView(
              child: Text(
                widget.story,
                style: const TextStyle(fontSize: 14, height: 1.6, fontWeight: FontWeight.w600, color: Color(0xFF37474F)),
              ),
            ),
          ),
          if (_spokenText.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFE0F2F1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Duyulan: $_spokenText',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11.5, color: Color(0xFF00695C), fontWeight: FontWeight.w700),
              ),
            ),
          ],
          const SizedBox(height: 16),
          if (_isEvaluating) ...[
            const CircularProgressIndicator(),
            const SizedBox(height: 10),
            const Text(
              'Yapay Zeka Okumanı Analiz Ediyor... 🤖',
              style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF1976D2)),
            ),
          ] else ...[
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF58CC02),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 3,
              ),
              icon: const Icon(Icons.check_circle_rounded),
              label: const Text(
                'Okumayı Tamamladım! Analiz Et 🚀',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
              ),
              onPressed: _finishAndEvaluate,
            ),
          ],
        ],
      ),
    );
  }
}

