with open('backend/main.py', 'r', encoding='utf-8') as f:
    lines = f.readlines()

for i in range(435, min(len(lines), 510)):
    print(f"{i+1}: {lines[i]}", end='')
