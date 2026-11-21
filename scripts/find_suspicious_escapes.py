import re

with open('mobile/lib/data/sound_groups_data.dart', 'r', encoding='utf-8') as f:
    text = f.read()

# Check for trailing backslashes in any string
suspicious_escapes = []
for line_no, line in enumerate(text.split('\n'), 1):
    if "\\'" in line or "\\\"" in line:
        # Check if the line ends with \' or \\'
        if line.strip().endswith("\\'") or line.strip().endswith("\\',") or line.strip().endswith("\\\""):
            suspicious_escapes.append((line_no, line.strip()))

print(f"Suspicious escaped lines found: {len(suspicious_escapes)}")
for l_no, l in suspicious_escapes[:30]:
    print(f"L{l_no}: {l}")
