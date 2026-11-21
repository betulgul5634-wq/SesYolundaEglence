import re
import sys

sys.stdout.reconfigure(encoding='utf-8')

with open('mobile/lib/data/sound_groups_data.dart', encoding='utf-8') as f:
    text = f.read()

stages = re.findall(r"id:\s*'(sound_[a-zğüşöçı]+)'", text)
print("Stages:", stages)

for st in stages:
    idx = text.find(f"id: '{st}'")
    idx_next = text.find("SoundStage(", idx + 1)
    if idx_next == -1: idx_next = len(text)
    blk = text[idx:idx_next]
    
    m_beg = re.search(r'wordsBeginning:\s*\[(.*?)\]', blk, re.DOTALL)
    words = re.findall(r"'([^']*)'", m_beg.group(1)) if m_beg else []
    
    # Check if words have Turkish characters
    tr_chars = sum(1 for w in words for c in w if c in 'çğıöşüÇĞİÖŞÜ')
    print(f"{st}: {len(words)} words, {tr_chars} Turkish diacritics. Sample: {words[:5]}")
