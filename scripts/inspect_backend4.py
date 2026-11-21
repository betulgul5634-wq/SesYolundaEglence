with open('backend/main.py', 'r', encoding='utf-8') as f:
    content = f.read()

pos = content.find("syllable_phonetic_map = {")
if pos != -1:
    print(content[pos:pos+3500])
else:
    print("Not found")
