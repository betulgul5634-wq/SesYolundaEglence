with open('mobile/lib/screens/sound_practice_screen.dart', 'r', encoding='utf-8') as f:
    lines = f.readlines()

for i, l in enumerate(lines):
    if 'showDialog' in l or 'showModalBottomSheet' in l:
        # read next 6 lines
        context_str = "".join([x.strip() for x in lines[i:i+6]])
        print(f"Line {i+1}: {context_str[:90]}")
