import 'dart:async';
import 'package:flutter/material.dart';
import '../services/audio_speech_service.dart';
import '../services/sound_effects_service.dart';
import '../models/reward_state.dart';

class _ScreeningItem {
  final String word;
  final String phoneme;
  final String emoji;
  final String hint;

  const _ScreeningItem({
    required this.word,
    required this.phoneme,
    required this.emoji,
    required this.hint,
  });
}

/// 🔍 2 DAKİKALIK AKILLI ARTİKÜLASYON TARAMA TESTİ
/// Çocuğun hangi seslerde zorlandığını saniyeler içinde teşhis eden klinik ön değerlendirme modülü.
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

  static const List<_ScreeningItem> _items = [
    _ScreeningItem(word: 'Pasta', phoneme: 'P', emoji: '🎂', hint: 'Çift Dudak Patlamalı'),
    _ScreeningItem(word: 'Balık', phoneme: 'B', emoji: '🐟', hint: 'Çift Dudak Ötümlü'),
    _ScreeningItem(word: 'Tavşan', phoneme: 'T', emoji: '🐰', hint: 'Diş Yuvasıl Patlamalı'),
    _ScreeningItem(word: 'Dede', phoneme: 'D', emoji: '👴', hint: 'Diş Yuvasıl Ötümlü'),
    _ScreeningItem(word: 'Saat', phoneme: 'S', emoji: '⏰', hint: 'Diş Yuvasıl Sürtünmeli'),
    _ScreeningItem(word: 'Şapka', phoneme: 'Ş', emoji: '👒', hint: 'Diş Yuvası Ardı Sürtünmeli'),
    _ScreeningItem(word: 'Köpek', phoneme: 'K', emoji: '🐶', hint: 'Yumuşak Damak Patlamalı'),
    _ScreeningItem(word: 'Muz', phoneme: 'M', emoji: '🍌', hint: 'Genizsi Dudak Sesi'),
    _ScreeningItem(word: 'Roket', phoneme: 'R', emoji: '🚀', hint: 'Diş Yuvasıl Titrek'),
    _ScreeningItem(word: 'Limon', phoneme: 'L', emoji: '🍋', hint: 'Akıcı Yan Ses'),
    _ScreeningItem(word: 'Yıldız', phoneme: 'Y', emoji: '⭐', hint: 'Damak Daralmalı'),
  ];

  int _currentIndex = 0;
  bool _isListening = false;
  bool _isPlayingAudio = false;
  String _liveSpeech = '';
  int _secondsLeft = 8;
  Timer? _countdownTimer;

  SpeechEvaluationResult? _lastResult;
  final Map<String, bool> _results = {}; // phoneme -> isCorrect
  final Map<String, String> _recognizedWords = {}; // phoneme -> what was heard
  bool _isFinished = false;

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
    final item = _items[_currentIndex];
    setState(() => _isPlayingAudio = true);

    await _audioService.speakTurkish(
      item.word,
      phoneme: item.phoneme,
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

    final item = _items[_currentIndex];
    _sfx.playPopSound();

    setState(() {
      _isListening = true;
      _lastResult = null;
      _liveSpeech = 'Dinleniyor... Şimdi "${item.word}" de! 🎤';
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
      targetText: item.word,
      phoneme: item.phoneme,
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
      _recognizedWords[item.phoneme] = res.recognizedText.isNotEmpty ? res.recognizedText : '(Sessiz)';
      _results[item.phoneme] = res.isMatched;
    });

    _rewardState.recordAttempt(
      phoneme: item.phoneme,
      position: 'Başta',
      isCorrect: res.isMatched,
    );

    if (res.isMatched) {
      _sfx.playSuccessDing();
      _rewardState.unlockSticker(item.word);
      _rewardState.addReward(earnedStars: 1, earnedXp: 15, earnedGems: 5);
    }
  }

  /// Kullanıcı konuşmayı bitirdiğinde erken durdur
  void _stopListeningEarly() {
    _countdownTimer?.cancel();
    _audioService.stopListening();
  }

  /// Sonraki kelimeye geç
  void _advanceToNextItem() {
    _sfx.playPopSound();
    if (_currentIndex + 1 < _items.length) {
      setState(() {
        _currentIndex++;
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
    final item = _items[_currentIndex];
    _results[item.phoneme] = isCorrect;
    _recognizedWords[item.phoneme] = isCorrect ? item.word : '(Farklı Sesletim)';

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

    final item = _items[_currentIndex];

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
                          'Madde ${_currentIndex + 1} / ${_items.length} • /${item.phoneme.toLowerCase()}/ Sesi (${item.hint})',
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

              // 11 SESLİK İLERLEME ÇUBUĞU (Progress Dots)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(_items.length, (i) {
                    final p = _items[i].phoneme;
                    final isDone = _results.containsKey(p);
                    final isCorrect = _results[p] == true;
                    final isCurrent = i == _currentIndex;

                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2.5),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? const Color(0xFF1E88E5)
                            : (isDone
                                ? (isCorrect ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE))
                                : Colors.grey[200]),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isCurrent
                              ? const Color(0xFF0D47A1)
                              : (isDone
                                  ? (isCorrect ? const Color(0xFF4CAF50) : const Color(0xFFE53935))
                                  : Colors.transparent),
                          width: isCurrent ? 1.5 : 1.0,
                        ),
                      ),
                      child: Text(
                        '/${p.toLowerCase()}/',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w900,
                          color: isCurrent
                              ? Colors.white
                              : (isDone
                                  ? (isCorrect ? const Color(0xFF2E7D32) : const Color(0xFFC62828))
                                  : Colors.grey[600]),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 14),

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
                    Text(item.emoji, style: const TextStyle(fontSize: 60)),
                    const SizedBox(height: 8),
                    Text(
                      item.word,
                      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Color(0xFF1565C0)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'İpucu: "${item.word}" de ve mikrofona söyle!',
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
                        'Hedef: "${item.word}"  •  Duyulan: "${_lastResult!.recognizedText.isNotEmpty ? _lastResult!.recognizedText : '(Net duyulamadı)'}"',
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
                                _currentIndex + 1 < _items.length ? 'Sonraki Sese Geç ➔' : 'Taramayı Tamamla 🏁',
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
    final correctCount = _results.values.where((v) => v).length;
    final incorrectPhonemes = _results.entries
        .where((e) => !e.value)
        .map((e) => '/${e.key.toLowerCase()}/')
        .toList();

    final recommended = incorrectPhonemes.isNotEmpty ? incorrectPhonemes.first : '/r/';
    final percent = ((correctCount / _items.length) * 100).round();

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
                'Genel Fonetik Uyum: $correctCount / ${_items.length} (%$percent Başarı)',
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
                          ? 'Mükemmel telaffuz! Çocuğunuz taranan 11 temel sesin tamamını yaş gelişimine uygun olarak başarıyla üretiyor.'
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
