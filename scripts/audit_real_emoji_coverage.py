import re

with open('mobile/lib/data/sound_groups_data.dart', 'r', encoding='utf-8') as f:
    dart_text = f.read()

with open('mobile/lib/utils/word_pictogram_helper.dart', 'r', encoding='utf-8') as f:
    dict_text = f.read()

dict_keys = dict(re.findall(r"['\"]([\wığüşöçİĞÜŞÖÇ]+)['\"]\s*:\s*['\"]([^'\"]+)['\"]", dict_text))
dict_words = {k.lower(): v for k, v in dict_keys.items()}

fallback_icons = {'🎈', '🫐', '🎾', '🐬', '👑', '🌈', '🦩', '🎻', '⭐', '🦓', '🍭', '🐆', '🚁', '🌸', '🎸', '🐵', '🍀', '🍋', '🚀', '⛵', '✨'}

def get_pictogram(word):
    if not word:
        return '✨'
    clean = word.strip().lower().replace('\u0307', '')
    if clean in dict_words:
        return dict_words[clean]
    for k, v in dict_words.items():
        if clean.startswith(k) and len(clean) <= len(k) + 4:
            return v
    for k, v in dict_words.items():
        if k in clean and len(k) >= 3:
            return v
    # fallback
    return 'FALLBACK'

stages = dart_text.split('SoundStage(')[1:]
print(f"{'Sound':<8} {'Total Words':<12} {'Has Real Emoji':<16} {'Fallback':<12} {'Real Emoji %'}")
print("-" * 65)

total_all = 0
total_real = 0

for s in stages:
    sub = s.split('SoundStage(')[0]
    p_m = re.search(r"phoneme:\s*['\"](.*?)['\"]", sub)
    if not p_m: continue
    ph = p_m.group(1)
    
    words_m = re.findall(r"words(?:Beginning|Middle|Ending):\s*\[(.*?)\]", sub, re.DOTALL)
    words = []
    for wm in words_m:
        words.extend([w.strip().strip("'\"") for w in wm.split(',') if w.strip().strip("'\"")])
    
    real_count = 0
    fallback_count = 0
    for w in words:
        pic = get_pictogram(w)
        if pic != 'FALLBACK':
            real_count += 1
        else:
            fallback_count += 1
            
    pct = (real_count / len(words) * 100) if words else 0
    print(f"{ph:<8} {len(words):<12} {real_count:<16} {fallback_count:<12} {pct:.1f}%")
    total_all += len(words)
    total_real += real_count

print("-" * 65)
tot_pct = total_real / total_all * 100
print(f"TOTAL:   {total_all:<12} {total_real:<16} {total_all - total_real:<12} {tot_pct:.1f}%")
