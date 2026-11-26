import 'package:flutter/material.dart';
import '../models/reward_state.dart';
import '../services/sound_effects_service.dart';
import 'interactive_avatar_widget.dart';

class _ShopItem {
  final String id;
  final String category; // 'hat', 'glasses', 'prop', 'pet', 'avatar'
  final String name;
  final String emoji;
  final int gemPrice;

  _ShopItem({
    required this.id,
    required this.category,
    required this.name,
    required this.emoji,
    required this.gemPrice,
  });
}

/// 🛍️ CANLI KARAKTER ODASI & KOSTÜM GARDIROBU
/// Çocuğun kazandığı elmasları özelleştirmeye dönüştürerek motivasyonunu zirveye taşır.
/// Aksesuarlar artık avatara tam kalibreli oturur ve avatar canlı tepkiler verir.
class AvatarWardrobeSheet extends StatefulWidget {
  const AvatarWardrobeSheet({super.key});

  @override
  State<AvatarWardrobeSheet> createState() => _AvatarWardrobeSheetState();
}

class _AvatarWardrobeSheetState extends State<AvatarWardrobeSheet> {
  final RewardState _rewardState = RewardState();
  final SoundEffectsService _sfx = SoundEffectsService();
  int _selectedCategoryIndex = 0; // 0: Şapkalar, 1: Gözlükler, 2: Eşyalar, 3: Yoldaşlar, 4: Avatarlar

  final List<_ShopItem> _hats = [
    _ShopItem(id: 'hat_none', category: 'hat', name: 'Şapkasız', emoji: '❌', gemPrice: 0),
    _ShopItem(id: 'hat_crown', category: 'hat', name: 'Kral Tacı', emoji: '👑', gemPrice: 100),
    _ShopItem(id: 'hat_cap', category: 'hat', name: 'Havalı Kep', emoji: '🧢', gemPrice: 40),
    _ShopItem(id: 'hat_wizard', category: 'hat', name: 'Sihirbaz Şapkası', emoji: '🎩', gemPrice: 80),
    _ShopItem(id: 'hat_space', category: 'hat', name: 'Uzay Kaskı', emoji: '🚀', gemPrice: 120),
    _ShopItem(id: 'hat_knight', category: 'hat', name: 'Kahraman Miğferi', emoji: '🪖', gemPrice: 110),
    _ShopItem(id: 'hat_party', category: 'hat', name: 'Parti Şapkası', emoji: '🥳', gemPrice: 30),
    _ShopItem(id: 'hat_pirate', category: 'hat', name: 'Korsan Şapkası', emoji: '🏴‍☠️', gemPrice: 90),
    _ShopItem(id: 'hat_beanie', category: 'hat', name: 'Kış Beresi', emoji: '🎅', gemPrice: 45),
    _ShopItem(id: 'hat_dj', category: 'hat', name: 'DJ Kulaklığı', emoji: '🎧', gemPrice: 70),
    _ShopItem(id: 'hat_cowboy', category: 'hat', name: 'Kovboy Şapkası', emoji: '🤠', gemPrice: 85),
    _ShopItem(id: 'hat_grad', category: 'hat', name: 'Mezuniyet Kepi', emoji: '🎓', gemPrice: 95),
    _ShopItem(id: 'hat_flower', category: 'hat', name: 'Çiçek Tacı', emoji: '🌸', gemPrice: 50),
  ];

  final List<_ShopItem> _glasses = [
    _ShopItem(id: 'glass_none', category: 'glasses', name: 'Gözlüksüz', emoji: '❌', gemPrice: 0),
    _ShopItem(id: 'glass_sun', category: 'glasses', name: 'Karizma Güneş', emoji: '🕶️', gemPrice: 50),
    _ShopItem(id: 'glass_nerd', category: 'glasses', name: 'Bilgin Gözlüğü', emoji: '👓', gemPrice: 35),
    _ShopItem(id: 'glass_diver', category: 'glasses', name: 'Dalgıç Maskesi', emoji: '🥽', gemPrice: 60),
    _ShopItem(id: 'glass_hero', category: 'glasses', name: 'Kahraman Maskesi', emoji: '🦸', gemPrice: 75),
    _ShopItem(id: 'glass_cyber', category: 'glasses', name: 'Siber Vizör', emoji: '🤖', gemPrice: 90),
    _ShopItem(id: 'glass_pilot', category: 'glasses', name: 'Retro Havacı', emoji: '🛩️', gemPrice: 65),
    _ShopItem(id: 'glass_carnival', category: 'glasses', name: 'Karnaval Maskesi', emoji: '🎭', gemPrice: 80),
    _ShopItem(id: 'glass_funny', category: 'glasses', name: 'Şakacı Dedektif', emoji: '🥸', gemPrice: 40),
  ];

