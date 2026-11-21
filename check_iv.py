import re

with open('mobile/lib/data/sound_groups_data.dart', 'r', encoding='utf-8') as f:
    text = f.read()

m = re.search(r"phoneme:\s*'/v/'.*?syllables:\s*\[(.*?)\]", text, re.DOTALL)
if m:
    for item in m.group(1).split(','):
        if 'iv' in item.lower():
            print(repr(item.strip()))
