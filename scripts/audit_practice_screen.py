import re

with open('mobile/lib/screens/sound_practice_screen.dart', 'r', encoding='utf-8') as f:
    text = f.read()

tabs = re.findall(r"Tab\s*\(\s*text:\s*['\"](.*?)['\"]", text)
print(f"Practice screen tabs: {tabs}")

# Check any dialog openers
dialogs = re.findall(r"showDialog.*?builder:.*?context\)\s*=>\s*([A-Za-z0-9_]+)", text)
print(f"Dialogs opened in practice screen ({len(dialogs)}): {set(dialogs)}")
