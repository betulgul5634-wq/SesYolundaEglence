import json
import re

missing_data = json.load(open('missing_sounds.json', encoding='utf-8'))

# Read existing sound_groups_data.dart to extract the existing 8 stages
with open('mobile/lib/data/sound_groups_data.dart', encoding='utf-8') as f:
    existing_content = f.read()

VOWELS = set('aeıioöuüAEIİOÖUÜ')
def count_vowels(word):
    return sum(1 for c in word if c in VOWELS)

def generate_syllables(c):
    c_lower = c.lower()
    vowels = ['ı', 'i', 'a', 'e', 'o', 'ö', 'u', 'ü']
    ladder = []
    # CV
    for v in vowels: ladder.append(f"{c_lower}{v}")
    # VC
    for v in vowels: ladder.append(f"{v}{c_lower}")
    # VCV
    for v in vowels: ladder.append(f"{v}{c_lower}{v}")
    # CVC
    for v in vowels: ladder.append(f"{c_lower}{v}{c_lower}")
    return ladder

# Full order of 20 sounds matching Book's Table of Contents
BOOK_SOUNDS = [
    'p', 'b', 't', 'd', 'k', 'g',
    'f', 'v', 's', 'z', 'ş', 'j', 'h',
    'ç', 'c',
    'm', 'n',
    'l', 'r',
    'y'
]

