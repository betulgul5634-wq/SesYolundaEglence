import re

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

def deasciify_word(word, target_phoneme=None):
    if not word: return ""
    clean_w = re.sub(r'^[^\wçğıöşüÇĞİÖŞÜ]+|[^\wçğıöşüÇĞİÖŞÜ]+$', '', word)
    if not clean_w: return word
    
    k = to_ascii_key(clean_w)
    candidates = ascii_to_tr.get(k, [])
    if not candidates:
        return word
        
    # Sort candidates
    def rank(c):
        cw, freq = c
        bonus = 0
        if target_phoneme:
            tp = target_phoneme.lower()
            if tp in cw.lower():
                bonus += 500000
        return freq + bonus
        
    candidates.sort(key=rank, reverse=True)
    best = candidates[0][0]
    
    # Preserve original case
    if clean_w[0].isupper():
        if best[0] == 'i': best = 'İ' + best[1:]
        elif best[0] == 'ı': best = 'I' + best[1:]
        else: best = best[0].upper() + best[1:]
    else:
        best = best.lower()
        
    return word.replace(clean_w, best)

def deasciify_sentence(text, target_phoneme=None):
    tokens = re.split(r'(\s+|[^\wçğıöşüÇĞİÖŞÜ]+)', text)
    result = []
    for tok in tokens:
        if tok and any(c.isalpha() for c in tok):
            result.append(deasciify_word(tok, target_phoneme))
        else:
            result.append(tok)
    return "".join(result)

test_sentences = [
    "Findik fistik faydalidir.",
    "Ferhat fikrayl fisildadi.",
    "Sevimli tavsan havuclari yedi.",
    "Tavadaki mucver nefisti.",
    "sisko sempanze sirindi.",
    "Celik cicek cizdi.",
    "Cilekler curuk gikti.",
    "Visneli vitamin",
    "Vefasiz Vildan",
    "F avori film",
    "Hizli hirsIZ",
]

for s in test_sentences:
    print(f"'{s}' -> '{deasciify_sentence(s)}'")
