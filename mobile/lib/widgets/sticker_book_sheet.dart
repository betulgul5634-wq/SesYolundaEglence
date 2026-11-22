import 'dart:async';
import 'package:flutter/material.dart';
import '../models/reward_state.dart';
import '../services/audio_speech_service.dart';
import '../services/sound_effects_service.dart';

class _StickerItem {
  final String id;
  final String word;
  final String phoneme;
  final String emoji;
  final String categoryTitle;
  final String hint;

  _StickerItem({
    required this.id,
    required this.word,
    required this.phoneme,
    required this.emoji,
    required this.categoryTitle,
    this.hint = '',
  });
}

/// 📖 SES ÇIKARTMA VE KLİNİK KOLEKSİYON ALBÜMÜ
/// Çocukların artikülasyon ve pratik çalışmalarında doğru söyledikleri kelimelerin
/// gerçek zamanlı olarak parıldayan bir koleksiyon çıkartmasına dönüştüğü ana albüm.
class StickerBookSheet extends StatefulWidget {
  const StickerBookSheet({super.key});

  @override
  State<StickerBookSheet> createState() => _StickerBookSheetState();
}

class _StickerBookSheetState extends State<StickerBookSheet> {
  final RewardState _rewardState = RewardState();
  final AudioSpeechService _audioService = AudioSpeechService();
  final SoundEffectsService _sfx = SoundEffectsService();
  int _selectedTabIndex = 0;

