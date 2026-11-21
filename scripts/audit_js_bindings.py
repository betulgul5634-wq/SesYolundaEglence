import os
import re

with open('mobile/web/index.html', 'r', encoding='utf-8') as f:
    html_text = f.read()

js_calls = []
for root, dirs, files in os.walk('mobile/lib'):
    for f in files:
        if f.endswith('.dart'):
            p = os.path.join(root, f)
            with open(p, 'r', encoding='utf-8') as fh:
                code = fh.read()
            # find js.context.callMethod('functionName'
            matches = re.findall(r"js\.context\.callMethod\(\s*['\"]([^'\"]+)['\"]", code)
            for m in matches:
                js_calls.append((f, m))

print(f"Total js.context.callMethod calls: {len(js_calls)}")
missing_js = []
for fname, fn in js_calls:
    if fn == 'eval':
        continue
    # check if fn is defined in html_text
    # e.g. function fn( or window.fn =
    pattern = rf"(function\s+{fn}\b|window\.{fn}\s*=|let\s+{fn}\s*=|var\s+{fn}\s*=)"
    if not re.search(pattern, html_text):
        missing_js.append((fname, fn))
    else:
        print(f"OK: {fname} calls '{fn}' -> DEFINED in index.html")

if missing_js:
    print(f"\nMISSING JS FUNCTIONS: {missing_js}")
else:
    print("\nALL JS FUNCTIONS ARE DEFINED IN index.html!")
