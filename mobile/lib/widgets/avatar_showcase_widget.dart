import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/reward_state.dart';
import '../services/audio_speech_service.dart';
import 'subway_surfers_unlock_dialog.dart';
import 'interactive_avatar_widget.dart';

/// 🏆 EFSANE AVATAR VİTRİNİ & KOLEKSİYONU
/// Sayfada avatarlar için ayrılan kocaman, canlı ve hareketli vitrin!
/// - Kazanılmamış olanlar GRİ ve KİLİTLİ (🔒) görünür.
/// - Kazanılmış olanlar KOCAMAN, hareketli (nefes alan, yüzen, dönen altın ışınlı) podyumda durur.
/// - Tek tıkla kuşanılır, kuşanılan karakter "KUŞANILDI ✅" rozetiyle parıldar.
class AvatarShowcaseWidget extends StatefulWidget {
  final VoidCallback? onOpenMiniGame;
  final ValueChanged<int>? onSelectStage;

  const AvatarShowcaseWidget({
    super.key,
    this.onOpenMiniGame,
    this.onSelectStage,
  });

  @override
  State<AvatarShowcaseWidget> createState() => _AvatarShowcaseWidgetState();
}

class _AvatarShowcaseWidgetState extends State<AvatarShowcaseWidget>
    with TickerProviderStateMixin {
  late AnimationController _idleFloatController;
  late AnimationController _rayController;
  final RewardState _rewardState = RewardState();
  final AudioSpeechService _audioService = AudioSpeechService();

  @override
  void initState() {
    super.initState();

    // 1. Canlı Yüzme & Nefes Alma Animasyonu (Idle Floating: 2.4 saniye ritim)
    _idleFloatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    // 2. Kuşanılan karakter arkasındaki dönen altın ışınlar
    _rayController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _idleFloatController.dispose();
    _rayController.dispose();
    super.dispose();
  }

  void _equip(SubwayCharacter char) {
    _rewardState.equipCharacter(char.id, char.name, char.avatarEmoji);
    _audioService.speakTurkish('Harika seçim! ${char.name} seninle!');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Text(char.avatarEmoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '🎉 ${char.name} KUŞANILDI! Tüm oyunlarda seninle! ⭐',
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF2E7D32),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showLockedHint(SubwayCharacter char, int stageNum) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.amberAccent, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.6),
                blurRadius: 20,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Kilitli Gri Avatar
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black38,
                  border: Border.all(color: Colors.white24, width: 3),
                ),
                alignment: Alignment.center,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Text(
                      char.avatarEmoji,
                      style: const TextStyle(fontSize: 44, color: Colors.white24),
                    ),
                    const Positioned(
                      bottom: 4,
                      right: 4,
                      child: Text('🔒', style: TextStyle(fontSize: 24)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Text(
                '🔒 ${char.name}',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: Colors.amberAccent,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                char.title,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'Bu efsanevi karakterin kilidini açmak için:\nAşama $stageNum Kelime Avı oyununu kazan ve 4 doğru hedef kelime topla! 🏆',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.4, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF9800),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  icon: const Text('🎮', style: TextStyle(fontSize: 18)),
                  label: Text('Aşama $stageNum Oyununa Git 🚀', style: const TextStyle(fontWeight: FontWeight.w900)),
                  onPressed: () {
                    Navigator.pop(ctx);
                    if (widget.onSelectStage != null) {
                      widget.onSelectStage!(stageNum - 1);
                    }
                    if (widget.onOpenMiniGame != null) {
                      widget.onOpenMiniGame!();
                    }
                  },
                ),
              ),
              const SizedBox(height: 6),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Kapat', style: TextStyle(color: Colors.white54)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _rewardState,
      builder: (context, _) {
        final unlockedCount = kSubwayCharacters
            .where((c) => _rewardState.unlockedCharacters.contains(c.id))
            .length;

        return Container(
          margin: const EdgeInsets.fromLTRB(16, 4, 16, 10),
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF0F172A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFFFB300).withValues(alpha: 0.6), width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.amber.withValues(alpha: 0.18),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Başlık ve Koleksiyon İlerlemesi
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Text('👑', style: TextStyle(fontSize: 20)),
                      SizedBox(width: 8),
                      Text(
                        'EFSANE AVATAR KOLEKSİYONU',
                        style: TextStyle(
                          color: Color(0xFFFFD54F),
                          fontWeight: FontWeight.w900,
                          fontSize: 13.5,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.amberAccent, width: 1.2),
                    ),
                    child: Text(
                      '🔓 $unlockedCount/${kSubwayCharacters.length} Açıldı',
                      style: const TextStyle(
                        color: Colors.amberAccent,
                        fontWeight: FontWeight.w900,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // 5 Karakterin Yatay Kaydırılabilir Büyük Kartları
              SizedBox(
                height: 185,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: kSubwayCharacters.length,
                  separatorBuilder: (ctx, i) => const SizedBox(width: 12),
                  itemBuilder: (ctx, index) {
                    final char = kSubwayCharacters[index];
                    final isUnlocked = _rewardState.unlockedCharacters.contains(char.id);
                    final isEquipped = _rewardState.activeCharacterName == char.name;

                    return _buildAvatarCard(
                      char: char,
                      stageNum: index + 1,
                      isUnlocked: isUnlocked,
                      isEquipped: isEquipped,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 🌟 TEKİL AVATAR KARTI (KOCAMAN, HAREKETLİ PODYUM VEYA KİLİTLİ GRİ)
  Widget _buildAvatarCard({
    required SubwayCharacter char,
    required int stageNum,
    required bool isUnlocked,
    required bool isEquipped,
  }) {
    if (!isUnlocked) {
      // 🔒 KİLİTLİ / KAZANILMAMIŞ AVATAR: TAMAMEN GRİ VE SİYAH-BEYAZ!
      return GestureDetector(
        onTap: () => _showLockedHint(char, stageNum),
        child: Container(
          width: 120,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1E282D), Color(0xFF151C20)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white12, width: 1.5),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Gri Karartılmış Daire & Kilit
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black54,
                  border: Border.all(color: Colors.white10, width: 2),
                ),
                alignment: Alignment.center,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Silüet emoji
                    Opacity(
                      opacity: 0.18,
                      child: Text(
                        char.avatarEmoji,
                        style: const TextStyle(fontSize: 38),
                      ),
                    ),
                    // Büyük Kilit Rozeti
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white38, width: 1.5),
                      ),
                      child: const Text('🔒', style: TextStyle(fontSize: 20)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Gri İsim
              Text(
                char.name,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white38,
                  fontWeight: FontWeight.w900,
                  fontSize: 10.5,
                ),
              ),
              const SizedBox(height: 6),

              // Kilit Açma İpucu Rozeti
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Aşama $stageNum Ödülü',
                  style: const TextStyle(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 🌟 KAZANILMIŞ AVATAR: KOCAMAN, PARLAK VE HAREKETLİ PODYUM!
    return AnimatedBuilder(
      animation: _idleFloatController,
      builder: (ctx, _) {
        // Canlı nefes alma ve hafif yukarı-aşağı salınım (Idle bobbing)
        final floatOffset = math.sin(_idleFloatController.value * math.pi) * 4.5;
        final breatheScale = 1.0 + (math.sin(_idleFloatController.value * math.pi) * 0.04);

        return Container(
          width: 126,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isEquipped
                  ? [const Color(0xFF2E2405), const Color(0xFF1A1400)]
                  : [const Color(0xFF1E293B), const Color(0xFF0F172A)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isEquipped ? const Color(0xFFFFD700) : char.gradientColors.first.withValues(alpha: 0.8),
              width: isEquipped ? 2.5 : 1.5,
            ),
            boxShadow: isEquipped
                ? [
                    BoxShadow(
                      color: Colors.amber.withValues(alpha: 0.45),
                      blurRadius: 14,
                      spreadRadius: 1,
                    ),
                  ]
                : [],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // KOCAMAN HAREKETLİ AVATAR & PARLAK PODYUM
              Transform.translate(
                offset: Offset(0, -floatOffset),
                child: Transform.scale(
                  scale: breatheScale,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Kuşanıldıysa Dönen Altın Işık Huzmeleri
                      if (isEquipped)
                        RotationTransition(
                          turns: _rayController,
                          child: Container(
                            width: 78,
                            height: 78,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: SweepGradient(
                                colors: [
                                  Colors.amber.withValues(alpha: 0.0),
                                  Colors.amber.withValues(alpha: 0.5),
                                  Colors.orange.withValues(alpha: 0.0),
                                  Colors.amber.withValues(alpha: 0.5),
                                  Colors.orange.withValues(alpha: 0.0),
                                ],
                              ),
                            ),
                          ),
                        ),

                      // Avatar Yuvarlağı (Kuşanılan Aksesuarlarla Canlı Entegrasyon)
                      if (isEquipped)
                        InteractiveAvatarWidget(
                          avatar: char.avatarEmoji,
                          hat: _rewardState.equippedHat,
                          glasses: _rewardState.equippedGlasses,
                          prop: _rewardState.equippedProp,
                          pet: _rewardState.equippedPet,
                          size: 56,
                          showPedestal: false,
                        )
                      else
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: char.gradientColors,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white70,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: char.gradientColors.first.withValues(alpha: 0.55),
                                blurRadius: 12,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            char.avatarEmoji,
                            style: const TextStyle(fontSize: 34),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 6),

              // Karakter İsmi
              Text(
                char.name,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isEquipped ? const Color(0xFFFFD700) : Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 10.5,
                ),
              ),
              const SizedBox(height: 6),

              // KUŞANILDI VEYA KUŞAN BUTONU
              if (isEquipped)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD700),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'KUŞANILDI ✅',
                    style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w900, fontSize: 9.5),
                  ),
                )
              else
                SizedBox(
                  height: 24,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF58CC02),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 2,
                    ),
                    onPressed: () => _equip(char),
                    child: const Text(
                      'KUŞAN ⚡',
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 9.5),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
