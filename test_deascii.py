import re

def to_ascii_key(s):
    # Mapping turkish chars to ascii
    tr_map = str.maketrans("çğıöşüÇĞİÖŞÜI", "cgiosuCGIOSUi")
    return s.translate(tr_map).lower()

# Build frequency map
freq_map = {}
with open('tr_50k.txt', encoding='utf-8') as f:
    for line in f:
        parts = line.strip().split()
        if len(parts) == 2:
            word, count = parts[0].strip().lower(), int(parts[1])
            freq_map[word] = count

# Load Hunspell dictionary
dic_words = set()
with open('turkish_wordlist.txt', encoding='utf-8') as f:
    for line in f:
        w = line.strip().split('/')[0].strip()
        if w and w.isalpha():
            dic_words.add(w)

print(f"Total dictionary words: {len(dic_words)}")

# Build lookup: ascii_key -> list of (turkish_word, frequency)
ascii_to_tr = {}
for w in dic_words:
    k = to_ascii_key(w)
    freq = freq_map.get(w.lower(), 1)
    if k not in ascii_to_tr:
        ascii_to_tr[k] = []
    ascii_to_tr[k].append((w, freq))

# Test words mentioned by user
test_samples = [
    'fistik', 'fisek', 'fuze', 'cicek', 'cilek', 'curuk', 'bahce', 'tebesir',
    'sasi', 'cekilis', 'cadi', 'lule', 'mutercim', 'juri', 'icecek', 'mangal',
    'fincan', 'fare', 'fener', 'futbol', 'firat', 'firin', 'filiz'
]

for t in test_samples:
    candidates = ascii_to_tr.get(t.lower(), [])
    # sort by frequency
    candidates.sort(key=lambda x: x[1], reverse=True)
    best = candidates[0][0] if candidates else t
    print(f"'{t}' -> '{best}' (candidates: {[c[0] for c in candidates[:3]]})")
