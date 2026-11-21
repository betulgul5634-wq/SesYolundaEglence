import re

with open('mobile/lib/data/sound_groups_data.dart', 'r', encoding='utf-8') as f:
    text = f.read()

m = re.search(r"SoundStage\(\s*id:\s*'sound_b'(.*?)\n  \),", text, re.DOTALL)
block = m.group(1)

def parse_list(name):
    match = re.search(name + r':\s*\[(.*?)\]', block, re.DOTALL)
    if not match: return []
    raw = match.group(1)
    items = re.findall(r"'((?:[^'\\]|\\.)*)'", raw)
    return [it.replace("\\'", "'") for it in items]

all_b_words = set(parse_list('wordsBeginning') + parse_list('wordsMiddle') + parse_list('wordsEnding') +
                  parse_list('words1Syllable') + parse_list('words2Syllables') + parse_list('words3Syllables'))

with open('mobile/lib/utils/word_pictogram_helper.dart', 'r', encoding='utf-8') as f:
    pic_code = f.read()

missing = []
for w in sorted(all_b_words):
    clean = w.lower().strip()
    if f"'{clean}':" not in pic_code:
        missing.append(w)

print(f"Total /b/ words: {len(all_b_words)}")
print(f"Directly missing from _dict: {len(missing)}")
for w in missing:
    print(f"'{w.lower()}': '',")
