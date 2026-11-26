import 'dart:math';
import 'package:flutter/material.dart';
import '../models/reward_state.dart';
import '../services/audio_speech_service.dart';
import '../services/sound_effects_service.dart';

class _RiddleItem {
  final String phoneme;
  final String riddle;
  final String answer;
  final String answerEmoji;
  final List<Map<String, String>> options;

  const _RiddleItem({
    required this.phoneme,
    required this.riddle,
    required this.answer,
    required this.answerEmoji,
    required this.options,
  });
}

/// 🦉 BİLGE BAYKUŞ BİLMECE OYUNU (DOĞAL KONUŞMAYA GEÇİŞ)
class OwlRiddleGameDialog extends StatefulWidget {
  final String phoneme;
  const OwlRiddleGameDialog({super.key, this.phoneme = 'K'});

  @override
  State<OwlRiddleGameDialog> createState() => _OwlRiddleGameDialogState();
}

class _OwlRiddleGameDialogState extends State<OwlRiddleGameDialog> {
  final AudioSpeechService _audioService = AudioSpeechService();
  final SoundEffectsService _sfx = SoundEffectsService();
  final RewardState _rewardState = RewardState();
  final Random _rng = Random();

  static const List<_RiddleItem> _riddles = [
    // P
    _RiddleItem(
      phoneme: 'P',
      riddle: 'Doğum günlerinde üstüne mum dikilir, çok tatlıdır. Bu nedir?',
      answer: 'Pasta',
      answerEmoji: '🎂',
      options: [
        {'word': 'Pasta', 'emoji': '🎂'},
        {'word': 'Elma', 'emoji': '🍎'},
        {'word': 'Top', 'emoji': '⚽'},
      ],
    ),
    _RiddleItem(
      phoneme: 'P',
      riddle: 'Kırmızı burunlu, renkli kıyafetli sirk neşesi kimdir?',
      answer: 'Palyaço',
      answerEmoji: '🤡',
      options: [
        {'word': 'Aslan', 'emoji': '🦁'},
        {'word': 'Palyaço', 'emoji': '🤡'},
        {'word': 'Balon', 'emoji': '🎈'},
      ],
    ),
    // B
    _RiddleItem(
      phoneme: 'B',
      riddle: 'Suda yüzer, pulları vardır, hiç konuşmaz. Bu kimdir?',
      answer: 'Balık',
      answerEmoji: '🐟',
      options: [
        {'word': 'Balık', 'emoji': '🐟'},
        {'word': 'Kedi', 'emoji': '🐱'},
        {'word': 'Kuş', 'emoji': '🐦'},
      ],
    ),
    _RiddleItem(
      phoneme: 'B',
      riddle: 'İçine hava üflenir, gökyüzüne doğru süzülür. Bu nedir?',
      answer: 'Balon',
      answerEmoji: '🎈',
      options: [
        {'word': 'Kitap', 'emoji': '📖'},
        {'word': 'Saat', 'emoji': '⏰'},
        {'word': 'Balon', 'emoji': '🎈'},
      ],
    ),
    // T
    _RiddleItem(
      phoneme: 'T',
      riddle: 'Uzun kulaklıdır, zıp zıp zıplar ve havucu çok sever. Kimdir?',
      answer: 'Tavşan',
      answerEmoji: '🐰',
      options: [
        {'word': 'Tavşan', 'emoji': '🐰'},
        {'word': 'Fil', 'emoji': '🐘'},
        {'word': 'Köpek', 'emoji': '🐶'},
      ],
    ),
    _RiddleItem(
      phoneme: 'T',
      riddle: 'Rayların üstünde çuf çuf diyerek uzun yolculuk yapar. Nedir?',
      answer: 'Tren',
      answerEmoji: '🚂',
      options: [
        {'word': 'Gemi', 'emoji': '🚢'},
        {'word': 'Tren', 'emoji': '🚂'},
        {'word': 'Uçak', 'emoji': '✈️'},
      ],
    ),
    // D
    _RiddleItem(
      phoneme: 'D',
      riddle: 'Yazın külaha konur, soğuk soğuk yalanır. Bu nedir?',
      answer: 'Dondurma',
      answerEmoji: '🍦',
      options: [
        {'word': 'Dondurma', 'emoji': '🍦'},
        {'word': 'Çorba', 'emoji': '🍲'},
        {'word': 'Ekmek', 'emoji': '🍞'},
      ],
    ),
    _RiddleItem(
      phoneme: 'D',
      riddle: 'Çölde yaşar, uzun boyludur ve sırtında hörgücü vardır. Kimdir?',
      answer: 'Deve',
      answerEmoji: '🐪',
      options: [
        {'word': 'Penguen', 'emoji': '🐧'},
        {'word': 'Zürafa', 'emoji': '🦒'},
        {'word': 'Deve', 'emoji': '🐪'},
      ],
    ),
    // K
    _RiddleItem(
      phoneme: 'K',
      riddle: 'Ağaçta yetişir, kırmızı ve iki tanesi kulağa küpe gibi asılır. Nedir?',
      answer: 'Kiraz',
      answerEmoji: '🍒',
      options: [
        {'word': 'Muz', 'emoji': '🍌'},
        {'word': 'Kiraz', 'emoji': '🍒'},
        {'word': 'Havuç', 'emoji': '🥕'},
      ],
    ),
    _RiddleItem(
      phoneme: 'K',
      riddle: 'Miyav der, süt içer, yumuşacık tüyleri vardır. Kimdir?',
      answer: 'Kedi',
      answerEmoji: '🐱',
      options: [
        {'word': 'Kedi', 'emoji': '🐱'},
        {'word': 'Kurbağa', 'emoji': '🐸'},
        {'word': 'Ördek', 'emoji': '🦆'},
      ],
    ),
    // G
    _RiddleItem(
      phoneme: 'G',
      riddle: 'Sabah doğar, gökyüzünden dünyamızı ısıtır ve aydınlatır. Nedir?',
      answer: 'Güneş',
      answerEmoji: '☀️',
      options: [
        {'word': 'Ay', 'emoji': '🌙'},
        {'word': 'Güneş', 'emoji': '☀️'},
        {'word': 'Bulut', 'emoji': '☁️'},
      ],
    ),
    _RiddleItem(
      phoneme: 'G',
      riddle: 'Büyük denizlerde dalgaların üstünde yüzen dev araç nedir?',
      answer: 'Gemi',
      answerEmoji: '🚢',
      options: [
        {'word': 'Bisiklet', 'emoji': '🚲'},
        {'word': 'Kamyon', 'emoji': '🚚'},
        {'word': 'Gemi', 'emoji': '🚢'},
      ],
    ),
    // F
    _RiddleItem(
      phoneme: 'F',
      riddle: 'Kocaman kulakları ve uzun hortumu vardır. Bu hayvan kimdir?',
      answer: 'Fil',
      answerEmoji: '🐘',
      options: [
        {'word': 'Fil', 'emoji': '🐘'},
        {'word': 'Fare', 'emoji': '🐭'},
        {'word': 'Maymun', 'emoji': '🐵'},
      ],
    ),
    _RiddleItem(
      phoneme: 'F',
      riddle: 'Karanlıkta önümüzü aydınlatan el lambasına ne denir?',
      answer: 'Fener',
      answerEmoji: '🔦',
      options: [
        {'word': 'Şemsiye', 'emoji': '☂️'},
        {'word': 'Fener', 'emoji': '🔦'},
        {'word': 'Kalem', 'emoji': '✏️'},
      ],
    ),
    // V
    _RiddleItem(
      phoneme: 'V',
      riddle: 'İçine su koyup renkli çiçekleri yerleştirdiğimiz kap nedir?',
      answer: 'Vazo',
      answerEmoji: '🏺',
      options: [
        {'word': 'Vazo', 'emoji': '🏺'},
        {'word': 'Tencere', 'emoji': '🍲'},
        {'word': 'Kutu', 'emoji': '📦'},
      ],
    ),
    _RiddleItem(
      phoneme: 'V',
      riddle: 'Trene bağlıdır, içinde yolcular veya yükler taşınır. Nedir?',
      answer: 'Vagon',
      answerEmoji: '🚃',
      options: [
        {'word': 'Uçak', 'emoji': '✈️'},
        {'word': 'Kayık', 'emoji': '🛶'},
        {'word': 'Vagon', 'emoji': '🚃'},
      ],
    ),
    // S
    _RiddleItem(
      phoneme: 'S',
      riddle: 'Duvara asılır veya kola takılır, tik tak diyerek zamanı gösterir. Nedir?',
      answer: 'Saat',
      answerEmoji: '⏰',
      options: [
        {'word': 'Kitap', 'emoji': '📖'},
        {'word': 'Güneş', 'emoji': '☀️'},
        {'word': 'Saat', 'emoji': '⏰'},
      ],
    ),
    _RiddleItem(
      phoneme: 'S',
      riddle: 'İnekten gelir, bembeyazdır, içince kemiklerimiz güçlenir. Nedir?',
      answer: 'Süt',
      answerEmoji: '🥛',
      options: [
        {'word': 'Süt', 'emoji': '🥛'},
        {'word': 'Limonata', 'emoji': '🍋'},
        {'word': 'Bal', 'emoji': '🍯'},
      ],
    ),
    // Z
    _RiddleItem(
      phoneme: 'Z',
      riddle: 'Siyah beyaz çizgili pijaması varmış gibi görünen at hangisidir?',
      answer: 'Zebra',
      answerEmoji: '🦓',
      options: [
        {'word': 'Kaplan', 'emoji': '🐯'},
        {'word': 'Zebra', 'emoji': '🦓'},
        {'word': 'Ayı', 'emoji': '🐻'},
      ],
    ),
    _RiddleItem(
      phoneme: 'Z',
      riddle: 'Upuzun boynuyla ağaçların en tepesindeki yaprakları yer. Kimdir?',
      answer: 'Zürafa',
      answerEmoji: '🦒',
      options: [
        {'word': 'Zürafa', 'emoji': '🦒'},
        {'word': 'Sincap', 'emoji': '🐿️'},
        {'word': 'Kirpi', 'emoji': '🦔'},
      ],
    ),
    // Ş
    _RiddleItem(
      phoneme: 'Ş',
      riddle: 'Yağmur yağarken başımızın üstünde açıp ıslanmamızı önler. Nedir?',
      answer: 'Şemsiye',
      answerEmoji: '☂️',
      options: [
        {'word': 'Şapka', 'emoji': '👒'},
        {'word': 'Şemsiye', 'emoji': '☂️'},
        {'word': 'Eldiven', 'emoji': '🧤'},
      ],
    ),
    _RiddleItem(
      phoneme: 'Ş',
      riddle: 'Yazın güneşten korunmak için başımıza taktığımız şey nedir?',
      answer: 'Şapka',
      answerEmoji: '👒',
      options: [
        {'word': 'Şapka', 'emoji': '👒'},
        {'word': 'Gözlük', 'emoji': '👓'},
        {'word': 'Çorap', 'emoji': '🧦'},
      ],
    ),
    // J
    _RiddleItem(
      phoneme: 'J',
      riddle: 'Renkli, yumuşak ve ayı şeklinde de yapılan tatlı şekerleme nedir?',
      answer: 'Jelibon',
      answerEmoji: '🍬',
      options: [
        {'word': 'Jelibon', 'emoji': '🍬'},
        {'word': 'Biber', 'emoji': '🌶️'},
        {'word': 'Peynir', 'emoji': '🧀'},
      ],
    ),
    _RiddleItem(
      phoneme: 'J',
      riddle: 'Gökyüzünde çok hızlı uçan ses hızında uçak nedir?',
      answer: 'Jet',
      answerEmoji: '✈️',
      options: [
        {'word': 'Traktör', 'emoji': '🚜'},
        {'word': 'Jet', 'emoji': '✈️'},
        {'word': 'Bisiklet', 'emoji': '🚲'},
      ],
    ),
    // H
    _RiddleItem(
      phoneme: 'H',
      riddle: 'Turuncu renklidir, toprağın altında büyür, tavşanlar bayılır. Nedir?',
      answer: 'Havuç',
      answerEmoji: '🥕',
      options: [
        {'word': 'Havuç', 'emoji': '🥕'},
        {'word': 'Üzüm', 'emoji': '🍇'},
        {'word': 'Mısır', 'emoji': '🌽'},
      ],
    ),
    _RiddleItem(
      phoneme: 'H',
      riddle: 'Tepesinde dönen pervanesiyle dikey kalkış yapabilen hava aracı nedir?',
      answer: 'Helikopter',
      answerEmoji: '🚁',
      options: [
        {'word': 'Otobüs', 'emoji': '🚌'},
        {'word': 'Gemi', 'emoji': '🚢'},
        {'word': 'Helikopter', 'emoji': '🚁'},
      ],
    ),
    // Ç
    _RiddleItem(
      phoneme: 'Ç',
      riddle: 'Kırmızı, üstünde minik benekleri olan mis kokulu yaz meyvesi nedir?',
      answer: 'Çilek',
      answerEmoji: '🍓',
      options: [
        {'word': 'Çilek', 'emoji': '🍓'},
        {'word': 'Armut', 'emoji': '🍐'},
        {'word': 'Karpuz', 'emoji': '🍉'},
      ],
    ),
    _RiddleItem(
      phoneme: 'Ç',
      riddle: 'Kitaplarımızı ve kalemlerimizi koyup sırtımıza astığımız şey nedir?',
      answer: 'Çanta',
      answerEmoji: '🎒',
      options: [
        {'word': 'Ayakkabı', 'emoji': '👟'},
        {'word': 'Çanta', 'emoji': '🎒'},
        {'word': 'Yastık', 'emoji': '🛏️'},
      ],
    ),
    // C
    _RiddleItem(
      phoneme: 'C',
      riddle: 'Sert kabuğu kırılınca içinden beyne benzeyen lezzetli yemiş çıkar. Nedir?',
      answer: 'Ceviz',
      answerEmoji: '🥜',
      options: [
        {'word': 'Ceviz', 'emoji': '🥜'},
        {'word': 'Domates', 'emoji': '🍅'},
        {'word': 'Limon', 'emoji': '🍋'},
      ],
    ),
    _RiddleItem(
      phoneme: 'C',
      riddle: 'Sıcak yaz günlerinde küçük dilimlerle serinleten yeşil sebze nedir?',
      answer: 'Cacık',
      answerEmoji: '🥒',
      options: [
        {'word': 'Simit', 'emoji': '🥨'},
        {'word': 'Cacık', 'emoji': '🥒'},
        {'word': 'Kek', 'emoji': '🧁'},
      ],
    ),
    // M
    _RiddleItem(
      phoneme: 'M',
      riddle: 'Sarı kabuğu soyulur, maymunların en sevdiği meyvedir. Nedir?',
      answer: 'Muz',
      answerEmoji: '🍌',
      options: [
        {'word': 'Muz', 'emoji': '🍌'},
        {'word': 'Kivi', 'emoji': '🥝'},
        {'word': 'Nar', 'emoji': '🍎'},
      ],
    ),
    _RiddleItem(
      phoneme: 'M',
      riddle: 'Dört bacağı vardır, üstünde yemek yeriz veya ders çalışırız. Nedir?',
      answer: 'Masa',
      answerEmoji: '🪑',
      options: [
        {'word': 'Yatak', 'emoji': '🛏️'},
        {'word': 'Masa', 'emoji': '🪑'},
        {'word': 'Halı', 'emoji': '🧶'},
      ],
    ),
    // N
    _RiddleItem(
      phoneme: 'N',
      riddle: 'Çarşıdan aldım bir tane, eve geldim bin tane! Kırmızı taneli meyve nedir?',
      answer: 'Nar',
      answerEmoji: '🍎',
      options: [
        {'word': 'Nar', 'emoji': '🍎'},
        {'word': 'Muz', 'emoji': '🍌'},
        {'word': 'Armut', 'emoji': '🍐'},
      ],
    ),
    _RiddleItem(
      phoneme: 'N',
      riddle: 'Bizi uyutmak için söylenen yumuşacık, tatlı şarkılara ne denir?',
      answer: 'Ninni',
      answerEmoji: '🎵',
      options: [
        {'word': 'Masal', 'emoji': '📖'},
        {'word': 'Ninni', 'emoji': '🎵'},
        {'word': 'Resim', 'emoji': '🎨'},
      ],
    ),
    // L
    _RiddleItem(
      phoneme: 'L',
      riddle: 'Sapsarıdır, tadı çok ekşidir, çaya veya salataya sıkılır. Nedir?',
      answer: 'Limon',
      answerEmoji: '🍋',
      options: [
        {'word': 'Limon', 'emoji': '🍋'},
        {'word': 'Çikolata', 'emoji': '🍫'},
        {'word': 'Pasta', 'emoji': '🎂'},
      ],
    ),
    _RiddleItem(
      phoneme: 'L',
      riddle: 'Düğmesine basınca karanlık odayı aydınlatan ışık nedir?',
      answer: 'Lamba',
      answerEmoji: '💡',
      options: [
        {'word': 'Ayna', 'emoji': '🪞'},
        {'word': 'Lamba', 'emoji': '💡'},
        {'word': 'Tarak', 'emoji': '🪮'},
      ],
    ),
    // R
    _RiddleItem(
      phoneme: 'R',
      riddle: 'Pille çalışır, metalden yapılır ve bip bip diye konuşur. Nedir?',
      answer: 'Robot',
      answerEmoji: '🤖',
      options: [
        {'word': 'Araba', 'emoji': '🚗'},
        {'word': 'Robot', 'emoji': '🤖'},
        {'word': 'Balon', 'emoji': '🎈'},
      ],
    ),
    _RiddleItem(
      phoneme: 'R',
      riddle: 'Astronotları uzaya, yıldızların yanına götüren hızlı araç nedir?',
      answer: 'Roket',
      answerEmoji: '🚀',
      options: [
        {'word': 'Roket', 'emoji': '🚀'},
        {'word': 'Kamyon', 'emoji': '🚚'},
        {'word': 'Traktör', 'emoji': '🚜'},
      ],
    ),
    // Y
    _RiddleItem(
      phoneme: 'Y',
      riddle: 'Gece gökyüzünde ayın yanında pırıl pırıl parlayan minik ışıklar nedir?',
      answer: 'Yıldız',
      answerEmoji: '⭐',
      options: [
        {'word': 'Yıldız', 'emoji': '⭐'},
        {'word': 'Güneş', 'emoji': '☀️'},
        {'word': 'Deniz', 'emoji': '🌊'},
      ],
    ),
    _RiddleItem(
      phoneme: 'Y',
      riddle: 'Sabah kahvaltısında haşlanır ya da tavada kırılır, kabuğu beyazdır. Nedir?',
      answer: 'Yumurta',
      answerEmoji: '🥚',
      options: [
        {'word': 'Yumurta', 'emoji': '🥚'},
        {'word': 'Peynir', 'emoji': '🧀'},
        {'word': 'Ekmek', 'emoji': '🍞'},
      ],
    ),
  ];

