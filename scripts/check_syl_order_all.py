import re

with open('mobile/lib/data/sound_groups_data.dart', encoding='utf-8') as f:
    sg_content = f.read()

stages = re.findall(r"SoundStage\((.*?)\n  \),", sg_content, re.DOTALL)

def get_list(block, name):
    m = re.search(name + r':\s*\[(.*?)\]', block, re.DOTALL)
    if not m: return []
    return re.findall(r"'([^']+)'", m.group(1))

def get_val(block, name):
    m = re.search(name + r":\s*'([^']+)'", block)
    return m.group(1) if m else ''

for block in stages:
    phoneme = get_val(block, 'phoneme')
    syls = get_list(block, 'syllables')
    first_8 = syls[:8]
    print(f"{phoneme:<6} ({len(syls)} syls): First 8: {first_8}")
