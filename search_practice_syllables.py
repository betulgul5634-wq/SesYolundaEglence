import sys, re
sys.stdout.reconfigure(encoding='utf-8')

with open('mobile/lib/screens/sound_practice_screen.dart', 'r', encoding='utf-8') as f:
    text = f.read()

# Let's search for "hece" or "kelime" or how audio speech service is called in syllable section
matches = re.findall(r'.{0,60}(?:hece|kelime|syllable).{0,60}', text, re.IGNORECASE)
for m in matches[:30]:
    print(m.strip())
