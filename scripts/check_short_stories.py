import re

with open('mobile/lib/data/sound_groups_data.dart', 'r', encoding='utf-8') as f:
    text = f.read()

chunks = text.split('SoundStage(')[1:]
for idx in [2, 6, 7, 9, 10, 13, 15]:
    c = chunks[idx]
    ph = re.search(r"phoneme:\s*['\"](.*?)['\"]", c).group(1)
    st = re.search(r"storyTitle:\s*['\"](.*?)['\"]", c).group(1)
    sc = re.search(r"storyContent:\s*['\"](.*?)['\"]", c)
    sc_val = sc.group(1) if sc else "None"
    print(f"=== Stage {idx+1} {ph} ({st}) ===")
    print(repr(sc_val))