  // 6 Genişletilmiş Klinik Ses Kategorisi (21 Ses ve 100+ Kelime)
  final List<List<_StickerItem>> _pages = [
    // 1. Sayfa: 👄 Çift Dudak Sesleri (/p/, /b/, /m/)
    [
      _StickerItem(id: 'pasta', word: 'Pasta', phoneme: 'P', emoji: '🎂', categoryTitle: 'Tatlılar', hint: 'Dudaklarını kapat ve patlat'),
      _StickerItem(id: 'panda', word: 'Panda', phoneme: 'P', emoji: '🐼', categoryTitle: 'Hayvanlar', hint: 'Sevimli panda'),
      _StickerItem(id: 'peynir', word: 'Peynir', phoneme: 'P', emoji: '🧀', categoryTitle: 'Yiyecekler', hint: 'Sarı dilim peynir'),
      _StickerItem(id: 'pilot', word: 'Pilot', phoneme: 'P', emoji: '👨‍✈️', categoryTitle: 'Meslekler', hint: 'Uçak süren pilot'),
      _StickerItem(id: 'pide', word: 'Pide', phoneme: 'P', emoji: '🥖', categoryTitle: 'Fırın', hint: 'Sıcak leziz pide'),
      _StickerItem(id: 'portakal', word: 'Portakal', phoneme: 'P', emoji: '🍊', categoryTitle: 'Meyveler', hint: 'Sulu C vitamini'),
      _StickerItem(id: 'balik', word: 'Balık', phoneme: 'B', emoji: '🐟', categoryTitle: 'Deniz', hint: 'Yüzen minik balık'),
      _StickerItem(id: 'balon', word: 'Balon', phoneme: 'B', emoji: '🎈', categoryTitle: 'Eğlence', hint: 'Uçan kırmızı balon'),
      _StickerItem(id: 'bavul', word: 'Bavul', phoneme: 'B', emoji: '🧳', categoryTitle: 'Seyahat', hint: 'Yolculuk bavulu'),
      _StickerItem(id: 'bebek', word: 'Bebek', phoneme: 'B', emoji: '👶', categoryTitle: 'Aile', hint: 'Gülümseyen bebek'),
      _StickerItem(id: 'bardak', word: 'Bardak', phoneme: 'B', emoji: '🥛', categoryTitle: 'Mutfak', hint: 'Süt bardağı'),
      _StickerItem(id: 'biber', word: 'Biber', phoneme: 'B', emoji: '🌶️', categoryTitle: 'Sebzeler', hint: 'Kırmızı tatlı biber'),
      _StickerItem(id: 'maymun', word: 'Maymun', phoneme: 'M', emoji: '🐵', categoryTitle: 'Orman', hint: 'Muz seven sevimli maymun'),
      _StickerItem(id: 'masa', word: 'Masa', phoneme: 'M', emoji: '🪑', categoryTitle: 'Ev', hint: 'Çalışma masası'),
      _StickerItem(id: 'muz', word: 'Muz', phoneme: 'M', emoji: '🍌', categoryTitle: 'Meyveler', hint: 'Sarı tatlı muz'),
      _StickerItem(id: 'misir', word: 'Mısır', phoneme: 'M', emoji: '🌽', categoryTitle: 'Lezzetler', hint: 'Sarı taze mısır'),
      _StickerItem(id: 'makas', word: 'Makas', phoneme: 'M', emoji: '✂️', categoryTitle: 'Kırtasiye', hint: 'Kağıt kesen makas'),
      _StickerItem(id: 'mum', word: 'Mum', phoneme: 'M', emoji: '🕯️', categoryTitle: 'Işık', hint: 'Pasta mumu'),
    ],
    // 2. Sayfa: 🦷 Diş & Diş Yuvası (/t/, /d/, /n/)
    [
      _StickerItem(id: 'top', word: 'Top', phoneme: 'T', emoji: '⚽', categoryTitle: 'Oyun', hint: 'Futbol topu'),
      _StickerItem(id: 'tren', word: 'Tren', phoneme: 'T', emoji: '🚂', categoryTitle: 'Ulaşım', hint: 'Çuf çuf tren'),
      _StickerItem(id: 'tarak', word: 'Tarak', phoneme: 'T', emoji: '🪮', categoryTitle: 'Bakım', hint: 'Saç tarağı'),
      _StickerItem(id: 'tilki', word: 'Tilki', phoneme: 'T', emoji: '🦊', categoryTitle: 'Hayvanlar', hint: 'Kızıl orman tilkisi'),
      _StickerItem(id: 'tavsan', word: 'Tavşan', phoneme: 'T', emoji: '🐰', categoryTitle: 'Dostlar', hint: 'Zıp zıp tavşan'),
      _StickerItem(id: 'timsah', word: 'Timsah', phoneme: 'T', emoji: '🐊', categoryTitle: 'Nehir', hint: 'Yeşil timsah'),
      _StickerItem(id: 'dondurma', word: 'Dondurma', phoneme: 'D', emoji: '🍦', categoryTitle: 'Tatlılar', hint: 'Külah dondurma'),
      _StickerItem(id: 'dede', word: 'Dede', phoneme: 'D', emoji: '👴', categoryTitle: 'Aile', hint: 'Gözlüklü tonton dede'),
      _StickerItem(id: 'deve', word: 'Deve', phoneme: 'D', emoji: '🐪', categoryTitle: 'Çöl', hint: 'Hörgüçlü çöl devesi'),
      _StickerItem(id: 'davul', word: 'Davul', phoneme: 'D', emoji: '🥁', categoryTitle: 'Müzik', hint: 'Ritim davulu'),
      _StickerItem(id: 'dugme', word: 'Düğme', phoneme: 'D', emoji: '🔘', categoryTitle: 'Giysi', hint: 'Gömlek düğmesi'),
      _StickerItem(id: 'dis', word: 'Diş', phoneme: 'D', emoji: '🦷', categoryTitle: 'Sağlık', hint: 'Beyaz temiz diş'),
      _StickerItem(id: 'nar', word: 'Nar', phoneme: 'N', emoji: '🍎', categoryTitle: 'Meyveler', hint: 'Kırmızı taneli nar'),
      _StickerItem(id: 'nokta', word: 'Nokta', phoneme: 'N', emoji: '🎯', categoryTitle: 'Hedef', hint: 'Tam isabet noktası'),
      _StickerItem(id: 'nal', word: 'Nal', phoneme: 'N', emoji: '🧲', categoryTitle: 'Eşyalar', hint: 'Uğurlu at nalı'),
      _StickerItem(id: 'nane', word: 'Nane', phoneme: 'N', emoji: '🌿', categoryTitle: 'Doğa', hint: 'Mis kokulu nane'),
      _StickerItem(id: 'nehir', word: 'Nehir', phoneme: 'N', emoji: '🌊', categoryTitle: 'Coğrafya', hint: 'Akan berrak nehir'),
      _StickerItem(id: 'nota', word: 'Nota', phoneme: 'N', emoji: '🎵', categoryTitle: 'Müzik', hint: 'Şarkı notası'),
    ],
    // 3. Sayfa: 🏰 Damak Sesleri (/k/, /g/)
    [
      _StickerItem(id: 'kedi', word: 'Kedi', phoneme: 'K', emoji: '🐱', categoryTitle: 'Evcil', hint: 'Miyavlayan pamuk kedi'),
      _StickerItem(id: 'kopek', word: 'Köpek', phoneme: 'K', emoji: '🐶', categoryTitle: 'Evcil', hint: 'Sadık dost köpek'),
      _StickerItem(id: 'kus', word: 'Kuş', phoneme: 'K', emoji: '🐦', categoryTitle: 'Gökyüzü', hint: 'Kanat çırpan kuş'),
      _StickerItem(id: 'kelebek', word: 'Kelebek', phoneme: 'K', emoji: '🦋', categoryTitle: 'Doğa', hint: 'Renkli kelebek'),
      _StickerItem(id: 'kalem', word: 'Kalem', phoneme: 'K', emoji: '✏️', categoryTitle: 'Okul', hint: 'Yazı kalemi'),
      _StickerItem(id: 'karpuz', word: 'Karpuz', phoneme: 'K', emoji: '🍉', categoryTitle: 'Yaz', hint: 'Tatlı kırmızı karpuz'),
      _StickerItem(id: 'gemi', word: 'Gemi', phoneme: 'G', emoji: '🚢', categoryTitle: 'Deniz', hint: 'Büyük yolcu gemisi'),
      _StickerItem(id: 'gozluk', word: 'Gözlük', phoneme: 'G', emoji: '👓', categoryTitle: 'Aksesuar', hint: 'Güneş ve okuma gözlüğü'),
      _StickerItem(id: 'gitar', word: 'Gitar', phoneme: 'G', emoji: '🎸', categoryTitle: 'Müzik', hint: 'Telli akustik gitar'),
      _StickerItem(id: 'gunes', word: 'Güneş', phoneme: 'G', emoji: '☀️', categoryTitle: 'Uzay', hint: 'Parlayan sarı güneş'),
      _StickerItem(id: 'gul', word: 'Gül', phoneme: 'G', emoji: '🌹', categoryTitle: 'Çiçekler', hint: 'Kırmızı kokulu gül'),
      _StickerItem(id: 'geyik', word: 'Geyik', phoneme: 'G', emoji: '🦌', categoryTitle: 'Orman', hint: 'Boynuzlu sevimli geyik'),
    ],
    // 4. Sayfa: 🌬️ Diş-Dudak & Islıklı (/f/, /v/, /s/, /z/)
    [
      _StickerItem(id: 'fil', word: 'Fil', phoneme: 'F', emoji: '🐘', categoryTitle: 'Devler', hint: 'Uzun hortumlu fil'),
      _StickerItem(id: 'fener', word: 'Fener', phoneme: 'F', emoji: '🏮', categoryTitle: 'Işık', hint: 'Yol gösteren fener'),
      _StickerItem(id: 'fare', word: 'Fare', phoneme: 'F', emoji: '🐭', categoryTitle: 'Minikler', hint: 'Peynir seven sevimli fare'),
      _StickerItem(id: 'findik', word: 'Fındık', phoneme: 'F', emoji: '🌰', categoryTitle: 'Yemiş', hint: 'Kıtır fındık'),
      _StickerItem(id: 'firca', word: 'Fırça', phoneme: 'F', emoji: '🖌️', categoryTitle: 'Sanat', hint: 'Resim boyama fırçası'),
      _StickerItem(id: 'fincan', word: 'Fincan', phoneme: 'F', emoji: '☕', categoryTitle: 'İçecek', hint: 'Sıcak çay fincanı'),
      _StickerItem(id: 'vazo', word: 'Vazo', phoneme: 'V', emoji: '🏺', categoryTitle: 'Dekor', hint: 'Çiçek vazosu'),
      _StickerItem(id: 'vapur', word: 'Vapur', phoneme: 'V', emoji: '⛴️', categoryTitle: 'Deniz', hint: 'Boğaz vapuru'),
      _StickerItem(id: 'valiz', word: 'Valiz', phoneme: 'V', emoji: '🧳', categoryTitle: 'Seyahat', hint: 'Tekerlekli valiz'),
      _StickerItem(id: 'vida', word: 'Vida', phoneme: 'V', emoji: '🔩', categoryTitle: 'Tamir', hint: 'Dönen metal vida'),
      _StickerItem(id: 'saat', word: 'Saat', phoneme: 'S', emoji: '⏰', categoryTitle: 'Zaman', hint: 'Tik tak saat'),
      _StickerItem(id: 'sincap', word: 'Sincap', phoneme: 'S', emoji: '🐿️', categoryTitle: 'Orman', hint: 'Palamut toplayan sincap'),
      _StickerItem(id: 'sandalye', word: 'Sandalye', phoneme: 'S', emoji: '🪑', categoryTitle: 'Mobilya', hint: 'Ahşap sandalye'),
      _StickerItem(id: 'su', word: 'Su', phoneme: 'S', emoji: '💧', categoryTitle: 'Yaşam', hint: 'Temiz su damlası'),
      _StickerItem(id: 'sepet', word: 'Sepet', phoneme: 'S', emoji: '🧺', categoryTitle: 'Piknik', hint: 'Piknik sepeti'),
      _StickerItem(id: 'sabun', word: 'Sabun', phoneme: 'S', emoji: '🧼', categoryTitle: 'Hijyen', hint: 'Köpüklü temiz sabun'),
      _StickerItem(id: 'zurafa', word: 'Zürafa', phoneme: 'Z', emoji: '🦒', categoryTitle: 'Savana', hint: 'Uzun boyunlu zürafa'),
      _StickerItem(id: 'zeytin', word: 'Zeytin', phoneme: 'Z', emoji: '🫒', categoryTitle: 'Kahvaltı', hint: 'Siyah lezzetli zeytin'),
      _StickerItem(id: 'zil', word: 'Zil', phoneme: 'Z', emoji: '🔔', categoryTitle: 'Ses', hint: 'Çalan altın zil'),
      _StickerItem(id: 'zebra', word: 'Zebra', phoneme: 'Z', emoji: '🦓', categoryTitle: 'Çizgili', hint: 'Siyah beyaz zebra'),
    ],
    // 5. Sayfa: 🎭 Damak-Diş Yuvası (/ş/, /ç/, /c/, /j/)
    [
      _StickerItem(id: 'sapka', word: 'Şapka', phoneme: 'Ş', emoji: '🧢', categoryTitle: 'Giyim', hint: 'Güneşten koruyan şapka'),
      _StickerItem(id: 'seker', word: 'Şeker', phoneme: 'Ş', emoji: '🍬', categoryTitle: 'Tatlılar', hint: 'Renkli bayram şekeri'),
      _StickerItem(id: 'semsiye', word: 'Şemsiye', phoneme: 'Ş', emoji: '☂️', categoryTitle: 'Yağmur', hint: 'Yağmur şemsiyesi'),
      _StickerItem(id: 'sise', word: 'Şişe', phoneme: 'Ş', emoji: '🍾', categoryTitle: 'Mutfak', hint: 'Cam su şişesi'),
      _StickerItem(id: 'seftali', word: 'Şeftali', phoneme: 'Ş', emoji: '🍑', categoryTitle: 'Meyveler', hint: 'Tüylü tatlı şeftali'),
      _StickerItem(id: 'simsek', word: 'Şimşek', phoneme: 'Ş', emoji: '⚡', categoryTitle: 'Gökyüzü', hint: 'Pırıl pırıl şimşek'),
      _StickerItem(id: 'cicek', word: 'Çiçek', phoneme: 'Ç', emoji: '🌸', categoryTitle: 'Bahar', hint: 'Renkli bahar çiçeği'),
      _StickerItem(id: 'canta', word: 'Çanta', phoneme: 'Ç', emoji: '🎒', categoryTitle: 'Okul', hint: 'Sırt okul çantası'),
      _StickerItem(id: 'cilek', word: 'Çilek', phoneme: 'Ç', emoji: '🍓', categoryTitle: 'Meyveler', hint: 'Kırmızı tatlı çilek'),
      _StickerItem(id: 'corap', word: 'Çorap', phoneme: 'Ç', emoji: '🧦', categoryTitle: 'Giyim', hint: 'Yumuşak sıcak çorap'),
      _StickerItem(id: 'catal', word: 'Çatal', phoneme: 'Ç', emoji: '🍴', categoryTitle: 'Sofra', hint: 'Yemek çatalı'),
      _StickerItem(id: 'cadir', word: 'Çadır', phoneme: 'Ç', emoji: '⛺', categoryTitle: 'Kamp', hint: 'Doğa kamp çadırı'),
      _StickerItem(id: 'ceviz', word: 'Ceviz', phoneme: 'C', emoji: '🥜', categoryTitle: 'Kuruyemiş', hint: 'Sert kabuklu ceviz'),
      _StickerItem(id: 'cami', word: 'Cami', phoneme: 'C', emoji: '🕌', categoryTitle: 'Mimari', hint: 'Tarihi kubbeli cami'),
      _StickerItem(id: 'cetvel', word: 'Cetvel', phoneme: 'C', emoji: '📏', categoryTitle: 'Kırtasiye', hint: 'Düz çizgi cetveli'),
      _StickerItem(id: 'civciv', word: 'Civciv', phoneme: 'C', emoji: '🐥', categoryTitle: 'Çiftlik', hint: 'Sarı minik civciv'),
      _StickerItem(id: 'jant', word: 'Jant', phoneme: 'J', emoji: '🛞', categoryTitle: 'Araba', hint: 'Dönen tekerlek jantı'),
      _StickerItem(id: 'jole', word: 'Jöle', phoneme: 'J', emoji: '🍮', categoryTitle: 'Tatlı', hint: 'Kıpırdayan renkli jöle'),
    ],
    // 6. Sayfa: 🚀 Akıcı & Boğaz Sesleri (/r/, /l/, /y/, /h/)
    [
      _StickerItem(id: 'roket', word: 'Roket', phoneme: 'R', emoji: '🚀', categoryTitle: 'Uzay', hint: 'Aya giden hızlı roket'),
      _StickerItem(id: 'robot', word: 'Robot', phoneme: 'R', emoji: '🤖', categoryTitle: 'Teknoloji', hint: 'Konuşan akıllı robot'),
      _StickerItem(id: 'radyo', word: 'Radyo', phoneme: 'R', emoji: '📻', categoryTitle: 'Müzik', hint: 'Şarkı çalan radyo'),
      _StickerItem(id: 'resim', word: 'Resim', phoneme: 'R', emoji: '🖼️', categoryTitle: 'Sanat', hint: 'Çerçeveli güzel resim'),
      _StickerItem(id: 'renk', word: 'Renk', phoneme: 'R', emoji: '🎨', categoryTitle: 'Boya', hint: 'Gökkuşağı renkleri'),
      _StickerItem(id: 'ruzgar', word: 'Rüzgar', phoneme: 'R', emoji: '🌪️', categoryTitle: 'Doğa', hint: 'Esen tatlı rüzgar'),
      _StickerItem(id: 'leylek', word: 'Leylek', phoneme: 'L', emoji: '🪿', categoryTitle: 'Göçmen', hint: 'Bahar getiren leylek'),
      _StickerItem(id: 'limon', word: 'Limon', phoneme: 'L', emoji: '🍋', categoryTitle: 'Ekşi', hint: 'Sarı ekşi sulu limon'),
      _StickerItem(id: 'lamba', word: 'Lamba', phoneme: 'L', emoji: '💡', categoryTitle: 'Işık', hint: 'Odayı aydınlatan lamba'),
      _StickerItem(id: 'lokum', word: 'Lokum', phoneme: 'L', emoji: '🍬', categoryTitle: 'Gelenek', hint: 'Gül kokulu Türk lokumu'),
      _StickerItem(id: 'lale', word: 'Lale', phoneme: 'L', emoji: '🌷', categoryTitle: 'Çiçekler', hint: 'Zarif kırmızı lale'),
      _StickerItem(id: 'lokomotif', word: 'Lokomotif', phoneme: 'L', emoji: '🚂', categoryTitle: 'Tren', hint: 'Trenin ön motoru'),
      _StickerItem(id: 'yildiz', word: 'Yıldız', phoneme: 'Y', emoji: '⭐', categoryTitle: 'Gece', hint: 'Gökte parıldayan yıldız'),
      _StickerItem(id: 'yelken', word: 'Yelkenli', phoneme: 'Y', emoji: '⛵', categoryTitle: 'Deniz', hint: 'Rüzgarla giden yelkenli'),
      _StickerItem(id: 'yumurta', word: 'Yumurta', phoneme: 'Y', emoji: '🥚', categoryTitle: 'Besin', hint: 'Beyaz taze yumurta'),
      _StickerItem(id: 'yilan', word: 'Yılan', phoneme: 'Y', emoji: '🐍', categoryTitle: 'Doğa', hint: 'Kıvrılan yeşil yılan'),
      _StickerItem(id: 'havuc', word: 'Havuç', phoneme: 'H', emoji: '🥕', categoryTitle: 'Sebzeler', hint: 'Turuncu kıtır havuç'),
      _StickerItem(id: 'horoz', word: 'Horoz', phoneme: 'H', emoji: '🐓', categoryTitle: 'Sabah', hint: 'Ü ürü üü öten horoz'),
      _StickerItem(id: 'helikopter', word: 'Helikopter', phoneme: 'H', emoji: '🚁', categoryTitle: 'Havacılık', hint: 'Pervaneli helikopter'),
      _StickerItem(id: 'hediye', word: 'Hediye', phoneme: 'H', emoji: '🎁', categoryTitle: 'Sürpriz', hint: 'Kurdeleli hediye paketi'),
    ],
  ];

