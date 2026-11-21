import re
import sys

sys.stdout.reconfigure(encoding='utf-8')

# Let's inspect all fields of SoundStage
with open('mobile/lib/data/sound_groups_data.dart', 'r', encoding='utf-8') as f:
    text = f.read()

print("Initial length:", len(text))
