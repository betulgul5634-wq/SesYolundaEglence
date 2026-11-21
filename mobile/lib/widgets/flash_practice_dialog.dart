import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../services/audio_speech_service.dart';
import '../services/sound_effects_service.dart';
import '../models/reward_state.dart';
import '../utils/word_pictogram_helper.dart';

class _FlashWord {
  final String word;
  final String emoji;
  final String hint;

  const _FlashWord({
    required this.word,
    required this.emoji,
    required this.hint,
  });
}

/// ⚡ HIZLI TELAFFUZ RULETİ & CANLI MİKROFON TESTİ (FLASH DRILL)
/// Çocuk ekrana gelen kelimeyi mikrofona seslendirir; yapay zeka telaffuzu anında
/// puanlayarak doğruluk yüzdesini (%95 Mükemmel!) ve yıldızları canlı gösterir.
class FlashPracticeDialog extends StatefulWidget {
  final String phoneme;
  final List<String> words;

  const FlashPracticeDialog({
    super.key,
    required this.phoneme,
    required this.words,
  });

  @override
  State<FlashPracticeDialog> createState() => _FlashPracticeDialogState();
}

class _FlashPracticeDialogState extends State<FlashPracticeDialog> {
  final AudioSpeechService _audioService = AudioSpeechService();
  final SoundEffectsService _sfx = SoundEffectsService();
  final RewardState _rewardState = RewardState();

  late List<_FlashWord> _pool;
  int _currentIndex = 0;
  int _masteredCount = 0;
  int _totalAttempts = 0;
  int _totalAccuracySum = 0;

  bool _isListening = false;
  String _lastRecognized = '';
  int? _lastScore;
  String? _scoreFeedback;

