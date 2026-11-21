with open('mobile/lib/widgets/minimal_pairs_dialog.dart', 'r', encoding='utf-8') as f:
    text = f.read()

import re
matches = re.findall(r'_MinimalPairQuestion\((.*?)\)', text, re.DOTALL)
print(f"Total minimal pair questions: {len(matches)}")
for m in matches:
    t = re.search(r"title:\s*['\"](.*?)['\"]", m)
    wa = re.search(r"word:\s*['\"](.*?)['\"]", m)
    # find second word
    words = re.findall(r"word:\s*['\"](.*?)['\"]", m)
    t_str = t.group(1) if t else "?"
    w_str = " vs ".join(words)
    print(f"  - {t_str}: {w_str}")
