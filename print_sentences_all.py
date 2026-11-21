import sys
sys.stdout.reconfigure(encoding='utf-8')

with open('all_sentences_detailed.txt', 'r', encoding='utf-8') as f:
    text = f.read()

# Let's inspect all stages
stages = text.split("==================== STAGE ")

for s in stages[1:]:
    lines = s.strip().splitlines()
    header = lines[0]
    print(f"\n{header}")
    for l in lines[1:]:
        print(l)
