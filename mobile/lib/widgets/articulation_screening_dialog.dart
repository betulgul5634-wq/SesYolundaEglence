import 'package:flutter/material.dart';
import '../services/audio_speech_service.dart';
import '../models/reward_state.dart';

class _ScreeningItem {
  final String word;
  final String phoneme;
  final String emoji;
  final String hint;

  _ScreeningItem({
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
  final RewardState _rewardState = RewardState();

  final List<_ScreeningItem> _items = [
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
  String _liveSpeech = '';
  final Map<String, bool> _results = {}; // phoneme -> isCorrect
  bool _isFinished = false;

  void _startListeningForWord() async {
    if (_isListening || _isFinished) return;

    final item = _items[_currentIndex];

    setState(() {
      _isListening = true;
      _liveSpeech = 'Dinleniyor... Konuşun 🎤';
    });

    final res = await _audioService.listenAndEvaluate(
      targetText: item.word,
      phoneme: item.phoneme,
      duration: const Duration(seconds: 4),
      onLiveSpeech: (text) {
        if (mounted) setState(() => _liveSpeech = text);
      },
    );

    if (!mounted) return;

    setState(() {
      _isListening = false;
      _results[item.phoneme] = res.isMatched;

      if (_currentIndex + 1 < _items.length) {
        _currentIndex++;
        _liveSpeech = '';
      } else {
        _isFinished = true;
        _rewardState.addReward(earnedStars: 5, earnedXp: 100, earnedGems: 40);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isFinished) {
      final correctCount = _results.values.where((v) => v).length;
      final incorrectPhonemes = _results.entries
          .where((e) => !e.value)
          .map((e) => '/${e.key.toLowerCase()}/')
          .toList();

      final recommended = incorrectPhonemes.isNotEmpty ? incorrectPhonemes.first : '/r/';

      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        child: Container(
          width: 440,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            color: Colors.white,
          ),
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
                'Genel Fonetik Uyum: $correctCount / ${_items.length}',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF1976D2)),
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
                    Row(
                      children: const [
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
                          ? 'Mükemmel telaffuz! Çocuğunuz tüm hedef sesleri yaş gelişimine uygun olarak başarıyla üretiyor.'
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
      );
    }

    final item = _items[_currentIndex];

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      child: Container(
        width: 420,
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Üst Başlık
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
                        'Madde ${_currentIndex + 1} / ${_items.length} • /${item.phoneme.toLowerCase()}/ Sesi',
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

            // Büyük Görsel Kartı
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24),
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
                  Text(item.emoji, style: const TextStyle(fontSize: 64)),
                  const SizedBox(height: 10),
                  Text(
                    item.word,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF1565C0)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'İpucu: "${item.word}" de ve mikrofona söyle!',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.black54),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Canlı Duyulan Metin
            if (_liveSpeech.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Text(
                  _liveSpeech,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: Color(0xFFE65100)),
                ),
              ),
            const SizedBox(height: 16),

            // Mikrofon Butonu
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
                icon: Icon(_isListening ? Icons.hearing_rounded : Icons.mic_rounded, size: 24),
                label: Text(
                  _isListening ? 'DİNLİYORUM... SÖYLE 🗣️' : 'MİKROFONLA SÖYLE 🎤',
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                ),
                onPressed: _isListening ? null : _startListeningForWord,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
