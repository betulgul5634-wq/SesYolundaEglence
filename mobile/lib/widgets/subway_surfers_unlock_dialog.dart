import 'package:flutter/material.dart';
import 'animated_dancing_character.dart';
import '../services/sound_effects_service.dart';

class SubwayCharacter {
  final String id;
  final String name;
  final String title;
  final String avatarEmoji;
  final List<Color> gradientColors;
  final String ability;
  final int speedStars;
  final int powerStars;

  const SubwayCharacter({
    required this.id,
    required this.name,
    required this.title,
    required this.avatarEmoji,
    required this.gradientColors,
    required this.ability,
    this.speedStars = 5,
    this.powerStars = 5,
  });
}

const List<SubwayCharacter> kSubwayCharacters = [
  SubwayCharacter(
    id: 'char_skater_can',
    name: 'SES KAŞİFİ',
    title: 'Sokakların Neşeli Kaykaycısı 🛹',
    avatarEmoji: '🛹',
    gradientColors: [Color(0xFFFF9800), Color(0xFFFF5722), Color(0xFFD84315)],
    ability: 'Hızlı Kaykay & Akıcı Konuşma Ritmi ⚡',
  ),
  SubwayCharacter(
    id: 'char_robo_b',
    name: 'SES ROBOTU',
    title: 'Gelişmiş Ses & Frekans Robotu 🤖',
    avatarEmoji: '🤖',
    gradientColors: [Color(0xFF00E5FF), Color(0xFF0091EA), Color(0xFF0D47A1)],
    ability: 'Lazer Ses Dalgası & Çelik Dudaklar 💥',
  ),
  SubwayCharacter(
    id: 'char_ninja_shadow',
    name: 'RİTİM NİNJASI',
    title: 'Gizemli Söz & Doğru Nefes Ustası 🥷',
    avatarEmoji: '🥷',
    gradientColors: [Color(0xFF7C4DFF), Color(0xFF512DA8), Color(0xFF311B92)],
    ability: 'Sessiz Hızlı Atlayış & Keskin Dil 🎯',
  ),
  SubwayCharacter(
    id: 'char_princess_star',
    name: 'MELODİ PRENSESİ',
    title: 'Altın Taçlı Kristal Ses Kraliçesi 👑',
    avatarEmoji: '👸',
    gradientColors: [Color(0xFFFF4081), Color(0xFFE91E63), Color(0xFF880E4F)],
    ability: 'Sihirli Yıldız Yağmuru & Berrak Ton 🌟',
  ),
  SubwayCharacter(
    id: 'char_superhero',
    name: 'SÜPER KONUŞMACI',
    title: 'Galaksi Ses Şampiyonu 🦸',
    avatarEmoji: '🦸',
    gradientColors: [Color(0xFFFFD600), Color(0xFFFF6D00), Color(0xFFDD2C00)],
    ability: 'Altın Pelerin & Süper Ses Gücü 🏆',
  ),
  SubwayCharacter(
    id: 'char_dino',
    name: 'NEŞELİ DİNO',
    title: 'Ritim Tutan Yavru Dinozor 🦖',
    avatarEmoji: '🦖',
    gradientColors: [Color(0xFF66BB6A), Color(0xFF2E7D32), Color(0xFF1B5E20)],
    ability: 'Dinozor Kükremesi & Güçlü Diyafram 🐾',
  ),
  SubwayCharacter(
    id: 'char_korsan',
    name: 'SES KAPTANI',
    title: 'Uzak Denizlerin Ritim Kaptanı 🏴‍☠️',
    avatarEmoji: '🏴‍☠️',
    gradientColors: [Color(0xFFD32F2F), Color(0xFF1A237E), Color(0xFF212121)],
    ability: 'Korsan Narası & Güçlü Yankı Ritmi ⚓',
  ),
  SubwayCharacter(
    id: 'char_astronot',
    name: 'UZAY KAŞİFİ',
    title: 'Galaksi Ses & Frekans Pilotu 🚀',
    avatarEmoji: '👨‍🚀',
    gradientColors: [Color(0xFF00E5FF), Color(0xFF1E88E5), Color(0xFF0D47A1)],
    ability: 'Yerçekimsiz Ses Süzülüşü & Radyo Netliği 🪐',
  ),
];

/// Subway Surfers Tarzı Dev Karakter Açılış ve Ödül Ekranı
class SubwaySurfersUnlockDialog extends StatefulWidget {
  final SubwayCharacter character;
  final String stageName;
  final VoidCallback onEquip;

