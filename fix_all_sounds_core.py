import re
import sys

sys.stdout.reconfigure(encoding='utf-8')

# Load dictionary & freq
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

# Exact fixes dictionary for clinical words
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
    'kadifeydi': 'kadifeydi', 'mangal': 'mangal', 'fincana': 'fincana', 'fincanda': 'fincanda',
    'filikada': 'filikada', 'filikayla': 'filikayla', 'fenerle': 'fenerle',
    # V words
    'vahsi': 'vahşi', 'valisi': 'valisi', 'visneli': 'vişneli', 'vefasiz': 'vefasız',
    'varlikli': 'varlıklı', 'vezneci': 'vezneci', 'vananin': 'vananın', 'vidasi': 'vidası',
    'vedasi': 'vedası', 'vagondaki': 'vagondaki', 'videosu': 'videosu', 'vosvosu': 'vosvosu',
    'vatandaslik': 'vatandaşlık', 'vazifesi': 'vazifesi', 'vejetaryen': 'vejetaryen', 'voleybolcu': 'voleybolcu',
    'civisi': 'çivisi', 'kuvvetli': 'kuvvetli', 'avcl': 'avcı', 'suveter': 'süveter',
    'tavuklu': 'tavuklu', 'sevimli': 'sevimli', 'tavsan': 'tavşan', 'guvercin': 'güvercin',
    'lacivert': 'lacivert', 'eldiven': 'eldiven', 'mucver': 'mücver', 'manavi': 'manavı',
    'vaktinde': 'vaktinde', 'vardi': 'vardı', 'vidaladi': 'vidaladı', 'bavul': 'bavul',
    'bavulu': 'bavulu', 'bavula': 'bavula', 'vagon': 'vagon', 'vali': 'vali', 'valiz': 'valiz',
    'vitamin': 'vitamin', 'veteriner': 'veteriner', 'vazo': 'vazo', 'vida': 'vida', 'vapur': 'vapur',
    # Ş words
    'sisman': 'şişman', 'sef': 'şef', 'san': 'şan', 'sohret': 'şöhret', 'sirin': 'şirin',
    'sapka': 'şapka', 'sekeri': 'şekeri', 'sam': 'Şam', 'sisko': 'şişko', 'sempanze': 'şempanze',
    'sirindi': 'şirindi', 'sampiyon': 'şampiyon', 'seniz': 'Şeniz', 'simarikti': 'şımarıktı',
    'dis': 'diş', 'tasi': 'taşı', 'karis': 'karış', 'yavas': 'yavaş', 'tasit': 'taşıt',
    'hvs': '', 'bas': 'baş', 'les': 'leş', 'bes': 'beş', 'sok': 'şok', 'los': 'loş',
    'bos': 'boş', 'tas': 'taş', 'kus': 'kuş', 'kis': 'kış', 'yas': 'yaş', 'sis': 'şiş',
    'sise': 'şişe', 'sen': 'şen', 'sehir': 'şehir', 'surup': 'şurup', 'kumas': 'kumaş',
    'ates': 'ateş', 'gunes': 'güneş', 'gure': 'güreş', 'gures': 'güreş', 'sarkici': 'şarkıcı',
    'sarki': 'şarkı', 'sarap': 'şarap', 'sarj': 'şarj', 'sans': 'şans', 'sey': 'şey',
    # Ç words
    'ac': 'aç', 'cay': 'çay', 'guc': 'güç', 'ic': 'iç', 'cam': 'çam', 'cik': 'çık',
    'sec': 'seç', 'can': 'çan', 'ciz': 'çiz', 'tac': 'taç', 'uc': 'üç', 'koc': 'koç',
    'mac': 'maç', 'sac': 'saç', 'goc': 'göç', 'harc': 'harç', 'borc': 'borç',
    'cani': 'çanı', 'caldi': 'çaldı', 'cizdi': 'çizdi', 'gikti': 'çıktı', 'cilekler': 'çilekler',
    'ucak': 'uçak', 'agacli': 'ağaçlı', 'inatci': 'inatçı', 'keci': 'keçi', 'canta': 'çanta',
    'cukur': 'çukur', 'cocuk': 'çocuk', 'cizme': 'çizme', 'corek': 'çörek', 'corba': 'çorba',
    'agac': 'ağaç', 'arac': 'araç', 'ilac': 'ilaç', 'fici': 'fıçı', 'paca': 'paça',
    # J words
    'joleli': 'jöleli', 'juri': 'jüri', 'japonlar': 'Japonlar', 'jubilesi': 'jübilesi',
    'jestti': 'jestti', 'jandarma': 'jandarma', 'jakuzi': 'jakuzi', 'jilet': 'jilet',
    'jeton': 'jeton', 'judo': 'judo', 'joker': 'joker', 'jole': 'jöle', 'bej': 'bej',
    'ruj': 'ruj', 'mesaj': 'mesaj', 'baraj': 'baraj', 'garaj': 'garaj', 'plaj': 'plaj',
    # H words
    'havuc': 'havuç', 'hizli': 'hızlı', 'hirsiz': 'hırsız', 'hirsizi': 'hırsızı',
    'hatirladi': 'hatırladı', 'hickirdi': 'hıçkırdı', 'halat': 'halat', 'hasir': 'hasır',
    'halka': 'halka', 'hamsi': 'hamsi', 'hasta': 'hasta', 'havlu': 'havlu', 'hazine': 'hazine',
    'heykel': 'heykel', 'hırka': 'hırka', 'horoz': 'horoz', 'huni': 'huni', 'timsah': 'timsah',
    'sabah': 'sabah', 'silah': 'silah', 'kuhte': 'külte', 'kulah': 'külah', 'tesbih': 'tespih',
    # C words
    'cuce': 'cüce', 'cadi': 'cadı', 'cilali': 'cilalı', 'cezve': 'cezve', 'civil': 'cıvıl',
    'civildi': 'cıvıldı', 'cemre': 'Cemre', 'cesurdur': 'cesurdur', 'ceviz': 'ceviz',
    'ceket': 'ceket', 'cennet': 'cennet', 'cephe': 'cephe', 'cetvel': 'cetvel', 'civciv': 'civciv',
    'ciger': 'ciğer', 'cumbur': 'cumbur', 'cumhuriyet': 'cumhuriyet', 'gece': 'gece',
    'baca': 'baca', 'amca': 'amca', 'koca': 'koca', 'sicak': 'sıcak', 'sucuk': 'sucuk',
    'bocek': 'böcek', 'karinca': 'karınca',
    # M words
    'mizikci': 'mızıkçı', 'mira': 'Mira', 'mutluydu': 'mutluydu', 'matrakti': 'matraktı',
    'maskesi': 'maskesi', 'makas': 'makas', 'masa': 'masa', 'maymun': 'maymun',
    'mandal': 'mandal', 'mantar': 'mantar', 'marul': 'marul', 'maydanoz': 'maydanoz',
    'merdiven': 'merdiven', 'meyve': 'meyve', 'midye': 'midye', 'minare': 'minare',
    'elma': 'elma', 'armut': 'armut', 'kalem': 'kalem', 'adam': 'adam', 'resim': 'resim',
    # N words
    'neseli': 'neşeli', 'nota': 'nota', 'nazli': 'Nazlı', 'nehir': 'Nehir', 'naneli': 'naneli',
    'nohut': 'nohut', 'nefisti': 'nefisti', 'narin': 'narin', 'nilufer': 'nilüfer', 'nehirdeydi': 'nehirdeydi',
    'nal': 'nal', 'nam': 'nam', 'nar': 'nar', 'naz': 'naz', 'nane': 'nane', 'namaz': 'namaz',
    'nalbant': 'nalbant', 'namlu': 'namlu', 'narenciye': 'narenciye', 'nazar': 'nazar',
    'anne': 'anne', 'bina': 'bina', 'dinozor': 'dinozor', 'fener': 'fener', 'gunes': 'güneş',
    # L words
    'laleli': 'Laleli', 'logo': 'logo', 'los': 'loş', 'lokanta': 'lokanta', 'lila': 'lila',
    'lamba': 'lamba', 'lekelendi': 'lekelendi', 'lutfu': 'Lütfü', 'lisesi': 'lisesi',
    'limon': 'limon', 'lale': 'lale', 'lahana': 'lahana', 'leylek': 'leylek', 'lokum': 'lokum',
    'balik': 'balık', 'kale': 'kale', 'elek': 'elek', 'kolye': 'kolye', 'bulut': 'bulut',
    'gul': 'gül', 'kol': 'kol', 'fil': 'fil', 'yol': 'yol', 'tel': 'tel', 'bel': 'bel',
    'luks': 'lüks',
    # Y words
    'yeni': 'yeni', 'yatak': 'yatak', 'yedi': 'yedi', 'yunus': 'yunus', 'yavuz': 'Yavuz',
    'yemek': 'yemek', 'yapti': 'yaptı', 'yigit': 'Yiğit', 'yegeni': 'yeğeni', 'yuzbasiydi': 'yüzbaşıydı',
    'yilan': 'yılan', 'yildiz': 'yıldız', 'yuzuk': 'yüzük', 'yaprak': 'yaprak', 'yastik': 'yastık',
    'boya': 'boya', 'koyun': 'koyun', 'maymun': 'maymun', 'zeytin': 'zeytin', 'ayna': 'ayna',
    'koy': 'köy', 'cay': 'çay', 'yay': 'yay', 'pay': 'pay', 'bay': 'bay', 'ay': 'ay',
    # Z words
    'zurna': 'zurna', 'zeki': 'Zeki', 'zafer': 'Zafer', 'zipzip': 'zıpzıp', 'zipladi': 'zıpladı',
    'zerrin': 'Zerrin', 'zarfi': 'zarfı', 'zamkladi': 'zamkladı', 'zebra': 'zebra',
    'zil': 'zil', 'zeytin': 'zeytin', 'zincir': 'zincir', 'zurafa': 'zürafa', 'zambak': 'zambak',
    'kazak': 'kazak', 'yuzuk': 'yüzük', 'teze': 'teze', 'duzluk': 'düzlük', 'yildiz': 'yıldız',
    'kiraz': 'kiraz', 'ceviz': 'ceviz', 'karpuz': 'karpuz', 'deniz': 'deniz', 'goz': 'göz',
    'hiz': 'hız', 'tuz': 'tuz', 'buz': 'buz', 'muz': 'muz', 'gaz': 'gaz', 'yuz': 'yüz',
}

