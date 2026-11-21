import sys
import re

sys.stdout.reconfigure(encoding='utf-8')

with open('mobile/lib/data/sound_groups_data.dart', 'r', encoding='utf-8') as f:
    text = f.read()

# Load dictionaries
valid_words = set()
with open('turkish_wordlist.txt', 'r', encoding='utf-8') as f:
    for line in f:
        w = line.strip().split('/')[0].strip().replace('I', 'ı').replace('İ', 'i').lower()
        if w: valid_words.add(w)

with open('tr_50k.txt', 'r', encoding='utf-8') as f:
    for line in f:
        p = line.strip().split()
        if p:
            w = p[0].strip().replace('I', 'ı').replace('İ', 'i').lower()
            if w: valid_words.add(w)

print(f'Dictionary size: {len(valid_words)}')

# Split stages
stage_blocks = re.findall(r'SoundStage\((.*?)\n  \),', text, re.DOTALL)
print(f'Total stages found: {len(stage_blocks)}')

def get_list(block, field):
    m = re.search(rf'{field}:\s*\[(.*?)\](?=\s*,\s*\w+:|\s*\))', block, re.DOTALL)
    if not m: return []
    items = re.findall(r"'((?:[^'\\]|\\.)*)'", m.group(1))
    return [i.replace(r"\'", "'").replace(r"\\", "\\").strip() for i in items]

def get_field(block, field):
    m = re.search(rf"{field}:\s*'((?:[^'\\]|\\.)*)'", block)
    return m.group(1) if m else ''

vowels = set('aeıioöuüAEIİOÖUÜ')

for b in stage_blocks:
    target = get_field(b, 'targetSound')
    name = get_field(b, 'name')
    print(f'\n=== STAGE /{target}/ ({name}) ===')
    for list_name in ['wordsBeginning', 'wordsMiddle', 'wordsEnding', 'words1Syllable', 'words2Syllables', 'words3Syllables']:
        words = get_list(b, list_name)
        bad = []
        for w in words:
            w_clean = w.lower().strip()
            # check dictionary
            if w_clean not in valid_words:
                bad.append(w)
        if bad:
            print(f'  {list_name} not in dictionary ({len(bad)}/{len(words)}): {bad}')