SOUND_METADATA = {
    'p': {
        'id': 'sound_p', 'phoneme': '/p/', 'soundLetter': 'P',
        'categoryTitle': 'Çift Dudak Patlamalı - Durak Sesler',
        'mainCategory': 'Patlamalı - Durak Sesler', 'emoji': '👄', 'colorHex': '0xFFE53935',
        'articulationHint': 'Dudaklarını birbirine sıkıca bastır, havanın birikmesini sağla ve aniden "P" diyerek dudaklarını patlat!',
    },
    'b': {
        'id': 'sound_b', 'phoneme': '/b/', 'soundLetter': 'B',
        'categoryTitle': 'Çift Dudak Patlamalı - Durak Sesler',
        'mainCategory': 'Patlamalı - Durak Sesler', 'emoji': '🎈', 'colorHex': '0xFF1E88E5',
        'articulationHint': 'Dudaklarını kapat, ses tellerini titreterek boğazında vızıltıyı hisset ve "B" diyerek patlat!',
    },
    't': {
        'id': 'sound_t', 'phoneme': '/t/', 'soundLetter': 'T',
        'categoryTitle': 'Diş Yuvasıl Patlamalı - Durak Sesleri',
        'mainCategory': 'Patlamalı - Durak Sesler', 'emoji': '⏰', 'colorHex': '0xFFFB8C00',
        'articulationHint': 'Dilinin ucunu üst ön dişlerinin arkasındaki damağa sıkıca yapıştır, havayı biriktir ve saat gibi "Tık! T!" diyerek patlat!',
    },
    'd': {
        'id': 'sound_d', 'phoneme': '/d/', 'soundLetter': 'D',
        'categoryTitle': 'Diş Yuvasıl Patlamalı - Durak Sesleri',
        'mainCategory': 'Patlamalı - Durak Sesler', 'emoji': '🥁', 'colorHex': '0xFF43A047',
        'articulationHint': 'Dilinin ucunu üst ön dişlerinin arkasındaki damağa yapıştır, ses tellerini titreterek araba kornası ve davul gibi "Düt! Dan! D!" diyerek patlat!',
    },
    'k': {
        'id': 'sound_k', 'phoneme': '/k/', 'soundLetter': 'K',
        'categoryTitle': 'Yumuşak Damak Patlamalı - Durak Sesleri',
        'mainCategory': 'Patlamalı - Durak Sesler', 'emoji': '🦆', 'colorHex': '0xFF8E24AA',
        'articulationHint': 'Dilinin ucunu alt ön dişlerin arkasında tut, dilinin arkasını damağına yapıştır ve boğazından havayı "K! K!" diyerek patlat!',
    },
    'g': {
        'id': 'sound_g', 'phoneme': '/g/', 'soundLetter': 'G',
        'categoryTitle': 'Yumuşak Damak Patlamalı - Durak Sesleri',
        'mainCategory': 'Patlamalı - Durak Sesler', 'emoji': '🎸', 'colorHex': '0xFF00ACC1',
        'articulationHint': 'Dilinin ucunu alt dişlerin arkasında tut, dilinin arkasını damağına yapıştır, ses tellerini titreterek boğazından tok bir "G! G!" çıkar!',
    },
    'f': {
        'id': 'sound_f', 'phoneme': '/f/', 'soundLetter': 'F',
        'categoryTitle': 'Diş - Dudak Sürtünmeli Sesleri',
        'mainCategory': 'Sürtünmeli Sesler', 'emoji': '🌬️', 'colorHex': '0xFF3949AB',
        'articulationHint': 'Üst dişlerini alt dudağının üstüne hafifçe dokundur ve dişlerin arasından ince bir nefes üfle: Fff!',
        'storyTitle': 'Fotoğrafçı Fuat Floransa’da',
    },
    'v': {
        'id': 'sound_v', 'phoneme': '/v/', 'soundLetter': 'V',
        'categoryTitle': 'Diş - Dudak Sürtünmeli Sesleri',
        'mainCategory': 'Sürtünmeli Sesler', 'emoji': '🚗', 'colorHex': '0xFF00897B',
        'articulationHint': 'Üst ön dişlerini alt dudağına değdir, ses tellerini titreterek araba motoru gibi vızıldat: Vvv!',
        'storyTitle': 'Van Hayvanat Bahçesi',
    },
    's': {
        'id': 'sound_s', 'phoneme': '/s/', 'soundLetter': 'S',
        'categoryTitle': 'Diş Yuvasıl Sürtünmeli Sesler',
        'mainCategory': 'Sürtünmeli Sesler', 'emoji': '🐍', 'colorHex': '0xFF7CB342',
        'articulationHint': 'Dişlerini birbirine yaklaştır, dilini ortada tutarak ince ve serin bir rüzgar gibi üfle: Sss!',
    },
    'z': {
        'id': 'sound_z', 'phoneme': '/z/', 'soundLetter': 'Z',
        'categoryTitle': 'Diş Yuvasıl Sürtünmeli Sesler',
        'mainCategory': 'Sürtünmeli Sesler', 'emoji': '🐝', 'colorHex': '0xFFFBC02D',
        'articulationHint': 'Dişlerini birbirine yaklaştır, ses tellerini çalıştırarak bir arı gibi vızılda: Zzz!',
        'storyTitle': 'Zeynep Hanım’ın Portekiz Gezisi',
    },
    'ş': {
        'id': 'sound_ş', 'phoneme': '/ş/', 'soundLetter': 'Ş',
        'categoryTitle': 'Diş Yuvası Ardı Sürtünmeli Sesler',
        'mainCategory': 'Sürtünmeli Sesler', 'emoji': '🤫', 'colorHex': '0xFF5E35B1',
        'articulationHint': 'Dudaklarını öne doğru yuvarla, dilinin yanlarını kaldırıp "Şşş! Sessiz ol!" der gibi güçlü bir nefes çıkar!',
        'storyTitle': 'Şule’nin Şiir Yarışması',
    },
    'j': {
        'id': 'sound_j', 'phoneme': '/j/', 'soundLetter': 'J',
        'categoryTitle': 'Diş Yuvası Ardı Sürtünmeli Sesler',
        'mainCategory': 'Sürtünmeli Sesler', 'emoji': '💎', 'colorHex': '0xFFD81B60',
        'articulationHint': 'Dudaklarını öne doğru yuvarla, ses tellerini titreterek boğazından güçlü bir "Jjj!" sesi çıkar!',
        'storyTitle': 'Jale’nin Jakuzi Macerası',
    },
    'h': {
        'id': 'sound_h', 'phoneme': '/h/', 'soundLetter': 'H',
        'categoryTitle': 'Gırtlak Sürtünmeli Ses',
        'mainCategory': 'Sürtünmeli Sesler', 'emoji': '🧣', 'colorHex': '0xFFFFB300',
        'articulationHint': 'Ağzını rahatça aç, ellerini ısıtmak için sıcak bir nefes verir gibi boğazından üfle: Hhh!',
        'storyTitle': 'Hasibe Hala ve Havuç Bahçesi',
    },
    'ç': {
        'id': 'sound_ç', 'phoneme': '/ç/', 'soundLetter': 'Ç',
        'categoryTitle': 'Diş Yuvası Ardı Durak Sürtünmeli Sesler',
        'mainCategory': 'Durak Sürtünmeli Sesler', 'emoji': '☕', 'colorHex': '0xFF6D4C41',
        'articulationHint': 'Dilinin ön kısmını üst diş arkasına yapıştır, havayı biriktirip aniden sürtünmeli şekilde patlat: Çık! Ç!',
        'storyTitle': 'Çağan ve Çiğdem Hanım',
    },
    'c': {
        'id': 'sound_c', 'phoneme': '/c/', 'soundLetter': 'C',
        'categoryTitle': 'Diş Yuvası Ardı Durak Sürtünmeli Sesler',
        'mainCategory': 'Durak Sürtünmeli Sesler', 'emoji': '🐥', 'colorHex': '0xFF039BE5',
        'articulationHint': 'Dilinin ön kısmını damağa yapıştır, ses tellerini titreterek neşeyle patlat: Cik cik! C!',
        'storyTitle': 'Caner ile Cem',
    },
    'm': {
        'id': 'sound_m', 'phoneme': '/m/', 'soundLetter': 'M',
        'categoryTitle': 'Çift Dudak Genizsi Ses',
        'mainCategory': 'Genizsi Sesler', 'emoji': '🧁', 'colorHex': '0xFFE91E63',
        'articulationHint': 'Dudaklarını birbirine yapıştır ve açmadan, nefesi burnundan vererek lezzetli bir "Mmm!" sesi çıkar!',
        'storyTitle': 'Mira’nın Amerika Yolculuğu',
    },
    'n': {
        'id': 'sound_n', 'phoneme': '/n/', 'soundLetter': 'N',
        'categoryTitle': 'Diş Yuvasıl Genizsi Ses',
        'mainCategory': 'Genizsi Sesler', 'emoji': '🎵', 'colorHex': '0xFF00ACC1',
        'articulationHint': 'Dilinin ucunu üst diş yuvasına yapıştır, nefesi burnundan vererek tatlı bir melodi gibi "Nnn!" de!',
        'storyTitle': 'Nehir Kenarında Hafta Sonu',
    },
    'l': {
        'id': 'sound_l', 'phoneme': '/l/', 'soundLetter': 'L',
        'categoryTitle': 'Diş Yuvasıl Akıcı Sesler',
        'mainCategory': 'Akıcı Sesler', 'emoji': '🍋', 'colorHex': '0xFFF4511E',
        'articulationHint': 'Dilinin ucunu üst ön dişlerinin arkasındaki damağa dokundur, havanın dilinin iki yanından neşeyle akmasına izin ver: La la l!',
        'storyTitle': 'Lale’nin Lambası',
    },
    'r': {
        'id': 'sound_r', 'phoneme': '/r/', 'soundLetter': 'R',
        'categoryTitle': 'Diş Yuvasıl Akıcı Sesler',
        'mainCategory': 'Akıcı Sesler', 'emoji': '🏎️', 'colorHex': '0xFFC2185B',
        'articulationHint': 'Dilinin ucunu damağına yaklaştır, güçlü bir nefes gönder ve araba motoru gibi dil ucunu neşeyle titret: Rrr!',
    },
    'y': {
        'id': 'sound_y', 'phoneme': '/y/', 'soundLetter': 'Y',
        'categoryTitle': 'Sert Damak Daralmalı Ses',
        'mainCategory': 'Daralmalı Sesler', 'emoji': '⛵', 'colorHex': '0xFF26A69A',
        'articulationHint': 'Dilinin ortasını damağına doğru yükselt ve havayı yumuşacık bir kaydırak gibi kaydırarak akıt: Yyy!',
        'storyTitle': 'Yelda’nın Yeni Yıl Hediyesi',
    },
}