  const SubwaySurfersUnlockDialog({
    super.key,
    required this.character,
    required this.stageName,
    required this.onEquip,
  });

  static SubwayCharacter getCharacterForLevel(int stageLevel) {
    final idx = (stageLevel - 1) % kSubwayCharacters.length;
    return kSubwayCharacters[idx];
  }

  @override
  State<SubwaySurfersUnlockDialog> createState() => _SubwaySurfersUnlockDialogState();
}

class _SubwaySurfersUnlockDialogState extends State<SubwaySurfersUnlockDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    SoundEffectsService().playVictoryFanfare();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.character;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 420),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFF0F3460)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(36),
            border: Border.all(color: const Color(0xFFFFD700), width: 3.5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFD700).withValues(alpha: 0.45),
                blurRadius: 30,
                spreadRadius: 4,
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ÜST BAŞLIK: SUBWAY SURFERS TARZI "YENİ KARAKTER AÇILDI!"
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(color: Colors.black45, blurRadius: 6, offset: Offset(0, 3)),
                  ],
                ),
                child: const Text(
                  '🎉 YENİ KARAKTER AÇILDI! 🔓',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Aşama Başarısı: ${widget.stageName}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),

              // DEVASA DÖNEN GÜNEŞ IŞIĞI & CANLI DANS EDEN KARAKTER SAHNESİ
              SizedBox(
                height: 230,
                width: 230,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Dönen Işık Huzmeleri
                    RotationTransition(
                      turns: _controller,
                      child: Container(
                        width: 220,
                        height: 220,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: SweepGradient(
                            colors: [
                              Colors.amber.withValues(alpha: 0.0),
                              Colors.amber.withValues(alpha: 0.4),
                              Colors.orange.withValues(alpha: 0.0),
                              Colors.amber.withValues(alpha: 0.4),
                              Colors.orange.withValues(alpha: 0.0),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Dev Avatar Sahnesi (Neon Spotlight Dairesi)
                    Container(
                      width: 175,
                      height: 175,
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            c.gradientColors.first.withValues(alpha: 0.85),
                            c.gradientColors.last,
                          ],
                          center: const Alignment(0, -0.3),
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFFFD700), width: 3.5),
                        boxShadow: [
                          BoxShadow(
                            color: c.gradientColors.first.withValues(alpha: 0.65),
                            blurRadius: 25,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                    ),

                    // Canlı Dans Eden & Dokunulduğunda Takla Atan Karakter
                    Positioned(
                      bottom: 16,
                      child: AnimatedDancingCharacter(
                        characterId: c.id,
                        size: 110,
                        isDancing: true,
                        showPedestal: false,
                        showShadow: true,
                      ),
                    ),

                    // Seviye / Güç Rozeti
                    Positioned(
                      bottom: 2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: const [
                            BoxShadow(color: Colors.black54, blurRadius: 4, offset: Offset(0, 2)),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.bolt_rounded, size: 14, color: Colors.black),
                            SizedBox(width: 2),
                            Text(
                              'EFSANE V.I.P',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 11,
                                color: Colors.black,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // KARAKTER ADI VE UNVANI
              Text(
                c.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.1,
                  color: Color(0xFFFFD700),
                  shadows: [Shadow(color: Colors.black, blurRadius: 4, offset: Offset(0, 2))],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                c.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),

              // ÖZELLİK VE GÜÇ ÇUBUKLARI
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('⚡ Kaykay Hızı:', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                        Row(children: List.generate(5, (_) => const Text('⭐', style: TextStyle(fontSize: 12)))),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('🎙️ Ses & Telaffuz:', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                        Row(children: List.generate(5, (_) => const Text('⭐', style: TextStyle(fontSize: 12)))),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Özel Yetenek: ${c.ability}',
                      style: const TextStyle(color: Color(0xFFFFD700), fontSize: 11.5, fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // DEV BUTON: "HEMEN KUŞAN & OYNA 🎮"
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF58CC02),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 8,
                    shadowColor: const Color(0xFF58CC02).withValues(alpha: 0.6),
                  ),
                  icon: const Icon(Icons.check_circle_rounded, size: 24),
                  label: const Text(
                    'HEMEN KUŞAN & OYNA 🛹',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 0.8),
                  ),
                  onPressed: () {
                    widget.onEquip();
                    Navigator.pop(context);
                  },
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Şimdilik Geç', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
