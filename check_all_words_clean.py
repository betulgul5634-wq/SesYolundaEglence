import re

valid_words = set()
with open('turkish_wordlist.txt', 'r', encoding='utf-8') as f:
    for line in f:
        w = line.strip().split('/')[0].strip().replace('I', 'ı').replace('İ', 'i').lower()
        if w:
            valid_words.add(w)

with open('tr_50k.txt', 'r', encoding='utf-8') as f:
    for line in f:
        parts = line.strip().split()
        if parts:
            w = parts[0].strip().replace('I', 'ı').replace('İ', 'i').lower()
            if w:
                valid_words.add(w)

print(f"Loaded {len(valid_words)} clean valid Turkish words.")

with open('mobile/lib/data/sound_groups_data.dart', 'r', encoding='utf-8') as f:
    dart_text = f.read()

stages = re.findall(r"SoundStage\((.*?)\n  \),", dart_text, re.DOTALL)

def get_list(text, field):
    m = re.search(rf"{field}:\s*\[(.*?)\]", text, re.DOTALL)
    if not m: return []
    items = re.findall(r"'((?:[^'\\]|\\.)*)'", m.group(1))
    return [i.replace("\\'", "'") for i in items]

all_errors = {}

for s in stages:
    ph = re.search(r"phoneme:\s*'([^']+)'", s).group(1)
    letter = re.search(r"soundLetter:\s*'([^']+)'", s).group(1).replace('I', 'ı').replace('İ', 'i').lower()
    
    words = (get_list(s, 'wordsBeginning') +
             get_list(s, 'wordsMiddle') +
             get_list(s, 'wordsEnding') +
             get_list(s, 'words1Syllable') +
             get_list(s, 'words2Syllables') +
             get_list(s, 'words3Syllables'))
             
    unique_words = list(dict.fromkeys(words))
    
    dict_errors = []
    missing_target = []
    
    for w in unique_words:
        clean = w.strip().replace('I', 'ı').replace('İ', 'i').lower()
        if letter not in clean:
            missing_target.append(w)
        if clean not in valid_words:
            dict_errors.append(w)
            
    all_errors[ph] = {
        "dict_errors": dict_errors,
        "missing_target": missing_target
    }

for ph, data in all_errors.items():
    print(f"\n==================== {ph} ====================")
    if data["missing_target"]:
        print(f"  Missing target letter: {data['missing_target']}")
    print(f"  Not in Turkish dict ({len(data['dict_errors'])}): {data['dict_errors']}")
