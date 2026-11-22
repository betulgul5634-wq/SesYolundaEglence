import 'package:flutter/material.dart';
import '../models/reward_state.dart';
import '../services/sound_effects_service.dart';
import 'avatar_wardrobe_sheet.dart';
import 'lucky_spin_dialog.dart';

/// 💎 ELMAS & ÖDÜL MERKEZİ DİYALOĞU
class GemsShopDialog extends StatefulWidget {
  const GemsShopDialog({super.key});

  @override
  State<GemsShopDialog> createState() => _GemsShopDialogState();
}

class _GemsShopDialogState extends State<GemsShopDialog> {
  final _rewardState = RewardState();
  final _sfx = SoundEffectsService();

  void _refillHeartsWithGems() {
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
          content: Text('🎉 Harika! 50 💎 karşılığında canların 5/5 olarak yenilendi! ❤️'),
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
            colors: [Color(0xFFE1F5FE), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          border: Border.all(color: const Color(0xFF03A9F4), width: 2.5),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Üst Başlık & Bakiye
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Color(0xFFB3E5FC),
                      shape: BoxShape.circle,
                    ),
                    child: const Text('💎', style: TextStyle(fontSize: 28)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Elmas & Ödül Merkezi',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF0277BD)),
                        ),
                        Text(
                          'Mevcut Bakiye: ${_rewardState.gems} Elmas 💎',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF0288D1)),
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
              const SizedBox(height: 18),

              // 1. Kart: Canları Yenile
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFFFCDD2), width: 1.5),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6, offset: const Offset(0, 2)),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEBEE),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text('❤️', style: TextStyle(fontSize: 24)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Canları Doldur (5/5)',
                            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Color(0xFFC62828)),
                          ),
                          Text(
                            'Şu anki canın: ${_rewardState.hearts}/5',
                            style: const TextStyle(fontSize: 11.5, color: Colors.black54, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _rewardState.hearts >= 5 ? Colors.grey[300] : const Color(0xFFE53935),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: _rewardState.hearts >= 5 ? null : _refillHeartsWithGems,
                      child: Text(
                        _rewardState.hearts >= 5 ? 'Dolu ❤️' : '50 💎',
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // 2. Kart: Gardırop & Aksesuarlar
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFC8E6C9), width: 1.5),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6, offset: const Offset(0, 2)),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text('👑', style: TextStyle(fontSize: 24)),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Kahraman Gardırobu',
                            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Color(0xFF2E7D32)),
                          ),
                          Text(
                            'Şapkalar, gözlükler ve kaykaylar',
                            style: TextStyle(fontSize: 11.5, color: Colors.black54, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF43A047),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => const AvatarWardrobeSheet(),
                        );
                      },
                      child: const Text('Gardırop 🛍️', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // 3. Kart: Günlük Şans Çarkıfeleği
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFFFE082), width: 1.5),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6, offset: const Offset(0, 2)),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF8E1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text('🎡', style: TextStyle(fontSize: 24)),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Günlük Şans Çarkı',
                            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Color(0xFFF57F17)),
                          ),
                          Text(
                            'Ücretsiz elmas ve can kazan!',
                            style: TextStyle(fontSize: 11.5, color: Colors.black54, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFA000),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        showDialog(
                          context: context,
                          builder: (_) => const LuckySpinDialog(),
                        );
                      },
                      child: const Text('Çarkı Çevir 🎡', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Bilgi Kutucuğu
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE1F5FE),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF81D4FA)),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('💡', style: TextStyle(fontSize: 16)),
                        SizedBox(width: 6),
                        Text(
                          'Nasıl Elmas Kazanırım?',
                          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Color(0xFF0277BD)),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text('• Her doğru sesletimde +15 💎', style: TextStyle(fontSize: 11, color: Color(0xFF01579B), fontWeight: FontWeight.w700)),
                    Text('• Her tamamlanan mini oyunda +25 💎', style: TextStyle(fontSize: 11, color: Color(0xFF01579B), fontWeight: FontWeight.w700)),
                    Text('• Her okunan hikayede +40 💎', style: TextStyle(fontSize: 11, color: Color(0xFF01579B), fontWeight: FontWeight.w700)),
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
