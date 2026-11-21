with open('mobile/lib/screens/home_screen.dart', 'r', encoding='utf-8') as f:
    lines = f.readlines()

for idx, line in enumerate(lines, 1):
    if any(k in line.lower() for k in ['unlocked', 'islocked', 'iscompleted', 'kbookstages', '_stages', 'kallsounds']):
        print(f"Line {idx}: {line.strip()}")