  static final Map<String, List<_FlashWord>> _curatedSoundWords = {
    'P': const [
      _FlashWord(word: 'Pasta', emoji: '🎂', hint: 'Dudaklarını bas ve puf diye aç!'),
      _FlashWord(word: 'Pilav', emoji: '🍚', hint: 'P sesini başta net patlat!'),
      _FlashWord(word: 'Park', emoji: '🎡', hint: 'P sesiyle neşeyle başla!'),
      _FlashWord(word: 'Portakal', emoji: '🍊', hint: 'Dudaklarını kapatıp aç!'),
      _FlashWord(word: 'Panda', emoji: '🐼', hint: 'Sevimli panda için P!'),
      _FlashWord(word: 'Penguen', emoji: '🐧', hint: 'Kutup pengueni için P!'),
      _FlashWord(word: 'Peynir', emoji: '🧀', hint: 'Lezzetli peynir!'),
      _FlashWord(word: 'Piyano', emoji: '🎹', hint: 'P sesiyle müzik başlasın!'),
      _FlashWord(word: 'Çorap', emoji: '🧦', hint: 'Sonda P sesini duyur!'),
      _FlashWord(word: 'Kapı', emoji: '🚪', hint: 'Ortada P sesini yakala!'),
      _FlashWord(word: 'Top', emoji: '⚽', hint: 'Sonunda puf diye bitir!'),
    ],
    'B': const [
      _FlashWord(word: 'Balık', emoji: '🐟', hint: 'Boğazını titreterek B de!'),
      _FlashWord(word: 'Balon', emoji: '🎈', hint: 'Dudaklarını birbirine bas!'),
      _FlashWord(word: 'Bebek', emoji: '👶', hint: 'B sesini iki kez patlat!'),
      _FlashWord(word: 'Biber', emoji: '🫑', hint: 'Neşeyle B de!'),
      _FlashWord(word: 'Bardak', emoji: '🥛', hint: 'Dudak titreşimini hisset!'),
      _FlashWord(word: 'Araba', emoji: '🚗', hint: 'Ortadaki B sesini duyur!'),
      _FlashWord(word: 'Tabak', emoji: '🍽️', hint: 'B sesini kuvvetle ver!'),
      _FlashWord(word: 'Bulut', emoji: '☁️', hint: 'Gökyüzündeki bulut için B!'),
    ],
    'T': const [
      _FlashWord(word: 'Tarak', emoji: '🪮', hint: 'Dil ucunu üst damağa bas!'),
      _FlashWord(word: 'Top', emoji: '⚽', hint: 'Tıkır tıkır T sesi!'),
      _FlashWord(word: 'Tavşan', emoji: '🐰', hint: 'Dilini hızla patlat!'),
      _FlashWord(word: 'Terlik', emoji: '🩴', hint: 'T sesiyle başla!'),
      _FlashWord(word: 'Timsah', emoji: '🐊', hint: 'Kocaman T sesi patlat!'),
      _FlashWord(word: 'Saat', emoji: '⏰', hint: 'Sonunda T sesini vur!'),
      _FlashWord(word: 'Sepet', emoji: '🧺', hint: 'Dil ucunu yukarı dokundur!'),
      _FlashWord(word: 'Kutu', emoji: '📦', hint: 'Ortada T sesini yakala!'),
    ],
    'D': const [
      _FlashWord(word: 'Dondurma', emoji: '🍦', hint: 'Düt düt gibi dili patlat!'),
      _FlashWord(word: 'Davul', emoji: '🥁', hint: 'Boğazını titret ve Dan de!'),
      _FlashWord(word: 'Dede', emoji: '👴', hint: 'Dil ucunu damağa vur!'),
      _FlashWord(word: 'Deniz', emoji: '🌊', hint: 'Mavi deniz için D!'),
      _FlashWord(word: 'Deve', emoji: '🐪', hint: 'Dede gibi dili damağa bas!'),
      _FlashWord(word: 'Ördek', emoji: '🦆', hint: 'Ortada D sesini hisset!'),
      _FlashWord(word: 'Bardak', emoji: '🥛', hint: 'Dilini damağa bas!'),
      _FlashWord(word: 'Yıldız', emoji: '⭐', hint: 'D sesini net söyle!'),
    ],
    'K': const [
      _FlashWord(word: 'Kedi', emoji: '🐱', hint: 'Boğazından kıkırdayarak patlat!'),
      _FlashWord(word: 'Köpek', emoji: '🐶', hint: 'Dil ucun aşağıda kalsın!'),
      _FlashWord(word: 'Kuş', emoji: '🐦', hint: 'Boğazından güçlü bir K ver!'),
      _FlashWord(word: 'Kiraz', emoji: '🍒', hint: 'Tatlı kiraz için K!'),
      _FlashWord(word: 'Kalem', emoji: '✏️', hint: 'K sesiyle yaz!'),
      _FlashWord(word: 'Ekmek', emoji: '🍞', hint: 'Ortada ve sonda K!'),
      _FlashWord(word: 'Tabak', emoji: '🍽️', hint: 'Sonda K sesini patlat!'),
      _FlashWord(word: 'Balık', emoji: '🐟', hint: 'Sonunda kıkırdayan K!'),
    ],
    'G': const [
      _FlashWord(word: 'Gözlük', emoji: '👓', hint: 'Dilin arkasını damağa bas ve boğazı titret!'),
      _FlashWord(word: 'Gemi', emoji: '🚢', hint: 'Tok ve güçlü G sesi!'),
      _FlashWord(word: 'Güneş', emoji: '☀️', hint: 'Sıcacık güneş için G!'),
      _FlashWord(word: 'Gazete', emoji: '📰', hint: 'Boğazında sesi titret!'),
      _FlashWord(word: 'Gitar', emoji: '🎸', hint: 'G sesiyle müzik başlasın!'),
      _FlashWord(word: 'Geyik', emoji: '🦌', hint: 'Ormandaki geyik için G!'),
      _FlashWord(word: 'Kanguru', emoji: '🦘', hint: 'Ortadaki tok G sesini duyur!'),
      _FlashWord(word: 'Çizgi', emoji: '📏', hint: 'Ortada G sesini net söyle!'),
    ],
    'F': const [
      _FlashWord(word: 'Fil', emoji: '🐘', hint: 'Tavşan dişlerini alt dudağa değdir, üfle!'),
      _FlashWord(word: 'Fare', emoji: '🐭', hint: 'Fısıltıyla rüzgar yap: Fff!'),
      _FlashWord(word: 'Fırça', emoji: '🖌️', hint: 'Dişlerin alt dudağa değsin!'),
      _FlashWord(word: 'Fener', emoji: '🏮', hint: 'Işıltılı fener için F!'),
      _FlashWord(word: 'Fındık', emoji: '🌰', hint: 'Lezzetli fındık için F!'),
      _FlashWord(word: 'Zürafa', emoji: '🦒', hint: 'Ortada fısıldayan F!'),
      _FlashWord(word: 'Telefon', emoji: '📱', hint: 'Ortadaki F sesini üfle!'),
      _FlashWord(word: 'Çiftlik', emoji: '🚜', hint: 'F sesini kaçırma!'),
    ],
    'V': const [
      _FlashWord(word: 'Vazo', emoji: '🏺', hint: 'Dişleri alt dudağa değdir, motor gibi titret!'),
      _FlashWord(word: 'Vagon', emoji: '🚃', hint: 'Vızır vızır V sesi!'),
      _FlashWord(word: 'Vida', emoji: '🔩', hint: 'Boğazını titreterek Vvv de!'),
      _FlashWord(word: 'Vişne', emoji: '🍒', hint: 'Kırmızı vişne için V!'),
      _FlashWord(word: 'Tavşan', emoji: '🐰', hint: 'Ortadaki V motorunu hisset!'),
      _FlashWord(word: 'Deve', emoji: '🐪', hint: 'Ortada V sesini titret!'),
      _FlashWord(word: 'Havuz', emoji: '🏊', hint: 'Ortadaki serin V sesi!'),
      _FlashWord(word: 'Yuva', emoji: '🪺', hint: 'Sıcak yuva için V!'),
    ],
    'S': const [
      _FlashWord(word: 'Su', emoji: '💧', hint: 'Gülümse ve serin rüzgar gibi üfle!'),
      _FlashWord(word: 'Süt', emoji: '🥛', hint: 'Dişlerinin arasından sssss de!'),
      _FlashWord(word: 'Saat', emoji: '⏰', hint: 'İnce bir ıslık gibi!'),
      _FlashWord(word: 'Süpürge', emoji: '🧹', hint: 'S rüzgarıyla başla!'),
      _FlashWord(word: 'Masa', emoji: '🪵', hint: 'Ortada S rüzgarı!'),
      _FlashWord(word: 'Pasta', emoji: '🎂', hint: 'S sesini kaçırma!'),
      _FlashWord(word: 'Aslan', emoji: '🦁', hint: 'Güçlü bir S sesi!'),
      _FlashWord(word: 'Otobüs', emoji: '🚌', hint: 'Sonunda sss diye dur!'),
    ],
    'Z': const [
      _FlashWord(word: 'Zebra', emoji: '🦓', hint: 'Dişlerini yaklaştır, arı gibi vızılda!'),
      _FlashWord(word: 'Zil', emoji: '🔔', hint: 'Çınlayan Z sesi!'),
      _FlashWord(word: 'Zeytin', emoji: '🫒', hint: 'Kahvaltıdaki zeytin için Z!'),
      _FlashWord(word: 'Zürafa', emoji: '🦒', hint: 'Uzun boyunlu zürafa için Z!'),
      _FlashWord(word: 'Yüzük', emoji: '💍', hint: 'Ortada arı gibi vızılda!'),
      _FlashWord(word: 'Kiraz', emoji: '🍒', hint: 'Sonunda Z sesini çınlat!'),
      _FlashWord(word: 'Deniz', emoji: '🌊', hint: 'Sonunda vızıldayan Z!'),
      _FlashWord(word: 'Gözlük', emoji: '👓', hint: 'Ortada Z sesini yakala!'),
    ],
    'Ş': const [
      _FlashWord(word: 'Şapka', emoji: '👒', hint: 'Dudaklarını öne yuvarla, rüzgar üfle!'),
      _FlashWord(word: 'Şeker', emoji: '🍬', hint: 'Tatlı şeker için Şşş!'),
      _FlashWord(word: 'Şemsiye', emoji: '☂️', hint: 'Yağmurdaki şemsiye için Ş!'),
      _FlashWord(word: 'Şişe', emoji: '🍾', hint: 'İki kez Ş sesini üfle!'),
      _FlashWord(word: 'Kuş', emoji: '🐦', hint: 'Sonda yumuşak rüzgar: Kuş!'),
      _FlashWord(word: 'Güneş', emoji: '☀️', hint: 'Sonunda Ş sesini duyur!'),
      _FlashWord(word: 'Ateş', emoji: '🔥', hint: 'Sıcak ateş için Ş!'),
      _FlashWord(word: 'Kaşık', emoji: '🥄', hint: 'Ortadaki Ş sesini üfle!'),
    ],
    'J': const [
      _FlashWord(word: 'Jelibon', emoji: '🍬', hint: 'Dudakları uzat, motor gibi vızıldat!'),
      _FlashWord(word: 'Jandarma', emoji: '👮', hint: 'Güçlü J sesiyle başla!'),
      _FlashWord(word: 'Jet', emoji: '✈️', hint: 'Hızlı jet uçağı için J!'),
      _FlashWord(word: 'Jaguar', emoji: '🐆', hint: 'Hızlı jaguar için J!'),
      _FlashWord(word: 'Baraj', emoji: '🌊', hint: 'Sonda J sesini titret!'),
      _FlashWord(word: 'Garaj', emoji: '🚗', hint: 'Araba garajı için J!'),
      _FlashWord(word: 'Plaj', emoji: '🏖️', hint: 'Sıcak kumsal için J!'),
      _FlashWord(word: 'Viraj', emoji: '🛣️', hint: 'Sonda vızıldayan J!'),
    ],
    'H': const [
      _FlashWord(word: 'Havuç', emoji: '🥕', hint: 'Sıcak bir nefes ver: Ha!'),
      _FlashWord(word: 'Horoz', emoji: '🐓', hint: 'Boğazından serbestçe üfle!'),
      _FlashWord(word: 'Havlu', emoji: '🧖', hint: 'Ağzını rahat tut: Ha!'),
      _FlashWord(word: 'Halı', emoji: '🧶', hint: 'Yumuşak halı için H!'),
      _FlashWord(word: 'Kahve', emoji: '☕', hint: 'Ortadaki sıcak nefesi duyur!'),
      _FlashWord(word: 'Sahil', emoji: '🏖️', hint: 'Boğazından yumuşak nefes!'),
      _FlashWord(word: 'Lahana', emoji: '🥬', hint: 'Ortada H nefesini hisset!'),
      _FlashWord(word: 'Timsah', emoji: '🐊', hint: 'Sonunda sıcak bir nefes ver!'),
    ],
    'Ç': const [
      _FlashWord(word: 'Çilek', emoji: '🍓', hint: 'Dil ucunu damağa bas, tren gibi patlat!'),
      _FlashWord(word: 'Çanta', emoji: '🎒', hint: 'Çuf çuf gibi Ç sesi!'),
      _FlashWord(word: 'Çiçek', emoji: '🌸', hint: 'Mis kokulu çiçek için Ç!'),
      _FlashWord(word: 'Çekiç', emoji: '🔨', hint: 'İki kez Ç sesini vur!'),
      _FlashWord(word: 'Uçak', emoji: '✈️', hint: 'Ortadaki Ç patlamasını duyur!'),
      _FlashWord(word: 'Bahçe', emoji: '🏡', hint: 'Ortada neşeli Ç sesi!'),
      _FlashWord(word: 'Ağaç', emoji: '🌳', hint: 'Sonda Ç sesini net bitir!'),
      _FlashWord(word: 'Havuç', emoji: '🥕', hint: 'Sonunda Ç sesini patlat!'),
    ],
    'C': const [
      _FlashWord(word: 'Ceket', emoji: '🧥', hint: 'Dilini damağa bas, boğazı titreterek patlat!'),
      _FlashWord(word: 'Civciv', emoji: '🐥', hint: 'Cik cik diye iki kez C patlat!'),
      _FlashWord(word: 'Ceviz', emoji: '🥜', hint: 'Sert ceviz için C!'),
      _FlashWord(word: 'Cami', emoji: '🕌', hint: 'C sesiyle başla!'),
      _FlashWord(word: 'Gece', emoji: '🌙', hint: 'Ortada C sesini titret!'),
      _FlashWord(word: 'Böcek', emoji: '🐞', hint: 'Ortadaki minik C sesi!'),
      _FlashWord(word: 'İncir', emoji: '🫐', hint: 'Tatlı incir için C!'),
      _FlashWord(word: 'Yonca', emoji: '☘️', hint: 'Uğurlu yonca için C!'),
    ],
    'M': const [
      _FlashWord(word: 'Maymun', emoji: '🐒', hint: 'Dudaklarını kapat, burnundan ses ver: Mmm!'),
      _FlashWord(word: 'Masa', emoji: '🪵', hint: 'Dudak titreşimiyle başla!'),
      _FlashWord(word: 'Mısır', emoji: '🌽', hint: 'Sarı mısır için M!'),
      _FlashWord(word: 'Mantar', emoji: '🍄', hint: 'Ormandaki mantar için M!'),
      _FlashWord(word: 'Elma', emoji: '🍎', hint: 'Ortadaki lezzetli M sesi!'),
      _FlashWord(word: 'Kalem', emoji: '✏️', hint: 'Sonunda dudaklarını kapat: M!'),
      _FlashWord(word: 'Dondurma', emoji: '🍦', hint: 'Mmm diye lezzeti hisset!'),
      _FlashWord(word: 'Gemi', emoji: '🚢', hint: 'Sonunda dudakları birleştir!'),
    ],
    'N': const [
      _FlashWord(word: 'Nar', emoji: '🍎', hint: 'Dilini üst diş arkasına bas, burnundan çınlat!'),
      _FlashWord(word: 'Nokta', emoji: '🎯', hint: 'Tam hedefe N sesi!'),
      _FlashWord(word: 'Nine', emoji: '👵', hint: 'İki kez N sesini çınlat!'),
      _FlashWord(word: 'Nal', emoji: '🧲', hint: 'Uğurlu at nalı için N!'),
      _FlashWord(word: 'Tren', emoji: '🚂', hint: 'Sonunda N sesini çınlat!'),
      _FlashWord(word: 'Anne', emoji: '👩', hint: 'En sevdiğin N sesi!'),
      _FlashWord(word: 'Aslan', emoji: '🦁', hint: 'Sonunda N sesini duyur!'),
      _FlashWord(word: 'Sabun', emoji: '🧼', hint: 'Köpüklü sabun için N!'),
    ],
    'L': const [
      _FlashWord(word: 'Limon', emoji: '🍋', hint: 'Dil ucunu üst diş arkasına kaldır, şarkı söyler gibi akıt!'),
      _FlashWord(word: 'Lale', emoji: '🌷', hint: 'La la la diye L sesi!'),
      _FlashWord(word: 'Leylek', emoji: '🪶', hint: 'Gökyüzündeki leylek için L!'),
      _FlashWord(word: 'Lamba', emoji: '💡', hint: 'Işıltılı lamba için L!'),
      _FlashWord(word: 'Balon', emoji: '🎈', hint: 'Ortada dili yukarı kaldır!'),
      _FlashWord(word: 'Kale', emoji: '🏰', hint: 'Ortadaki sağlam L sesi!'),
      _FlashWord(word: 'Çilek', emoji: '🍓', hint: 'Tatlı çilek için L!'),
      _FlashWord(word: 'Fil', emoji: '🐘', hint: 'Sonunda dili yukarı dokundur!'),
    ],
    'R': const [
      _FlashWord(word: 'Radyo', emoji: '📻', hint: 'Dil ucunu damağa yaklaştır, motoru titret!'),
      _FlashWord(word: 'Renk', emoji: '🎨', hint: 'Rengarenk R sesi!'),
      _FlashWord(word: 'Roket', emoji: '🚀', hint: 'Uzaya uçan roket için R!'),
      _FlashWord(word: 'Robot', emoji: '🤖', hint: 'Sevimli robot için R!'),
      _FlashWord(word: 'Araba', emoji: '🚗', hint: 'Ortada motor gibi titret: Rrr!'),
      _FlashWord(word: 'Ördek', emoji: '🦆', hint: 'Ortadaki R sesini hisset!'),
      _FlashWord(word: 'Kar', emoji: '❄️', hint: 'Sonunda R sesini titreterek bitir!'),
      _FlashWord(word: 'Biber', emoji: '🫑', hint: 'Sonunda R motorunu çalıştır!'),
    ],
    'Y': const [
      _FlashWord(word: 'Yumurta', emoji: '🥚', hint: 'Gülümse, dil ortasını damağa yaklaştırıp kaydır!'),
      _FlashWord(word: 'Yaprak', emoji: '🍃', hint: 'Yeşil yaprak için Y!'),
      _FlashWord(word: 'Yıldız', emoji: '⭐', hint: 'Parlayan yıldız için Y!'),
      _FlashWord(word: 'Yılan', emoji: '🐍', hint: 'Kayarak giden Y sesi!'),
      _FlashWord(word: 'Ayı', emoji: '🐻', hint: 'Ortada tatlı bir Y sesi!'),
      _FlashWord(word: 'Kayık', emoji: '⛵', hint: 'Denizde yüzen kayık için Y!'),
      _FlashWord(word: 'Geyik', emoji: '🦌', hint: 'Ortada Y sesini akıt!'),
      _FlashWord(word: 'Ayna', emoji: '🪞', hint: 'Ortada Y sesini kaçırma!'),
    ],
  };

