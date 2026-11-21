with open('mobile/lib/screens/sound_practice_screen.dart', 'r', encoding='utf-8') as f:
    lines = f.readlines()

for i, l in enumerate(lines):
    if "Text('Kapat'" in l:
        print(f"=== Line {i+1} ===")
        for j in range(max(0, i-45), min(len(lines), i+15)):
            print(f"{j+1}: {lines[j]}", end='')
