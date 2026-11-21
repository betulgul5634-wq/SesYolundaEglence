import json
import re
import sys
from fix_all_sounds_core import (
    clean_and_correct_word, correct_sentence, count_vowels
)

sys.stdout.reconfigure(encoding='utf-8')

# 1. Read pristine_kbookstages.txt
with open('pristine_kbookstages.txt', encoding='utf-8') as f:
    kbook_raw = f.read()

# 2. Read missing_sounds.json
missing_data = json.load(open('missing_sounds.json', encoding='utf-8'))

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

# Parse pristine stages from kbook_raw
def parse_pristine_list(block, field_name):
    m = re.search(rf'{field_name}:\s*\[(.*?)\](?=\s*,\s*\w+:|\s*\))', block, re.DOTALL)
    if not m: return []
    raw = m.group(1)
    items = []
    for match in re.finditer(r"'((?:[^'\\]|\\.)*)'", raw):
        s = match.group(1).replace(r"\'", "'").replace(r"\\", "\\").strip()
        if s and not s.endswith('\\') and s not in [',', '']:
            items.append(s)
    return items

def parse_pristine_str(block, field_name):
    m = re.search(rf"{field_name}:\s*'((?:[^'\\]|\\.)*)'", block, re.DOTALL)
    if m:
        return m.group(1).replace(r"\'", "'").replace(r"\\", "\\").strip()
    return ""

pristine_stages = {}
stage_regex = re.compile(r"SoundStage\(\s*id:\s*'sound_([a-zğüşöçı]+)'", re.DOTALL)
matches = list(stage_regex.finditer(kbook_raw))
for i, m in enumerate(matches):
    let = m.group(1)
    start_idx = m.start()
    end_idx = matches[i+1].start() if i + 1 < len(matches) else len(kbook_raw)
    blk = kbook_raw[start_idx:end_idx]
    
    pristine_stages[let] = {
        'syllables': parse_pristine_list(blk, 'syllables'),
        'wordsBeginning': parse_pristine_list(blk, 'wordsBeginning'),
        'wordsMiddle': parse_pristine_list(blk, 'wordsMiddle'),
        'wordsEnding': parse_pristine_list(blk, 'wordsEnding'),
        'phrases': parse_pristine_list(blk, 'phrases'),
        'sentences': parse_pristine_list(blk, 'sentences'),
        'storyTitle': parse_pristine_str(blk, 'storyTitle'),
        'storyContent': parse_pristine_str(blk, 'storyContent'),
    }

print("Pristine stages found:", list(pristine_stages.keys()))

def escape_for_dart(s):
    return s.replace('\\', '\\\\').replace("'", "\\'").replace('$', '\\$')

def render_dart_list(lst, indent_spaces=8):
    if not lst: return "const []"
    ind = " " * indent_spaces
    lines = [f"{ind}'{escape_for_dart(x)}'," for x in lst if x]
    return "[\n" + "\n".join(lines) + f"\n{' ' * (indent_spaces - 2)}]"

