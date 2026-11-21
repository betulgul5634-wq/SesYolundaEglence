import sys
sys.stdout.reconfigure(encoding='utf-8')

with open('mobile/lib/data/sound_groups_data.dart', 'r', encoding='utf-8') as f:
    text = f.read()

idx = 136900
print(text[idx-1200:idx+400])
