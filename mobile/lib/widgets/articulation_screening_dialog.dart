import 'dart:async';
import 'package:flutter/material.dart';
import '../services/audio_speech_service.dart';
import '../services/sound_effects_service.dart';
import '../models/reward_state.dart';

class _PositionWord {
  final String position; // 'Başta', 'Ortada', 'Sonda'
  final String word;
  final String emoji;

  const _PositionWord({
    required this.position,
    required this.word,
    required this.emoji,
  });
}

class _ScreeningSound {
  final String phoneme;
  final String hint;
  final List<_PositionWord> positions;

  const _ScreeningSound({
    required this.phoneme,
    required this.hint,
    required this.positions,
  });
}

/// 🔍 2 DAKİKALIK AKILLI ARTİKÜLASYON TARAMA TESTİ
/// Çocuğun hangi seslerde ve hangi kelime pozisyonlarında (Başta, Ortada, Sonda) zorlandığını teşhis eden klinik modül.
class ArticulationScreeningDialog extends StatefulWidget {
  final ValueChanged<String>? onSelectRecommendedSound;

  const ArticulationScreeningDialog({
    super.key,
    this.onSelectRecommendedSound,
  });

  @override
  State<ArticulationScreeningDialog> createState() => _ArticulationScreeningDialogState();
}

class _ArticulationScreeningDialogState extends State<ArticulationScreeningDialog> {
  final AudioSpeechService _audioService = AudioSpeechService();
  final SoundEffectsService _sfx = SoundEffectsService();
  final RewardState _rewardState = RewardState();

