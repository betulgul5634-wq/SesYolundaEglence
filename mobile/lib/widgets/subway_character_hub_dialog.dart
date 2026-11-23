import 'package:flutter/material.dart';
import '../models/reward_state.dart';
import '../services/sound_effects_service.dart';
import 'animated_dancing_character.dart';

class SubwayRosterCharacter {
  final String id;
  final String name;
  final String title;
  final String avatarEmoji;
  final String ability;
  final int requiredStage;
  final int requiredStars;
  final int speed;
  final int rhythm;
  final int articulation;
  final int power;
  final List<Color> themeColors;

  const SubwayRosterCharacter({
    required this.id,
    required this.name,
    required this.title,
    required this.avatarEmoji,
    required this.ability,
    required this.requiredStage,
    required this.requiredStars,
    required this.speed,
    required this.rhythm,
    required this.articulation,
    required this.power,
    required this.themeColors,
  });
}

const List<SubwayRosterCharacter> kSubwayRoster = [
  SubwayRosterCharacter(
    id: 'char_skater_can',
    name: 'SES KAŞİFİ CAN',
    title: 'Sokakların Neşeli Kaykaycısı 🛹',
    avatarEmoji: '🛹',
    ability: 'Hızlı Kaykay & Akıcı Konuşma Ritmi ⚡',
    requiredStage: 1,
    requiredStars: 0,
    speed: 95,
    rhythm: 88,
    articulation: 90,
    power: 85,
    themeColors: [Color(0xFFFF9800), Color(0xFFFF5722)],
  ),
  SubwayRosterCharacter(
    id: 'char_robo_b',
    name: 'SES ROBOTU BİBİ',
    title: 'Gelişmiş Ses & Frekans Robotu 🤖',
    avatarEmoji: '🤖',
    ability: 'Lazer Ses Dalgası & Çelik Dudaklar 💥',
    requiredStage: 2,
    requiredStars: 10,
    speed: 85,
    rhythm: 98,
    articulation: 95,
    power: 92,
    themeColors: [Color(0xFF00E5FF), Color(0xFF0091EA)],
  ),
  SubwayRosterCharacter(
    id: 'char_ninja',
    name: 'RİTİM NİNJASI',
    title: 'Gizemli Söz & Doğru Nefes Ustası 🥷',
    avatarEmoji: '🥷',
    ability: 'Sessiz Hızlı Atlayış & Keskin Dil 🎯',
    requiredStage: 3,
    requiredStars: 20,
    speed: 98,
    rhythm: 92,
    articulation: 94,
    power: 89,
    themeColors: [Color(0xFF7C4DFF), Color(0xFF311B92)],
  ),
  SubwayRosterCharacter(
    id: 'char_prenses',
    name: 'MELODİ PRENSESİ',
    title: 'Altın Taçlı Kristal Ses Kraliçesi 👑',
    avatarEmoji: '👸',
    ability: 'Sihirli Yıldız Yağmuru & Berrak Ton 🌟',
    requiredStage: 4,
    requiredStars: 30,
    speed: 88,
    rhythm: 96,
    articulation: 99,
    power: 94,
    themeColors: [Color(0xFFFF4081), Color(0xFFC2185B)],
  ),
  SubwayRosterCharacter(
    id: 'char_superhero',
    name: 'SÜPER KONUŞMACI',
    title: 'Galaksi Ses Şampiyonu 🦸',
    avatarEmoji: '🦸',
    ability: 'Altın Pelerin & Süper Ses Gücü 🏆',
    requiredStage: 5,
    requiredStars: 40,
    speed: 100,
    rhythm: 95,
    articulation: 100,
    power: 100,
    themeColors: [Color(0xFFFFD600), Color(0xFFDD2C00)],
  ),
  SubwayRosterCharacter(
    id: 'char_dino',
    name: 'DİNO DİDİ',
    title: 'Neşeli Dansçı Yavru Ejder 🦖',
    avatarEmoji: '🦖',
    ability: 'Dinozor Kükremesi & Güçlü Diyafram 🐾',
    requiredStage: 6,
    requiredStars: 50,
    speed: 82,
    rhythm: 90,
    articulation: 92,
    power: 96,
    themeColors: [Color(0xFF66BB6A), Color(0xFF2E7D32)],
  ),
  SubwayRosterCharacter(
    id: 'char_korsan',
    name: 'KAPTAN KORSAN',
    title: 'Yedi Denizlerin Söz Kaptanı 🏴‍☠️',
    avatarEmoji: '🏴‍☠️',
    ability: 'Korsan Narası & Cesur Telaffuz ⚓',
    requiredStage: 7,
    requiredStars: 60,
    speed: 86,
    rhythm: 89,
    articulation: 91,
    power: 95,
    themeColors: [Color(0xFFD32F2F), Color(0xFF4E342E)],
  ),
  SubwayRosterCharacter(
    id: 'char_astronot',
    name: 'YILDIZ ASTRONOTU',
    title: 'Yıldızlararası Uzay Kaşifi 👩‍🚀',
    avatarEmoji: '👩‍🚀',
    ability: 'Yerçekimsiz Söz Süzülüşü & Radyo Netliği 🪐',
    requiredStage: 8,
    requiredStars: 75,
    speed: 92,
    rhythm: 94,
    articulation: 98,
    power: 97,
    themeColors: [Color(0xFF00E5FF), Color(0xFF78909C)],
  ),
];

