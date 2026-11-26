import 'package:flutter/material.dart';
import '../services/audio_speech_service.dart';
import '../services/sound_effects_service.dart';
import '../models/reward_state.dart';

class _PairOption {
  final String word;
  final String emoji;
  final String phoneme;

  _PairOption({
    required this.word,
    required this.emoji,
    required this.phoneme,
  });
}

class _MinimalPairQuestion {
  final String title;
  final _PairOption optionA;
  final _PairOption optionB;
  final int correctIndex; // 0: A, 1: B

  _MinimalPairQuestion({
    required this.title,
    required this.optionA,
    required this.optionB,
    required this.correctIndex,
  });

  _PairOption get correctOption => correctIndex == 0 ? optionA : optionB;
}

/// 👂 KLİNİK KULAK EĞİTİMİ & MİNİMAL ÇİFTLER
/// Çocukların karıştırılan sesleri (Örn: P/B, R/Y, S/Ş) zihninde ayırt edebilmesi için
/// altın standart klinik işitsel ayırt etme alıştırması.
class MinimalPairsDialog extends StatefulWidget {
  final String phoneme;

  const MinimalPairsDialog({
    super.key,
    required this.phoneme,
  });

  @override
  State<MinimalPairsDialog> createState() => _MinimalPairsDialogState();
}

class _MinimalPairsDialogState extends State<MinimalPairsDialog> {
  final AudioSpeechService _audioService = AudioSpeechService();
  final SoundEffectsService _sfx = SoundEffectsService();
  final RewardState _rewardState = RewardState();

  late List<_MinimalPairQuestion> _questions;
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _answered = false;
  int? _selectedAnswerIndex;
  bool _isFinished = false;

  @override
  void initState() {
    super.initState();
    _initQuestions();
    _playCurrentAudio();
  }

