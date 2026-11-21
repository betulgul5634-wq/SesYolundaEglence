import json

data = json.load(open('missing_sounds.json', encoding='utf-8'))

for k, v in data.items():
    s = v['story'].strip()
    first_line = s.split('\n')[0][:50]
    print(f"/{k}/ story len: {len(s)}, preview: {first_line}")
