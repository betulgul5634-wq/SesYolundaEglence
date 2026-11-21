import re
from audit_real_emoji_coverage import get_pictogram, dart_text

stages = dart_text.split('SoundStage(')[1:]
remaining_fallbacks = set()

for s in stages:
    sub = s.split('SoundStage(')[0]
    words_m = re.findall(r"words(?:Beginning|Middle|Ending):\s*\[(.*?)\]", sub, re.DOTALL)
    for wm in words_m:
        for w in [x.strip().strip("'\"") for x in wm.split(',') if x.strip().strip("'\"")]:
            if get_pictogram(w) == 'FALLBACK':
                remaining_fallbacks.add(w.lower())

print(f"Unique fallback words: {len(remaining_fallbacks)}")
with open('fallbacks_remaining.txt', 'w', encoding='utf-8') as f:
    for w in sorted(remaining_fallbacks):
        f.write(w + '\n')
