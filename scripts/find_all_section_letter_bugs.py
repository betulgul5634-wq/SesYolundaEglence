import re

with open('mobile/lib/screens/sound_practice_screen.dart', 'r', encoding='utf-8') as f:
    text = f.read()

matches = re.findall(r"['\"][^'\"]*[A-H]\.\s+Sesi[^'\"]*['\"]", text)
print(f"Matches count: {len(matches)}")
for m in matches:
    print(m)