  static const List<_ScreeningSound> _sounds = [
    _ScreeningSound(phoneme: 'P', hint: 'Çift Dudak Patlamalı', positions: [
      _PositionWord(position: 'Başta', word: 'Pasta', emoji: '🎂'),
      _PositionWord(position: 'Ortada', word: 'Köpek', emoji: '🐶'),
      _PositionWord(position: 'Sonda', word: 'Top', emoji: '⚽'),
    ]),
    _ScreeningSound(phoneme: 'B', hint: 'Çift Dudak Ötümlü', positions: [
      _PositionWord(position: 'Başta', word: 'Balık', emoji: '🐟'),
      _PositionWord(position: 'Ortada', word: 'Araba', emoji: '🚗'),
      _PositionWord(position: 'Sonda', word: 'Web', emoji: '🌐'),
    ]),
    _ScreeningSound(phoneme: 'T', hint: 'Diş Yuvasıl Patlamalı', positions: [
      _PositionWord(position: 'Başta', word: 'Tavşan', emoji: '🐰'),
      _PositionWord(position: 'Ortada', word: 'Kutu', emoji: '📦'),
      _PositionWord(position: 'Sonda', word: 'At', emoji: '🐴'),
    ]),
    _ScreeningSound(phoneme: 'D', hint: 'Diş Yuvasıl Ötümlü', positions: [
      _PositionWord(position: 'Başta', word: 'Dede', emoji: '👴'),
      _PositionWord(position: 'Ortada', word: 'Kedi', emoji: '🐱'),
      _PositionWord(position: 'Sonda', word: 'Kod', emoji: '💻'),
    ]),
    _ScreeningSound(phoneme: 'K', hint: 'Yumuşak Damak Patlamalı', positions: [
      _PositionWord(position: 'Başta', word: 'Köpek', emoji: '🐶'),
      _PositionWord(position: 'Ortada', word: 'Şeker', emoji: '🍬'),
      _PositionWord(position: 'Sonda', word: 'Balık', emoji: '🐟'),
    ]),
    _ScreeningSound(phoneme: 'G', hint: 'Yumuşak Damak Ötümlü', positions: [
      _PositionWord(position: 'Başta', word: 'Güneş', emoji: '☀️'),
      _PositionWord(position: 'Ortada', word: 'Gaga', emoji: '🐦'),
      _PositionWord(position: 'Sonda', word: 'Lig', emoji: '🏆'),
    ]),
    _ScreeningSound(phoneme: 'F', hint: 'Dudak-Diş Sürtünmeli', positions: [
      _PositionWord(position: 'Başta', word: 'Fil', emoji: '🐘'),
      _PositionWord(position: 'Ortada', word: 'Zürafa', emoji: '🦒'),
      _PositionWord(position: 'Sonda', word: 'Şef', emoji: '👨‍🍳'),
    ]),
    _ScreeningSound(phoneme: 'V', hint: 'Dudak-Diş Ötümlü Sürtünmeli', positions: [
      _PositionWord(position: 'Başta', word: 'Vazo', emoji: '🏺'),
      _PositionWord(position: 'Ortada', word: 'Havuç', emoji: '🥕'),
      _PositionWord(position: 'Sonda', word: 'Ev', emoji: '🏠'),
    ]),
    _ScreeningSound(phoneme: 'S', hint: 'Diş Yuvasıl Sürtünmeli', positions: [
      _PositionWord(position: 'Başta', word: 'Saat', emoji: '⏰'),
      _PositionWord(position: 'Ortada', word: 'Masa', emoji: '🪑'),
      _PositionWord(position: 'Sonda', word: 'Otobüs', emoji: '🚌'),
    ]),
    _ScreeningSound(phoneme: 'Z', hint: 'Diş Yuvasıl Ötümlü Sürtünmeli', positions: [
      _PositionWord(position: 'Başta', word: 'Zebra', emoji: '🦓'),
      _PositionWord(position: 'Ortada', word: 'Üzüm', emoji: '🍇'),
      _PositionWord(position: 'Sonda', word: 'Muz', emoji: '🍌'),
    ]),
    _ScreeningSound(phoneme: 'Ş', hint: 'Diş Yuvası Ardı Sürtünmeli', positions: [
      _PositionWord(position: 'Başta', word: 'Şapka', emoji: '👒'),
      _PositionWord(position: 'Ortada', word: 'Kaşık', emoji: '🥄'),
      _PositionWord(position: 'Sonda', word: 'Kuş', emoji: '🐦'),
    ]),
    _ScreeningSound(phoneme: 'J', hint: 'Diş Yuvası Ardı Ötümlü', positions: [
      _PositionWord(position: 'Başta', word: 'Jelibon', emoji: '🍬'),
      _PositionWord(position: 'Ortada', word: 'Pijama', emoji: '🛌'),
      _PositionWord(position: 'Sonda', word: 'Plaj', emoji: '🏖️'),
    ]),
    _ScreeningSound(phoneme: 'H', hint: 'Gırtlak Sürtünmeli', positions: [
      _PositionWord(position: 'Başta', word: 'Havuç', emoji: '🥕'),
      _PositionWord(position: 'Ortada', word: 'Kahve', emoji: '☕'),
      _PositionWord(position: 'Sonda', word: 'Timsah', emoji: '🐊'),
    ]),
    _ScreeningSound(phoneme: 'Ç', hint: 'Ön Damak Patlamalı Sürtünmeli', positions: [
      _PositionWord(position: 'Başta', word: 'Çilek', emoji: '🍓'),
      _PositionWord(position: 'Ortada', word: 'Böcek', emoji: '🐞'),
      _PositionWord(position: 'Sonda', word: 'Ağaç', emoji: '🌳'),
    ]),
    _ScreeningSound(phoneme: 'C', hint: 'Ön Damak Ötümlü Sürtünmeli', positions: [
      _PositionWord(position: 'Başta', word: 'Ceviz', emoji: '🥜'),
      _PositionWord(position: 'Ortada', word: 'Tencere', emoji: '🍲'),
      _PositionWord(position: 'Sonda', word: 'Sac', emoji: '🍳'),
    ]),
    _ScreeningSound(phoneme: 'M', hint: 'Genizsi Dudak Sesi', positions: [
      _PositionWord(position: 'Başta', word: 'Muz', emoji: '🍌'),
      _PositionWord(position: 'Ortada', word: 'Elma', emoji: '🍎'),
      _PositionWord(position: 'Sonda', word: 'Kalem', emoji: '✏️'),
    ]),
    _ScreeningSound(phoneme: 'N', hint: 'Diş Yuvasıl Genizsi', positions: [
      _PositionWord(position: 'Başta', word: 'Nar', emoji: '🍎'),
      _PositionWord(position: 'Ortada', word: 'Anne', emoji: '👩'),
      _PositionWord(position: 'Sonda', word: 'Balon', emoji: '🎈'),
    ]),
    _ScreeningSound(phoneme: 'L', hint: 'Akıcı Yan Ses', positions: [
      _PositionWord(position: 'Başta', word: 'Limon', emoji: '🍋'),
      _PositionWord(position: 'Ortada', word: 'Kalem', emoji: '✏️'),
      _PositionWord(position: 'Sonda', word: 'Gül', emoji: '🌹'),
    ]),
    _ScreeningSound(phoneme: 'R', hint: 'Diş Yuvasıl Titrek', positions: [
      _PositionWord(position: 'Başta', word: 'Roket', emoji: '🚀'),
      _PositionWord(position: 'Ortada', word: 'Arı', emoji: '🐝'),
      _PositionWord(position: 'Sonda', word: 'Kar', emoji: '❄️'),
    ]),
    _ScreeningSound(phoneme: 'Y', hint: 'Damak Daralmalı', positions: [
      _PositionWord(position: 'Başta', word: 'Yıldız', emoji: '⭐'),
      _PositionWord(position: 'Ortada', word: 'Ayı', emoji: '🐻'),
      _PositionWord(position: 'Sonda', word: 'Ay', emoji: '🌙'),
    ]),
  ];

