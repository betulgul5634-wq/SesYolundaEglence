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
    name: 'SES KAŞİFİ',
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
    name: 'SES ROBOTU',
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
    name: 'NEŞELİ DİNO',
    title: 'Ritim Tutan Yavru Dinozor 🦖',
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
    name: 'SES KAPTANI',
    title: 'Uzak Denizlerin Ritim Kaptanı 🏴‍☠️',
    avatarEmoji: '🏴‍☠️',
    ability: 'Korsan Narası & Güçlü Yankı Ritmi ⚓',
    requiredStage: 7,
    requiredStars: 60,
    speed: 86,
    rhythm: 92,
    articulation: 91,
    power: 95,
    themeColors: [Color(0xFFD32F2F), Color(0xFF1A237E)],
  ),
  SubwayRosterCharacter(
    id: 'char_astronot',
    name: 'UZAY KAŞİFİ',
    title: 'Galaksi Ses & Frekans Pilotu 🚀',
    avatarEmoji: '👨‍🚀',
    ability: 'Yerçekimsiz Ses Süzülüşü & Radyo Netliği 🪐',
    requiredStage: 8,
    requiredStars: 75,
    speed: 94,
    rhythm: 95,
    articulation: 98,
    power: 99,
    themeColors: [Color(0xFF00E5FF), Color(0xFF1E88E5)],
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🎉 ${c.name} KİLİDİ AÇILDI VE KUŞANILDI!'),
          backgroundColor: c.themeColors.first,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      _sfx.playPopSound();
      _showHowToEarnDialog(c);
    }
  }

  void _showHowToEarnDialog(SubwayRosterCharacter c) {
    final remaining = (c.requiredStars - widget.rewardState.totalStars).clamp(1, 999);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            const Text('🌟', style: TextStyle(fontSize: 24)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${c.name} Nasıl Kazanılır?',
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.amberAccent.withAlpha(120)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.stars_rounded, color: Colors.amberAccent, size: 28),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Şu an $remaining yıldıza daha ihtiyacın var.\n(Mevcut: ${widget.rewardState.totalStars} / ${c.requiredStars} ⭐)',
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              '🎯 Yıldız Kazanma Adımları:',
              style: TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.w900, fontSize: 13),
            ),
            const SizedBox(height: 8),
            _buildGuideStep('1', 'Ana sayfadan Ses Yolculuğu haritasına veya ses alıştırmalarına gir.'),
            _buildGuideStep('2', 'Mikrofon butonuna basıp ekrandaki kelimeleri net bir sesle tekrar et.'),
            _buildGuideStep('3', 'Her doğru telaffuzda 1 ila 3 Altın Yıldız kazanacaksın!'),
            _buildGuideStep('4', 'Veya haritada ${c.requiredStage}. Ses Seviyesini tamamladığında bu kahraman sana ÜCRETSİZ hediye edilecek!'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber.shade700,
              foregroundColor: Colors.black87,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text('Anladım, Pratiğe Başla! 🚀', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }

  Widget _buildGuideStep(String num, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              color: Colors.amberAccent,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(num, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 11)),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.3)),
          ),
        ],
      ),
    );
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

                          // Eğer Kilitliyse Kilit Rozeti (Yıldız & Aşama Bilgisi)
                          if (!unlocked)
                            Positioned(
                              top: 16,
                              right: 20,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: Colors.black.withAlpha(220),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: Colors.amberAccent, width: 2),
                                  boxShadow: const [
                                    BoxShadow(color: Colors.black45, blurRadius: 6, offset: Offset(0, 2)),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.stars_rounded, color: Colors.amberAccent, size: 16),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${c.requiredStars} ⭐ veya Aşama ${c.requiredStage}',
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

                    // EĞER KİLİTLİYSE: BU KAHRAMAN NASIL KAZANILIR? (Rehber Kutusu)
                    if (!unlocked) ...[
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                            ),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: Colors.amberAccent.withAlpha(160), width: 1.5),
                            boxShadow: const [
                              BoxShadow(color: Colors.black38, blurRadius: 8, offset: Offset(0, 2)),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.emoji_events_rounded, color: Colors.amberAccent, size: 18),
                                  const SizedBox(width: 6),
                                  const Text(
                                    'BU KAHRAMAN NASIL KAZANILIR?',
                                    style: TextStyle(
                                      color: Colors.amberAccent,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.black45,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '${widget.rewardState.totalStars} / ${c.requiredStars} ⭐',
                                      style: const TextStyle(
                                        color: Colors.amberAccent,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: LinearProgressIndicator(
                                  value: (widget.rewardState.totalStars / (c.requiredStars == 0 ? 1 : c.requiredStars)).clamp(0.0, 1.0),
                                  minHeight: 8,
                                  backgroundColor: Colors.white12,
                                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.amberAccent),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('⭐', style: TextStyle(fontSize: 13)),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      '1. Yol: ${c.requiredStars} Yıldız topla. (Kelimeleri söyledikçe yıldız kazanırsın)',
                                      style: const TextStyle(color: Colors.white70, fontSize: 11, height: 1.2),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('🗺️', style: TextStyle(fontSize: 13)),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      '2. Yol: Haritada ${c.requiredStage}. Ses Seviyesini bitir, ücretsiz hediye açılsın!',
                                      style: const TextStyle(color: Colors.white70, fontSize: 11, height: 1.2),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],

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
                                      Text('🌟', style: TextStyle(fontSize: 20)),
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
                                    backgroundColor: widget.rewardState.totalStars >= c.requiredStars
                                        ? const Color(0xFFFFB300)
                                        : const Color(0xFF334155),
                                    foregroundColor: widget.rewardState.totalStars >= c.requiredStars
                                        ? Colors.black87
                                        : Colors.white,
                                    minimumSize: const Size(double.infinity, 52),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    elevation: widget.rewardState.totalStars >= c.requiredStars ? 6 : 2,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        widget.rewardState.totalStars >= c.requiredStars
                                            ? Icons.lock_open_rounded
                                            : Icons.help_outline_rounded,
                                        size: 20,
                                        color: widget.rewardState.totalStars >= c.requiredStars
                                            ? Colors.black87
                                            : Colors.amberAccent,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        widget.rewardState.totalStars >= c.requiredStars
                                            ? '🌟 ${c.requiredStars} YILDIZ İLE KİLİDİ AÇ!'
                                            : '🔒 ${(c.requiredStars - widget.rewardState.totalStars).clamp(1, 999)} ⭐ DAHA GEREKLİ (Nasıl Kazanılır?)',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w900,
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
