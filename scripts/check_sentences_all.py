import re

with open('mobile/lib/data/sound_groups_data.dart', 'r', encoding='utf-8') as f:
    text = f.read()

chunks = text.split('SoundStage(')[1:]
for idx, c in enumerate(chunks):
    ph = re.search(r"phoneme:\s*['\"](.*?)['\"]", c).group(1)
    
    # check sentences
    sent_m = re.search(r"sentences:\s*\[(.*?)\]", c, re.DOTALL)
    s_count = len([x for x in sent_m.group(1).split(',') if x.strip() and not x.strip().startswith('//')]) if sent_m else 0
    
    sb_m = re.search(r"sentencesBeginning:\s*\[(.*?)\]", c, re.DOTALL)
    sc_m = re.search(r"sentencesContaining:\s*\[(.*?)\]", c, re.DOTALL)
    sb_count = len([x for x in sb_m.group(1).split(',') if x.strip() and not x.strip().startswith('//')]) if sb_m else 0
    sc_count = len([x for x in sc_m.group(1).split(',') if x.strip() and not x.strip().startswith('//')]) if sc_m else 0
    
    print(f"[{idx+1:02d}] {ph:5s} | Sentences: Total={s_count:02d}, Beg={sb_count:02d}, Cont={sc_count:02d}")
