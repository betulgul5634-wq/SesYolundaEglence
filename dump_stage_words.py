import re

with open('mobile/lib/data/sound_groups_data.dart', 'r', encoding='utf-8') as f:
    text = f.read()

# Let's inspect each stage and dump its words
stages = re.findall(r"SoundStage\((.*?)\n  \),", text, re.DOTALL)

for s in stages:
    phoneme_m = re.search(r"phoneme:\s*'([^']+)'", s)
    ph = phoneme_m.group(1) if phoneme_m else '?'
    
    wb = re.search(r"wordsBeginning:\s*\[(.*?)\]", s, re.DOTALL)
    wm = re.search(r"wordsMiddle:\s*\[(.*?)\]", s, re.DOTALL)
    we = re.search(r"wordsEnding:\s*\[(.*?)\]", s, re.DOTALL)
    
    w1 = re.search(r"words1Syllable:\s*\[(.*?)\]", s, re.DOTALL)
    w2 = re.search(r"words2Syllables:\s*\[(.*?)\]", s, re.DOTALL)
    w3 = re.search(r"words3Syllables:\s*\[(.*?)\]", s, re.DOTALL)
    
    def parse_list(match):
        if not match: return []
        items = re.findall(r"'((?:[^'\\]|\\.)*)'", match.group(1))
        return [i.replace("\\'", "'") for i in items]
        
    print(f"\n==================== {ph} ====================")
    print("Beginning:", parse_list(wb)[:15])
    print("Middle:", parse_list(wm)[:15])
    print("Ending:", parse_list(we)[:15])
    print("1 Syl:", parse_list(w1)[:15])
    print("2 Syl:", parse_list(w2)[:15])
    print("3 Syl:", parse_list(w3)[:15])
