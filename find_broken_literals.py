import re
import sys

sys.stdout.reconfigure(encoding='utf-8')

with open('mobile/lib/data/sound_groups_data.dart', encoding='utf-8') as f:
    text = f.read()

broken = []
for match in re.finditer(r"'([^']*)'", text):
    s = match.group(1)
    if '\\' in s or '\n' in s or s in [',', '']:
        broken.append(s)

print(f"Total broken string literals: {len(broken)}")
for b in broken[:30]:
    print(repr(b))
