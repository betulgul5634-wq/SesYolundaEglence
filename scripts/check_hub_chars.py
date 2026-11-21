with open('mobile/lib/widgets/subway_character_hub_dialog.dart', 'r', encoding='utf-8') as f:
    text = f.read()

import re
chars = re.findall(r"id:\s*['\"](.*?)['\"]", text)
names = re.findall(r"name:\s*['\"](.*?)['\"]", text)
for c, n in zip(chars, names):
    print(f"{c}: {n}")
