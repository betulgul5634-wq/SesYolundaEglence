# -*- coding: utf-8 -*-
import re

# Comprehensive semantic dictionary for Turkish words
EMOJI_MAP = {
    # İnsan, Aile, Meslekler
    'anne': '👩', 'baba': '👨', 'dede': '👴', 'nene': '👵', 'nine': '👵', 'amca': '👨', 'hala': '👩', 'teyze': '👩',
    'dayı': '👨', 'kardeş': '👧', 'bebek': '👶', 'çocuk': '👦', 'kız': '👧', 'oğul': '👦', 'adam': '👨', 'kadın': '👩',
    'aşçı': '👨‍🍳', 'bahçıvan': '🧑‍🌾', 'bekçi': '👮', 'doktor': '👨‍⚕️', 'hemşire': '👩‍⚕️', 'öğretmen': '👩‍🏫',
    'öğrenci': '🧑‍🎓', 'avukat': '⚖️', 'pilot': '👨‍✈️', 'kaptan': '🧑‍✈️', 'itfaiyeci': '👨‍🚒', 'polis': '👮‍♂️',
    'asker': '🪖', 'mimar': '📐', 'mühendis': '👷', 'berber': '💇‍♂️', 'terzi': '🧵', 'palyaço': '🤡', 'sihirbaz': '🧙‍♂️',
    'cambaz': '🎪', 'amigo': '📣', 'şoför': '🚍', 'prens': '🤴', 'prenses': '👸', 'kral': '👑', 'kraliçe': '👑',
    'ihtiyar': '👴', 'genç': '🧑', 'arkadaş': '🤝', 'komşu': '🏡', 'usta': '🔨', 'ressam': '🎨', 'şair': '✍️',
    'müzisyen': '🎵', 'şarkıcı': '🎤', 'dansçı': '💃', 'balerin': '🩰', 'sporcu': '🏃', 'hakem': '🏁',

    # Doğa, Hava Durumu, Çevre
    'güneş': '☀️', 'ay': '🌙', 'yıldız': '⭐', 'bulut': '☁️', 'yağmur': '🌧️', 'kar': '❄️', 'şimşek': '⚡',
    'gök': '🌤️', 'gökkuşağı': '🌈', 'rüzgar': '💨', 'fırtına': '🌪️', 'sis': '🌫️', 'deniz': '🌊', 'dalga': '🌊',
    'göl': '🏞️', 'nehir': '🏞️', 'dere': '🏞️', 'dağ': '⛰️', 'tepe': '🏔️', 'orman': '🌲', 'ağaç': '🌳', 'yaprak': '🍃',
    'çiçek': '🌸', 'gül': '🌹', 'lale': '🌷', 'papatya': '🌼', 'karanfil': '🌺', 'menekşe': '💐', 'sümbül': '🪻',
    'açelya': '🌺', 'nilüfer': '🪷', 'çimen': '🌱', 'ot': '🌿', 'çam': '🌲', 'meşe': '🌳', 'kavak': '🌳',
    'bahar': '🌻', 'yaz': '☀️', 'sonbahar': '🍂', 'kış': '☃️', 'sabah': '🌅', 'akşam': '🌆', 'gece': '🌃',
    'gündüz': '☀️', 'aydınlık': '💡', 'karanlık': '🌑', 'ateş': '🔥', 'alev': '🔥', 'duman': '💨', 'buhar': '💨',
    'toprak': '🪴', 'kum': '🏖️', 'taş': '🪨', 'kaya': '🪨', 'çakıl': '🪨', 'ada': '🏝️', 'mağara': '🕳️', 'vadi': '🏞️',

    # Yiyecek & İçecek
    'ekmek': '🍞', 'su': '💧', 'süt': '🥛', 'çay': '🍵', 'kahve': '☕', 'meyve': '🍎', 'sebze': '🥕', 'et': '🥩',
    'biftek': '🥩', 'köfte': '🧆', 'tavuk': '🍗', 'balık': '🐟', 'çorba': '🥣', 'pilav': '🍚', 'makarna': '🍝',
    'börek': '🥟', 'çörek': '🥐', 'simit': '🥨', 'poğaça': '🥐', 'pasta': '🎂', 'kek': '🧁', 'kurabiye': '🍪',
    'turta': '🥧', 'tatlı': '🍰', 'baklava': '🧇', 'dondurma': '🍦', 'şeker': '🍬', 'çikolata': '🍫', 'bal': '🍯',
    'reçel': '🫙', 'peynir': '🧀', 'zeytin': '🫒', 'yumurta': '🥚', 'tereyağı': '🧈', 'yoğurt': '🥣', 'patates': '🥔',
    'domates': '🍅', 'salatalık': '🥒', 'biber': '🌶️', 'patlıcan': '🍆', 'havuç': '🥕', 'soğan': '🧅', 'sarımsak': '🧄',
    'marul': '🥬', 'ıspanak': '🥬', 'lahana': '🥬', 'pırasa': '🌱', 'bezelye': '🫛', 'fasulye': '🫘', 'mısır': '🌽',
    'mantar': '🍄', 'kabak': '🎃', 'limon': '🍋', 'portakal': '🍊', 'mandalina': '🍊', 'greyfurt': '🍊', 'muz': '🍌',
    'elma': '🍎', 'armut': '🍐', 'çilek': '🍓', 'kiraz': '🍒', 'vişne': '🍒', 'üzüm': '🍇', 'karpuz': '🍉',
    'kavun': '🍈', 'şeftali': '🍑', 'kayısı': '🍑', 'erik': '🫐', 'incir': '🫐', 'nar': '🫐', 'ananas': '🍍',
    'kivi': '🥝', 'avokado': '🥑', 'badem': '🥜', 'fındık': '🌰', 'fıstık': '🥜', 'ceviz': '🌰', 'kestane': '🌰',
    'zeytinyağı': '🫒', 'tuz': '🧂', 'biber': '🌶️', 'baharat': '🧂', 'sirke': '🍾', 'sos': '🥫', 'salça': '🥫',
    'ayran': '🥛', 'meyve suyu': '🧃', 'gazoz': '🥤', 'limonata': '🍋', 'şerbet': '🍹', 'lahmacun': '🫓', 'pide': '🫓',
    'döner': '🥙', 'dürüm': '🌯', 'kebap': '🍢', 'sandviç': '🥪', 'tost': '🥪', 'pizza': '🍕', 'hamburger': '🍔',
    'patates kızartması': '🍟', 'cips': '🍟', 'çerez': '🥜', 'leblebi': '🥜', 'çekirdek': '🌻', 'badem': '🥜',

    # Hayvanlar (Ek)
    'aslan': '🦁', 'kaplan': '🐯', 'leopar': '🐆', 'çita': '🐆', 'jaguar': '🐆', 'kurt': '🐺', 'tilki': '🦊',
    'ayı': '🐻', 'kutup ayısı': '🐻‍❄️', 'panda': '🐼', 'koala': '🐨', 'kanguru': '🦘', 'maymun': '🐵', 'şempanze': '🐒',
    'goril': '🦍', 'fil': '🐘', 'gergedan': '🦏', 'hipopotam': '🦛', 'zürafa': '🦒', 'zebra': '🦓', 'deve': '🐫',
    'lama': '🦙', 'geyik': '🦌', 'ceylan': '🦌', 'at': '🐴', 'eşek': '🫏', 'katır': '🫏', 'inek': '🐮', 'öküz': '🐂',
    'boğa': '🐂', 'manda': '🐃', 'koyun': '🐑', 'kuzu': '🐑', 'keçi': '🐐', 'oğlak': '🐐', 'domuz': '🐷',
    'tavşan': '🐰', 'fare': '🐭', 'sıçan': '🐀', 'hamster': '🐹', 'kunduz': '🦫', 'kirpi': '🦔', 'köstebek': '🦫',
    'yarasa': '🦇', 'su samuru': '🦦', 'fok': '🦭', 'mors': '🦭', 'balina': '🐋', 'yunus': '🐬', 'köpekbalığı': '🦈',
    'vatoz': '🐡', 'ahtapot': '🐙', 'mürekkep balığı': '🦑', 'ıstakoz': '🦞', 'yengeç': '🦀', 'karides': '🦐',
    'denizyıldızı': '⭐', 'denizatı': '🪸', 'denizanası': '🪼', 'mercan': '🪸', 'istiridye': '🦪', 'salyangoz': '🐌',
    'kurbağa': '🐸', 'semender': '🦎', 'kertenkele': '🦎', 'bukalemun': '🦎', 'yılan': '🐍', 'timsah': '🐊',
    'kaplumbağa': '🐢', 'kuş': '🐦', 'güvercin': '🕊️', 'kumru': '🕊️', 'serçe': '🐦', 'karga': '🐦‍⬛', 'saksağan': '🐦‍⬛',
    'kartal': '🦅', 'şahin': '🦅', 'doğan': '🦅', 'akbaba': '🦅', 'baykuş': '🦉', 'leylek': '🪿', 'turna': '🪿',
    'pelikan': '🪿', 'flamingo': '🦩', 'kuğu': '🦢', 'kaz': '🪿', 'ördek': '🦆', 'tavuk': '🐔', 'horoz': '🐓',
    'civciv': '🐤', 'hindi': '🦃', 'bıldırcın': '🐦', 'sülün': '🦚', 'tavuskuşu': '🦚', 'papağan': '🦜', 'kanarya': '🐤',
    'ağaçkakan': '🐦', 'martı': '🐦', 'penguen': '🐧', 'arı': '🐝', 'eşekarısı': '🐝', 'karınca': '🐜', 'kelebek': '🦋',
    'güve': '🦋', 'sinek': '🪰', 'sivrisinek': '🦟', 'uğurböceği': '🐞', 'böcek': '🪲', 'çekirge': '🦗', 'cırcır böceği': '🦗',
    'akrep': '🦂', 'örümcek': '🕷️', 'kırkayak': '🐛', 'solucan': '🪱', 'tırtıl': '🐛', 'pire': '🪲',

    # Eşyalar, Araçlar, Teknoloji
    'masa': '🪵', 'sandalye': '🪑', 'koltuk': '🛋️', 'berjer': '🛋️', 'kanepe': '🛋️', 'yatak': '🛏️', 'dolap': '🚪',
    'gardırop': '🚪', 'komodin': '🗄️', 'sehpa': '☕', 'halı': '🧶', 'kilim': '🧶', 'perde': '🪟', 'pencere': '🪟',
    'kapı': '🚪', 'anahtar': '🔑', 'kilit': '🔒', 'lamba': '🛋️', 'abajur': '🛋️', 'avize': '💡', 'ampul': '💡',
    'fener': '🔦', 'mum': '🕯️', 'ayna': '🪞', 'saat': '⏰', 'kol saati': '⌚', 'duvar saati': '🕰️', 'alarm': '⏰',
    'televizyon': '📺', 'radyo': '📻', 'telefon': '📱', 'cep telefonu': '📱', 'bilgisayar': '💻', 'tablet': '📱',
    'laptop': '💻', 'klavye': '⌨️', 'fare (pc)': '🖱️', 'kulaklık': '🎧', 'hoparlör': '🔊', 'mikrofon': '🎤',
    'kamera': '📷', 'fotoğraf': '📸', 'video': '📹', 'sinema': '🎬', 'film': '🎞️', 'projektör': '📽️',
    'ütü': '👔', 'çamaşır makinesi': '🧺', 'bulaşık makinesi': '🍽️', 'fırın': '🍳', 'ocak': '🍳', 'mikrodalga': '📻',
    'buzdolabı': '🧊', 'süpürge': '🧹', 'paspas': '🧹', 'kova': '🪣', 'leğen': '🪣', 'fırça': '🪥', 'tarak': '🪮',
    'makas': '✂️', 'iğne': '🪡', 'iplik': '🧵', 'düğme': '🔘', 'fermuar': '🤐', 'çivi': '🔩', 'vida': '🔩',
    'çekiç': '🔨', 'pense': '🔧', 'tornavida': '🪛', 'matkap': '🔩', 'testere': '🪚', 'kürek': '🪵', 'tırmık': '🪵',
    'balta': '🪓', 'bıçak': '🔪', 'çatal': '🍴', 'kaşık': '🥄', 'tabak': '🍽️', 'kase': '🥣', 'bardak': '🥛',
    'kupa': '☕', 'fincan': '☕', 'sürahi': '🫖', 'çaydanlık': '🫖', 'cezve': '☕', 'tencere': '🍲', 'tava': '🍳',
    'süzgeç': '🥣', 'rende': '🧀', 'açacak': '🍾', 'şişe': '🍾', 'kavanoz': '🫙', 'kutu': '📦', 'sepet': '🧺',
    'poşet': '🛍️', 'çanta': '🎒', 'bavul': '🧳', 'cüzdan': '👛', 'kumbara': '🪙', 'para': '💵', 'madeni para': '🪙',
    'kitap': '📚', 'defter': '📓', 'kalem': '✏️', 'boya': '🎨', 'silgi': '🧼', 'cetvel': '📏', 'pergel': '📐',
    'zarf': '✉️', 'mektup': '✉️', 'gazete': '📰', 'dergi': '📖', 'harita': '🗺️', 'küre': '🌐', 'bayrak': '🚩',
    'rozet': '🎖️', 'madalya': '🏅', 'kupa (ödül)': '🏆', 'hediye': '🎁', 'balon': '🎈', 'pasta': '🎂',

    # Giysiler & Aksesuarlar
    'gömlek': '👔', 'tişört': '👕', 'pantolon': '👖', 'şort': '🩳', 'etek': '👗', 'elbise': '👗', 'ceket': '🧥',
    'mont': '🧥', 'kaban': '🧥', 'palto': '🧥', 'hırka': '🧥', 'kazak': '🧶', 'yelek': '🦺', 'pijama': '🛌',
    'bornoz': '🥋', 'mayo': '🩱', 'şapka': '🧢', 'bere': '🧢', 'kasket': '🧢', 'eşarp': '🧣', 'atkı': '🧣',
    'eldiven': '🧤', 'çorap': '🧦', 'ayakkabı': '👞', 'bot': '🥾', 'çizme': '👢', 'terlik': '🩴', 'sandalet': '👡',
    'kemer': '🥋', 'kravat': '👔', 'papyon': '🎀', 'gözlük': '👓', 'güneş gözlüğü': '🕶️', 'yüzük': '💍',
    'küpe': '✨', 'kolye': '📿', 'bilezik': '🪙', 'toka': '🎀', 'şemsiye': '☂️',

    # Taşıtlar & Ulaşım
    'araba': '🚗', 'otomobil': '🚗', 'araç': '🚗', 'otobüs': '🚌', 'minibüs': '🚐', 'dolmuş': '🚐', 'kamyon': '🚛',
    'tır': '🚛', 'kamyonet': '🛻', 'traktör': '🚜', 'motosiklet': '🏍️', 'motor': '🏍️', 'bisiklet': '🚲',
    'scooter': '🛴', 'kaykay': '🛹', 'paten': '🛼', 'tren': '🚆', 'tramvay': '🚊', 'metro': '🚇', 'vapur': '⛴️',
    'gemi': '🚢', 'tekne': '⛵', 'yat': '🛥️', 'sandal': '🛶', 'bot (deniz)': '🚤', 'sal': '🪵', 'denizaltı': '🤿',
    'uçak': '✈️', 'helikopter': '🚁', 'roket': '🚀', 'zeplin': '🎈', 'balon (sıcak hava)': '🎈', 'paraşüt': '🪂',
    'ambulans': '🚑', 'itfaiye': '🚒', 'polis arabası': '🚓', 'taksi': '🚕', 'çekici': '🚜', 'vinç': '🏗️',
    'kepçe': '🚜', 'buldozer': '🚜', 'teleferik': '🚡',

    # Mekanlar & Binalar
    'ev': '🏠', 'apartman': '🏢', 'bina': '🏢', 'site': '🏘️', 'villa': '🏡', 'kulübe': '🛖', 'çadır': '⛺',
    'saray': '🏰', 'kale': '🏰', 'kule': '🗼', 'cami': '🕌', 'kilise': '⛪', 'okul': '🏫', 'hastane': '🏥',
    'eczane': '💊', 'postane': '🏣', 'banka': '🏦', 'otel': '🏨', 'restoran': '🍽️', 'lokanta': '🍽️', 'kafe': '☕',
    'pastane': '🧁', 'fırın': '🥖', 'market': '🛒', 'bakkal': '🏪', 'manav': '🥕', 'kasap': '🥩', 'pazar': '🧺',
    'avm': '🛍️', 'mağaza': '🛍️', 'dükkan': '🏪', 'sinema': '🎬', 'tiyatro': '🎭', 'müze': '🏛️', 'kütüphane': '📚',
    'stadyum': '🏟️', 'havuz': '🏊', 'park': '🌳', 'bahçe': '🌻', 'çiftlik': '🚜', 'ahır': '🐴', 'kümes': '🐔',
    'havaalanı': '🛫', 'liman': '⚓', 'istasyon': '🚉', 'gar': '🚉', 'durak': '🚏', 'otogar': '🚌', 'köprü': '🌉',
    'tünel': '🚇', 'sokak': '🛣️', 'cadde': '🛣️', 'meydan': '🏙️', 'yol': '🛣️', 'kavşak': '🚦',

    # Vücut & Sağlık
    'baş': '🗣️', 'kafa': '🗣️', 'saç': '💇', 'yüz': '🙂', 'göz': '👁️', 'kaş': '🤨', 'kirpik': '👁️', 'kulak': '👂',
    'burun': '👃', 'ağız': '👄', 'dudak': '👄', 'diş': '🦷', 'dil': '👅', 'çene': '🧔', 'boyun': '🧣', 'boğaz': '🧣',
    'omuz': '💪', 'kol': '💪', 'dirsek': '💪', 'el': '✋', 'bilek': '⌚', 'parmak': '☝️', 'tırnak': '💅',
    'avuç': '🤲', 'göğüs': '👕', 'karın': '🫄', 'göbek': '🫄', 'sırt': '🚶', 'bel': '🥋', 'bacak': '🦵', 'diz': '🦵',
    'ayak': '🦶', 'topuk': '👠', 'kalp': '❤️', 'akciğer': '🫁', 'beyin': '🧠', 'kemik': '🦴', 'kan': '🩸',
    'aşı': '💉', 'ilaç': '💊', 'hap': '💊', 'şurup': '🧪', 'merhem': '🧴', 'yara': '🩹', 'alçı': '🩹', 'sargı': '🩹',
    'bandaj': '🩹', 'termometre': '🌡️', 'stetoskop': '🩺', 'gözlük': '👓',

    # Spor, Oyun, Hobi, Müzik
    'top': '⚽', 'futbol': '⚽', 'basketbol': '🏀', 'basket': '🏀', 'voleybol': '🏐', 'tenis': '🎾', 'masa tenisi': '🏓',
    'pinpon': '🏓', 'badminton': '🏸', 'beyzbol': '⚾', 'ragbi': '🏈', 'bovling': '🎳', 'bilardo': '🎱', 'golf': '⛳',
    'yüzme': '🏊', 'koşu': '🏃', 'atletizm': '🏃', 'jimnastik': '🤸', 'güreş': '🤼', 'boks': '🥊', 'karate': '🥋',
    'okçuluk': '🏹', 'binicilik': '🏇', 'kayak': '⛷️', 'paten': '🛼', 'kızak': '🛷', 'balık tutma': '🎣',
    'kamp': '⛺', 'satranç': '♟️', 'dama': '⚪', 'tavla': '🎲', 'lego': '🧱', 'yapboz': '🧩', 'oyuncak': '🧸',
    'ayıcık': '🧸', 'bebek': '🪆', 'uçurtma': '🪁', 'ip atlama': '🪢', 'salıncak': '🛝', 'kaydırak': '🛝',
    'tahterevalli': '⚖️', 'kum havuzu': '🏖️', 'piyano': '🎹', 'gitar': '🎸', 'keman': '🎻', 'flüt': '🪈',
    'davul': '🥁', 'trampet': '🥁', 'zurna': '🪈', 'saz': '🪕', 'bağlama': '🪕', 'trompet': '🎺', 'borazan': '🎺',
    'klarnet': '🎷', 'zil': '🔔', 'tef': '🪘', 'not': '🎵', 'şarkı': '🎶',

    # Eylemler & Duygular
    'gül': '😊', 'gülümse': '🙂', 'kahkaha': '😄', 'ağla': '😢', 'üzgün': '🙁', 'mutlu': '😀', 'kızgın': '😠',
    'korku': '😨', 'şaşkın': '😲', 'uyku': '😴', 'uyu': '💤', 'uyan': '⏰', 'ye': '🍽️', 'iç': '🥤', 'koş': '🏃',
    'yürü': '🚶', 'zıpla': '🦘', 'atla': '🦘', 'otur': '🪑', 'kalk': '🧍', 'yat': '🛌', 'oku': '📖', 'yaz': '✍️',
    'çiz': '🎨', 'boya': '🖌️', 'dinle': '👂', 'bak': '👀', 'gör': '👁️', 'dokun': '🖐️', 'kokla': '👃', 'tat': '👅',
    'öp': '😘', 'sarıl': '🫂', 'alkış': '👏', 'tokalaş': '🤝', 'el salla': '👋', 'sev': '❤️', 'aşk': '💖',
    'hediye': '🎁', 'kutla': '🎉', 'parti': '🥳', 'bayram': '🎈', 'zafer': '✌️', 'başarı': '🌟', 'yıldız': '⭐',
}