  @override
  void initState() {
    super.initState();
    final cleanP = widget.phoneme.replaceAll('/', '').trim().toUpperCase();
    if (_curatedSoundWords.containsKey(cleanP)) {
      _pool = List.from(_curatedSoundWords[cleanP]!);
    } else if (widget.words.isNotEmpty) {
      _pool = widget.words.map((w) => _FlashWord(
        word: w,
        emoji: WordPictogramHelper.getPictogram(w),
        hint: 'İçindeki [$cleanP] sesini net ve temiz söyle!',
      )).toList();
    } else {
      _pool = List.from(_curatedSoundWords['P']!);
    }
    _pool.shuffle(math.Random());
  }

  int _calculateAccuracy(String spoken, String targetWord, String targetPhoneme) {
    final s = spoken.toLowerCase().replaceAll(RegExp(r'[^a-zçğıöşü]'), '').trim();
    final t = targetWord.toLowerCase().replaceAll(RegExp(r'[^a-zçğıöşü]'), '').trim();
    final p = targetPhoneme.toLowerCase().replaceAll('/', '').trim();

    if (s.isEmpty) return 0;
    if (s == t) return 100;
    if (s.contains(t) || t.contains(s)) return 94;

    // Hedef ses kontrolü (Atlama ve Yer Değiştirme tespiti)
    final bool containsPhoneme = s.contains(p);

    int matches = 0;
    final minLen = math.min(s.length, t.length);
    for (int i = 0; i < minLen; i++) {
      if (s[i] == t[i]) matches++;
    }
    int rawScore = ((matches / t.length) * 100).round();

    // Klinik eşik: Hedef ses hiç söylenmediyse puan 40'ı geçemez!
    if (!containsPhoneme) {
      rawScore = math.min(rawScore, 38);
    }

    return rawScore.clamp(10, 98);
  }

