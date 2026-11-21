import re

with open('mobile/lib/data/sound_groups_data.dart', encoding='utf-8') as f:
    text = f.read()

# Find all word lists in sound_groups_data.dart
words = set()
for match in re.finditer(r"'(.*?)'", text):
    s = match.group(1).strip()
    if s and ' ' not in s and len(s) > 1 and not s.startswith('/') and not s.startswith('sound_') and not s.startswith('0x'):
        words.add(s)

print(f"Total unique words found: {len(words)}")
# Let's see words that contain only ascii letters and might be missing Turkish diacritics
sample_ascii = [w for w in words if all(c.isascii() for c in w)]
print(f"Ascii-only words: {len(sample_ascii)}")
print("Sample ascii words:", sample_ascii[:40])