# Add words from unmatched_words.txt with pattern matching
with open('unmatched_words.txt', 'r', encoding='utf-8') as f:
    unmatched = [line.strip() for line in f if line.strip()]

# Stem matching rules for Turkish
STEM_RULES = [
    # Animals & Insects
    (['arı', 'bal', 'petek'], '🐝'),
    (['kuş', 'ötü', 'kanat', 'yuva', 'gaga'], '🐦'),
    (['balık', 'yüzgeç', 'olta', 'ağ'], '🐟'),
    (['kedi', 'miyav', 'pati', 'tırmık'], '🐱'),
    (['köpek', 'hav', 'kuyruk', 'tasma'], '🐶'),
    (['at', 'tay', 'yele', 'nal', 'eyer'], '🐴'),
    (['kuzu', 'koyun', 'koç', 'yün'], '🐑'),
    (['keçi', 'oğlak', 'boynuz'], '🐐'),
    (['inek', 'öküz', 'dana', 'buzağı'], '🐮'),
    (['ördek', 'kaz', 'vak'], '🦆'),
    (['tavuk', 'horoz', 'civciv', 'yem'], '🐔'),
    (['tavşan', 'havuç'], '🐰'),
    (['fare', 'kemir'], '🐭'),
    (['ayı', 'in', 'pençe'], '🐻'),
    (['tilki', 'kurnaz'], '🦊'),
    (['kurt', 'ulu'], '🐺'),
    (['aslan', 'yele', 'kükre'], '🦁'),
    (['kaplan', 'çizgili'], '🐯'),
    (['fil', 'hortum', 'fildişi'], '🐘'),
    (['maymun', 'muz'], '🐵'),
    (['yılan', 'sürün', 'zehir'], '🐍'),
    (['kurbağa', 'vırak', 'göl'], '🐸'),
    (['kaplumbağa', 'kaba', 'kabuk'], '🐢'),
    (['kelebek', 'tırtıl', 'koza'], '🦋'),
    (['karınca', 'çalışkan'], '🐜'),
    (['örümcek', 'ağ'], '🕷️'),
    (['salyangoz', 'kabuk'], '🐌'),

    # Food & Kitchen
    (['ekmek', 'fırın', 'buğday', 'un', 'hamur', 'somun', 'bazlama', 'lavaş'], '🍞'),
    (['su', 'damla', 'çeşme', 'musluk', 'bardak', 'şişe', 'sürahi', 'kuyu', 'pınar'], '💧'),
    (['süt', 'yoğurt', 'ayran', 'kaymak', 'peynir', 'çökelek', 'kaşar'], '🥛'),
    (['çay', 'dem', 'demlik', 'çaydanlık', 'bardak', 'şeker'], '🍵'),
    (['kahve', 'fincan', 'cezve', 'telve'], '☕'),
    (['çorba', 'tencere', 'kepçe', 'kase', 'kaşık'], '🥣'),
    (['pilav', 'pirinç', 'tane'], '🍚'),
    (['makarna', 'erişte', 'şehriye'], '🍝'),
    (['börek', 'çörek', 'açma', 'katmer', 'gözleme'], '🥐'),
    (['pasta', 'kek', 'turta', 'tart', 'dilim', 'krema'], '🎂'),
    (['şeker', 'tatlı', 'lokum', 'akide', 'helva'], '🍬'),
    (['çikolata', 'kakao'], '🍫'),
    (['elma', 'armut', 'meyve', 'ağaç', 'dal'], '🍎'),
    (['limon', 'ekşi', 'narenciye'], '🍋'),
    (['portakal', 'mandalina'], '🍊'),
    (['üzüm', 'bağ', 'salkım'], '🍇'),
    (['çilek', 'kiraz', 'vişne'], '🍓'),
    (['karpuz', 'kavun', 'çekirdek'], '🍉'),
    (['domates', 'salça', 'sos'], '🍅'),
    (['patates', 'kızartma', 'püre'], '🥔'),
    (['soğan', 'sarımsak', 'cacık'], '🧅'),
    (['biber', 'acı', 'pul'], '🌶️'),
    (['patlıcan', 'musakka', 'karnıyarık'], '🍆'),
    (['kabak', 'dolma', 'balkabağı'], '🎃'),
    (['havuç', 'turp', 'kök'], '🥕'),
    (['fındık', 'fıstık', 'ceviz', 'badem', 'kestane', 'çerez'], '🌰'),
    (['tuz', 'baharat', 'nane', 'kekik', 'kimyon', 'karabiber', 'tarçın'], '🧂'),

    # Clothes
    (['gömlek', 'yaka', 'kol'], '👔'),
    (['pantolon', 'paça', 'kot'], '👖'),
    (['elbise', 'etek', 'fistan'], '👗'),
    (['ceket', 'mont', 'kaban', 'palto', 'hırka', 'yelek', 'kürk'], '🧥'),
    (['şapka', 'bere', 'kasket', 'fes', 'takke'], '🧢'),
    (['ayakkabı', 'bot', 'çizme', 'kundura', 'pabuç', 'çarık'], '👞'),
    (['terlik', 'sandalet', 'takunya'], '🩴'),
    (['çorap', 'patik'], '🧦'),
    (['eldiven', 'atkı', 'kaşkol', 'boyunluk'], '🧤'),
    (['kemer', 'toka', 'bağcık'], '🥋'),
    (['gözlük', 'çerçeve', 'cam'], '👓'),
    (['saat', 'kadran', 'yelkovan', 'akrep'], '⌚'),
    (['çanta', 'cüzdan', 'bavul', 'valiz', 'torba', 'kese'], '🎒'),

    # Home & Tools
    (['ev', 'oda', 'çatı', 'baca', 'duvar', 'bina', 'konut'], '🏠'),
    (['kapı', 'eşik', 'tokmak', 'kol', 'kilit', 'anahtar'], '🚪'),
    (['pencere', 'cam', 'perde', 'tül', 'panjur'], '🪟'),
    (['masa', 'sehpa', 'sıra', 'tezgah'], '🪵'),
    (['sandalye', 'koltuk', 'kanepe', 'tabure', 'minder'], '🪑'),
    (['yatak', 'yorgan', 'yastık', 'çarşaf', 'battaniye'], '🛏️'),
    (['lamba', 'ampul', 'ışık', 'avize', 'fener', 'mum'], '💡'),
    (['makas', 'kes', 'kırp'], '✂️'),
    (['iğne', 'iplik', 'dikiş', 'yama', 'nakış'], '🪡'),
    (['çekiç', 'çivi', 'nal', 'örs'], '🔨'),
    (['pense', 'anahtar', 'vida', 'tornavida'], '🔧'),
    (['bıçak', 'keskin', 'bile'], '🔪'),
    (['fırça', 'boya', 'tarak'], '🖌️'),
    (['süpürge', 'faraş', 'toz'], '🧹'),
    (['kova', 'leğen', 'tas', 'ibrik'], '🪣'),
    (['tarak', 'fırça', 'ayna'], '🪮'),
    (['sabun', 'köpük', 'şampuan', 'lif'], '🧼'),
    (['havlu', 'peçete', 'mendil', 'bez'], '🧻'),

    # Nature & Space
    (['güneş', 'sıcak', 'gün', 'ışık', 'ışın', 'parlak'], '☀️'),
    (['ay', 'gece', 'hilal', 'dolunay', 'mehtap'], '🌙'),
    (['yıldız', 'kuzey', 'parla', 'göktaşı'], '⭐'),
    (['bulut', 'duman', 'sis', 'pus'], '☁️'),
    (['yağmur', 'damla', 'sağanak', 'çise'], '🌧️'),
    (['kar', 'buz', 'kırağı', 'dolu', 'tipi'], '❄️'),
    (['rüzgar', 'yel', 'fırtına', 'kasırga', 'hortum', 'meltem'], '💨'),
    (['deniz', 'okyanus', 'dalga', 'kıyı', 'sahil', 'kumsal', 'ada'], '🌊'),
    (['nehir', 'ırmak', 'dere', 'çay', 'akarsu', 'şelale'], '🏞️'),
    (['dağ', 'zirve', 'doruk', 'tepe', 'kaya', 'uçurum'], '⛰️'),
    (['orman', 'ağaç', 'koru', 'çalılık', 'fidan'], '🌲'),
    (['çiçek', 'yaprak', 'dal', 'gonca', 'tohum', 'kök'], '🌸'),
    (['ateş', 'alev', 'köz', 'kıvılcım', 'kül', 'yangın'], '🔥'),
    (['toprak', 'çamur', 'balçık', 'kum', 'tarla', 'bağ', 'bahçe'], '🪴'),
    (['yol', 'patika', 'cadde', 'sokak', 'geçit', 'köprü'], '🛣️'),

    # Vehicles & Travel
    (['araba', 'oto', 'araç', 'teker', 'direksiyon', 'vites', 'fren', 'motor'], '🚗'),
    (['kamyon', 'tır', 'kamyonet', 'damper', 'yük'], '🚛'),
    (['otobüs', 'minibüs', 'dolmuş', 'servis'], '🚌'),
    (['tren', 'vagon', 'lokomotif', 'ray'], '🚆'),
    (['gemi', 'vapur', 'motor', 'tekne', 'sandal', 'kayık', 'feribot', 'yat', 'dümen', 'çapa'], '🚢'),
    (['uçak', 'kanat', 'pervane', 'hava', 'uçuş', 'meydan'], '✈️'),
    (['helikopter', 'pervane'], '🚁'),
    (['roket', 'füze', 'uzay'], '🚀'),
    (['bisiklet', 'pedal', 'zincir', 'gidon'], '🚲'),
    (['kaykay', 'paten', 'kızak'], '🛹'),

    # School, Art & Sports
    (['kitap', 'sayfa', 'cilt', 'okuma'], '📚'),
    (['defter', 'yaprak', 'not'], '📓'),
    (['kalem', 'uç', 'silgi', 'yazı', 'mürekkep'], '✏️'),
    (['resim', 'tablo', 'boya', 'fırça', 'palet', 'tuval'], '🎨'),
    (['müzik', 'şarkı', 'ezgi', 'melodi', 'ses', 'nota'], '🎵'),
    (['top', 'kale', 'pas', 'şut', 'gol', 'maç', 'oyun'], '⚽'),
    (['kupa', 'madalya', 'ödül', 'şampiyon', 'birinci'], '🏆'),
    (['bayrak', 'flama', 'sancak'], '🚩'),
    (['oyuncak', 'kukla', 'bebek', 'balon'], '🧸'),
]

