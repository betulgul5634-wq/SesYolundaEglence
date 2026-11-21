import os
import re

found = []
for root, dirs, files in os.walk('mobile/lib'):
    for f in files:
        if f.endswith('.dart'):
            p = os.path.join(root, f)
            with open(p, 'r', encoding='utf-8') as fh:
                t = fh.read()
            m = re.findall(r"['\"](assets/[^'\"]+)['\"]", t)
            if m:
                found.append((f, m))

print(f"Asset references found: {len(found)}")
for fname, refs in found:
    print(f"{fname}: {refs}")