  void _initQuestions() {
    final cleanP = widget.phoneme.replaceAll('/', '').trim().toLowerCase();

    if (cleanP == 'r' || cleanP == 'y') {
      _questions = [
        _MinimalPairQuestion(
          title: '/r/ ve /y/ Ayırt Etme',
          optionA: _PairOption(word: 'Arı', emoji: '🐝', phoneme: 'R'),
          optionB: _PairOption(word: 'Ayı', emoji: '🐻', phoneme: 'Y'),
          correctIndex: 0,
        ),
        _MinimalPairQuestion(
          title: '/r/ ve /y/ Ayırt Etme',
          optionA: _PairOption(word: 'Kar', emoji: '❄️', phoneme: 'R'),
          optionB: _PairOption(word: 'Kay', emoji: '⛷️', phoneme: 'Y'),
          correctIndex: 1,
        ),
        _MinimalPairQuestion(
          title: '/r/ ve /y/ Ayırt Etme',
          optionA: _PairOption(word: 'Ray', emoji: '🚂', phoneme: 'R'),
          optionB: _PairOption(word: 'Yay', emoji: '🏹', phoneme: 'Y'),
          correctIndex: 0,
        ),
        _MinimalPairQuestion(
          title: '/r/ ve /y/ Ayırt Etme',
          optionA: _PairOption(word: 'Kör', emoji: '🙈', phoneme: 'R'),
          optionB: _PairOption(word: 'Köy', emoji: '🏡', phoneme: 'Y'),
          correctIndex: 1,
        ),
      ];
    } else if (cleanP == 's' || cleanP == 'ş') {
      _questions = [
        _MinimalPairQuestion(
          title: '/s/ ve /ş/ Ayırt Etme',
          optionA: _PairOption(word: 'Kas', emoji: '💪', phoneme: 'S'),
          optionB: _PairOption(word: 'Kaş', emoji: '🤨', phoneme: 'Ş'),
          correctIndex: 0,
        ),
        _MinimalPairQuestion(
          title: '/s/ ve /ş/ Ayırt Etme',
          optionA: _PairOption(word: 'As', emoji: '🃏', phoneme: 'S'),
          optionB: _PairOption(word: 'Aş', emoji: '🍲', phoneme: 'Ş'),
          correctIndex: 1,
        ),
        _MinimalPairQuestion(
          title: '/s/ ve /ş/ Ayırt Etme',
          optionA: _PairOption(word: 'Tas', emoji: '🥣', phoneme: 'S'),
          optionB: _PairOption(word: 'Taş', emoji: '🪨', phoneme: 'Ş'),
          correctIndex: 0,
        ),
      ];
    } else if (cleanP == 't' || cleanP == 'd') {
      _questions = [
        _MinimalPairQuestion(
          title: '/t/ ve /d/ Ayırt Etme',
          optionA: _PairOption(word: 'Tam', emoji: '💯', phoneme: 'T'),
          optionB: _PairOption(word: 'Dam', emoji: '🏠', phoneme: 'D'),
          correctIndex: 0,
        ),
        _MinimalPairQuestion(
          title: '/t/ ve /d/ Ayırt Etme',
          optionA: _PairOption(word: 'Tel', emoji: '🧵', phoneme: 'T'),
          optionB: _PairOption(word: 'Del', emoji: '🕳️', phoneme: 'D'),
          correctIndex: 1,
        ),
        _MinimalPairQuestion(
          title: '/t/ ve /d/ Ayırt Etme',
          optionA: _PairOption(word: 'Tur', emoji: '🚴', phoneme: 'T'),
          optionB: _PairOption(word: 'Dur', emoji: '🛑', phoneme: 'D'),
          correctIndex: 1,
        ),
        _MinimalPairQuestion(
          title: '/t/ ve /d/ Ayırt Etme',
          optionA: _PairOption(word: 'Ot', emoji: '🌿', phoneme: 'T'),
          optionB: _PairOption(word: 'Od', emoji: '🔥', phoneme: 'D'),
          correctIndex: 0,
        ),
      ];
    } else if (cleanP == 'k' || cleanP == 'g') {
      _questions = [
        _MinimalPairQuestion(
          title: '/k/ ve /g/ Ayırt Etme',
          optionA: _PairOption(word: 'Kül', emoji: '💨', phoneme: 'K'),
          optionB: _PairOption(word: 'Gül', emoji: '🌹', phoneme: 'G'),
          correctIndex: 1,
        ),
        _MinimalPairQuestion(
          title: '/k/ ve /g/ Ayırt Etme',
          optionA: _PairOption(word: 'Kar', emoji: '❄️', phoneme: 'K'),
          optionB: _PairOption(word: 'Gar', emoji: '🚉', phoneme: 'G'),
          correctIndex: 0,
        ),
        _MinimalPairQuestion(
          title: '/k/ ve /g/ Ayırt Etme',
          optionA: _PairOption(word: 'Köz', emoji: '🪵', phoneme: 'K'),
          optionB: _PairOption(word: 'Göz', emoji: '👁️', phoneme: 'G'),
          correctIndex: 1,
        ),
      ];
    } else if (cleanP == 'f' || cleanP == 'v') {
      _questions = [
        _MinimalPairQuestion(
          title: '/f/ ve /v/ Ayırt Etme',
          optionA: _PairOption(word: 'Far', emoji: '💡', phoneme: 'F'),
          optionB: _PairOption(word: 'Var', emoji: '✅', phoneme: 'V'),
          correctIndex: 0,
        ),
        _MinimalPairQuestion(
          title: '/f/ ve /v/ Ayırt Etme',
          optionA: _PairOption(word: 'Saf', emoji: '🥛', phoneme: 'F'),
          optionB: _PairOption(word: 'Sav', emoji: '🛡️', phoneme: 'V'),
          correctIndex: 1,
        ),
      ];
    } else if (cleanP == 'c' || cleanP == 'ç') {
      _questions = [
        _MinimalPairQuestion(
          title: '/c/ ve /ç/ Ayırt Etme',
          optionA: _PairOption(word: 'Can', emoji: '❤️', phoneme: 'C'),
          optionB: _PairOption(word: 'Çan', emoji: '🔔', phoneme: 'Ç'),
          correctIndex: 0,
        ),
        _MinimalPairQuestion(
          title: '/c/ ve /ç/ Ayırt Etme',
          optionA: _PairOption(word: 'Cam', emoji: '🪟', phoneme: 'C'),
          optionB: _PairOption(word: 'Çam', emoji: '🌲', phoneme: 'Ç'),
          correctIndex: 1,
        ),
      ];
    } else if (cleanP == 'l') {
      _questions = [
        _MinimalPairQuestion(
          title: '/l/ ve /r/ Ayırt Etme',
          optionA: _PairOption(word: 'Bal', emoji: '🍯', phoneme: 'L'),
          optionB: _PairOption(word: 'Bar', emoji: '🍫', phoneme: 'R'),
          correctIndex: 0,
        ),
        _MinimalPairQuestion(
          title: '/l/ ve /r/ Ayırt Etme',
          optionA: _PairOption(word: 'Sal', emoji: '🪵', phoneme: 'L'),
          optionB: _PairOption(word: 'Sar', emoji: '📦', phoneme: 'R'),
          correctIndex: 0,
        ),
        _MinimalPairQuestion(
          title: '/l/ ve /r/ Ayırt Etme',
          optionA: _PairOption(word: 'Kol', emoji: '💪', phoneme: 'L'),
          optionB: _PairOption(word: 'Kor', emoji: '🔥', phoneme: 'R'),
          correctIndex: 0,
        ),
      ];
    } else if (cleanP == 'z') {
      _questions = [
        _MinimalPairQuestion(
          title: '/z/ ve /s/ Ayırt Etme',
          optionA: _PairOption(word: 'Kaz', emoji: '🪿', phoneme: 'Z'),
          optionB: _PairOption(word: 'Kas', emoji: '💪', phoneme: 'S'),
          correctIndex: 0,
        ),
        _MinimalPairQuestion(
          title: '/z/ ve /s/ Ayırt Etme',
          optionA: _PairOption(word: 'Zil', emoji: '🔔', phoneme: 'Z'),
          optionB: _PairOption(word: 'Sil', emoji: '🧹', phoneme: 'S'),
          correctIndex: 0,
        ),
      ];
    } else if (cleanP == 'm' || cleanP == 'n') {
      _questions = [
        _MinimalPairQuestion(
          title: '/m/ ve /n/ Ayırt Etme',
          optionA: _PairOption(word: 'Masa', emoji: '🪑', phoneme: 'M'),
          optionB: _PairOption(word: 'Nasa', emoji: '🚀', phoneme: 'N'),
          correctIndex: 0,
        ),
        _MinimalPairQuestion(
          title: '/m/ ve /n/ Ayırt Etme',
          optionA: _PairOption(word: 'Mal', emoji: '📦', phoneme: 'M'),
          optionB: _PairOption(word: 'Nal', emoji: '🧲', phoneme: 'N'),
          correctIndex: 1,
        ),
        _MinimalPairQuestion(
          title: '/m/ ve /n/ Ayırt Etme',
          optionA: _PairOption(word: 'Muz', emoji: '🍌', phoneme: 'M'),
          optionB: _PairOption(word: 'Nar', emoji: '🍎', phoneme: 'N'),
          correctIndex: 0,
        ),
      ];
    } else if (cleanP == 'h' || cleanP == 'j') {
      _questions = [
        _MinimalPairQuestion(
          title: '/h/ ve /j/ Ayırt Etme',
          optionA: _PairOption(word: 'Halı', emoji: '🧶', phoneme: 'H'),
          optionB: _PairOption(word: 'Jale', emoji: '👩', phoneme: 'J'),
          correctIndex: 0,
        ),
        _MinimalPairQuestion(
          title: '/h/ ve /j/ Ayırt Etme',
          optionA: _PairOption(word: 'Havuç', emoji: '🥕', phoneme: 'H'),
          optionB: _PairOption(word: 'Jelibon', emoji: '🍬', phoneme: 'J'),
          correctIndex: 1,
        ),
        _MinimalPairQuestion(
          title: '/h/ ve /j/ Ayırt Etme',
          optionA: _PairOption(word: 'Horoz', emoji: '🐓', phoneme: 'H'),
          optionB: _PairOption(word: 'Jeton', emoji: '🪙', phoneme: 'J'),
          correctIndex: 0,
        ),
      ];
    } else {
      // Varsayılan: P ve B Ayırt Etme
      _questions = [
        _MinimalPairQuestion(
          title: '/p/ ve /b/ Ayırt Etme',
          optionA: _PairOption(word: 'Pil', emoji: '🔋', phoneme: 'P'),
          optionB: _PairOption(word: 'Bil', emoji: '🧠', phoneme: 'B'),
          correctIndex: 0,
        ),
        _MinimalPairQuestion(
          title: '/p/ ve /b/ Ayırt Etme',
          optionA: _PairOption(word: 'Pas', emoji: '⚽', phoneme: 'P'),
          optionB: _PairOption(word: 'Bas', emoji: '🦶', phoneme: 'B'),
          correctIndex: 1,
        ),
        _MinimalPairQuestion(
          title: '/p/ ve /b/ Ayırt Etme',
          optionA: _PairOption(word: 'Pak', emoji: '🧼', phoneme: 'P'),
          optionB: _PairOption(word: 'Bak', emoji: '👀', phoneme: 'B'),
          correctIndex: 0,
        ),
        _MinimalPairQuestion(
          title: '/p/ ve /b/ Ayırt Etme',
          optionA: _PairOption(word: 'Pul', emoji: '✉️', phoneme: 'P'),
          optionB: _PairOption(word: 'Bul', emoji: '🔍', phoneme: 'B'),
          correctIndex: 1,
        ),
      ];
    }
  }

