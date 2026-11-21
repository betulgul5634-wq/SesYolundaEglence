import re
import sys

sys.stdout.reconfigure(encoding='utf-8')

def to_ascii_key(s):
    tr_map = str.maketrans("çğıöşüÇĞİÖŞÜI", "cgiosuCGIOSUi")
    return s.translate(tr_map).lower()

freq_map = {}
with open('tr_50k.txt', encoding='utf-8') as f:
    for line in f:
        p = line.strip().split()
        if len(p) == 2:
            freq_map[p[0].strip().lower()] = int(p[1])

dic_words = set()
with open('turkish_wordlist.txt', encoding='utf-8') as f:
    for line in f:
        w = line.strip().split('/')[0].strip()
        if w and w.isalpha():
            dic_words.add(w)

ascii_to_tr = {}
for w in dic_words:
    k = to_ascii_key(w)
    freq = freq_map.get(w.lower(), 1)
    if k not in ascii_to_tr:
        ascii_to_tr[k] = []
    ascii_to_tr[k].append((w, freq))

# Extra custom corrections for clinical speech pathology words
EXACT_CORRECTIONS = {
    'fistik': 'fıstık',
    'fisek': 'fişek',
    'fuze': 'füze',
    'tufek': 'tüfek',
    'findik': 'fındık',
    'afis': 'afiş',
    'seffaf': 'şeffaf',
    'tesaduf': 'tesadüf',
    'feslegen': 'fesleğen',
    'kadayif': 'kadayıf',
    'firildak': 'fırıldak',
    'kiyafet': 'kıyafet',
    'firtina': 'fırtına',
    'zurafa': 'zürafa',
    'cicek': 'çiçek',
    'cilek': 'çilek',
    'curuk': 'çürük',
    'bahce': 'bahçe',
    'tebesir': 'tebeşir',
    'sasi': 'şaşı',
    'cekilis': 'çekiliş',
    'cadi': 'cadı',
    'lule': 'lüle',
    'mutercim': 'mütercim',
    'juri': 'jüri',
    'icecek': 'içecek',
    'fincan': 'fincan',
    'firat': 'Fırat',
    'firin': 'fırın',
    'filiz': 'filiz',
    'kufe': 'küfe',
    'kuflu': 'küflü',
    'ofkeli': 'öfkeli',
    'carsaf': 'çarşaf',
    'kunefe': 'künefe',
    'ciftci': 'çiftçi',
    'sofor': 'şoför',
    'parfum': 'parfüm',
    'paifum': 'parfüm',
    'sinif': 'sınıf',
    'hosaf': 'hoşaf',
    'kilfi': 'kılıfı',
    'firfrl': 'fırfırlı',
    'tariferle': 'tariflerle',
    'zayifadi': 'zayıfladı',
    'firinci': 'fırıncı',
    'seftalili': 'şeftalili',
    'pufarini': 'puflarını',
    'frinladi': 'fırınladı',
    'faydalidir': 'faydalıdır',
    'fisildadi': 'fısıldadı',
    'fiyaskoydu': 'fiyaskoydu',
    'fazlaydi': 'fazlaydı',
    'fatsali': 'Fatsalı',
    'fanatikti': 'fanatikti',
    'fakirlik': 'fakirlik',
    'fransiz': 'Fransız',
    'faytoncu': 'faytoncu',
    'fotograf': 'fotoğraf',
    'fotografci': 'fotoğrafçı',
    'fotograf cl': 'fotoğrafçı',
    'filikasi': 'filikası',
    'fabrikasi': 'fabrikası',
    'fincani': 'fincanı',
    'futbolcu': 'futbolcu',
    'fiyati': 'fiyatı',
    'faresi': 'faresi',
    'kuflu': 'küflü',
    'carsafi': 'çarşafı',
    'nafalinledi': 'naftalinledi',
    'defoluymus': 'defoluymuş',
    'fisildamayiniz': 'fısıldamayınız',
    'sinifta': 'sınıfta',
    'kofteler': 'köfteler',
    'koftesi': 'köftesi',
    'sofradaydi': 'sofradaydı',
    'teneffuste': 'teneffüste',
    'siniftan': 'sınıftan',
    'firladi': 'fırladı',
    'kadifeydi': 'kadifeydi',
}

def correct_word(w, target_phoneme=None):
    if not w: return ""
    clean = re.sub(r'^[^\wçğıöşüÇĞİÖŞÜ]+|[^\wçğıöşüÇĞİÖŞÜ]+$', '', w)
    if not clean: return w
    
    low = clean.lower()
    
    # Check exact dictionary first
    if low in EXACT_CORRECTIONS:
        res = EXACT_CORRECTIONS[low]
    else:
        k = to_ascii_key(clean)
        candidates = ascii_to_tr.get(k, [])
        if candidates:
            def rank(c):
                cw, freq = c
                bonus = 0
                if target_phoneme and target_phoneme.lower() in cw.lower():
                    bonus += 500000
                return freq + bonus
            candidates.sort(key=rank, reverse=True)
            res = candidates[0][0]
        else:
            res = clean
            
    # Apply casing
    if clean[0].isupper():
        if res[0] == 'i': res = 'İ' + res[1:]
        elif res[0] == 'ı': res = 'I' + res[1:]
        else: res = res[0].upper() + res[1:]
    else:
        res = res.lower()
        
    return w.replace(clean, res)

# Test all words from sound_f 2-syllables:
f_w2 = ['Tufek', 'Fare', 'Hafif', 'Findik', 'Afis', 'Tuhaf', 'Fuar', 'Nefes', 'Sahaf', 'Fuze', 'Biftek', 'Esnaf', 'Fakir', 'Kafa', 'Seffaf', 'Fisek', 'Fistik']
print("Corrected F 2-syllables:")
print([correct_word(w, 'f') for w in f_w2])
