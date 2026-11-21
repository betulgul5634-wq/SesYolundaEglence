with open('mobile/lib/widgets/therapy_certificate_dialog.dart', 'r', encoding='utf-8') as f:
    lines = f.readlines()

for i, l in enumerate(lines):
    if 'childName' in l:
        print(f"L{i+1}: {l.strip()}")
