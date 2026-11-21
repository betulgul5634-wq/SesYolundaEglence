import re

with open('mobile/lib/data/sound_groups_data.dart', 'r', encoding='utf-8') as f:
    text = f.read()

# Match each SoundStage block
stage_blocks = text.split('SoundStage(')[1:]
vowels = ['a', 'e', 'ı', 'i', 'o', 'ö', 'u', 'ü']

for idx, block in enumerate(stage_blocks):
    sub = block.split('SoundStage(')[0]
    id_m = re.search(r"id:\s*['\"](.*?)['\"]", sub)
    p_m = re.search(r"phoneme:\s*['\"](.*?)['\"]", sub)
    c_m = re.search(r"soundLetter:\s*['\"](.*?)['\"]", sub)
    syl_m = re.search(r"syllables:\s*\[(.*?)\]", sub, re.DOTALL)
    
    stage_id = id_m.group(1) if id_m else f"stage_{idx+1}"
    phoneme = p_m.group(1) if p_m else "?"
    char = c_m.group(1).lower() if c_m else "?"
    
    syls = []
    if syl_m:
        raw = syl_m.group(1)
        syls = [s.strip().strip("'\"") for s in raw.split(',') if s.strip().strip("'\"")]
    
    print(f"[{idx+1:02d}] {stage_id} {phoneme} char='{char}' count={len(syls)}")
    print(f"     First 8: {syls[:8]}")
    if len(syls) >= 16:
        print(f"     Next 8:  {syls[8:16]}")
    if len(syls) >= 24:
        print(f"     Next 8:  {syls[16:24]}")
    if len(syls) >= 32:
        print(f"     Next 8:  {syls[24:32]}")
    print()
