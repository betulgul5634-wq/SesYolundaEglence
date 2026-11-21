import re

with open('mobile/lib/data/sound_groups_data.dart', 'r', encoding='utf-8') as f:
    text = f.read()

chunks = text.split('SoundStage(')[1:]
for idx, c in enumerate(chunks):
    ph = re.search(r"phoneme:\s*['\"](.*?)['\"]", c).group(1)
    st = re.search(r"storyTitle:\s*['\"](.*?)['\"]", c).group(1)
    sc = re.search(r"storyContent:\s*['\"](.*?)['\"]", c)
    sc_val = sc.group(1) if sc else ""
    print(f"[{idx+1:02d}] {ph} | Title: {st} | Content ({len(sc_val)} chars):")
    print(f"     {sc_val[:80]}...")
