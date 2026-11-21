import re

with open('mobile/lib/screens/sound_practice_screen.dart', 'r', encoding='utf-8') as f:
    lines = f.readlines()

for i, l in enumerate(lines):
    if re.search(r'SES[İI]\s+İÇEREN', l, re.IGNORECASE) or 'TERAPİ HİKAYESİ' in l or re.search(r'[A-ZĞÜŞİÖÇ]\.\s+SES', l):
        print(f"Line {i+1}: {l.strip()}")
