with open('mobile/lib/screens/home_screen.dart', 'r', encoding='utf-8') as f:
    lines = f.readlines()

for i, l in enumerate(lines):
    if 'showDialog' in l or 'showModalBottomSheet' in l:
        print(f"L{i+1}:")
        for j in range(i, min(len(lines), i+6)):
            print(f"  {lines[j].strip()}")
