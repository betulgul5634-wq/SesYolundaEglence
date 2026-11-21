import json
import re

missing_data = json.load(open('missing_sounds.json', encoding='utf-8'))

with open('mobile/lib/data/sound_groups_data.dart', encoding='utf-8') as f:
    orig_text = f.read()

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

def extract_list(block, field_name):
    m = re.search(rf'{field_name}:\s*\[(.*?)\]', block, re.DOTALL)
    if not m: return []
    raw = m.group(1)
    items = re.findall(r"'([^']*)'", raw)
    return items

def extract_str(block, field_name):
    m = re.search(rf"{field_name}:\s*'((?:[^'\\]|\\.)*)'", block, re.DOTALL)
    if m:
        return m.group(1).replace("\\'", "'")
    return ""

existing_stages = {}
stage_matches = list(re.finditer(r"SoundStage\(\s*id:\s*'sound_([a-zğüşöçı]+)'", orig_text))
for i, match in enumerate(stage_matches):
    letter = match.group(1)
    start_pos = match.start()
    end_pos = stage_matches[i+1].start() if i + 1 < len(stage_matches) else len(orig_text)
    block = orig_text[start_pos:end_pos]
    
    syllables = extract_list(block, 'syllables')
    words_beg = extract_list(block, 'wordsBeginning')
    words_mid = extract_list(block, 'wordsMiddle')
    words_end = extract_list(block, 'wordsEnding')
    phrases = extract_list(block, 'phrases')
    sentences = extract_list(block, 'sentences')
    story_title = extract_str(block, 'storyTitle')
    story_content = extract_str(block, 'storyContent')
    
    all_words = list(dict.fromkeys(words_beg + words_mid + words_end))
    w1 = [w for w in all_words if count_vowels(w) == 1]
    w2 = [w for w in all_words if count_vowels(w) == 2]
    w3 = [w for w in all_words if count_vowels(w) >= 3]
    
    existing_stages[letter] = {
        'syllables': syllables,
        'wordsBeginning': words_beg,
        'wordsMiddle': words_mid,
        'wordsEnding': words_end,
        'words1Syllable': w1,
        'words2Syllables': w2,
        'words3Syllables': w3,
        'phrasesBeginning': phrases[:15],
        'phrasesContaining': phrases[15:],
        'phrases': phrases,
        'sentencesBeginning': sentences[:15],
        'sentencesContaining': sentences[15:],
        'sentences': sentences,
        'storyTitle': story_title,
        'storyContent': story_content,
    }

def clean_word_item(w, letter):
    w = w.strip()
    # clean punctuation
    w = re.sub(r'^[^\w]+|[^\w]+$', '', w)
    if not w: return ""
    if letter == 'ş':
        # restore ş for turkish words
        if w.lower() in ['sok', 'sal', 'som', 'sis', 'sen', 'su', 'sey', 'sapka', 'seker', 'sise', 'sehir', 'sofor', 'surup', 'sampiyon']:
            w = 'Ş' + w[1:]
        elif w.lower() in ['bas', 'les', 'bes', 'los', 'bos', 'tas', 'kus', 'dis', 'kis', 'yas', 'kumas', 'ates']:
            w = w[:-1] + 'ş'
    elif letter == 'ç':
        if w.lower() in ['cam', 'cay', 'can', 'ciz', 'cop', 'cok', 'cilek', 'cicek', 'corek', 'corba', 'canta', 'cukur', 'cocuk', 'curuk', 'cizme']:
            w = 'Ç' + w[1:]
        elif w.lower() in ['ac', 'ic', 'uc', 'koc', 'mac', 'sac', 'tac', 'guc', 'sec', 'agac', 'arac', 'borc']:
            w = w[:-1] + 'ç'
    return w.capitalize()

def escape_dart_str(s):
    return s.replace('\\', '\\\\').replace("'", "\\'").replace('$', '\\$')

def to_dart_list(lst, indent=8):
    if not lst: return '[]'
    lines = []
    ind = ' ' * indent
    for item in lst:
        if item:
            lines.append(f"{ind}'{escape_dart_str(item)}',")
    return "[\n" + "\n".join(lines) + f"\n{' ' * (indent - 2)}]"

# Build all 20 stages
out = []
out.append("import '../models/sound_group.dart';")
out.append("")
out.append("/// \"Heceden Hikayeye Konuşma Sesi Bozuklukları Terapi Alıştırma Kitabı\"")
out.append("/// (Serkan Bengisu ve ark.)")
out.append("///")
out.append("/// Kitabın İçindekiler Bölümüne Göre Klinik 20 Ses:")
out.append("/// 1. Patlamalı - Durak Sesler: /p/, /b/, /t/, /d/, /k/, /g/")
out.append("/// 2. Sürtünmeli Sesler: /f/, /v/, /s/, /z/, /ş/, /j/, /h/")
out.append("/// 3. Durak Sürtünmeli Sesler: /ç/, /c/")
out.append("/// 4. Genizsi Sesler: /m/, /n/")
out.append("/// 5. Akıcı Sesler: /l/, /r/")
out.append("/// 6. Daralmalı Sesler: /y/")
out.append("final List<SoundStage> kBookStages = [")