  final List<_ShopItem> _props = [
    _ShopItem(id: 'prop_none', category: 'prop', name: 'Aksesuarsız', emoji: '❌', gemPrice: 0),
    _ShopItem(id: 'prop_skateboard', category: 'prop', name: 'Altın Turbo Kaykay', emoji: '🛹', gemPrice: 60),
    _ShopItem(id: 'prop_wand', category: 'prop', name: 'Sihirli Yıldız Asa', emoji: '🪄', gemPrice: 75),
    _ShopItem(id: 'prop_guitar', category: 'prop', name: 'Alevli Rock Gitarı', emoji: '🎸', gemPrice: 90),
    _ShopItem(id: 'prop_trophy', category: 'prop', name: 'Şampiyonluk Kupası', emoji: '🏆', gemPrice: 110),
    _ShopItem(id: 'prop_mic', category: 'prop', name: 'Altın Mikrofon', emoji: '🎤', gemPrice: 65),
    _ShopItem(id: 'prop_shield', category: 'prop', name: 'Ejderha Kalkanı', emoji: '🛡️', gemPrice: 95),
    _ShopItem(id: 'prop_palette', category: 'prop', name: 'Ressam Paleti', emoji: '🎨', gemPrice: 55),
    _ShopItem(id: 'prop_book', category: 'prop', name: 'Büyülü Masal Kitabı', emoji: '📚', gemPrice: 70),
    _ShopItem(id: 'prop_ball', category: 'prop', name: 'Şampiyon Topu', emoji: '⚽', gemPrice: 45),
    _ShopItem(id: 'prop_gamepad', category: 'prop', name: 'Pro Oyuncu Kolu', emoji: '🎮', gemPrice: 85),
  ];

  final List<_ShopItem> _pets = [
    _ShopItem(id: 'pet_none', category: 'pet', name: 'Yoldaşsız', emoji: '❌', gemPrice: 0),
    _ShopItem(id: 'pet_dog', category: 'pet', name: 'Sadık Dost Çakıl', emoji: '🐶', gemPrice: 80),
    _ShopItem(id: 'pet_cat', category: 'pet', name: 'Yumak Pamuk Kedi', emoji: '🐱', gemPrice: 80),
    _ShopItem(id: 'pet_dragon', category: 'pet', name: 'Ateş Ejderhası', emoji: '🐲', gemPrice: 150),
    _ShopItem(id: 'pet_robot', category: 'pet', name: 'Mini Siber Bot', emoji: '🤖', gemPrice: 130),
    _ShopItem(id: 'pet_bunny', category: 'pet', name: 'Pofuduk Tavşan', emoji: '🐰', gemPrice: 70),
    _ShopItem(id: 'pet_parrot', category: 'pet', name: 'Geveze Papağan', emoji: '🦜', gemPrice: 90),
    _ShopItem(id: 'pet_fox', category: 'pet', name: 'Zeki Kızıl Tilki', emoji: '🦊', gemPrice: 100),
    _ShopItem(id: 'pet_unicorn', category: 'pet', name: 'Büyülü Tekboynuz', emoji: '🦄', gemPrice: 140),
    _ShopItem(id: 'pet_panda', category: 'pet', name: 'Tombul Panda', emoji: '🐼', gemPrice: 110),
    _ShopItem(id: 'pet_lion', category: 'pet', name: 'Cesur Aslancık', emoji: '🦁', gemPrice: 120),
    _ShopItem(id: 'pet_penguin', category: 'pet', name: 'Neşeli Penguen', emoji: '🐧', gemPrice: 85),
  ];

