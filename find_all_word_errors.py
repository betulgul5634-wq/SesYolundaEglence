import re

with open('mobile/lib/data/sound_groups_data.dart', 'r', encoding='utf-8') as f:
    dart_text = f.read()

# Load Turkish wordlist
valid_words = set()
with open('turkish_wordlist.txt', 'r', encoding='utf-8') as f:
    for line in f:
        w = line.strip().lower()
        if w:
            valid_words.add(w)

print(f"Loaded {len(valid_words)} valid Turkish words from dictionary.")

# Extract all stages and inspect word lists
stages = re.findall(r"SoundStage\((.*?)\n  \),", dart_text, re.DOTALL)

def get_list(text, field):
    m = re.search(rf"{field}:\s*\[(.*?)\]", text, re.DOTALL)
    if not m: return []
    items = re.findall(r"'((?:[^'\\]|\\.)*)'", m.group(1))
    return [i.replace("\\'", "'") for i in items]

all_invalid = {}

for s in stages:
    ph = re.search(r"phoneme:\s*'([^']+)'", s).group(1)
    letter = re.search(r"soundLetter:\s*'([^']+)'", s).group(1).lower()
    
    words = (get_list(s, 'wordsBeginning') +
             get_list(s, 'wordsMiddle') +
             get_list(s, 'wordsEnding') +
             get_list(s, 'words1Syllable') +
             get_list(s, 'words2Syllables') +
             get_list(s, 'words3Syllables'))
             
    unique_words = list(dict.fromkeys(words))
    
    invalid_for_ph = []
    wrong_target_for_ph = []
    
    for w in unique_words:
        clean = w.strip().lower()
        # check target phoneme
        if letter not in clean:
            wrong_target_for_ph.append(w)
            
        if clean not in valid_words:
            # Maybe capitalized proper noun or compound word?
            invalid_for_ph.append(w)
            
    if invalid_for_ph or wrong_target_for_ph:
        all_invalid[ph] = {
            "invalid_dict": invalid_for_ph,
            "missing_target": wrong_target_for_ph
        }

print(f"\nStages with issues: {len(all_invalid)}")
for ph, data in all_invalid.items():
    print(f"\n--- {ph} ---")
    if data["missing_target"]:
        print(f"  Missing target '{ph}': {data['missing_target']}")
    if data["invalid_dict"]:
        print(f"  Not in Turkish dict ({len(data['invalid_dict'])}): {data['invalid_dict'][:15]}")
