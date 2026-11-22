import 'package:flutter/material.dart';
import '../models/reward_state.dart';
import '../services/sound_effects_service.dart';
import '../services/audio_speech_service.dart';
import 'lucky_spin_dialog.dart';

/// ❤️ CAN YENİLEME & SAĞLIK MERKEZİ DİYALOĞU
class HeartsRefillDialog extends StatefulWidget {
  const HeartsRefillDialog({super.key});

  @override
  State<HeartsRefillDialog> createState() => _HeartsRefillDialogState();
}

class _HeartsRefillDialogState extends State<HeartsRefillDialog> {
  final _rewardState = RewardState();
  final _sfx = SoundEffectsService();
  final _audioService = AudioSpeechService();
  bool _isListeningBonus = false;

  void _refillWithGems() {
    if (_rewardState.hearts >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❤️ Canların zaten tamamen dolu (5/5)!'),
          backgroundColor: Color(0xFF2E7D32),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_rewardState.gems < 50) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Yetersiz elmas! Kelime pratikleri yaparak elmas kazanabilirsin.'),
          backgroundColor: Color(0xFFD32F2F),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final success = _rewardState.refillHeartsWithGems(gemCost: 50);
    if (success) {
      _sfx.playSuccessSound();
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎉 Canların 5/5 olarak dolduruldu! ❤️'),
          backgroundColor: Color(0xFF2E7D32),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _earnHeartByListening() async {
    if (_rewardState.hearts >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❤️ Canların zaten tamamen dolu (5/5)!'),
          backgroundColor: Color(0xFF2E7D32),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isListeningBonus = true);
    // Terapist örnek seslendirme yapar
    await _audioService.speakTurkish('Harika dinledin! Bir can kazandın!');
    _sfx.playPowerUpSound();
    _rewardState.gainHeart(1);
    if (mounted) {
      setState(() => _isListeningBonus = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎉 Tebrikler! Dinleme pratiği yaparak +1 Can kazandın! ❤️'),
          backgroundColor: Color(0xFF2E7D32),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      child: Container(
        width: 440,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          gradient: const LinearGradient(
            colors: [Color(0xFFFFEBEE), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          border: Border.all(color: const Color(0xFFEF5350), width: 2.5),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Üst Başlık
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFCDD2),
                      shape: BoxShape.circle,
                    ),
                    child: const Text('❤️', style: TextStyle(fontSize: 28)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Can Durumu & Sağlık',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFFB71C1C)),
                        ),
                        Text(
                          'Mevcut Canın: ${_rewardState.hearts} / 5',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFFC62828)),
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
              const SizedBox(height: 20),

              // 5 CANIN GÖRSEL DİZİLİMİ
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color(0xFFFFCDD2), width: 1.5),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6, offset: const Offset(0, 2)),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(5, (index) {
                    final isFilled = index < _rewardState.hearts;
                    return AnimatedScale(
                      scale: isFilled ? 1.15 : 0.9,
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        isFilled ? '❤️' : '🤍',
                        style: TextStyle(
                          fontSize: 32,
                          color: isFilled ? null : Colors.grey[400],
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 16),

              // Durum Bilgisi
              Text(
                _rewardState.hearts >= 5
                    ? 'Canların tamamen dolu! Hatalardan korkmadan konuşmaya devam et! 🚀'
                    : 'Yanlış telaffuzlarda 1 can kaybedersin. Canlarını hemen yenileyebilirsin!',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.black87, height: 1.4),
              ),
              const SizedBox(height: 18),

              // 1. Seçenek: 50 Elmas ile Canları Doldur
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFF81D4FA), width: 1.5),
                ),
                child: Row(
                  children: [
                    const Text('💎', style: TextStyle(fontSize: 24)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('50 💎 ile Canları Doldur', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Color(0xFF0277BD))),
                          Text('Bakiye: ${_rewardState.gems} Elmas', style: const TextStyle(fontSize: 11, color: Colors.black54, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0288D1),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _rewardState.hearts >= 5 ? null : _refillWithGems,
                      child: const Text('Doldur', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // 2. Seçenek: Dinleme Alıştırmasıyla Can Kazan
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFA5D6A7), width: 1.5),
                ),
                child: Row(
                  children: [
                    const Text('🎧', style: TextStyle(fontSize: 24)),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Dinleme Pratiği Yap', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Color(0xFF2E7D32))),
                          Text('Örnek sesi dinle ve +1 Can kazan', style: TextStyle(fontSize: 11, color: Colors.black54, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF388E3C),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: (_rewardState.hearts >= 5 || _isListeningBonus) ? null : _earnHeartByListening,
                      child: Text(_isListeningBonus ? 'Çalıyor...' : '+1 Can ❤️', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // 3. Seçenek: Şans Çarkıfeleği
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFFFE082), width: 1.5),
                ),
                child: Row(
                  children: [
                    const Text('🎡', style: TextStyle(fontSize: 24)),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Şans Çarkıfeleği', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Color(0xFFF57F17))),
                          Text('Çarkı çevir, ücretsiz can ve elmas kazan', style: TextStyle(fontSize: 11, color: Colors.black54, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFA000),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        showDialog(
                          context: context,
                          builder: (_) => const LuckySpinDialog(),
                        );
                      },
                      child: const Text('Çarkı Çevir', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