# Specific Turkish word repairs for OCR imperfections in /ş/ and /ç/
REPAIRS_S = {
    'sisman sef': 'Şişman şef', 'san sohret': 'Şan şöhret', 'sirin sapka': 'Şirin şapka',
    'Dis tas!': 'Diş taşı', 'Bes karis': 'Beş karış', 'Yavas tasit': 'Yavaş taşıt',
    "Sam sekeri sam'dadir.": "Şam şekeri Şam'dadır.",
    'sisko sempanze sirindi.': 'Şişko şempanze şirindi.',
    'sampiyon seniz simarikti.': 'Şampiyon Şeniz şımartıldı.',
}

REPAIRS_C = {
    'Curuk cilek': 'Çürük çilek', 'Cirkin corek': 'Çirkin çörek', 'Cukur canak': 'Çukur çanak',
    'Uc ucak': 'Üç uçak', 'Agacli bahce': 'Ağaçlı bahçe', 'inatci keci': 'İnatçı keçi',
    'Cocuk cani caldi.': 'Çocuk çanı çaldı.', 'Celik cicek cizdi.': 'Çelik çiçek çizdi.',
    'Cilekler curuk gikti.': 'Çilekler çürük çıktı.',
}

def clean_word(w, target_letter):
    w = w.strip()
    if target_letter == 'ş':
        # restore ş where obvious
        if w.startswith(('S', 's')) and w.lower() in ['sok', 'sal', 'som', 'sis', 'sen', 'su', 'sey']:
            w = 'Ş' + w[1:]
        if w.endswith(('S', 's')) and w.lower() in ['bas', 'les', 'bes', 'los', 'bos', 'tas', 'kus', 'dis', 'kis', 'yas', 'kras']:
            w = w[:-1] + 'ş'
    elif target_letter == 'ç':
        if w.startswith(('C', 'c')):
            w = 'Ç' + w[1:]
        if w.endswith(('C', 'c')):
            w = w[:-1] + 'ç'
    return w

def escape_dart_str(s):
    return s.replace('\\', '\\\\').replace("'", "\\'").replace('$', '\\$')

def to_dart_list(lst, indent=8):
    if not lst: return '[]'
    lines = []
    ind = ' ' * indent
    for item in lst:
        lines.append(f"{ind}'{escape_dart_str(item)}',")
    return "[\n" + "\n".join(lines) + f"\n{' ' * (indent - 2)}]"

print("Ready to construct 20 stages.")
