with open('mobile/lib/screens/sound_practice_screen.dart', 'r', encoding='utf-8') as f:
    text = f.read()

import re
matches = re.findall(r'_audioService\.speakTurkish\([^)]+\)', text)
print("speakTurkish calls in sound_practice_screen.dart:")
for m in matches:
    print("  ->", m.replace('\n', ' '))
