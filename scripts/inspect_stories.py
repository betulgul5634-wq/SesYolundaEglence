import re
with open('mobile/lib/data/sound_groups_data.dart', 'r', encoding='utf-8') as f:
    text = f.read()

for sid in ['sound_v', 'sound_z', 'sound_ç', 'sound_f', 'sound_m', 'sound_ş']:
    pattern = r"id:\s*['\"]" + sid + r"['\"][\s\S]*?storyContent:\s*['\"](.*?)['\"],"
    m = re.search(pattern, text)
    if m:
        print(f"=== {sid} ===")
        print(repr(m.group(1)))
