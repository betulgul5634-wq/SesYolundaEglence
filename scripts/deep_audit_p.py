import re
import urllib.request
import urllib.parse
import json

with open('mobile/lib/data/sound_groups_data.dart', 'r', encoding='utf-8') as f:
    text = f.read()

m = re.search(r"SoundStage\(\s*id:\s*'sound_p'(.*?)\n  \),", text, re.DOTALL)
if not m:
    print("ERROR: /p/ stage not found!")
    exit(1)

block = m.group(1)

def get_list(name):
    match = re.search(name + r':\s*\[(.*?)\]', block, re.DOTALL)
    if not match: return []
    return re.findall(r"'([^']+)'", match.group(1))

def get_str(name):
    match = re.search(name + r":\s*'([^']*)'", block)
    return match.group(1) if match else ''

phoneme = get_str('phoneme')
letter = get_str('soundLetter').lower()
hint = get_str('articulationHint')
story_title = get_str('storyTitle')
story_content = get_str('storyContent')

syllables = get_list('syllables')
beg = get_list('wordsBeginning')
mid = get_list('wordsMiddle')
end = get_list('wordsEnding')
s1 = get_list('words1Syllable')
s2 = get_list('words2Syllables')
s3 = get_list('words3Syllables')
phrases_beg = get_list('phrasesBeginning')
phrases_mid = get_list('phrasesContaining')
phrases = get_list('phrases')
sents_beg = get_list('sentencesBeginning')
sents_mid = get_list('sentencesContaining')
sents = get_list('sentences')

vowels = set('aeıioöuüAEIİOÖUÜ')
def count_syllables(w):
    return sum(1 for c in w if c in vowels)

print(f"=== /P/ SESİ DERİNLEMESİNE DENETİM RAPORU ===")
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
    if 'p' not in s.lower():
        errors.append(f"Hece hatası: '{s}' içinde 'p' yok!")

# 2. Pozisyon Uygunluğu
for w in beg:
    if not w.lower().startswith('p'):
        errors.append(f"Başta pozisyon hatası: '{w}' 'p' ile başlamıyor!")
for w in end:
    if not w.lower().endswith('p'):
        errors.append(f"Sonda pozisyon hatası: '{w}' 'p' ile bitmiyor!")
for w in mid:
    inner = w.lower()[1:-1]
    if 'p' not in inner:
        errors.append(f"Ortada pozisyon hatası: '{w}' ortasında 'p' barındırmıyor!")

# 3. Hece Sayısı Doğruluğu
for w in s1:
    c = count_syllables(w)
    if c != 1: errors.append(f"1 Hece listesinde hata: '{w}' {c} heceli!")
for w in s2:
    c = count_syllables(w)
    if c != 2: errors.append(f"2 Hece listesinde hata: '{w}' {c} heceli!")
for w in s3:
    c = count_syllables(w)
    if c != 3: errors.append(f"3 Hece listesinde hata: '{w}' {c} heceli!")

# 4. Mükerrer Kontrolü (Duplicates)
for name, lst in [('wordsBeginning', beg), ('wordsMiddle', mid), ('wordsEnding', end), 
                  ('words1Syllable', s1), ('words2Syllables', s2), ('words3Syllables', s3),
                  ('sentencesBeginning', sents_beg), ('sentencesContaining', sents_mid),
                  ('phrasesBeginning', phrases_beg), ('phrasesContaining', phrases_mid)]:
    seen = set()
    for item in lst:
        if item in seen:
            errors.append(f"Mükerrer ({name}): '{item}'")
        seen.add(item)

# 5. Cümleler 'p' içeriyor mu?
for s in sents:
    if 'p' not in s.lower():
        errors.append(f"Cümle hatası: '{s}' içinde hiç 'p' yok!")

# 6. Piktogram Eşleşmesi Kontrolü
with open('mobile/lib/utils/word_pictogram_helper.dart', 'r', encoding='utf-8') as f_pic:
    pic_code = f_pic.read()

# Check all unique words in /p/
all_p_words = set(beg + mid + end + s1 + s2 + s3)
missing_pictograms = []
for w in all_p_words:
    clean = w.lower().strip()
    if f"'{clean}':" not in pic_code:
        # Check root match
        matched = False
        for m_root in re.findall(r"'([a-zçğıöşü]+)':", pic_code):
            if clean.startswith(m_root) and len(clean) <= len(m_root) + 4:
                matched = True
                break
        if not matched:
            missing_pictograms.append(w)

print(f"\nToplam benzersiz /p/ kelimesi: {len(all_p_words)}")
print(f"Piktogramı eksik kalan kelime sayısı: {len(missing_pictograms)}")
if missing_pictograms:
    print(f"Eksik kalanlar: {missing_pictograms}")

# 7. Ses Sunucusu (TTS) Testi
try:
    url = "http://127.0.0.1:8000/api/tts?text=" + urllib.parse.quote("pasta") + "&phoneme=p"
    req = urllib.request.urlopen(url, timeout=3)
    content_type = req.headers.get('Content-Type')
    length = len(req.read())
    print(f"\nTTS /api/tts Endpoint Testi: HTTP {req.status}, Content-Type: {content_type}, Boyut: {length} bytes -> BAŞARILI")
except Exception as e:
    errors.append(f"TTS endpoint hatası: {e}")

# 8. İzole P ve Anatomi Açıklama Ses Dosyaları
for audio_path in ["backend/static/audio/p.wav", "backend/static/audio/p_explain.wav"]:
    import os
    if os.path.exists(audio_path):
        size = os.path.getsize(audio_path)
        print(f"Ses Dosyası '{audio_path}': MEVCUT ({size} bytes)")
    else:
        errors.append(f"Ses dosyası eksik: {audio_path}")

print(f"\n=== DENETİM SONUCU ===")
if not errors and not missing_pictograms:
    print("KUSURSUZ! /p/ sesinde SIFIR HATA, SIFIR EKSİK!")
else:
    print(f"Toplam Hata Sayısı: {len(errors)}")
    for err in errors:
        print(" - " + err)