new_dict_entries = {}
# Add all EMOJI_MAP directly
for k, v in EMOJI_MAP.items():
    new_dict_entries[k.lower()] = v

# Match unmatched words by STEM_RULES
for word in unmatched:
    if word in new_dict_entries:
        continue
    assigned = None
    for stems, emoji in STEM_RULES:
        for stem in stems:
            if stem in word or word.startswith(stem) or stem.startswith(word):
                assigned = emoji
                break
        if assigned:
            break
    if assigned:
        new_dict_entries[word] = assigned

print(f"Total new dict entries created: {len(new_dict_entries)}")

# Read existing word_pictogram_helper.dart
with open('mobile/lib/utils/word_pictogram_helper.dart', 'r', encoding='utf-8') as f:
    orig = f.read()

# Find the end of _dict before '};'
dict_end_pos = orig.find('  };\n\n  static String getPictogram')
if dict_end_pos == -1:
    dict_end_pos = orig.find('  };\r\n\r\n  static String getPictogram')
if dict_end_pos == -1:
    dict_end_pos = orig.find('  };\n')

if dict_end_pos == -1:
    print("Could not find dictionary closing in word_pictogram_helper.dart")
else:
    # Build additional entries
    existing_keys = set(re.findall(r"['\"]([\wığüşöçİĞÜŞÖÇ]+)['\"]\s*:\s*", orig))
    
    add_lines = ["\n    // ── GENİŞLETİLMİŞ GÖRSEL PİKTOGRAM LİSTESİ (20 SES / KLİNİK SÖZLÜK) ──"]
    added_count = 0
    for k, v in sorted(new_dict_entries.items()):
        if k not in existing_keys and len(k) > 1:
            add_lines.append(f"    '{k}': '{v}',")
            added_count += 1
            existing_keys.add(k)
    
    new_content = orig[:dict_end_pos] + "\n".join(add_lines) + "\n" + orig[dict_end_pos:]
    with open('mobile/lib/utils/word_pictogram_helper.dart', 'w', encoding='utf-8') as f:
        f.write(new_content)
    print(f"Injected {added_count} new pictogram definitions into word_pictogram_helper.dart!")
