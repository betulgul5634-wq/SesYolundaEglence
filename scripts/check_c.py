import sys
sys.stdout.reconfigure(encoding='utf-8')

with open('mobile/lib/data/sound_groups_data.dart', 'r', encoding='utf-8') as f:
    content = f.read()

pos = content.find("'sound_c'")
if pos == -1:
    pos = content.find('"sound_c"')

print(content[pos:pos+3000])
