import os
import re

print("=" * 70)
print("FORENSIC CODEBASE AUDIT ACROSS ALL DART FILES")
print("=" * 70)

dart_files = []
for root, dirs, files in os.walk('mobile/lib'):
    for f in files:
        if f.endswith('.dart'):
            dart_files.append(os.path.join(root, f))

print(f"Total Dart files to inspect: {len(dart_files)}")

# 1. Check for AnimationController or Timer initialized but missing dispose()
missing_dispose = []
for p in dart_files:
    fname = os.path.basename(p)
    with open(p, 'r', encoding='utf-8') as fh:
        code = fh.read()
    
    controllers = re.findall(r'(\b\w+Controller\b)\s*=', code)
    controllers = [c for c in controllers if c not in ('ScrollController', 'TextEditingController', 'TabController')]
    has_dispose = 'void dispose()' in code
    if controllers and not has_dispose:
        missing_dispose.append((fname, controllers))

print(f"\n1. Missing dispose() check: {len(missing_dispose)} issues")
for f, c in missing_dispose:
    print(f"   {f}: {set(c)}")

# 2. Check for sublist() without bounds checks
sublist_risks = []
for p in dart_files:
    fname = os.path.basename(p)
    with open(p, 'r', encoding='utf-8') as fh:
        lines = fh.readlines()
    for idx, line in enumerate(lines):
        if '.sublist(' in line:
            # check if line has bounds or min/clamp
            sublist_risks.append((fname, idx+1, line.strip()))

print(f"\n2. Sublist usage check: {len(sublist_risks)} instances")
for f, lnum, line in sublist_risks:
    print(f"   {f}:{lnum} -> {line}")

# 3. Check for hardcoded phoneme patterns like "/p/" or "/b/" or "P Sesi" in generic widgets
generic_phoneme_hardcodes = []
for p in dart_files:
    fname = os.path.basename(p)
    if fname in ('sound_groups_data.dart', 'word_pictogram_helper.dart', 'mouth_anatomy_widget.dart'):
        continue
    with open(p, 'r', encoding='utf-8') as fh:
        lines = fh.readlines()
    for idx, line in enumerate(lines):
        # find things like "P Sesi" or "B Sesi" hardcoded in UI strings
        m = re.findall(r"['\"][^'\"]*\b([PBTDKGFSZŞJHÇCMNLRY]\s+Sesi)\b[^'\"]*['\"]", line)
        if m:
            generic_phoneme_hardcodes.append((fname, idx+1, line.strip(), m))

print(f"\n3. Hardcoded phoneme names in UI widgets: {len(generic_phoneme_hardcodes)} instances")
for f, lnum, line, m in generic_phoneme_hardcodes:
    print(f"   {f}:{lnum} -> {m} in '{line}'")
