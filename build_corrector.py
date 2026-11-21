import re
import sys

sys.stdout.reconfigure(encoding='utf-8')

# 1. Build deasciifier maps
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

# Common speech therapy book corrections
KNOWN_FIXES = {
    'fistik': 'fıstık', 'fisek': 'fişek', 'fuze': 'füze', 'tufek': 'tüfek', 'findik': 'fındık',
    'afis': 'afiş', 'seffaf': 'şeffaf', 'tesaduf': 'tesadüf', 'feslegen': 'fesleğen',
    'kadayif': 'kadayıf', 'firildak': 'fırıldak', 'kiyafet': 'kıyafet', 'firtina': 'fırtına',
    'zurafa': 'zürafa', 'cicek': 'çiçek', 'cilek': 'çilek', 'curuk': 'çürük', 'bahce': 'bahçe',
    'tebesir': 'tebeşir', 'sasi': 'şaşı', 'cekilis': 'çekiliş', 'cadi': 'cadı', 'lule': 'lüle',
    'mutercim': 'mütercim', 'juri': 'jüri', 'icecek': 'içecek', 'fincan': 'fincan', 'firat': 'Fırat',
    'firin': 'fırın', 'filiz': 'filiz', 'kufe': 'küfe', 'kuflu': 'küflü', 'ofkeli': 'öfkeli',
    'carsaf': 'çarşaf', 'kunefe': 'künefe', 'ciftci': 'çiftçi', 'sofor': 'şoför', 'parfum': 'parfüm',
    'paifum': 'parfüm', 'sinif': 'sınıf', 'hosaf': 'hoşaf', 'kilfi': 'kılıfı', 'firfrl': 'fırfırlı',
    'tariferle': 'tariflerle', 'zayifadi': 'zayıfladı', 'firinci': 'fırıncı', 'seftalili': 'şeftalili',
    'pufarini': 'puflarını', 'frinladi': 'fırınladı', 'faydalidir': 'faydalıdır', 'fisildadi': 'fısıldadı',
    'fiyaskoydu': 'fiyaskoydu', 'fazlaydi': 'fazlaydı', 'fatsali': 'Fatsalı', 'fanatikti': 'fanatikti',
    'fakirlik': 'fakirlik', 'fransiz': 'Fransız', 'faytoncu': 'faytoncu', 'fotograf': 'fotoğraf',
    'fotografci': 'fotoğrafçı', 'fotograf cl': 'fotoğrafçı', 'filikasi': 'filikası', 'fabrikasi': 'fabrikası',
    'fincani': 'fincanı', 'futbolcu': 'futbolcu', 'fiyati': 'fiyatı', 'faresi': 'faresi',
    'carsafi': 'çarşafı', 'nafalinledi': 'naftalinledi', 'defoluymus': 'defoluymuş',
    'fisildamayiniz': 'fısıldamayınız', 'sinifta': 'sınıfta', 'kofteler': 'köfteler', 'koftesi': 'köftesi',
    'sofradaydi': 'sofradaydı', 'teneffuste': 'teneffüste', 'siniftan': 'sınıftan', 'firladi': 'fırladı',
    'kadifeydi': 'kadifeydi', 'mangal': 'mangal',
    # V words
    'vahsi': 'vahşi', 'valisi': 'valisi', 'visneli': 'vişneli', 'vefasiz': 'vefasız',
    'varlikli': 'varlıklı', 'vezneci': 'vezneci', 'vananin': 'vananın', 'vidasi': 'vidası',
    'vedasi': 'vedası', 'vagondaki': 'vagondaki', 'videosu': 'videosu', 'vosvosu': 'vosvosu',
    'vatandaslik': 'vatandaşlık', 'vazifesi': 'vazifesi', 'vejetaryen': 'vejetaryen', 'voleybolcu': 'voleybolcu',
    'civisi': 'çivisi', 'kuvvetli': 'kuvvetli', 'avcl': 'avcı', 'suveter': 'süveter',
    'tavuklu': 'tavuklu', 'sevimli': 'sevimli', 'tavsan': 'tavşan', 'guvercin': 'güvercin',
    'lacivert': 'lacivert', 'eldiven': 'eldiven', 'mucver': 'mücver', 'manavi': 'manavı',
    'vaktinde': 'vaktinde', 'vardi': 'vardı', 'vidaladi': 'vidaladı',
    # Ş words
    'sisman': 'şişman', 'sef': 'şef', 'san': 'şan', 'sohret': 'şöhret', 'sirin': 'şirin',
    'sapka': 'şapka', 'sekeri': 'şekeri', 'sam': 'Şam', 'sisko': 'şişko', 'sempanze': 'şempanze',
    'sirindi': 'şirindi', 'sampiyon': 'şampiyon', 'seniz': 'Şeniz', 'simarikti': 'şımarıktı',
    'dis': 'diş', 'tasi': 'taşı', 'karis': 'karış', 'yavas': 'yavaş', 'tasit': 'taşıt',
    'hvs': '', 'bas': 'baş', 'les': 'leş', 'bes': 'beş', 'sok': 'şok', 'los': 'loş',
    'bos': 'boş', 'tas': 'taş', 'kus': 'kuş', 'kis': 'kış', 'yas': 'yaş',
    # Ç words
    'ac': 'aç', 'cay': 'çay', 'guc': 'güç', 'ic': 'iç', 'cam': 'çam', 'cik': 'çık',
    'sec': 'seç', 'can': 'çan', 'ciz': 'çiz', 'tac': 'taç', 'uc': 'üç', 'koc': 'koç',
    'mac': 'maç', 'sac': 'saç', 'goc': 'göç', 'harc': 'harç', 'borc': 'borç',
    'cani': 'çanı', 'caldi': 'çaldı', 'cizdi': 'çizdi', 'gikti': 'çıktı', 'cilekler': 'çilekler',
    'ucak': 'uçak', 'agacli': 'ağaçlı', 'inatci': 'inatçı', 'keci': 'keçi',
    # J words
    'joleli': 'jöleli', 'juri': 'jüri', 'japonlar': 'Japonlar', 'jubilesi': 'jübilesi',
    'jestti': 'jestti', 'jandarma': 'jandarma', 'jakuzi': 'jakuzi',
    # H words
    'havuc': 'havuç', 'hizli': 'hızlı', 'hirsiz': 'hırsız', 'hirsizi': 'hırsızı',
    'hatirladi': 'hatırladı', 'hickirdi': 'hıçkırdı',
    # C words
    'cuce': 'cüce', 'cadi': 'cadı', 'cilali': 'cilalı', 'cezve': 'cezve', 'civil': 'cıvıl',
    'civildi': 'cıvıldı', 'cemre': 'Cemre', 'cesurdur': 'cesurdur',
    # M words
    'mizikci': 'mızıkçı', 'mira': 'Mira', 'mutluydu': 'mutluydu', 'matrakti': 'matraktı',
    'maskesi': 'maskesi',
    # N words
    'neseli': 'neşeli', 'nota': 'nota', 'nazli': 'Nazlı', 'nehir': 'Nehir', 'naneli': 'naneli',
    'nohut': 'nohut', 'nefisti': 'nefisti', 'narin': 'narin', 'nilufer': 'nilüfer', 'nehirdeydi': 'nehirdeydi',
    # L words
    'laleli': 'Laleli', 'logo': 'logo', 'los': 'loş', 'lokanta': 'lokanta', 'lila': 'lila',
    'lamba': 'lamba', 'lekelendi': 'lekelendi', 'lutfu': 'Lütfü', 'lisesi': 'lisesi',
    # Y words
    'yeni': 'yeni', 'yatak': 'yatak', 'yedi': 'yedi', 'yunus': 'yunus', 'yavuz': 'Yavuz',
    'yemek': 'yemek', 'yapti': 'yaptı', 'yigit': 'Yiğit', 'yegeni': 'yeğeni', 'yuzbasiydi': 'yüzbaşıydı',
    # Z words
    'zurna': 'zurna', 'zeki': 'Zeki', 'zafer': 'Zafer', 'zipzip': 'zıpzıp', 'zipladi': 'zıpladı',
    'zerrin': 'Zerrin', 'zarfi': 'zarfı', 'zamkladi': 'zamkladı',
}

def correct_turkish_word(w, target_phoneme=None):
    if not w: return ""
    clean = re.sub(r'^[^\wçğıöşüÇĞİÖŞÜ]+|[^\wçğıöşüÇĞİÖŞÜ]+$', '', w)
    if not clean: return w
    
    low = clean.lower()
    
    # 1. Exact fix
    if low in KNOWN_FIXES:
        res = KNOWN_FIXES[low]
        if not res: return ""
    # 2. Dictionary lookup
    else:
        k = to_ascii_key(clean)
        candidates = ascii_to_tr.get(k, [])
        if candidates:
            def rank(c):
                cw, freq = c
                bonus = 0
                if target_phoneme:
                    tp = target_phoneme.lower()
                    if tp in cw.lower():
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

print("Corrector engine ready.")
