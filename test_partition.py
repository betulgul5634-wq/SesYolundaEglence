import json
import re

missing_data = json.load(open('missing_sounds.json', encoding='utf-8'))

for k, v in missing_data.items():
    let = k.lower()
    all_w = v['words_1'] + v['words_2'] + v['words_3']
    beg = []
    mid = []
    end = []
    for w in all_w:
        w_clean = w.strip()
        if not w_clean: continue
        w_lower = w_clean.lower()
        if w_lower.startswith(let):
            beg.append(w_clean)
        elif w_lower.endswith(let):
            end.append(w_clean)
        elif let in w_lower:
            mid.append(w_clean)
    print(f"Sound /{let}/: Total words={len(all_w)}, Beg={len(beg)}, Mid={len(mid)}, End={len(end)}, w1={len(v['words_1'])}, w2={len(v['words_2'])}, w3={len(v['words_3'])}")
