import re
import urllib.request
import urllib.parse
import json

with open("mobile/lib/data/sound_groups_data.dart", "r", encoding="utf-8") as f:
    text = f.read()

# Extract sound_p block
match = re.search(r"id:\s*['\"]sound_p['\"].*?storyTitle:", text, re.DOTALL)
if not match:
    print("ERROR: sound_p block not found!")
    exit(1)

block = match.group(0)

def extract_list(name, src):
    m = re.search(rf"{name}:\s*\[(.*?)\]", src, re.DOTALL)
    if not m: return []
    # match items inside single quotes
    return [x.strip() for x in re.findall(r"'([^']+)'", m.group(1))]

words_beg = extract_list("wordsBeginning", block)
words_mid = extract_list("wordsMiddle", block)
words_end = extract_list("wordsEnding", block)
words_1s = extract_list("words1Syllable", block)
words_2s = extract_list("words2Syllables", block)
words_3s = extract_list("words3Syllables", block)

print(f"P Words Count: Beginning={len(words_beg)}, Middle={len(words_mid)}, Ending={len(words_end)}")
print(f"P Syllable Groups: 1S={len(words_1s)}, 2S={len(words_2s)}, 3S={len(words_3s)}")

all_words = list(dict.fromkeys(words_beg + words_mid + words_end + words_1s + words_2s + words_3s))
print(f"Total Unique P Words: {len(all_words)}")

# 1. Check letter 'p' presence
missing_p = [w for w in all_words if 'p' not in w.lower()]
print(f"Words missing letter 'p': {missing_p}")

# 2. Check position
beg_errors = [w for w in words_beg if not w.lower().startswith('p')]
end_errors = [w for w in words_end if not w.lower().endswith('p')]
mid_errors = [w for w in words_mid if w.lower().startswith('p') or w.lower().endswith('p')]
print(f"Beginning errors: {beg_errors}")
print(f"Ending errors: {end_errors}")
print(f"Middle errors: {mid_errors}")

# 3. Syllable count verification in Turkish (vowels count)
VOWELS = set("aeıioöuüAEIİOÖUÜ")
def count_syl(w):
    return sum(1 for c in w if c in VOWELS)

syl1_errs = [w for w in words_1s if count_syl(w) != 1]
syl2_errs = [w for w in words_2s if count_syl(w) != 2]
syl3_errs = [w for w in words_3s if count_syl(w) != 3]
print(f"1-Syllable errors: {syl1_errs}")
print(f"2-Syllable errors: {syl2_errs}")
print(f"3-Syllable errors: {syl3_errs}")

# 4. Check pictograms
with open("mobile/lib/utils/word_pictogram_helper.dart", "r", encoding="utf-8") as f:
    pic_code = f.read()

missing_pics = []
for w in all_words:
    clean_w = w.lower()
    # check in dict
    if f"'{clean_w}':" not in pic_code.lower() and f'"{clean_w}":' not in pic_code.lower():
        missing_pics.append(w)
print(f"Missing pictograms ({len(missing_pics)}): {missing_pics}")

# 5. Check TTS endpoint for every word
tts_failures = []
print("Testing TTS endpoint for all words...")
for i, w in enumerate(all_words):
    encoded = urllib.parse.quote(w)
    url = f"http://127.0.0.1:8000/api/tts?text={encoded}&phoneme=p&mode=natural"
    try:
        req = urllib.request.urlopen(url, timeout=5)
        if req.status != 200:
            tts_failures.append((w, req.status))
    except Exception as e:
        tts_failures.append((w, str(e)))

print(f"TTS failures ({len(tts_failures)}): {tts_failures}")
