with open('backend/main.py', 'r', encoding='utf-8') as f:
    text = f.read()

target = '    # /f/ heceleri - Ef asla İngilizce \'ief\' olarak harflenmemeli:\n    "ef": "Ef",'
replacement = '''    # /f/ heceleri - Ef asla İngilizce 'ief' olarak harflenmemeli:
    "ef": "Ef",
    # /v/ heceleri - 'iv' Roman numeral IV ('4'), 'ıv' ('ı ve'), 'ov' ('of') karışıklığını önleme:
    "iv": "İvv.",
    "ıv": "Ivv.",
    "ov": "Ovv.",'''

assert target in text, "target not found"
text = text.replace(target, replacement, 1)

with open('backend/main.py', 'w', encoding='utf-8') as f:
    f.write(text)

print('Added /v/ phonetic overrides to backend/main.py successfully!')
