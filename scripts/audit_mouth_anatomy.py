import re

with open('mobile/lib/widgets/mouth_anatomy_widget.dart', 'r', encoding='utf-8') as f:
    text = f.read()

cases = re.findall(r"case\s+['\"](/.*?/)['\"]:", text)
print(f"Mouth anatomy cases ({len(cases)}): {cases}")

# Check missing from 20 phonemes
all_20 = ['/p/', '/b/', '/t/', '/d/', '/k/', '/g/', '/f/', '/v/', '/s/', '/z/', '/ş/', '/j/', '/h/', '/ç/', '/c/', '/m/', '/n/', '/l/', '/r/', '/y/']
missing_in_anatomy = [p for p in all_20 if p not in cases]
print(f"Missing from 20 phonemes: {missing_in_anatomy}")
