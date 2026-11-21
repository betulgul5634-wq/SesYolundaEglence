import re
import sys

sys.stdout.reconfigure(encoding='utf-8')

with open('mobile/lib/data/sound_groups_data.dart', encoding='utf-8') as f:
    text = f.read()

# Find sound_f stage
idx_f = text.find("id: 'sound_f'")
idx_next = text.find("SoundStage(", idx_f + 1)
f_block = text[idx_f:idx_next]

for field in ['words1Syllable', 'words2Syllables', 'words3Syllables', 'phrasesBeginning', 'phrasesContaining', 'sentencesBeginning', 'sentencesContaining']:
    m = re.search(rf'{field}:\s*\[(.*?)\]', f_block, re.DOTALL)
    if m:
        items = re.findall(r"'([^']*)'", m.group(1))
        print(f"=== {field} ({len(items)}) ===")
        print(items[:15])
