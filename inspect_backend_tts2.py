import sys
sys.stdout.reconfigure(encoding='utf-8')

with open('backend/main.py', 'r', encoding='utf-8') as f:
    lines = f.readlines()

for i in range(420, 480):
    if i < len(lines):
        print(f'{i+1}: {lines[i]}', end='')
