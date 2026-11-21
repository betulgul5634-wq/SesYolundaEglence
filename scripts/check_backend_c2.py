with open('backend/main.py', 'r', encoding='utf-8') as f:
    lines = f.readlines()

for i in range(545, 595):
    print(f"{i+1}: {lines[i]}", end='')