  final List<_ShopItem> _characters = [
    _ShopItem(id: 'char_skater_can', category: 'avatar', name: 'Ses Kaşifi', emoji: '👦', gemPrice: 0),
    _ShopItem(id: 'char_ece', category: 'avatar', name: 'Ritim Kaşifi', emoji: '👧', gemPrice: 0),
    _ShopItem(id: 'char_robo_b', category: 'avatar', name: 'Ses Robotu', emoji: '🤖', gemPrice: 120),
    _ShopItem(id: 'char_ninja', category: 'avatar', name: 'Ritim Ninjası', emoji: '🥷', gemPrice: 50),
    _ShopItem(id: 'char_prenses', category: 'avatar', name: 'Melodi Prensesi', emoji: '👸', gemPrice: 90),
    _ShopItem(id: 'char_superhero', category: 'avatar', name: 'Süper Konuşmacı', emoji: '🦸', gemPrice: 80),
    _ShopItem(id: 'char_dino', category: 'avatar', name: 'Neşeli Dino', emoji: '🦖', gemPrice: 110),
    _ShopItem(id: 'char_astro', category: 'avatar', name: 'Uzay Kaşifi', emoji: '🧑‍🚀', gemPrice: 100),
  ];

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _rewardState,
      builder: (context, _) {
        List<_ShopItem> currentItems;
        if (_selectedCategoryIndex == 0) {
          currentItems = _hats;
        } else if (_selectedCategoryIndex == 1) {
          currentItems = _glasses;
        } else if (_selectedCategoryIndex == 2) {
          currentItems = _props;
        } else if (_selectedCategoryIndex == 3) {
          currentItems = _pets;
        } else {
          currentItems = _characters;
        }

        return Container(
          height: MediaQuery.of(context).size.height * 0.90,
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

              // Üst Başlık & Elmas Sayacı
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3E5F5),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Text('🛍️', style: TextStyle(fontSize: 26)),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Avatar Gardırobu & Stüdyo',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF4A148C),
                            ),
                          ),
                          Text(
                            'Dokun, takla attır ve süsle! 🎨✨',
                            style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    // Kasa Bakiyesi (Elmaslar)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE1F5FE),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF03A9F4), width: 1.5),
                      ),
                      child: Row(
                        children: [
                          const Text('💎', style: TextStyle(fontSize: 18)),
                          const SizedBox(width: 6),
                          Text(
                            '${_rewardState.gems}',
                            style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF0277BD), fontSize: 14),
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

              // 🌟 CANLI VE ETKİLEŞİMLİ AVATAR SAHNESİ (Spotlight Preview)
              Container(
                margin: const EdgeInsets.all(14),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFEDE7F6), Color(0xFFD1C4E9)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFB39DDB), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF7E57C2).withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Canlı Katmanlı Avatar (Dokunulduğunda zıplar ve takla atar)
                    InteractiveAvatarWidget(
                      avatar: _rewardState.activeCharacterId,
                      hat: _rewardState.equippedHat,
                      glasses: _rewardState.equippedGlasses,
                      prop: _rewardState.equippedProp,
                      pet: _rewardState.equippedPet,
                      size: 96,
                      showPedestal: true,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _rewardState.activeCharacterName,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF311B92)),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              _buildEquipPill('👑', _rewardState.equippedHat ?? 'Şapkasız'),
                              _buildEquipPill('🕶️', _rewardState.equippedGlasses ?? 'Gözlüksüz'),
                              _buildEquipPill('🛹', _rewardState.equippedProp ?? 'Eşyasız'),
                              _buildEquipPill('🐾', _rewardState.equippedPet ?? 'Yoldaşsız'),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF58CC02),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              '👆 AVATARA DOKUN VE ZIPLAT!',
                              style: TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.w900),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // KATEGORİ SEKMELERİ (5 Adet Canlı Kategori)
              Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildCategoryTab(0, '👑 Şapkalar'),
                    const SizedBox(width: 6),
                    _buildCategoryTab(1, '🕶️ Gözlükler'),
                    const SizedBox(width: 6),
                    _buildCategoryTab(2, '🛹 Eşyalar'),
                    const SizedBox(width: 6),
                    _buildCategoryTab(3, '🐶 Yoldaş'),
                    const SizedBox(width: 6),
                    _buildCategoryTab(4, '🦸 Karakter'),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // ÜRÜN KARTLARI IZGARASI
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.88,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: currentItems.length,
                  itemBuilder: (ctx, i) {
                    final item = currentItems[i];
                    final isUnlocked = item.gemPrice == 0 ||
                        (item.category == 'avatar'
                            ? _rewardState.isCharacterUnlocked(item.id)
                            : _rewardState.isAccessoryUnlocked(item.id));
                    
                    bool isEquipped = false;
                    if (item.category == 'hat') {
                      isEquipped = _rewardState.equippedHat == (item.emoji == '❌' ? null : item.emoji) ||
                          _rewardState.equippedHat == item.id;
                    } else if (item.category == 'glasses') {
                      isEquipped = _rewardState.equippedGlasses == (item.emoji == '❌' ? null : item.emoji) ||
                          _rewardState.equippedGlasses == item.id;
                    } else if (item.category == 'prop') {
                      isEquipped = _rewardState.equippedProp == (item.emoji == '❌' ? null : item.emoji) ||
                          _rewardState.equippedProp == item.id;
                    } else if (item.category == 'pet') {
                      isEquipped = _rewardState.equippedPet == (item.emoji == '❌' ? null : item.emoji) ||
                          _rewardState.equippedPet == item.id;
                    } else if (item.category == 'avatar') {
                      isEquipped = _rewardState.activeCharacterId == item.id ||
                          _rewardState.activeAvatar == item.emoji;
                    }

                    return InkWell(
                      onTap: () {
                        if (item.category == 'avatar') {
                          if (isUnlocked) {
                            _rewardState.equipCharacter(item.id, item.name, item.emoji);
                            _sfx.playSuccessDing();
                          } else {
                            final success = _rewardState.buyAndEquipCharacter(
                              charId: item.id,
                              name: item.name,
                              emoji: item.emoji,
                              gemCost: item.gemPrice,
                            );
                            if (success) {
                              _sfx.playCoinChime();
                            } else {
                              _sfx.playPopSound();
                              showDialog(
                                context: context,
                                builder: (dCtx) => AlertDialog(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  title: const Text('💎 Yetersiz Elmas', style: TextStyle(fontWeight: FontWeight.w900)),
                                  content: Text(
                                    '${item.name} için ${item.gemPrice} 💎 gerekiyor.\nMevcut elmasın: ${_rewardState.gems} 💎\n\nKelimeleri çalışarak elmas toplayabilirsin!',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(dCtx),
                                      child: const Text('Tamam', style: TextStyle(fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),
                              );
                            }
                          }
                          return;
                        }

                        if (item.gemPrice == 0) {
                          // Çıkar
                          _rewardState.equipAccessory(item.category, null);
                          _sfx.playPopSound();
                        } else if (isUnlocked) {
                          // Kuşan
                          _rewardState.equipAccessory(item.category, item.emoji);
                          _sfx.playSuccessDing();
                        } else {
                          // Satın Al
                          final success = _rewardState.buyAndEquipAccessory(
                            itemId: item.id,
                            category: item.category,
                            emoji: item.emoji,
                            gemCost: item.gemPrice,
                          );
                          if (success) {
                            _sfx.playCoinChime();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('⚠️ Yeterli elmasın yok! Kelimeleri çalışarak elmas topla! 💎'),
                                backgroundColor: Color(0xFFD32F2F),
                              ),
                            );
                          }
                        }
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isEquipped
                              ? const Color(0xFFE8F5E9)
                              : (isUnlocked ? Colors.grey[50] : Colors.grey[100]),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isEquipped
                                ? const Color(0xFF58CC02)
                                : (isUnlocked ? Colors.grey[300]! : Colors.grey[400]!),
                            width: isEquipped ? 2.5 : 1.2,
                          ),
                          boxShadow: isEquipped
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFF58CC02).withValues(alpha: 0.3),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  )
                                ]
                              : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(item.emoji, style: const TextStyle(fontSize: 32)),
                            const SizedBox(height: 4),
                            Text(
                              item.name,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 4),
                            if (isEquipped)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF58CC02),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'KUŞANILDI',
                                  style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900),
                                ),
                              )
                            else if (isUnlocked)
                              Text(
                                item.gemPrice == 0 ? 'Çıkar' : 'Sahipsin',
                                style: const TextStyle(fontSize: 10, color: Colors.black54, fontWeight: FontWeight.w700),
                              )
                            else
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text('💎', style: TextStyle(fontSize: 11)),
                                  const SizedBox(width: 2),
                                  Text(
                                    '${item.gemPrice}',
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFF0288D1)),
                                  ),
                                ],
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

  Widget _buildEquipPill(String icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(220),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD1C4E9)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 10)),
          const SizedBox(width: 4),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 80),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: Color(0xFF4A148C)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTab(int index, String label) {
    final isSelected = _selectedCategoryIndex == index;
    return InkWell(
      onTap: () => setState(() => _selectedCategoryIndex = index),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF673AB7) : Colors.grey[100],
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? const Color(0xFF512DA8) : Colors.grey[300]!,
            width: 1.5,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w900,
            color: isSelected ? Colors.white : const Color(0xFF455A64),
          ),
        ),
      ),
    );
  }
}
