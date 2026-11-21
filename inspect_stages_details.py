import re

with open('audit_report.txt', 'r', encoding='utf-8') as f:
    text = f.read()

# Let's print for stages /s/, /z/, /ş/, /j/, /h/, /ç/, /c/, /m/, /n/
stages_to_check = ['/s/', '/z/', '/ş/', '/j/', '/h/', '/ç/', '/c/', '/m/', '/n/', '/l/', '/r/']
for part in text.split('==================== STAGE '):
    for ph in stages_to_check:
        if part.startswith(ph):
            lines = part.strip().split('\n')
            print(f"\n*** STAGE {ph} ({len(lines)} lines) ***")
            for l in lines[1:25]:
                print(l)