# Assemble output
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
    
    if sound_key in pristine_stages:
        pst = pristine_stages[sound_key]
        raw_words = list(dict.fromkeys(pst['wordsBeginning'] + pst['wordsMiddle'] + pst['wordsEnding']))
        syllables = pst['syllables']
        raw_phr_beg = pst['phrases'][:15]
        raw_phr_cont = pst['phrases'][15:]
        raw_snt_beg = pst['sentences'][:15]
        raw_snt_cont = pst['sentences'][15:]
        story_title = pst['storyTitle']
        story_content = pst['storyContent']
    else:
        raw_m = missing_data[sound_key]
        raw_words = list(dict.fromkeys(raw_m['words_1'] + raw_m['words_2'] + raw_m['words_3']))
        syllables = generate_syllables(sound_key)
        raw_phr_beg = raw_m['phrases_beg']
        raw_phr_cont = raw_m['phrases_cont']
        raw_snt_beg = raw_m['sentences_beg']
        raw_snt_cont = raw_m['sentences_cont']
        story_title = meta.get('storyTitle', f'{sound_letter} Sesi Hikayesi')
        story_content = raw_m['story']
        
    # Correct all words
    corrected_words = []
    for w in raw_words:
        cw = clean_and_correct_word(w, sound_key)
        if cw and len(cw) >= 2:
            corrected_words.append(cw)
    corrected_words = list(dict.fromkeys(corrected_words))
    
    # Syllable length sorting
    w1 = [w for w in corrected_words if count_vowels(w) == 1]
    w2 = [w for w in corrected_words if count_vowels(w) == 2]
    w3 = [w for w in corrected_words if count_vowels(w) >= 3]
    
    # Position sorting
    w_beg = []
    w_mid = []
    w_end = []
    t_char = sound_key.lower()
    for w in corrected_words:
        w_low = w.lower()
        if w_low.startswith(t_char):
            w_beg.append(w)
        elif w_low.endswith(t_char):
            w_end.append(w)
        elif t_char in w_low:
            w_mid.append(w)
        else:
            w_beg.append(w)
            
    if sound_key == 'b':
        w_end = []
        
    # Clean phrases
    def clean_phrases(plist):
        res = []
        for p in plist:
            clean_p = p.strip()
            if not clean_p or len(clean_p) < 3 or clean_p.endswith('\\'): continue
            cp = correct_sentence(clean_p, sound_key)
            if cp: res.append(cp)
        return list(dict.fromkeys(res))
        
    phr_beg = clean_phrases(raw_phr_beg)
    phr_cont = clean_phrases(raw_phr_cont)
    all_phr = phr_beg + phr_cont
    
    # Clean sentences
    def clean_sentences(slist):
        res = []
        for s in slist:
            clean_s = s.strip()
            if not clean_s or len(clean_s) < 5 or clean_s.endswith('\\') or clean_s.startswith(','): continue
            cs = correct_sentence(clean_s, sound_key)
            if cs:
                if not cs.endswith(('.', '!', '?')): cs += '.'
                res.append(cs)
        return list(dict.fromkeys(res))
        
    snt_beg = clean_sentences(raw_snt_beg)
    snt_cont = clean_sentences(raw_snt_cont)
    all_snt = snt_beg + snt_cont
    
    corr_story_title = correct_sentence(story_title, sound_key) if story_title else f'{sound_letter} Sesi Hikayesi'
    corr_story_content = correct_sentence(story_content, sound_key) if story_content else ""

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
    out.append(f"    articulationHint: '{escape_for_dart(art_hint)}',")
    out.append("    unlockedLevelIndex: 0,")
    out.append("    starsCollected: 0,")
    out.append("    content: SingleSoundLevel(")
    out.append(f"      syllables: {render_dart_list(syllables)},")
    out.append(f"      wordsBeginning: {render_dart_list(w_beg)},")
    out.append(f"      wordsMiddle: {render_dart_list(w_mid)},")
    out.append(f"      wordsEnding: {render_dart_list(w_end)},")
    out.append(f"      words1Syllable: {render_dart_list(w1)},")
    out.append(f"      words2Syllables: {render_dart_list(w2)},")
    out.append(f"      words3Syllables: {render_dart_list(w3)},")
    out.append(f"      phrasesBeginning: {render_dart_list(phr_beg)},")
    out.append(f"      phrasesContaining: {render_dart_list(phr_cont)},")
    out.append(f"      phrases: {render_dart_list(all_phr)},")
    out.append(f"      sentencesBeginning: {render_dart_list(snt_beg)},")
    out.append(f"      sentencesContaining: {render_dart_list(snt_cont)},")
    out.append(f"      sentences: {render_dart_list(all_snt)},")
    out.append(f"      storyTitle: '{escape_for_dart(corr_story_title)}',")
    out.append(f"      storyContent: '{escape_for_dart(corr_story_content)}',")
    out.append("    ),")
    out.append("  ),")

out.append("];")

final_code = "\n".join(out)
with open('mobile/lib/data/sound_groups_data.dart', 'w', encoding='utf-8') as f:
    f.write(final_code)

print("Generated clean and fully deasciified sound_groups_data.dart successfully!")
