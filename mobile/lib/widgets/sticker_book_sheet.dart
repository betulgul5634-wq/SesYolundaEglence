import 'package:flutter/material.dart';
import '../models/reward_state.dart';
import '../services/audio_speech_service.dart';

class _StickerItem {
  final String id;
  final String word;
  final String phoneme;
  final String emoji;
  final String categoryTitle;

  _StickerItem({
    required this.id,
    required this.word,
    required this.phoneme,
    required this.emoji,
    required this.categoryTitle,
  });
}

/// 📖 SES ÇIKARTMA VE KOLEKSİYON ALBÜMÜ
/// Çocukların kelimeleri başardıkça kazandığı çıkartmaları biriktirdiği renkli albüm.
class StickerBookSheet extends StatefulWidget {
  const StickerBookSheet({super.key});

  @override
  State<StickerBookSheet> createState() => _StickerBookSheetState();
}

class _StickerBookSheetState extends State<StickerBookSheet> {
  final RewardState _rewardState = RewardState();
  final AudioSpeechService _audioService = AudioSpeechService();
  int _selectedTabIndex = 0;

  final List<List<_StickerItem>> _pages = [
    // 1. Sayfa: /p/ ve /b/ Sesleri
    [
      _StickerItem(id: 'pasta', word: 'Pasta', phoneme: 'P', emoji: '🎂', categoryTitle: 'Tatlı Dünyası'),
      _StickerItem(id: 'panda', word: 'Panda', phoneme: 'P', emoji: '🐼', categoryTitle: 'Sevimli Hayvanlar'),
      _StickerItem(id: 'peynir', word: 'Peynir', phoneme: 'P', emoji: '🧀', categoryTitle: 'Lezzetli Yiyecekler'),
      _StickerItem(id: 'pilot', word: 'Pilot', phoneme: 'P', emoji: '👨‍✈️', categoryTitle: 'Meslekler'),
      _StickerItem(id: 'balik', word: 'Balık', phoneme: 'B', emoji: '🐟', categoryTitle: 'Deniz Canlıları'),
      _StickerItem(id: 'balon', word: 'Balon', phoneme: 'B', emoji: '🎈', categoryTitle: 'Eğlence'),
      _StickerItem(id: 'bavul', word: 'Bavul', phoneme: 'B', emoji: '🧳', categoryTitle: 'Yolculuk'),
      _StickerItem(id: 'bebek', word: 'Bebek', phoneme: 'B', emoji: '🪆', categoryTitle: 'Oyuncaklar'),
    ],
    // 2. Sayfa: /m/ ve /n/ Sesleri
    [
      _StickerItem(id: 'maymun', word: 'Maymun', phoneme: 'M', emoji: '🐵', categoryTitle: 'Orman Dostları'),
      _StickerItem(id: 'masa', word: 'Masa', phoneme: 'M', emoji: '🪑', categoryTitle: 'Ev Eşyaları'),
      _StickerItem(id: 'muz', word: 'Muz', phoneme: 'M', emoji: '🍌', categoryTitle: 'Meyveler'),
      _StickerItem(id: 'mısır', word: 'Mısır', phoneme: 'M', emoji: '🌽', categoryTitle: 'Lezzetler'),
      _StickerItem(id: 'nar', word: 'Nar', phoneme: 'N', emoji: '🍎', categoryTitle: 'Meyveler'),
      _StickerItem(id: 'nalbant', word: 'Nal', phoneme: 'N', emoji: '🧲', categoryTitle: 'Eşyalar'),
      _StickerItem(id: 'nane', word: 'Nane', phoneme: 'N', emoji: '🌿', categoryTitle: 'Doğa'),
      _StickerItem(id: 'nokta', word: 'Nokta', phoneme: 'N', emoji: '🎯', categoryTitle: 'Semboller'),
    ],
    // 3. Sayfa: /r/ ve /l/ Sesleri
    [
      _StickerItem(id: 'roket', word: 'Roket', phoneme: 'R', emoji: '🚀', categoryTitle: 'Uzay Macerası'),
      _StickerItem(id: 'robot', word: 'Robot', phoneme: 'R', emoji: '🤖', categoryTitle: 'Teknoloji'),
      _StickerItem(id: 'radyo', word: 'Radyo', phoneme: 'R', emoji: '📻', categoryTitle: 'Nostalji'),
      _StickerItem(id: 'resim', word: 'Resimli', phoneme: 'R', emoji: '🖼️', categoryTitle: 'Sanat'),
      _StickerItem(id: 'leylek', word: 'Leylek', phoneme: 'L', emoji: '🪿', categoryTitle: 'Kuşlar'),
      _StickerItem(id: 'limon', word: 'Limon', phoneme: 'L', emoji: '🍋', categoryTitle: 'C Vitamini'),
      _StickerItem(id: 'lamba', word: 'Lamba', phoneme: 'L', emoji: '💡', categoryTitle: 'Işık'),
      _StickerItem(id: 'lokum', word: 'Lokum', phoneme: 'L', emoji: '🍬', categoryTitle: 'Tatlılar'),
    ],
    // 4. Sayfa: /y/ ve /s/ Sesleri
    [
      _StickerItem(id: 'yildiz', word: 'Yıldız', phoneme: 'Y', emoji: '⭐', categoryTitle: 'Gökyüzü'),
      _StickerItem(id: 'yelken', word: 'Yelkenli', phoneme: 'Y', emoji: '⛵', categoryTitle: 'Denizcilik'),
      _StickerItem(id: 'yumurta', word: 'Yumurta', phoneme: 'Y', emoji: '🥚', categoryTitle: 'Kahvaltı'),
      _StickerItem(id: 'yilan', word: 'Yılan', phoneme: 'Y', emoji: '🐍', categoryTitle: 'Vahşi Doğa'),
      _StickerItem(id: 'saat', word: 'Saat', phoneme: 'S', emoji: '⏰', categoryTitle: 'Zaman'),
      _StickerItem(id: 'sandalye', word: 'Sandalye', phoneme: 'S', emoji: '🪑', categoryTitle: 'Ev'),
      _StickerItem(id: 'sincap', word: 'Sincap', phoneme: 'S', emoji: '🐿️', categoryTitle: 'Orman'),
      _StickerItem(id: 'su', word: 'Su', phoneme: 'S', emoji: '💧', categoryTitle: 'Hayat'),
    ],
  ];

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _rewardState,
      builder: (context, _) {
        final currentStickers = _pages[_selectedTabIndex];
        final totalUnlockedInPage = currentStickers.where((s) => _rewardState.isStickerUnlocked(s.id)).length;

        return Container(
          height: MediaQuery.of(context).size.height * 0.88,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            children: [
              // Çekme Barı
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(3),
                ),
              ),

              // Üst Başlık & İlerleme
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF9C4),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Text('📖', style: TextStyle(fontSize: 26)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Klinik Çıkartma Albümü',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFFF57F17),
                            ),
                          ),
                          Text(
                            'Başardığın her kelime parıldayan bir çıkartma olur! ($totalUnlockedInPage/${currentStickers.length})',
                            style: const TextStyle(fontSize: 11.5, color: Colors.grey, fontWeight: FontWeight.w600),
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
              ),
              const Divider(height: 1),

              // SAYFA SEKMELERİ
              Container(
                color: const Color(0xFFFAFAFA),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildPageTab(0, '🎈 P & B Sayfası'),
                      const SizedBox(width: 8),
                      _buildPageTab(1, '👃 M & N Sayfası'),
                      const SizedBox(width: 8),
                      _buildPageTab(2, '🚀 R & L Sayfası'),
                      const SizedBox(width: 8),
                      _buildPageTab(3, '✨ Y & S Sayfası'),
                    ],
                  ),
                ),
              ),
              const Divider(height: 1),

              // ÇIKARTMALAR SAYFASI
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.15,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: currentStickers.length,
                  itemBuilder: (ctx, i) {
                    final item = currentStickers[i];
                    final isUnlocked = _rewardState.isStickerUnlocked(item.id);

                    return InkWell(
                      onTap: () {
                        if (isUnlocked) {
                          _audioService.speakTurkish(item.word, phoneme: item.phoneme);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('🔊 Dinliyorsun: "${item.word}" (${item.phoneme} Sesi) ⭐'),
                              duration: const Duration(milliseconds: 900),
                              backgroundColor: const Color(0xFF2E7D32),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('🔒 "${item.word}" kilitli! "${item.phoneme}" sesini çalışıp doğru söyleyerek açabilirsin!'),
                              duration: const Duration(seconds: 1),
                              backgroundColor: const Color(0xFFE65100),
                            ),
                          );
                        }
                      },
                      borderRadius: BorderRadius.circular(22),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: isUnlocked ? Colors.white : const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: isUnlocked ? const Color(0xFFFFD54F) : Colors.grey[300]!,
                            width: isUnlocked ? 2.5 : 1.2,
                          ),
                          boxShadow: isUnlocked
                              ? const [
                                  BoxShadow(
                                    color: Color(0x29FFB300),
                                    blurRadius: 8,
                                    offset: Offset(0, 3),
                                  )
                                ]
                              : [],
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (isUnlocked)
                                  Text(item.emoji, style: const TextStyle(fontSize: 42))
                                else
                                  ColorFiltered(
                                    colorFilter: const ColorFilter.mode(Colors.black38, BlendMode.srcIn),
                                    child: Text(item.emoji, style: const TextStyle(fontSize: 42)),
                                  ),
                                const SizedBox(height: 6),
                                Text(
                                  isUnlocked ? item.word : '???',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 14,
                                    color: isUnlocked ? const Color(0xFF263238) : Colors.black38,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  isUnlocked ? '/${item.phoneme.toLowerCase()}/ sesi' : 'Kilitli 🔒',
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                    color: isUnlocked ? const Color(0xFFE65100) : Colors.black26,
                                  ),
                                ),
                              ],
                            ),
                            if (isUnlocked)
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFFFD700),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Text('✨', style: TextStyle(fontSize: 11)),
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
        );
      },
    );
  }

  Widget _buildPageTab(int index, String title) {
    final isSelected = _selectedTabIndex == index;
    return InkWell(
      onTap: () => setState(() => _selectedTabIndex = index),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFB300) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? const Color(0xFFFFA000) : Colors.grey[300]!,
            width: 1.5,
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            color: isSelected ? Colors.white : const Color(0xFF455A64),
          ),
        ),
      ),
    );
  }
}