  void _listenAndEvaluate() async {
    if (_isListening) return;

    final targetWord = _pool[_currentIndex];
    setState(() {
      _isListening = true;
      _lastRecognized = '';
      _lastScore = null;
      _scoreFeedback = null;
    });
    _sfx.playPopSound();

    try {
      final recognized = await _audioService.listenToSpeech(
        duration: const Duration(seconds: 4),
      );

      if (!mounted) return;

      final spoken = recognized.trim();
      final cleanP = widget.phoneme.replaceAll('/', '').trim().toUpperCase();
      final score = _calculateAccuracy(spoken, targetWord.word, cleanP);

      _totalAttempts++;
      _totalAccuracySum += score;

      String feedback;
      if (score >= 82) {
        feedback = 'Harika Telaffuz! [$cleanP] çok net.';
        _sfx.playSuccessDing();
        _masteredCount++;
        _rewardState.addReward(earnedStars: 1, earnedXp: 15, earnedGems: 5);
      } else if (spoken.isEmpty) {
        feedback = 'Ses algılanamadı, yaklaş!';
        _sfx.playPopSound();
      } else if (!spoken.toLowerCase().contains(cleanP.toLowerCase())) {
        feedback = '[$cleanP] sesi duyulamadı! Tane tane söyle.';
        _sfx.playPopSound();
      } else if (score >= 60) {
        feedback = 'Çok yaklaştın! Dudaklarını koru.';
        _sfx.playPopSound();
      } else {
        feedback = 'Tekrar dene: ${targetWord.hint}';
        _sfx.playPopSound();
      }

      setState(() {
        _isListening = false;
        _lastRecognized = spoken.isEmpty ? '(Ses algılanamadı)' : spoken;
        _lastScore = score;
        _scoreFeedback = feedback;
      });
    } catch (_) {
      if (mounted) setState(() => _isListening = false);
    }
  }

