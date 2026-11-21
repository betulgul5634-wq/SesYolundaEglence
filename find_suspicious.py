import sys, re
sys.stdout.reconfigure(encoding='utf-8')

with open('all_phrases_sentences_dump.txt', 'r', encoding='utf-8') as f:
    lines = f.readlines()

# Patterns of interest:
# 1. ASCII vs Turkish diacritics where Turkish expected (e.g. 'cicek', 'seker', 'somine', 'agac', 'faytoncu', 'ogrenci', 'guzel', 'kucuk', etc.)
# 2. Lowercase start of sentence
# 3. Missing punctuation or space
# 4. Words stuck to apostrophe

suspicious_lines = []

for idx, line in enumerate(lines):
    line_str = line.strip()
    if not line_str.startswith('P') and not line_str.startswith('S'):
        continue
    
    content = line_str.split(':', 1)[1].strip()
    
    # Check stuck apostrophe
    if re.search(r"[a-zA-ZçğıöşüÇĞİÖŞÜ]'[a-zA-ZçğıöşüÇĞİÖŞÜ]+[A-ZÇĞİÖŞÜa-zçğıöşü]{2,}", content):
        suspicious_lines.append((idx, line_str, "STUCK_APOSTROPHE"))
    
    # Check common ASCII mistakes
    ascii_words = ['cicek', 'cilek', 'curuk', 'bahce', 'tebesir', 'sasi', 'cekilis', 'cadi', 'cuppe', 'lule', 'fistik', 'fisek', 'fuze', 'tufek', 'findik', 'seffaf', 'tesaduf', 'feslegen', 'kadayif', 'firildak', 'kiyafet', 'firtina', 'zurafa', 'carsaf', 'kunefe', 'ciftci', 'sofor', 'parfum', 'hosaf', 'seftali', 'seker', 'somine', 'agac', 'agacl', 'ogrenci', 'ogretmen', 'guzel', 'kucuk', 'buyuk', 'faytoncu', 'Fransizfaytoncu', 'bakkali', 'kanadi', 'lostu', 'lambasi', 'Lokantanin', 'Judocularin', 'jolesi', 'janti', 'jileti', 'Legeni', 'lifledim', 'cirtl', 'coskusu', 'ikac', 'sömine', 'sasirtmisti', 'lazimlik', 'eldiven', 'lacivert', 'kivilcim', 'kavanoz', 'dolasmak']
    for aw in ascii_words:
        if re.search(r'\b' + aw + r'\b', content, re.IGNORECASE):
            suspicious_lines.append((idx, line_str, f"ASCII_WORD: {aw}"))

print(f"Total suspicious lines found: {len(suspicious_lines)}")
for idx, line_str, reason in suspicious_lines[:50]:
    print(f"[{reason}] {line_str}")
if len(suspicious_lines) > 50:
    print(f"... and {len(suspicious_lines) - 50} more")
