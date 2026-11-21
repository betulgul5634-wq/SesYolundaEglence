import re
import urllib.request
import urllib.parse
import os

with open('mobile/lib/data/sound_groups_data.dart', 'r', encoding='utf-8') as f:
    text = f.read()

m = re.search(r"SoundStage\(\s*id:\s*'sound_b'(.*?)\n  \),", text, re.DOTALL)
if not m:
    print("ERROR: /b/ stage not found!")
    exit(1)

block = m.group(1)

def parse_dart_string_list(name):
    match = re.search(name + r':\s*\[(.*?)\]', block, re.DOTALL)
    if not match: return []
    raw = match.group(1)
    items = re.findall(r"'((?:[^'\\]|\\.)*)'", raw)
    return [it.replace("\\'", "'") for it in items]

def get_str(name):
    match = re.search(name + r":\s*'((?:[^'\\]|\\.)*)'", block)
    return match.group(1).replace("\\'", "'") if match else ''

phoneme = get_str('phoneme')
letter = get_str('soundLetter').lower()
hint = get_str('articulationHint')
story_title = get_str('storyTitle')
story_content = get_str('storyContent')

syllables = parse_dart_string_list('syllables')
beg = parse_dart_string_list('wordsBeginning')
mid = parse_dart_string_list('wordsMiddle')
end = parse_dart_string_list('wordsEnding')
s1 = parse_dart_string_list('words1Syllable')
s2 = parse_dart_string_list('words2Syllables')
s3 = parse_dart_string_list('words3Syllables')
phrases_beg = parse_dart_string_list('phrasesBeginning')
phrases_mid = parse_dart_string_list('phrasesContaining')
phrases = parse_dart_string_list('phrases')
sents_beg = parse_dart_string_list('sentencesBeginning')
sents_mid = parse_dart_string_list('sentencesContaining')
sents = parse_dart_string_list('sentences')

vowels = set('aeıioöuüAEIİOÖUÜ')
def count_syllables(w):
    return sum(1 for c in w if c in vowels)

print(f"=== /B/ SESİ DERİNLEMESİNE DENETİM RAPORU ===")
print(f"Phoneme: {phoneme}, Letter: {letter.upper()}")
print(f"Articulation Hint: {hint}")
print(f"Story: '{story_title}' (Uzunluk: {len(story_content)} karakter)")
print(f"Toplam Heceler: {len(syllables)}")
print(f"Kelimeler: Başta={len(beg)}, Ortada={len(mid)}, Sonda={len(end)}")
print(f"Heceli Kelimeler: 1H={len(s1)}, 2H={len(s2)}, 3H={len(s3)}")
print(f"Cümleler: Başta={len(sents_beg)}, Ortada={len(sents_mid)}, Toplam={len(sents)}")
print(f"İfadeler (Phrases): Başta={len(phrases_beg)}, Ortada={len(phrases_mid)}, Toplam={len(phrases)}")

errors = []

# 1. Heceler
for s in syllables:
    if 'b' not in s.lower():
        errors.append(f"Hece hatası: '{s}' içinde 'b' yok!")

# 2. Pozisyon Uygunluğu
for w in beg:
    if not w.lower().startswith('b'):
        errors.append(f"Başta pozisyon hatası: '{w}' 'b' ile başlamıyor!")
for w in end:
    if not w.lower().endswith('b'):
        errors.append(f"Sonda pozisyon hatası: '{w}' 'b' ile bitmiyor!")
for w in mid:
    inner = w.lower()[1:-1]
    if 'b' not in inner:
        errors.append(f"Ortada pozisyon hatası: '{w}' ortasında 'b' barındırmıyor!")

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

# 4. Hedef Harf 'b' barındırıyor mu?
all_b_words = set(beg + mid + end + s1 + s2 + s3)
for w in all_b_words:
    if 'b' not in w.lower():
        errors.append(f"Kelime hatası: '{w}' içinde hiç 'b' yok!")

# 5. Mükerrer Kontrolleri
for name, lst in [('beg', beg), ('mid', mid), ('end', end), 
                  ('s1', s1), ('s2', s2), ('s3', s3),
                  ('sents_beg', sents_beg), ('sents_mid', sents_mid),
                  ('phrases_beg', phrases_beg), ('phrases_mid', phrases_mid)]:
    seen = set()
    for item in lst:
        if item in seen:
            errors.append(f"Mükerrer ({name}): '{item}'")
        seen.add(item)

# 6. Cümleler 'b' barındırıyor mu?
for s in sents:
    if 'b' not in s.lower():
        errors.append(f"Cümlede 'b' yok: '{s}'")

# 7. Piktogram Eşleşmesi
with open('mobile/lib/utils/word_pictogram_helper.dart', 'r', encoding='utf-8') as f_pic:
    pic_code = f_pic.read()

missing_pics = []
for w in all_b_words:
    clean = w.lower().strip()
    if f"'{clean}':" not in pic_code:
        matched = False
        for m_root in re.findall(r"'([a-zçğıöşü]+)':", pic_code):
            if clean.startswith(m_root) and len(clean) <= len(m_root) + 4:
                matched = True
                break
        if not matched:
            missing_pics.append(w)

print(f"\nToplam benzersiz /b/ kelimesi: {len(all_b_words)}")
print(f"Piktogramsız /b/ kelimesi: {len(missing_pics)}")
if missing_pics:
    print(f"Piktogram eksik kelimeler ({len(missing_pics)} adet): {missing_pics[:20]}...")

print(f"Kelimelerdeki / Fonolojideki Hata Sayısı: {len(errors)}")
if errors:
    for e in errors:
        print("  -", e)

# 8. TTS ve Ses Dosyaları Kontrolü
for ep in ['/api/tts?text=baba&phoneme=b', '/api/tts?text=b&phoneme=b', '/api/tts?text=b_explain&phoneme=b']:
    try:
        r = urllib.request.urlopen('http://127.0.0.1:8000' + ep, timeout=5)
        data = r.read()
        print(f"TTS {ep} -> Status: {r.status}, Boyut: {len(data)} bytes")
    except Exception as ex:
        print(f"TTS {ep} -> Hata: {ex}")

# 9. Hikaye Cümleleri Kontrolü
paragraphs = [p.strip() for p in story_content.split('\n\n') if p.strip()]
story_sents = []
for p in paragraphs:
    for s in re.split(r'(?<=[.!?])\s+', p):
        if s.strip():
            story_sents.append(s.strip())
print(f"Hikaye Toplam Cümle: {len(story_sents)}")
