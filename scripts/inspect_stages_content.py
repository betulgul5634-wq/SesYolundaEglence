with open('mobile/lib/data/sound_groups_data.dart', 'r', encoding='utf-8') as f:
    text = f.read()

import re
stages = re.split(r'SoundStage\(', text)
print(f"Total SoundStage blocks: {len(stages) - 1}")

for i, s in enumerate(stages[1:], 1):
    sid_m = re.search(r'id:\s*[\'"]([^\'"]+)[\'"]', s)
    letter_m = re.search(r'soundLetter:\s*[\'"]([^\'"]+)[\'"]', s)
    phoneme_m = re.search(r'phoneme:\s*[\'"]([^\'"]+)[\'"]', s)
    syl_m = re.search(r'syllables:\s*\[(.*?)\]', s, re.DOTALL)
    wb_m = re.search(r'wordsBeginning:\s*\[(.*?)\]', s, re.DOTALL)
    
    sid = sid_m.group(1) if sid_m else '?'
    letter = letter_m.group(1) if letter_m else '?'
    phoneme = phoneme_m.group(1) if phoneme_m else '?'
    syls = [x.strip().strip("'\"") for x in syl_m.group(1).split(',') if x.strip()] if syl_m else []
    wb = [x.strip().strip("'\"") for x in wb_m.group(1).split(',') if x.strip()] if wb_m else []
    
    print(f"[{i}] id={sid}, letter={letter}, phoneme={phoneme}, syls_count={len(syls)}, wordsBeg_count={len(wb)}")
