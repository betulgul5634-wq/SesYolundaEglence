import re

with open('mobile/lib/data/sound_groups_data.dart', 'r', encoding='utf-8') as f:
    text = f.read()

m = re.search(r"SoundStage\(\s*id:\s*'sound_p'(.*?)\n  \),", text, re.DOTALL)
block = m.group(1)

def parse_dart_string_list(name):
    match = re.search(name + r':\s*\[(.*?)\]', block, re.DOTALL)
    if not match: return []
    # Match strings inside list respecting \'
    raw = match.group(1)
    items = re.findall(r"'((?:[^'\\]|\\.)*)'", raw)
    return [it.replace("\\'", "'") for it in items]

syllables = parse_dart_string_list('syllables')
beg = parse_dart_string_list('wordsBeginning')
mid = parse_dart_string_list('wordsMiddle')
end = parse_dart_string_list('wordsEnding')
s1 = parse_dart_string_list('words1Syllable')
s2 = parse_dart_string_list('words2Syllables')
s3 = parse_dart_string_list('words3Syllables')
sents_beg = parse_dart_string_list('sentencesBeginning')
sents_mid = parse_dart_string_list('sentencesContaining')
sents = parse_dart_string_list('sentences')
phrases_beg = parse_dart_string_list('phrasesBeginning')
phrases_mid = parse_dart_string_list('phrasesContaining')
phrases = parse_dart_string_list('phrases')

vowels = set('aeıioöuüAEIİOÖUÜ')
def count_syllables(w):
    return sum(1 for c in w if c in vowels)

errors = []

# 1. Heceler
for s in syllables:
    if 'p' not in s.lower():
        errors.append(f"Hece hatası: '{s}'")

# 2. Pozisyon Uygunluğu
for w in beg:
    if not w.lower().startswith('p'):
        errors.append(f"Başta pozisyon hatası: '{w}'")
for w in end:
    if not w.lower().endswith('p'):
        errors.append(f"Sonda pozisyon hatası: '{w}'")
for w in mid:
    inner = w.lower()[1:-1]
    if 'p' not in inner:
        errors.append(f"Ortada pozisyon hatası: '{w}'")

# 3. Hece Sayısı
for w in s1:
    c = count_syllables(w)
    if c != 1: errors.append(f"1 Hece listesinde hata: '{w}' ({c} hece)")
for w in s2:
    c = count_syllables(w)
    if c != 2: errors.append(f"2 Hece listesinde hata: '{w}' ({c} hece)")
for w in s3:
    c = count_syllables(w)
    if c != 3: errors.append(f"3 Hece listesinde hata: '{w}' ({c} hece)")

# 4. Mükerrer Kontrolleri
for name, lst in [('beg', beg), ('mid', mid), ('end', end), 
                  ('s1', s1), ('s2', s2), ('s3', s3),
                  ('sents_beg', sents_beg), ('sents_mid', sents_mid),
                  ('phrases_beg', phrases_beg), ('phrases_mid', phrases_mid)]:
    seen = set()
    for item in lst:
        if item in seen:
            errors.append(f"Mükerrer ({name}): '{item}'")
        seen.add(item)

# 5. Cümleler 'p' barındırıyor mu?
for s in sents:
    if 'p' not in s.lower():
        errors.append(f"Cümlede 'p' yok: '{s}'")

# 6. Piktogram Eşleşmesi
with open('mobile/lib/utils/word_pictogram_helper.dart', 'r', encoding='utf-8') as f_pic:
    pic_code = f_pic.read()

all_p_words = set(beg + mid + end + s1 + s2 + s3)
missing_pics = []
for w in all_p_words:
    clean = w.lower().strip()
    if f"'{clean}':" not in pic_code:
        # Check root
        matched = False
        for m_root in re.findall(r"'([a-zçğıöşü]+)':", pic_code):
            if clean.startswith(m_root) and len(clean) <= len(m_root) + 4:
                matched = True
                break
        if not matched:
            missing_pics.append(w)

print(f"Toplam benzersiz /p/ kelimesi: {len(all_p_words)}")
print(f"Piktogramsız /p/ kelimesi: {len(missing_pics)}")
print(f"Toplam Hata Sayısı: {len(errors)}")
if errors:
    for e in errors:
        print("  -", e)
else:
    print("SONUÇ: /p/ sesinde SIFIR HATA! %100 KUSURSUZ!")
