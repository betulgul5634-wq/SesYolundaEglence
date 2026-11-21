with open('mobile/lib/data/sound_groups_data.dart', encoding='utf-8') as f:
    text = f.read()

import re
pattern = re.compile(r"'((?:[^'\\]|\\.)*)'")
idx = text.find("id: 'sound_f'")
f_blk = text[idx:idx+8000]
sents = [m.group(1).replace(r"\'", "'") for m in pattern.finditer(f_blk) if 'Fransa' in m.group(1)]
print('Actual sentences in file with Fransa:')
for s in sents:
    print(' -', repr(s))
