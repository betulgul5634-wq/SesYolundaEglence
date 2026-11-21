with open('mobile/lib/screens/sound_practice_screen.dart', 'r', encoding='utf-8') as f:
    text = f.read()

import re
tabs = re.findall(r"Tab\((.*?)\)", text, re.DOTALL)
print(f"Tabs in sound_practice_screen ({len(tabs)}):")
for t in tabs:
    text_m = re.search(r"text:\s*['\"](.*?)['\"]", t)
    if text_m:
        print("  -", text_m.group(1))

# Find TabBarView children
idx_tbv = text.find("TabBarView(")
if idx_tbv != -1:
    print("\nTabBarView found around line:", text[:idx_tbv].count('\n'))
