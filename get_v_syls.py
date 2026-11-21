import re

with open('mobile/lib/data/sound_groups_data.dart', 'r', encoding='utf-8') as f:
    text = f.read()

m = re.search(r"phoneme:\s*'/v/'.*?syllables:\s*\[(.*?)\]", text, re.DOTALL)
if m:
    syls = [s.strip(" '\r\n") for s in m.group(1).split(',') if s.strip(" '\r\n")]
    print('V syllables:', syls)
