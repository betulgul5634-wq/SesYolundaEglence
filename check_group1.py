import sys
sys.stdout.reconfigure(encoding='utf-8')

with open('all_stages_detail.txt', 'r', encoding='utf-8') as f:
    text = f.read()

stages = text.split("==================== STAGE ")

for s in stages[1:7]:
    lines = s.strip().splitlines()
    header = lines[0]
    print(f"\n***** {header} *****")
    for l in lines[1:]:
        if l.startswith("P") or l.startswith("S") or l.startswith("---"):
            print("  " + l)