  int _currentSoundIndex = 0;
  int _currentPosIndex = 0;
  bool _isListening = false;
  bool _isPlayingAudio = false;
  String _liveSpeech = '';
  int _secondsLeft = 8;
  Timer? _countdownTimer;

  SpeechEvaluationResult? _lastResult;
  final Map<String, bool> _results = {}; // '${phoneme}_${position}' -> isCorrect
  bool _isFinished = false;

  _ScreeningSound get _currentSound => _sounds[_currentSoundIndex];
  _PositionWord get _currentPosWord => _currentSound.positions[_currentPosIndex];
  String _resultKey(String phoneme, String position) => '${phoneme}_$position';

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _audioService.stopListening();
    super.dispose();
  }

  /// Terapist sesinden örnek telaffuzu dinlet
  void _playModelVoice() async {
    if (_isPlayingAudio || _isListening) return;
    _sfx.playPopSound();
    final sound = _currentSound;
    final posWord = _currentPosWord;
    setState(() => _isPlayingAudio = true);

    await _audioService.speakTurkish(
      posWord.word,
      phoneme: sound.phoneme,
    );

    if (mounted) {
      setState(() => _isPlayingAudio = false);
    }
  }

  /// Mikrofonu aç ve çocuğu dinle
  void _startListeningForWord() async {
    if (_isListening || _isFinished) return;

    // Mikrofon iznini kontrol et
    final hasPerm = await _audioService.requestMicrophonePermission();
    if (!hasPerm && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Lütfen tarayıcı adres çubuğundaki kilit simgesinden mikrofona İZİN VERİN!'),
          backgroundColor: Color(0xFFD32F2F),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final sound = _currentSound;
    final posWord = _currentPosWord;
    _sfx.playPopSound();

    setState(() {
      _isListening = true;
      _lastResult = null;
      _liveSpeech = 'Dinleniyor... Şimdi "${posWord.word}" de! 🎤';
      _secondsLeft = 8;
    });

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_secondsLeft <= 1) {
        timer.cancel();
      } else {
        setState(() => _secondsLeft--);
      }
    });

    final res = await _audioService.listenAndEvaluate(
      targetText: posWord.word,
      phoneme: sound.phoneme,
      duration: const Duration(seconds: 8),
      onLiveSpeech: (text) {
        if (mounted) {
          setState(() => _liveSpeech = '🗣️ Algılanan: "$text"');
        }
      },
    );

    _countdownTimer?.cancel();
    if (!mounted) return;

    // Değerlendirme sonucunu kaydet ve net görsel geri bildirim sun
    setState(() {
      _isListening = false;
      _lastResult = res;
      _results[_resultKey(sound.phoneme, posWord.position)] = res.isMatched;
    });

    _rewardState.recordAttempt(
      phoneme: sound.phoneme,
      position: posWord.position,
      isCorrect: res.isMatched,
    );

    if (res.isMatched) {
      _sfx.playSuccessDing();
      _rewardState.unlockSticker(posWord.word);
      _rewardState.addReward(earnedStars: 1, earnedXp: 15, earnedGems: 5);
    }
  }

  /// Kullanıcı konuşmayı bitirdiğinde erken durdur
  void _stopListeningEarly() {
    _countdownTimer?.cancel();
    _audioService.stopListening();
  }

  /// Sonraki pozisyona veya sonraki sese geç
  void _advanceToNextItem() {
    _sfx.playPopSound();
    if (_currentPosIndex + 1 < _currentSound.positions.length) {
      setState(() {
        _currentPosIndex++;
        _lastResult = null;
        _liveSpeech = '';
      });
    } else if (_currentSoundIndex + 1 < _sounds.length) {
      setState(() {
        _currentSoundIndex++;
        _currentPosIndex = 0;
        _lastResult = null;
        _liveSpeech = '';
      });
    } else {
      setState(() {
        _isFinished = true;
      });
      _sfx.playVictoryFanfare();
      _rewardState.recordPracticeToday();
      _rewardState.addReward(earnedStars: 5, earnedXp: 100, earnedGems: 40);
    }
  }

  /// Terapist / Ebeveyn için manuel hızlı değerlendirme
  void _manualScore(bool isCorrect) {
    final sound = _currentSound;
    final posWord = _currentPosWord;
    _results[_resultKey(sound.phoneme, posWord.position)] = isCorrect;
    _rewardState.recordAttempt(
      phoneme: sound.phoneme,
      position: posWord.position,
      isCorrect: isCorrect,
    );

    if (isCorrect) {
      _sfx.playSuccessDing();
      _rewardState.addReward(earnedStars: 1, earnedXp: 15, earnedGems: 5);
    } else {
      _sfx.playPopSound();
    }

    _advanceToNextItem();
  }

  @override
  Widget build(BuildContext context) {
    if (_isFinished) {
      return _buildFinishedReportDialog();
    }

    final sound = _currentSound;
    final posWord = _currentPosWord;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      child: Container(
        width: 460,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          gradient: const LinearGradient(
            colors: [Color(0xFFE3F2FD), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          border: Border.all(color: const Color(0xFF2196F3), width: 2.5),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ÜST BAŞLIK & İLERLEME SAYACI
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFBBDEFB),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Text('🔍', style: TextStyle(fontSize: 24)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Hızlı Artikülasyon Taraması',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0D47A1),
                          ),
                        ),
                        Text(
                          'Ses ${_currentSoundIndex + 1} / ${_sounds.length} • /${sound.phoneme.toLowerCase()}/ (${sound.hint})',
                          style: const TextStyle(fontSize: 11.5, color: Colors.black54, fontWeight: FontWeight.w700),
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

              // 20 SESLİK İLERLEME ÇUBUĞU (Tıklanabilir)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(_sounds.length, (i) {
                    final s = _sounds[i];
                    final posResults = s.positions
                        .map((pw) => _results[_resultKey(s.phoneme, pw.position)])
                        .whereType<bool>()
                        .toList();
                    final isDone = posResults.isNotEmpty;
                    final allCorrect = isDone && posResults.every((v) => v);
                    final isCurrent = i == _currentSoundIndex;

                    return GestureDetector(
                      onTap: _isListening
                          ? null
                          : () {
                              _sfx.playPopSound();
                              setState(() {
                                _currentSoundIndex = i;
                                _currentPosIndex = 0;
                                _lastResult = null;
                                _liveSpeech = '';
                              });
                            },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 2.5),
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: isCurrent
                              ? const Color(0xFF1E88E5)
                              : (isDone
                                  ? (allCorrect ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE))
                                  : Colors.grey[200]),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isCurrent
                                ? const Color(0xFF0D47A1)
                                : (isDone
                                    ? (allCorrect ? const Color(0xFF4CAF50) : const Color(0xFFE53935))
                                    : Colors.transparent),
                            width: isCurrent ? 1.5 : 1.0,
                          ),
                        ),
                        child: Text(
                          '/${s.phoneme.toLowerCase()}/',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w900,
                            color: isCurrent
                                ? Colors.white
                                : (isDone
                                    ? (allCorrect ? const Color(0xFF2E7D32) : const Color(0xFFC62828))
                                    : Colors.grey[600]),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 10),

              // BAŞTA / ORTADA / SONDA POZİSYON SEÇİCİ
              Row(
                children: List.generate(sound.positions.length, (pIdx) {
                  final pw = sound.positions[pIdx];
                  final pKey = _resultKey(sound.phoneme, pw.position);
                  final pRes = _results[pKey];
                  final isSelected = pIdx == _currentPosIndex;
                  return Expanded(
                    child: GestureDetector(
                      onTap: _isListening
                          ? null
                          : () {
                              _sfx.playPopSound();
                              setState(() {
                                _currentPosIndex = pIdx;
                                _lastResult = null;
                                _liveSpeech = '';
                              });
                            },
                      child: Container(
                        margin: EdgeInsets.only(right: pIdx < 2 ? 6 : 0),
                        padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 6),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF1565C0)
                              : (pRes == true
                                  ? const Color(0xFFE8F5E9)
                                  : (pRes == false ? const Color(0xFFFFEBEE) : const Color(0xFFF1F5F9))),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF0D47A1)
                                : (pRes == true
                                    ? const Color(0xFF66BB6A)
                                    : (pRes == false ? const Color(0xFFEF5350) : const Color(0xFFCBD5E1))),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(pw.emoji, style: const TextStyle(fontSize: 13)),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                pw.position,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w900,
                                  color: isSelected
                                      ? Colors.white
                                      : (pRes == true
                                          ? const Color(0xFF2E7D32)
                                          : (pRes == false ? const Color(0xFFC62828) : const Color(0xFF334155))),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 12),

              // BÜYÜK GÖRSEL & KELİME KARTI
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFF90CAF9), width: 2),
                  boxShadow: const [
                    BoxShadow(color: Color(0x1A2196F3), blurRadius: 10, offset: Offset(0, 4)),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE3F2FD),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '/${sound.phoneme.toLowerCase()}/ Sesi • ${posWord.position} Pozisyon',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFF1565C0)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(posWord.emoji, style: const TextStyle(fontSize: 60)),
                    const SizedBox(height: 8),
                    Text(
                      posWord.word,
                      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Color(0xFF1565C0)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'İpucu: "${posWord.word}" de ve mikrofona söyle!',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.black54),
                    ),
                    const SizedBox(height: 10),

                    // Model Sesi Dinleme Butonu
                    OutlinedButton.icon(
                      onPressed: _isListening ? null : _playModelVoice,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF1976D2),
                        side: const BorderSide(color: Color(0xFF64B5F6), width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      ),
                      icon: Icon(_isPlayingAudio ? Icons.volume_up_rounded : Icons.hearing_rounded, size: 18),
                      label: Text(
                        _isPlayingAudio ? 'Seslendiriliyor...' : '🔊 Nasıl Söylenir? Dinle',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // DEĞERLENDİRME SONUÇ KARTI (FEEDBACK BANNER)
              if (_lastResult != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _lastResult!.isMatched ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: _lastResult!.isMatched ? const Color(0xFF4CAF50) : const Color(0xFFFF9800),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _lastResult!.isMatched ? const Color(0x224CAF50) : const Color(0x22FF9800),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(_lastResult!.isMatched ? '🎉' : '👂', style: const TextStyle(fontSize: 22)),
                          const SizedBox(width: 8),
                          Text(
                            _lastResult!.isMatched ? 'DOĞRU SESLETİM! (+15 XP ⭐)' : 'FARKLI BİR SES DUYULDU',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: _lastResult!.isMatched ? const Color(0xFF2E7D32) : const Color(0xFFE65100),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Hedef: "${posWord.word}"  •  Duyulan: "${_lastResult!.recognizedText.isNotEmpty ? _lastResult!.recognizedText : '(Net duyulamadı)'}"',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: Color(0xFF37474F)),
                      ),
                      const SizedBox(height: 10),

                      // Sonuç Aksiyonları
                      Row(
                        children: [
                          if (!_lastResult!.isMatched) ...[
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _startListeningForWord,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFFE65100),
                                  side: const BorderSide(color: Color(0xFFFF9800), width: 1.5),
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                ),
                                icon: const Icon(Icons.refresh_rounded, size: 18),
                                label: const Text('Tekrar Dene 🔄', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _advanceToNextItem,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _lastResult!.isMatched ? const Color(0xFF2E7D32) : const Color(0xFF1976D2),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                              icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                              label: Text(
                                _currentPosIndex + 1 < _currentSound.positions.length
                                    ? 'Sonraki Pozisyona Geç ➔'
                                    : (_currentSoundIndex + 1 < _sounds.length ? 'Sonraki Sese Geç ➔' : 'Taramayı Tamamla 🏁'),
                                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ] else if (_liveSpeech.isNotEmpty) ...[
                // Canlı Dinleme Durumu
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFFF9800), width: 1.5),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('🎙️', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          _liveSpeech,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5, color: Color(0xFFE65100)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // MİKROFON İLE KONUŞMA BUTONU
              if (_lastResult == null)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isListening ? const Color(0xFFE53935) : const Color(0xFF58CC02),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      elevation: 4,
                    ),
                    icon: Icon(_isListening ? Icons.stop_circle_rounded : Icons.mic_rounded, size: 24),
                    label: Text(
                      _isListening ? 'BİTTİ / DEĞERLENDİR (${_secondsLeft}s) 🛑' : 'MİKROFONLA SÖYLE 🎤',
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                    ),
                    onPressed: _isListening ? _stopListeningEarly : _startListeningForWord,
                  ),
                ),

              // TERAPİST / EBEVEYN HIZLI MANUEL DEĞERLENDİRME BAR
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Terapist Hızlı Puanlama: ',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.grey[600]),
                  ),
                  InkWell(
                    onTap: () => _manualScore(true),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF81C784)),
                      ),
                      child: const Row(
                        children: [
                          Text('👍', style: TextStyle(fontSize: 12)),
                          SizedBox(width: 3),
                          Text('Doğru', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900, color: Color(0xFF2E7D32))),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => _manualScore(false),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEBEE),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE57373)),
                      ),
                      child: const Row(
                        children: [
                          Text('👎', style: TextStyle(fontSize: 12)),
                          SizedBox(width: 3),
                          Text('Hatalı', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900, color: Color(0xFFC62828))),
                        ],
                      ),
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

  /// TARAMA TESTİ TAMAMLANDIĞINDA AÇILAN KLİNİK RAPOR
  Widget _buildFinishedReportDialog() {
    final totalTested = _results.length;
    final correctCount = _results.values.where((v) => v).length;
    final incorrectPhonemes = _sounds
        .where((s) => s.positions.any((pw) => _results[_resultKey(s.phoneme, pw.position)] == false))
        .map((s) => '/${s.phoneme.toLowerCase()}/')
        .toList();

    final recommended = incorrectPhonemes.isNotEmpty ? incorrectPhonemes.first : '/r/';
    final percent = totalTested > 0 ? ((correctCount / totalTested) * 100).round() : 0;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      child: Container(
        width: 460,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          color: Colors.white,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🔬📊', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 8),
              const Text(
                'ARTİKÜLASYON TARAMA RAPORU',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF0D47A1)),
              ),
              const SizedBox(height: 4),
              Text(
                'Genel Fonetik Uyum: $correctCount / $totalTested (%$percent Başarı)',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF1976D2)),
              ),
              const SizedBox(height: 14),

              // Ödül Tebriği
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF81C784)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('🎉', style: TextStyle(fontSize: 20)),
                    SizedBox(width: 8),
                    Text(
                      '+5 ⭐  +100 XP  +40 💎 Kazanıldı!',
                      style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF2E7D32), fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Klinik Tavsiye Kutusu
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFFFB74D)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.lightbulb_rounded, color: Color(0xFFE65100), size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Klinik Öncelik Analizi',
                          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Color(0xFFE65100)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      incorrectPhonemes.isEmpty
                          ? 'Mükemmel telaffuz! Çocuğunuz taranan ${_sounds.length} klinik sesin tüm pozisyonlarını başarıyla üretiyor.'
                          : 'Tespit edilen öncelikli çalışma gerektiren sesler: ${incorrectPhonemes.join(", ")}.\n'
                              'Tavsiye edilen ilk seans: $recommended sesi basamağıdır.',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF37474F), height: 1.4),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Tavsiye Edilen Sese Git Butonu
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF58CC02),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    elevation: 3,
                  ),
                  icon: const Icon(Icons.play_arrow_rounded, size: 24),
                  label: Text(
                    'Önerilen "$recommended" Sesine Başla 🚀',
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13.5),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    widget.onSelectRecommendedSound?.call(recommended);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
