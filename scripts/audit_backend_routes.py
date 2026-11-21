with open('backend/main.py', 'r', encoding='utf-8') as f:
    text = f.read()

import re
routes = re.findall(r"@app\.(get|post|put|delete)\(['\"](.*?)['\"]", text)
for m, r in routes:
    print(f"{m.upper():4s} {r}")
