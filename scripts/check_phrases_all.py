import re

with open('mobile/lib/data/sound_groups_data.dart', 'r', encoding='utf-8') as f:
    text = f.read()

chunks = text.split('SoundStage(')[1:]
for idx, c in enumerate(chunks):
    ph = re.search(r"phoneme:\s*['\"](.*?)['\"]", c).group(1)
    
    # check phrases
    phrases_m = re.search(r"phrases:\s*\[(.*?)\]", c, re.DOTALL)
    p_count = len([x for x in phrases_m.group(1).split(',') if x.strip() and not x.strip().startswith('//')]) if phrases_m else 0
    
    # check phrasesBeginning / Containing
    pb_m = re.search(r"phrasesBeginning:\s*\[(.*?)\]", c, re.DOTALL)
    pc_m = re.search(r"phrasesContaining:\s*\[(.*?)\]", c, re.DOTALL)
    pb_count = len([x for x in pb_m.group(1).split(',') if x.strip() and not x.strip().startswith('//')]) if pb_m else 0
    pc_count = len([x for x in pc_m.group(1).split(',') if x.strip() and not x.strip().startswith('//')]) if pc_m else 0
    
    print(f"[{idx+1:02d}] {ph:5s} | Phrases: Total={p_count:02d}, Beg={pb_count:02d}, Cont={pc_count:02d}")
