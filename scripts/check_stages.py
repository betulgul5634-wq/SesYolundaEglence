with open('mobile/lib/data/sound_groups_data.dart', 'r', encoding='utf-8') as f:
    lines = f.readlines()

stages = []
current_id = None
for l in lines:
    l_str = l.strip()
    if l_str.startswith("id:"):
        current_id = l_str
    elif l_str.startswith("soundLetter:") and current_id:
        stages.append((current_id, l_str))
        current_id = None

print(f"Total stages found: {len(stages)}")
for sid, letter in stages:
    print(f"{sid} -> {letter}")