  void _nextWord() {
    _sfx.playPopSound();
    setState(() {
      _currentIndex = (_currentIndex + 1) % _pool.length;
      _lastRecognized = '';
      _lastScore = null;
      _scoreFeedback = null;
    });

    final nextWord = _pool[_currentIndex];
    _audioService.speakTurkish(nextWord.word, phoneme: widget.phoneme);
  }

  @override
  Widget build(BuildContext context) {
    final item = _pool[_currentIndex];
    final avgScore = _totalAttempts > 0 ? (_totalAccuracySum / _totalAttempts).round() : 0;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          gradient: const LinearGradient(
            colors: [Color(0xFFE8EAF6), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          border: Border.all(color: const Color(0xFF3F51B5), width: 2.5),
          boxShadow: const [
            BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, 8)),
          ],
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Üst Başlık & Açıklama
              Row(
                children: [
                  const Text('⚡', style: TextStyle(fontSize: 26)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Hızlı Pratik Ruleti',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF1A237E)),
                        ),
                        Text(
                          'Başarılan: $_masteredCount Kelime  •  Doğruluk: %$avgScore 🎯',
                          style: const TextStyle(fontSize: 11, color: Color(0xFF283593), fontWeight: FontWeight.w800),
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
              const SizedBox(height: 8),

              // Amacı ve Mantığı Açıklayan Bilgi Bandı
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8EAF6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF9FA8DA)),
                ),
                child: const Row(
                  children: [
                    Text('💡', style: TextStyle(fontSize: 14)),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Görseldeki kelimeyi mikrofona söyle! Yapay zeka telaffuzunu anında puanlar.',
                        style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFF283593)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // BÜYÜK FLASHCARD
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFC5CAE9), width: 2),
                  boxShadow: const [
                    BoxShadow(color: Color(0x1A3F51B5), blurRadius: 10, offset: Offset(0, 4)),
                  ],
                ),
                child: Column(
                  children: [
                    Text(item.emoji, style: const TextStyle(fontSize: 62)),
                    const SizedBox(height: 6),
                    Text(
                      item.word,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF283593),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.hint,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.volume_up_rounded, size: 18),
                      label: const Text('Terapistten Dinle 🔊', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11.5)),
                      onPressed: () => _audioService.speakTurkish(item.word, phoneme: widget.phoneme),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // CANLI MİKROFON SONUÇ PANELİ (Telefona Tam Sığacak Şekilde Duyarlı)
              if (_lastScore != null)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: _lastScore! >= 80 ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _lastScore! >= 80 ? const Color(0xFF4CAF50) : const Color(0xFFFF9800),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_lastScore! >= 80 ? '🌟' : '🎯', style: const TextStyle(fontSize: 24)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _scoreFeedback ?? '',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 12.5,
                                      color: _lastScore! >= 80 ? const Color(0xFF1B5E20) : const Color(0xFFE65100),
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: _lastScore! >= 80 ? const Color(0xFFC8E6C9) : const Color(0xFFFFE0B2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '%$_lastScore',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 13,
                                      color: _lastScore! >= 80 ? const Color(0xFF2E7D32) : const Color(0xFFEF6C00),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Söylenen: "$_lastRecognized"',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.black87),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              if (_isListening)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.mic_rounded, color: Colors.red, size: 20),
                    SizedBox(width: 8),
                    Text('Dinliyorum... Şimdi söyle! 🔴', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w800, fontSize: 12)),
                  ],
                ),
              ),

            const SizedBox(height: 14),

            // AKSİYON BUTONLARI: MİKROFON + SIRADAKİ KELİME
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isListening ? Colors.red : const Color(0xFF58CC02),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 3,
                    ),
                    icon: Icon(_isListening ? Icons.hearing_rounded : Icons.mic_rounded, size: 22),
                    label: Text(
                      _isListening ? 'DİNLİYORUM...' : 'SÖYLE VE TEST ET 🎤',
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                    ),
                    onPressed: _isListening ? null : _listenAndEvaluate,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      side: const BorderSide(color: Color(0xFF3F51B5), width: 1.5),
                    ),
                    onPressed: _nextWord,
                    child: const Text('Sıradaki ➔', style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF3F51B5), fontSize: 12)),
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
