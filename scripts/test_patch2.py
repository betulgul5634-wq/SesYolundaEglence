with open('backend/main.py', 'r', encoding='utf-8') as f:
    content = f.read()

pos = content.find('elif mode == "phoneme" or (len(trimmed_text) == 1 and (clean_p == "ç"')
print("Found target2 at:", pos)
if pos != -1:
    print(repr(content[pos:pos+400]))