  final List<String> _tabTitles = [
    '👄 P & B & M',
    '🦷 T & D & N',
    '🏰 K & G',
    '🌬️ F & V & S & Z',
    '🎭 Ş & Ç & C & J',
    '🚀 R & L & Y & H',
  ];

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _rewardState,
      builder: (context, _) {
        final currentStickers = _pages[_selectedTabIndex];
        final totalUnlockedInPage = currentStickers.where((s) => _rewardState.isStickerUnlocked(s.id)).length;

        // Toplam albüm istatistikleri
        int totalStickersAll = 0;
        int totalUnlockedAll = 0;
        for (final p in _pages) {
          totalStickersAll += p.length;
          totalUnlockedAll += p.where((s) => _rewardState.isStickerUnlocked(s.id)).length;
        }
        final double overallRatio = totalStickersAll > 0 ? (totalUnlockedAll / totalStickersAll) : 0.0;
        final int percent = (overallRatio * 100).toInt();

        return Container(
          height: MediaQuery.of(context).size.height * 0.90,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            children: [
              // 1. Çekme Barı
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 6),
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(3),
                ),
              ),

              // 2. ÜST BAŞLIK & CANLI ANALİTİK GÖSTERGELERİ
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFF9C4), Color(0xFFFFD54F)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [BoxShadow(color: Color(0x33FFB300), blurRadius: 8, offset: Offset(0, 3))],
                      ),
                      child: const Text('📖', style: TextStyle(fontSize: 26)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Text(
                                'Klinik Çıkartma Albümü',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFFE65100),
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Koleksiyon: $totalUnlockedAll / $totalStickersAll Kelime (%$percent Tamamlandı)',
                            style: const TextStyle(fontSize: 11, color: Colors.black54, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                    // Başarı Rozeti
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFF4CAF50), width: 1.5),
                      ),
                      child: Row(
                        children: [
                          const Text('⭐', style: TextStyle(fontSize: 13)),
                          const SizedBox(width: 4),
                          Text(
                            '%$percent',
                            style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF2E7D32), fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.grey, size: 26),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // 3. CANLI GENEL İLERLEME ÇUBUĞU
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: overallRatio.clamp(0.0, 1.0),
                        backgroundColor: Colors.grey[200],
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFFB300)),
                        minHeight: 7,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Sayfa Durumu: $totalUnlockedInPage / ${currentStickers.length} Çıkartma Açık',
                          style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFF78909C)),
                        ),
                        Text(
                          'Kalan: ${currentStickers.length - totalUnlockedInPage} Kilitli',
                          style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: Color(0xFFE65100)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              const Divider(height: 1),

              // 4. SAYFA SEKMELERİ (Yatay Kaydırılabilir 6 Sayfa)
              Container(
                color: const Color(0xFFFAFAFA),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: List.generate(_tabTitles.length, (i) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: _buildPageTab(i, _tabTitles[i]),
                      );
                    }),
                  ),
                ),
              ),
              const Divider(height: 1),

              // 5. ÇIKARTMALAR SAYFASI IZGARASI
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(14),
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.86,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: currentStickers.length,
                  itemBuilder: (ctx, i) {
                    final item = currentStickers[i];
                    final isUnlocked = _rewardState.isStickerUnlocked(item.id);

                    return InkWell(
                      onTap: () {
                        if (isUnlocked) {
                          _sfx.playSuccessDing();
                          _audioService.speakTurkish(item.word, phoneme: item.phoneme);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('🔊 Dinliyorsun: "${item.word}" (/${item.phoneme.toLowerCase()}/ sesi) ⭐'),
                              duration: const Duration(milliseconds: 1400),
                              backgroundColor: const Color(0xFF2E7D32),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        } else {
                          // Kilitli Çıkartmayı Mikrofonla Şimdi Açma Diyaloğu
                          _showUnlockPracticeDialog(context, item);
                        }
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: isUnlocked ? Colors.white : const Color(0xFFF7F8FA),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isUnlocked ? const Color(0xFFFFD54F) : const Color(0xFFE0E0E0),
                            width: isUnlocked ? 2.2 : 1.2,
                          ),
                          boxShadow: isUnlocked
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFFFFB300).withValues(alpha: 0.25),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  )
                                ]
                              : [
                                  const BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 3,
                                    offset: Offset(0, 1),
                                  ),
                                ],
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (isUnlocked) ...[
                                    // AÇILMIŞ CANLI PARLAK ÇIKARTMA
                                    Text(item.emoji, style: const TextStyle(fontSize: 38)),
                                    const SizedBox(height: 6),
                                    Text(
                                      item.word,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 12.5,
                                        color: Color(0xFF263238),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFF3E0),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        '/${item.phoneme.toLowerCase()}/ sesi',
                                        style: const TextStyle(
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFFE65100),
                                        ),
                                      ),
                                    ),
                                  ] else ...[
                                    // KİLİTLİ GİZEMLİ ÇIKARTMA (Şık kilit rozeti ve dokun-aç yönlendirmesi)
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.grey[300]!, width: 1.5),
                                      ),
                                      alignment: Alignment.center,
                                      child: const Text('🔒', style: TextStyle(fontSize: 22)),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      '???',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 12,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE3F2FD),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        '🎤 Dokun & Aç',
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.blue[800],
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            // Açık çıkartmalar için parıltı rozeti
                            if (isUnlocked)
                              Positioned(
                                top: 6,
                                right: 6,
                                child: Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFFFD700),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Text('✨', style: TextStyle(fontSize: 9)),
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
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFB300) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? const Color(0xFFFFA000) : Colors.grey[300]!,
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFFFB300).withValues(alpha: 0.35),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w900,
            color: isSelected ? Colors.white : const Color(0xFF455A64),
          ),
        ),
      ),
    );
  }

  /// 🎤 KİLİTLİ ÇIKARTMAYI MİKROFONLA ŞİMDİ SÖYLEYİP AÇMA DİYALOĞU
  void _showUnlockPracticeDialog(BuildContext context, _StickerItem item) {
    _sfx.playPopSound();

    showDialog(
      context: context,
      builder: (ctx) {
        return _QuickStickerUnlockModal(
          item: item,
          audioService: _audioService,
          sfx: _sfx,
          rewardState: _rewardState,
        );
      },
    );
  }
}