/// Subway Surfers Tarzı Tam Kapsamlı Karakter Galerisi & Kilit Açma Arenası
class SubwayCharacterHubDialog extends StatefulWidget {
  final RewardState rewardState;

  const SubwayCharacterHubDialog({
    super.key,
    required this.rewardState,
  });

  @override
  State<SubwayCharacterHubDialog> createState() => _SubwayCharacterHubDialogState();
}

class _SubwayCharacterHubDialogState extends State<SubwayCharacterHubDialog> {
  late int _selectedIndex;
  final SoundEffectsService _sfx = SoundEffectsService();

  @override
  void initState() {
    super.initState();
    final activeId = widget.rewardState.activeCharacterId;
    _selectedIndex = kSubwayRoster.indexWhere((c) => c.id == activeId);
    if (_selectedIndex == -1) _selectedIndex = 0;
  }

  bool _isUnlocked(SubwayRosterCharacter c) {
    if (c.requiredStage == 1) return true;
    if (widget.rewardState.isCharacterUnlocked(c.id)) return true;
    if (widget.rewardState.totalStars >= c.requiredStars) return true;
    return false;
  }

  void _equipCharacter(SubwayRosterCharacter c) {
    _sfx.playVictoryFanfare();
    widget.rewardState.equipCharacter(c.id, c.name, c.avatarEmoji);
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🎉 ${c.name} KUŞANILDI! Ana ekranda seninle canlı dans edecek!'),
        backgroundColor: c.themeColors.first,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 2200),
      ),
    );
  }

  void _unlockWithStars(SubwayRosterCharacter c) {
    if (widget.rewardState.totalStars >= c.requiredStars) {
      _sfx.playVictoryFanfare();
      widget.rewardState.unlockCharacter(c.id);
      widget.rewardState.equipCharacter(c.id, c.name, c.avatarEmoji);
      setState(() {});
    } else {
      _sfx.playPop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🔒 Bu karakter için ${c.requiredStars} Yıldız veya Aşama ${c.requiredStage} tamamlanmalı! (Şu an: ${widget.rewardState.totalStars} Yıldız)'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = kSubwayRoster[_selectedIndex];
    final unlocked = _isUnlocked(c);
    final isEquipped = widget.rewardState.activeCharacterId == c.id;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 580, maxHeight: 760),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A1A2E),
              Color(0xFF16213E),
              Color(0xFF0F3460),
            ],
          ),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: c.themeColors.first.withAlpha(160), width: 3),
          boxShadow: [
            BoxShadow(
              color: c.themeColors.first.withAlpha(80),
              blurRadius: 30,
              spreadRadius: 4,
            ),
          ],
        ),
        child: Column(
          children: [
            // 1. ÜST BAŞLIK & SUBWAY SURFERS LOGOSU
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 16, 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: c.themeColors),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: c.themeColors.first.withAlpha(120), blurRadius: 8),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('🌟', style: TextStyle(fontSize: 18)),
                        SizedBox(width: 6),
                        Text(
                          'SES KAHRAMANLARI KADROSU',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Toplam Yıldız Rozeti
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.amberAccent, width: 1.5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.rewardState.totalStars}',
                          style: const TextStyle(
                            color: Colors.amber,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 26),
                  ),
                ],
              ),
            ),

            // 2. ORTA BÖLÜM: SPOTLIGHT & DANS EDEN KARAKTER PODYUMU
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    // Karakter İsim & Ünvan Başlığı
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: Column(
                        key: ValueKey(c.id),
                        children: [
                          Text(
                            c.name,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                              shadows: [
                                Shadow(color: c.themeColors.first, blurRadius: 16),
                              ],
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            c.title,
                            style: const TextStyle(
                              color: Color(0xFFFFD54F),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    // CANLI DANS EDEN 3D KARAKTER (Bacakları, kolları ritimle hareket eder!)
                    Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Neon Spotlight Işığı
                          Container(
                            width: 220,
                            height: 220,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  c.themeColors.first.withAlpha(90),
                                  c.themeColors.last.withAlpha(30),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),

                          // Karakter Figürü
                          AnimatedDancingCharacter(
                            key: ValueKey('podium_${c.id}'),
                            characterId: c.id,
                            size: 175,
                            isDancing: true,
                            showPedestal: true,
                            showShadow: true,
                            onTap: () {
                              _sfx.playCoinChime();
                            },
                          ),

                          // Eğer Kilitliyse Kilit Rozeti
                          if (!unlocked)
                            Positioned(
                              top: 20,
                              right: 30,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: Colors.black.withAlpha(200),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.redAccent, width: 2),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.lock_rounded, color: Colors.redAccent, size: 16),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Aşama ${c.requiredStage}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Karakter Süper Gücü
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(15),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.flash_on_rounded, color: Colors.amber, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                c.ability,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // STATS ÇUBUKLARI (Subway Surfers Tarzı)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: Column(
                          children: [
                            _buildStatBar('⚡ HIZ (Tempo)', c.speed, Colors.orangeAccent),
                            const SizedBox(height: 8),
                            _buildStatBar('🎵 RİTİM (Beat)', c.rhythm, Colors.cyanAccent),
                            const SizedBox(height: 8),
                            _buildStatBar('🎯 ARTIKÜLASYON', c.articulation, Colors.greenAccent),
                            const SizedBox(height: 8),
                            _buildStatBar('💥 YILDIZ GÜCÜ', c.power, Colors.purpleAccent),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // EYLEM BUTONU (KUŞAN / KİLİTLİ / KUŞANILDI)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: isEquipped
                          ? Container(
                              width: double.infinity,
                              height: 52,
                              decoration: BoxDecoration(
                                color: const Color(0xFF2E7D32),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: const Color(0xFF66BB6A), width: 2),
                              ),
                              child: const Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.check_circle_rounded, color: Colors.white, size: 22),
                                    SizedBox(width: 8),
                                    Text(
                                      'BU KARAKTER KUŞANILDI ✓',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : unlocked
                              ? ElevatedButton(
                                  onPressed: () => _equipCharacter(c),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: c.themeColors.first,
                                    foregroundColor: Colors.white,
                                    minimumSize: const Size(double.infinity, 52),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    elevation: 8,
                                    shadowColor: c.themeColors.first.withAlpha(180),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text('🛹', style: TextStyle(fontSize: 20)),
                                      SizedBox(width: 8),
                                      Text(
                                        'KARAKTERİ KUŞAN!',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 1.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : ElevatedButton(
                                  onPressed: () => _unlockWithStars(c),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF424242),
                                    foregroundColor: Colors.white70,
                                    minimumSize: const Size(double.infinity, 52),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    elevation: 2,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.lock_outline_rounded, size: 18),
                                      const SizedBox(width: 8),
                                      Text(
                                        'KİLİTLİ (Aşama ${c.requiredStage} veya ${c.requiredStars} ⭐)',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                    ),
                  ],
                ),
              ),
            ),

            // 3. ALT BÖLÜM: YATAY KARAKTER SEÇİM ŞERİDİ (Carousel Ribbon)
            Container(
              height: 98,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: const BoxDecoration(
                color: Color(0xFF0F172A),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
              ),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: kSubwayRoster.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (ctx, i) {
                  final item = kSubwayRoster[i];
                  final isSelected = _selectedIndex == i;
                  final itemUnlocked = _isUnlocked(item);
                  final isCurrentActive = widget.rewardState.activeCharacterId == item.id;

                  return InkWell(
                    onTap: () {
                      _sfx.playPop();
                      setState(() => _selectedIndex = i);
                    },
                    borderRadius: BorderRadius.circular(18),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 76,
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? LinearGradient(
                                colors: item.themeColors,
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : LinearGradient(
                                colors: [Colors.white10, Colors.white.withAlpha(5)],
                              ),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isSelected ? Colors.white : Colors.white24,
                          width: isSelected ? 2.5 : 1,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: item.themeColors.first.withAlpha(140),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ]
                            : null,
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                item.avatarEmoji,
                                style: const TextStyle(fontSize: 26),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                item.name.split(' ').first,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),

                          // Kilitli İkonu
                          if (!itemUnlocked)
                            Positioned(
                              top: 4,
                              right: 4,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  color: Colors.black87,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.lock, color: Colors.amberAccent, size: 12),
                              ),
                            ),

                          // Kuşanıldı Rozeti
                          if (isCurrentActive)
                            Positioned(
                              top: 4,
                              left: 4,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF4CAF50),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.check, color: Colors.white, size: 10),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBar(String label, int value, Color color) {
    return Row(
      children: [
        SizedBox(
          width: 135,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: value / 100.0,
              backgroundColor: Colors.white12,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$value',
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}