  void _playCurrentAudio() {
    if (_isFinished) return;
    final q = _questions[_currentQuestionIndex];
    _audioService.speakTurkish(
      q.correctOption.word,
      phoneme: q.correctOption.phoneme,
    );
  }

  void _selectAnswer(int index) {
    if (_answered) return;

    final q = _questions[_currentQuestionIndex];
    final bool isCorrect = index == q.correctIndex;

    setState(() {
      _answered = true;
      _selectedAnswerIndex = index;
      if (isCorrect) {
        _score++;
        _sfx.playSuccessDing();
      } else {
        _sfx.playPopSound();
      }
    });

    Future.delayed(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      if (_currentQuestionIndex + 1 < _questions.length) {
        setState(() {
          _currentQuestionIndex++;
          _answered = false;
          _selectedAnswerIndex = null;
        });
        _playCurrentAudio();
      } else {
        setState(() {
          _isFinished = true;
        });
        _sfx.playVictoryFanfare();
        _rewardState.addReward(earnedStars: 3, earnedXp: 50, earnedGems: 25);
      }
    });
  }

  void _restartTest() {
    setState(() {
      _currentQuestionIndex = 0;
      _score = 0;
      _answered = false;
      _selectedAnswerIndex = null;
      _isFinished = false;
    });
    _playCurrentAudio();
  }

  @override
  Widget build(BuildContext context) {
    if (_isFinished) {
      final total = _questions.length;
      final ratio = total > 0 ? _score / total : 0.0;

      final String emoji;
      final String title;
      final String feedback;
      final Color bgColor;
      final Color textColor;
      final Color titleColor;
      final bool isSuccess = ratio >= 0.75;

      if (isSuccess) {
        emoji = '🏆🌟';
        title = 'MUHTEŞEM KULAK BAŞARISI!';
        feedback = 'Harika! Beynin artık benzer sesleri mükemmel ayırt edebiliyor. Bu sayede konuşurken dili ve dudağı doğru konumlandıracaksın!';
        bgColor = const Color(0xFFE8F5E9);
        textColor = const Color(0xFF2E7D32);
        titleColor = const Color(0xFF1B5E20);
      } else if (ratio >= 0.5) {
        emoji = '👂✨';
        title = 'GÜZEL DENEME!';
        feedback = 'Yarı yarıya doğru bildin! Kulakların seslerin farkını yakalamaya başladı. Bir kez daha dinleyerek 4\'te 4 yapabilirsin!';
        bgColor = const Color(0xFFFFF8E1);
        textColor = const Color(0xFFE65100);
        titleColor = const Color(0xFFBF360C);
      } else {
        emoji = '🎧💪';
        title = 'BİRAZ DAHA PRATİK YAPALIM!';
        feedback = 'Benzer sesleri birbirinden ayırmak başta biraz zor olabilir. Kulaklarını eğitmek için acele etme, tekrar dinleyip dudakların ve boğazın farkını hisset!';
        bgColor = const Color(0xFFFFEBEE);
        textColor = const Color(0xFFC62828);
        titleColor = const Color(0xFFB71C1C);
      }

      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        child: Container(
          width: 380,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            color: Colors.white,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 48)),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: titleColor),
              ),
              const SizedBox(height: 6),
              Text(
                'Skor: $_score / ${_questions.length} Doğru Dinleme!',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: textColor),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  feedback,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textColor, height: 1.4),
                ),
              ),
              const SizedBox(height: 18),
              if (!isSuccess)
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: BorderSide(color: titleColor, width: 2),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        icon: Icon(Icons.refresh_rounded, color: titleColor, size: 18),
                        label: Text(
                          'Tekrar Dene 🔄',
                          style: TextStyle(fontWeight: FontWeight.w900, color: titleColor, fontSize: 12.5),
                        ),
                        onPressed: _restartTest,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueGrey,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Kapat', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5)),
                      ),
                    ),
                  ],
                )
              else
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF58CC02),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('HARİKA, PRATİĞE DÖN 🎯', style: TextStyle(fontWeight: FontWeight.w900)),
                ),
            ],
          ),
        ),
      );
    }

    final q = _questions[_currentQuestionIndex];

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      child: Container(
        width: 420,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          gradient: const LinearGradient(
            colors: [Color(0xFFE0F7FA), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          border: Border.all(color: const Color(0xFF00ACC1), width: 2.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Üst Başlık
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFB2EBF2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Text('👂', style: TextStyle(fontSize: 24)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kulak Eğitimi (Minimal Çiftler)',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF006064),
                        ),
                      ),
                      Text(
                        'Soru ${_currentQuestionIndex + 1} / ${_questions.length} - Hangisini Duydun?',
                        style: const TextStyle(fontSize: 11, color: Colors.black54, fontWeight: FontWeight.w700),
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
            const SizedBox(height: 16),

            // Sesi Dinle Butonu (Büyük Kulak)
            InkWell(
              onTap: _playCurrentAudio,
              borderRadius: BorderRadius.circular(24),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF00BCD4),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [
                    BoxShadow(color: Color(0x3300BCD4), blurRadius: 10, offset: Offset(0, 4)),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.volume_up_rounded, color: Colors.white, size: 28),
                    SizedBox(width: 8),
                    Text(
                      'Sesi Tekrar Dinle 🔊',
                      style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 15),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // İKİ GÖRSEL SEÇENEK KARTI
            Row(
              children: [
                Expanded(child: _buildChoiceCard(0, q.optionA, q.correctIndex)),
                const SizedBox(width: 14),
                Expanded(child: _buildChoiceCard(1, q.optionB, q.correctIndex)),
              ],
            ),
            const SizedBox(height: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildChoiceCard(int index, _PairOption option, int correctIndex) {
    Color cardColor = Colors.white;
    Color borderColor = Colors.grey[300]!;

    if (_answered) {
      if (index == correctIndex) {
        cardColor = const Color(0xFFE8F5E9);
        borderColor = const Color(0xFF00E676);
      } else if (index == _selectedAnswerIndex) {
        cardColor = const Color(0xFFFFEBEE);
        borderColor = const Color(0xFFF44336);
      }
    }

    return InkWell(
      onTap: () => _selectAnswer(index),
      borderRadius: BorderRadius.circular(22),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: borderColor, width: 3),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
          ],
        ),
        child: Column(
          children: [
            Text(option.emoji, style: const TextStyle(fontSize: 44)),
            const SizedBox(height: 8),
            Text(
              option.word,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF263238)),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF00BCD4).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '/${option.phoneme.toLowerCase()}/ sesi',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF00838F)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
