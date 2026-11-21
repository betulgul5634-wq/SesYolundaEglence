import re

with open('mobile/lib/data/sound_groups_data.dart', 'r', encoding='utf-8') as f:
    text = f.read()

# Let's find all words in wordsBeginning, wordsMiddle, wordsEnding, words1Syllable, words2Syllables, words3Syllables
# and check which ones look like ASCII OCR artifacts (e.g. c instead of ç, s instead of ş, g instead of ğ, o instead of ö, u instead of ü, i instead of ı)
# or weird words.

# Let's inspect each stage
stages = re.findall(r"SoundStage\((.*?)\n  \),", text, re.DOTALL)
print(f"Total stages found: {len(stages)}")

for s in stages:
    phoneme_m = re.search(r"phoneme:\s*'([^']+)'", s)
    ph = phoneme_m.group(1) if phoneme_m else '?'
    
    # Extract words
    wb = re.search(r"wordsBeginning:\s*\[(.*?)\]", s, re.DOTALL)
    wm = re.search(r"wordsMiddle:\s*\[(.*?)\]", s, re.DOTALL)
    we = re.search(r"wordsEnding:\s*\[(.*?)\]", s, re.DOTALL)
    
    def parse_list(match):
        if not match: return []
        items = re.findall(r"'((?:[^'\\]|\\.)*)'", match.group(1))
        return [i.replace("\\'", "'") for i in items]
        
    all_words = parse_list(wb) + parse_list(wm) + parse_list(we)
    print(f"\nStage {ph}: {len(all_words)} words. Sample: {all_words[:8]}")
