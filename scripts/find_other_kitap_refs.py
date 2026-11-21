import re

with open('mobile/lib/screens/sound_practice_screen.dart', 'r', encoding='utf-8') as f:
    lines = f.readlines()

for i, l in enumerate(lines):
    if 'kitap' in l.lower() or 'basamak' in l.lower():
        print(f"Line {i+1}: {l.strip()}")
