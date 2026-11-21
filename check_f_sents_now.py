with open('mobile/lib/data/sound_groups_data.dart', encoding='utf-8') as f:
    text = f.read()

import re
pattern = re.compile(r"'((?:[^'\\]|\\.)*)'")
idx = text.find("id: 'sound_f'")
idx_next = text.find("SoundStage(", idx + 1)
f_blk = text[idx:idx_next]

m_snt = re.search(r'sentencesBeginning:\s*\[(.*?)\](?=\s*,\s*\w+:|\s*\))', f_blk, re.DOTALL)
if m_snt:
    items = [m.group(1).replace(r"\'", "'") for m in pattern.finditer(m_snt.group(1))]
    print("F sentencesBeginning:")
    for it in items:
        print(" *", repr(it))
