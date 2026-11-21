import os, re

widgets_dir = 'mobile/lib/widgets'
files = [f for f in os.listdir(widgets_dir) if f.endswith('.dart')]
print(f"Total widget files to audit: {len(files)}")

issues = []

for f in files:
    path = os.path.join(widgets_dir, f)
    with open(path, 'r', encoding='utf-8') as fp:
        code = fp.read()
        
    # Check for unmounted setState
    # Look for async methods calling setState without if (!mounted)
    # Check for missing controller dispose
    controllers = re.findall(r'(AnimationController|TextEditingController|ScrollController|TabController)\s+(\w+)', code)
    for c_type, c_name in controllers:
        if f"{c_name}.dispose()" not in code and f"{c_name}?.dispose()" not in code:
            # Check if it's passed from outside or instantiated here
            if f"= {c_type}" in code or f"late {c_type} {c_name}" in code:
                issues.append(f"{f}: Potential missing dispose for {c_type} {c_name}")
                
    # Check for hardcoded English texts that should be Turkish
    english_clues = ['Congratulations', 'Settings', 'Submit', 'Cancel', 'Password', 'Username']
    for clue in english_clues:
        if f"'{clue}'" in code or f'"{clue}"' in code:
            issues.append(f"{f}: Possible unlocalized English string: '{clue}'")

print(f"Total potential issues detected: {len(issues)}")
for iss in issues:
    print(f"  - {iss}")
