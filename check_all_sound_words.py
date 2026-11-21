with open('mobile/lib/data/sound_groups_data.dart', encoding='utf-8') as f:
    text = f.read()

import re
import sys
sys.stdout.reconfigure(encoding='utf-8')

pattern = re.compile(r"'((?:[^'\\]|\\.)*)'")
stage_regex = re.compile(r"SoundStage\(\s*id:\s*'sound_([a-zğüşöçı]+)'", re.DOTALL)
matches = list(stage_regex.finditer(text))

for i, m in enumerate(matches):
    let = m.group(1)
    start_idx = m.start()
    end_idx = matches[i+1].start() if i + 1 < len(matches) else len(text)
    blk = text[start_idx:end_idx]
    
    m_w2 = re.search(r'words2Syllables:\s*\[(.*?)\](?=\s*,\s*\w+:|\s*\))', blk, re.DOTALL)
    w2 = [item.group(1).replace(r"\'", "'") for item in pattern.finditer(m_w2.group(1))] if m_w2 else []
    
    m_w3 = re.search(r'words3Syllables:\s*\[(.*?)\](?=\s*,\s*\w+:|\s*\))', blk, re.DOTALL)
    w3 = [item.group(1).replace(r"\'", "'") for item in pattern.finditer(m_w3.group(1))] if m_w3 else []
    
    print(f"/{let}/: w2 ({len(w2)}): {w2[:6]} | w3 ({len(w3)}): {w3[:4]}")
