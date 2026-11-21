import sys
sys.stdout.reconfigure(encoding='utf-8')

with open('mobile/lib/screens/sound_practice_screen.dart', 'r', encoding='utf-8') as f:
    lines = f.readlines()

for i in range(1230, 1330):
    if i < len(lines):
        print(f'{i+1}: {lines[i]}', end='')
