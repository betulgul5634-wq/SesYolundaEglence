import re

with open('mobile/lib/data/sound_groups_data.dart', encoding='utf-8') as f:
    text = f.read()

# Pattern to find each SoundStage block
# id: 'sound_x'
matches = list(re.finditer(r"id:\s*'(sound_[a-zğüşöçı]+)'", text))
print("Found stages:", [m.group(1) for m in matches])
