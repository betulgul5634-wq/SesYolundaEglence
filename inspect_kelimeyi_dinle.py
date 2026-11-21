import sys
sys.stdout.reconfigure(encoding='utf-8')

with open('mobile/lib/screens/sound_practice_screen.dart', 'r', encoding='utf-8') as f:
    lines = f.readlines()

for i, l in enumerate(lines):
    if 'Kelimeyi Dinle' in l:
        for j in range(max(0, i - 15), min(len(lines), i + 20)):
            print(f'{j+1}: {lines[j]}', end='')