/// 🌟 HIZLI ÇIKARTMA AÇMA POP-UP MODALI (Ses Tanıma ile Canlı Kilit Açma)
class _QuickStickerUnlockModal extends StatefulWidget {
  final _StickerItem item;
  final AudioSpeechService audioService;
  final SoundEffectsService sfx;
  final RewardState rewardState;

  const _QuickStickerUnlockModal({
    required this.item,
    required this.audioService,
    required this.sfx,
    required this.rewardState,
  });

  @override
  State<_QuickStickerUnlockModal> createState() => _QuickStickerUnlockModalState();
}

class _QuickStickerUnlockModalState extends State<_QuickStickerUnlockModal> {
  bool _isListening = false;
  int _secondsRemaining = 6;
  Timer? _timer;
  String _liveTranscript = '';
  SpeechEvaluationResult? _evalResult;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _listenAndUnlock() async {
    widget.sfx.playPopSound();
    setState(() {
      _isListening = true;
      _secondsRemaining = 6;
      _liveTranscript = 'Seni dinliyorum... Şimdi "${widget.item.word}" de! 🎤';
      _evalResult = null;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (_secondsRemaining > 1) {
        setState(() => _secondsRemaining--);
      } else {
        t.cancel();
      }
    });

    final res = await widget.audioService.listenAndEvaluate(
      targetText: widget.item.word,
      phoneme: widget.item.phoneme,
      duration: const Duration(seconds: 6),
      onLiveSpeech: (text) {
        if (mounted) {
          setState(() => _liveTranscript = '🗣️ Algılanan: "$text"');
        }
      },
    );

    _timer?.cancel();
    if (!mounted) return;

    setState(() {
      _isListening = false;
      _evalResult = res;
      _liveTranscript = res.recognizedText.isNotEmpty ? res.recognizedText : '(Ses algılanamadı)';
    });

    if (res.isMatched) {
      widget.sfx.playSuccessDing();
      widget.rewardState.unlockSticker(widget.item.id);
      widget.rewardState.unlockSticker(widget.item.word);
      widget.rewardState.recordPracticeToday();
      widget.rewardState.recordQuestWord();
      widget.rewardState.addReward(earnedStars: 1, earnedXp: 30, earnedGems: 10);
    } else {
      widget.sfx.playPopSound();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSuccess = _evalResult?.isMatched == true;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, 8))],
        ),
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Kapatma
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.grey),
                onPressed: () => Navigator.pop(context),
              ),
            ),

            // Çıkartma Görseli
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isSuccess
                      ? [const Color(0xFFE8F5E9), const Color(0xFFC8E6C9)]
                      : [const Color(0xFFFFF9C4), const Color(0xFFFFECB3)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                border: Border.all(color: isSuccess ? const Color(0xFF4CAF50) : const Color(0xFFFFB300), width: 3),
              ),
              alignment: Alignment.center,
              child: Text(
                widget.item.emoji,
                style: const TextStyle(fontSize: 48),
              ),
            ),
            const SizedBox(height: 12),

            // Kelime & Ses Başlığı
            Text(
              widget.item.word,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF263238)),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '/${widget.item.phoneme.toLowerCase()}/ Sesi Çıkartması',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF1565C0)),
              ),
            ),
            const SizedBox(height: 14),

            // İpucu ve Örnek Dinleme
            Text(
              'İpucu: "${widget.item.word}" de ve mikrofona söyle!',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: Colors.black54, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),

            // Örnek Sesi Dinle Butonu
            OutlinedButton.icon(
              onPressed: () {
                widget.audioService.speakTurkish(widget.item.word, phoneme: widget.item.phoneme);
              },
              icon: const Icon(Icons.volume_up_rounded, color: Color(0xFF00897B), size: 20),
              label: const Text('Örnek Sesi Dinle', style: TextStyle(color: Color(0xFF00897B), fontWeight: FontWeight.w800, fontSize: 12)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF00897B), width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),

            const SizedBox(height: 14),

            // Değerlendirme Sonucu Kartı
            if (_evalResult != null)
              Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isSuccess ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSuccess ? const Color(0xFF4CAF50) : const Color(0xFFFF9800),
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Text(isSuccess ? '🎉' : '👂', style: const TextStyle(fontSize: 24)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isSuccess ? 'TEBRİKLER! ÇIKARTMA AÇILDI!' : 'ÇOK YAKLAŞTIN!',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 12.5,
                              color: isSuccess ? const Color(0xFF2E7D32) : const Color(0xFFE65100),
                            ),
                          ),
                          Text(
                            isSuccess
                                ? '+30 XP & +10 Elmas Kazandın! ⭐'
                                : 'Duyulan: "$_liveTranscript" • Tekrar dene!',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isSuccess ? Colors.black87 : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            // Dinleme Animasyonu veya Mikrofon Butonu
            if (_isListening) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF4CAF50), width: 2),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.mic, color: Color(0xFF2E7D32), size: 22),
                    const SizedBox(width: 8),
                    Text(
                      'Dinleniyor... (${_secondsRemaining}s)',
                      style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF2E7D32), fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _liveTranscript,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: Colors.black54, fontStyle: FontStyle.italic),
              ),
            ] else if (isSuccess) ...[
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.check_circle_rounded, color: Colors.white),
                label: const Text('HARİKA, ALBÜME DÖN!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  elevation: 4,
                ),
              ),
            ] else ...[
              ElevatedButton.icon(
                onPressed: _listenAndUnlock,
                icon: const Icon(Icons.mic, color: Colors.white),
                label: Text(
                  _evalResult != null ? 'TEKRAR SÖYLE 🎤' : 'MİKROFONLA SÖYLE VE AÇ 🎤',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13.5),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF58CC02),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  elevation: 4,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