VOWELS = set('aeıioöuüAEIİOÖUÜ')
def count_vowels(word):
    return sum(1 for c in word if c in VOWELS)

def clean_and_correct_word(w, target_phoneme=None):
    if not w: return ""
    clean = re.sub(r'^[^\wçğıöşüÇĞİÖŞÜ]+|[^\wçğıöşüÇĞİÖŞÜ]+$', '', w).strip()
    if not clean or len(clean) < 2 or clean.lower() in ['hvs', 'ns', 'soh']:
        return ""
        
    low = clean.lower()
    if low in KNOWN_FIXES:
        res = KNOWN_FIXES[low]
        if not res: return ""
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
            
    # Apply casing: First letter uppercase, rest lowercase (Turkish capitalization)
    res_clean = res.strip()
    if not res_clean: return ""
    if res_clean[0].lower() == 'i':
        return 'İ' + res_clean[1:].lower()
    elif res_clean[0].lower() == 'ı':
        return 'I' + res_clean[1:].lower()
    else:
        return res_clean[0].upper() + res_clean[1:].lower()

def correct_sentence(s, target_phoneme=None):
    # Fix broken OCR spaces like "F avori" -> "Favori", "F indik" -> "Fındık"
    s = re.sub(r'\b([A-Za-zÇĞİÖŞÜçğıöşü])\s+([a-zçğıöşü]{3,})\b', r'\1\2', s)
    tokens = re.split(r'(\s+|[^\wçğıöşüÇĞİÖŞÜ\']+|[\',])', s)
    out = []
    for tok in tokens:
        if tok and any(c.isalpha() for c in tok):
            low = tok.lower()
            if low in KNOWN_FIXES and KNOWN_FIXES[low]:
                cw = KNOWN_FIXES[low]
                if tok[0].isupper():
                    cw = 'İ' + cw[1:] if cw[0] == 'i' else ('I' + cw[1:] if cw[0] == 'ı' else cw[0].upper() + cw[1:])
                out.append(cw)
            else:
                k = to_ascii_key(tok)
                candidates = ascii_to_tr.get(k, [])
                if candidates:
                    cw = candidates[0][0]
                    if tok[0].isupper():
                        cw = 'İ' + cw[1:] if cw[0] == 'i' else ('I' + cw[1:] if cw[0] == 'ı' else cw[0].upper() + cw[1:])
                    out.append(cw)
                else:
                    out.append(tok)
        else:
            out.append(tok)
    res = "".join(out).strip()
    # Normalize punctuation spacing
    res = re.sub(r'\s+([,\.!\?])', r'\1', res)
    return res

print("Helpers ready.")