for idx, sound_key in enumerate(BOOK_SOUNDS):
    meta = SOUND_METADATA[sound_key]
    stage_id = meta['id']
    phoneme = meta['phoneme']
    sound_letter = meta['soundLetter']
    cat_title = meta['categoryTitle']
    main_cat = meta['mainCategory']
    emoji = meta['emoji']
    color_hex = meta['colorHex']
    art_hint = meta['articulationHint']
    
    if sound_key in existing_stages:
        st_data = existing_stages[sound_key]
    else:
        raw_m = missing_data[sound_key]
        raw_w1 = [clean_word_item(w, sound_key) for w in raw_m['words_1'] if clean_word_item(w, sound_key)]
        raw_w2 = [clean_word_item(w, sound_key) for w in raw_m['words_2'] if clean_word_item(w, sound_key)]
        raw_w3 = [clean_word_item(w, sound_key) for w in raw_m['words_3'] if clean_word_item(w, sound_key)]
        
        all_w = list(dict.fromkeys(raw_w1 + raw_w2 + raw_w3))
        w_beg = []
        w_mid = []
        w_end = []
        target_char = sound_key.lower()
        for w in all_w:
            w_low = w.lower()
            if w_low.startswith(target_char):
                w_beg.append(w)
            elif w_low.endswith(target_char):
                w_end.append(w)
            elif target_char in w_low:
                w_mid.append(w)
            else:
                w_beg.append(w)
                
        phr_b = [p.strip() for p in raw_m['phrases_beg'] if p.strip()]
        phr_c = [p.strip() for p in raw_m['phrases_cont'] if p.strip()]
        snt_b = [s.strip() for s in raw_m['sentences_beg'] if s.strip()]
        snt_c = [s.strip() for s in raw_m['sentences_cont'] if s.strip()]
        
        st_data = {
            'syllables': generate_syllables(sound_key),
            'wordsBeginning': w_beg,
            'wordsMiddle': w_mid,
            'wordsEnding': w_end,
            'words1Syllable': raw_w1,
            'words2Syllables': raw_w2,
            'words3Syllables': raw_w3,
            'phrasesBeginning': phr_b,
            'phrasesContaining': phr_c,
            'phrases': phr_b + phr_c,
            'sentencesBeginning': snt_b,
            'sentencesContaining': snt_c,
            'sentences': snt_b + snt_c,
            'storyTitle': meta.get('storyTitle', f'{sound_letter} Sesi Hikayesi'),
            'storyContent': raw_m['story'].strip(),
        }

    out.append("  // " + "─" * 73)
    out.append(f"  // {idx + 1}. /{sound_key}/ SESİ ({main_cat})")
    out.append("  // " + "─" * 73)
    out.append("  SoundStage(")
    out.append(f"    id: '{stage_id}',")
    out.append(f"    phoneme: '{phoneme}',")
    out.append(f"    soundLetter: '{sound_letter}',")
    out.append(f"    categoryTitle: '{cat_title}',")
    out.append(f"    mainCategory: '{main_cat}',")
    out.append(f"    emoji: '{emoji}',")
    out.append(f"    colorHex: {color_hex},")
    out.append(f"    articulationHint: '{escape_dart_str(art_hint)}',")
    out.append(f"    unlockedLevelIndex: 0,")
    out.append(f"    starsCollected: 0,")
    out.append("    content: SingleSoundLevel(")
    out.append(f"      syllables: {to_dart_list(st_data['syllables'])},")
    out.append(f"      wordsBeginning: {to_dart_list(st_data['wordsBeginning'])},")
    out.append(f"      wordsMiddle: {to_dart_list(st_data['wordsMiddle'])},")
    out.append(f"      wordsEnding: {to_dart_list(st_data['wordsEnding'])},")
    out.append(f"      words1Syllable: {to_dart_list(st_data['words1Syllable'])},")
    out.append(f"      words2Syllables: {to_dart_list(st_data['words2Syllables'])},")
    out.append(f"      words3Syllables: {to_dart_list(st_data['words3Syllables'])},")
    out.append(f"      phrasesBeginning: {to_dart_list(st_data['phrasesBeginning'])},")
    out.append(f"      phrasesContaining: {to_dart_list(st_data['phrasesContaining'])},")
    out.append(f"      phrases: {to_dart_list(st_data['phrases'])},")
    out.append(f"      sentencesBeginning: {to_dart_list(st_data['sentencesBeginning'])},")
    out.append(f"      sentencesContaining: {to_dart_list(st_data['sentencesContaining'])},")
    out.append(f"      sentences: {to_dart_list(st_data['sentences'])},")
    out.append(f"      storyTitle: '{escape_dart_str(st_data['storyTitle'])}',")
    out.append(f"      storyContent: '{escape_dart_str(st_data['storyContent'])}',")
    out.append("    ),")
    out.append("  ),")

out.append("];")

final_dart_code = "\n".join(out)
with open('mobile/lib/data/sound_groups_data.dart', 'w', encoding='utf-8') as f:
    f.write(final_dart_code)

print("Generated mobile/lib/data/sound_groups_data.dart successfully with 20 sounds!")