  late List<int> _order;
  int _orderPos = 0;
  String? _selected;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _buildShuffledOrder();
    _speakRiddle();
  }

  void _buildShuffledOrder() {
    final indices = List<int>.generate(_riddles.length, (i) => i)..shuffle(_rng);
    final cleanP = widget.phoneme.replaceAll('/', '').trim().toUpperCase();
    final preferred = indices.where((i) => _riddles[i].phoneme == cleanP).toList();
    final others = indices.where((i) => _riddles[i].phoneme != cleanP).toList();
    _order = [...preferred, ...others];
    _orderPos = 0;
  }

  _RiddleItem get _currentRiddle => _riddles[_order[_orderPos]];

  void _speakRiddle() {
    final item = _currentRiddle;
    _audioService.speakTurkish(item.riddle, phoneme: item.phoneme);
  }

  void _nextRiddle() {
    _sfx.playPopSound();
    setState(() {
      if (_orderPos + 1 < _order.length) {
        _orderPos++;
      } else {
        _buildShuffledOrder();
      }
      _selected = null;
      _finished = false;
    });
    _speakRiddle();
  }

  void _choose(String word) {
    if (_selected != null || _finished) return;
    final item = _currentRiddle;
    setState(() => _selected = word);
    if (word == item.answer) {
      _sfx.playVictoryFanfare();
      _audioService.speakTurkish('Aferin! Doğru bildin: ${item.answer}!', phoneme: item.phoneme);
      _rewardState.addReward(earnedStars: 2, earnedXp: 30, earnedGems: 20);
      Future.delayed(const Duration(milliseconds: 1400), () {
        if (!mounted) return;
        setState(() => _finished = true);
      });
    } else {
      _sfx.playPopSound();
      Future.delayed(const Duration(milliseconds: 800), () {
        if (!mounted) return;
        setState(() => _selected = null);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = _currentRiddle;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 460),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFF3E5F5), Color(0xFFFFFFFF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(28),
        ),
        child: ListenableBuilder(
          listenable: _rewardState,
          builder: (context, _) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      '🦉 Bilge Baykuş Bilmecesi',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: Color(0xFF4A148C)),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8E1),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFFFD54F)),
                    ),
                    child: Text(
                      '⭐ ${_rewardState.totalStars}  💎 ${_rewardState.gems}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFFE65100)),
                    ),
                  ),
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded)),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDE7F6),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Bilmece ${_orderPos + 1} / ${_riddles.length} • /${item.phoneme.toLowerCase()}/ Sesi',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF6A1B9A)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFCE93D8), width: 2),
                ),
                child: Column(
                  children: [
                    Text(
                      item.riddle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton.icon(
                          onPressed: _speakRiddle,
                          icon: const Icon(Icons.volume_up_rounded, color: Color(0xFF7B1FA2)),
                          label: const Text('Tekrar Dinle', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF7B1FA2))),
                        ),
                        const SizedBox(width: 8),
                        if (!_finished)
                          TextButton.icon(
                            onPressed: _nextRiddle,
                            icon: const Icon(Icons.shuffle_rounded, color: Color(0xFF0284C7), size: 18),
                            label: const Text('Bilmece Değiştir', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0284C7))),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (!_finished)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: item.options.map((opt) {
                    final w = opt['word']!;
                    final e = opt['emoji']!;
                    final isSel = _selected == w;
                    final isCorrect = w == item.answer;
                    return InkWell(
                      onTap: () => _choose(w),
                      borderRadius: BorderRadius.circular(18),
                      child: Container(
                        width: 108,
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                        decoration: BoxDecoration(
                          color: isSel ? (isCorrect ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2)) : Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isSel ? (isCorrect ? const Color(0xFF16A34A) : const Color(0xFFEF4444)) : const Color(0xFFCBD5E1),
                            width: 2,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(e, style: const TextStyle(fontSize: 34)),
                            const SizedBox(height: 6),
                            Text(w, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                )
              else
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFF81C784)),
                      ),
                      child: const Text(
                        '🎉 Süpersin! +2 ⭐ Altın Yıldız • +20 💎 Elmas • +30 XP kazandın!',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w900, color: Color(0xFF16A34A)),
                      ),
                    ),
                    const SizedBox(height: 14),
                    ElevatedButton.icon(
                      onPressed: _nextRiddle,
                      icon: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 18),
                      label: const Text('Yeni Bilmece 🦉', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7B1FA2),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
