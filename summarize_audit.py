import sys, re
sys.stdout.reconfigure(encoding='utf-8')

with open('full_audit_results.txt', 'r', encoding='utf-8') as f:
    text = f.read()

# Let's see what stages have obvious typos or OCR errors
lines = text.splitlines()
curr_stage = ""
stage_errors = {}

for line in lines:
    if line.startswith("===================="):
        curr_stage = line.strip()
        stage_errors[curr_stage] = []
    elif line.strip():
        stage_errors[curr_stage].append(line.strip())

for stage, errs in stage_errors.items():
    print(f"\n{stage} (Total issues flagged: {len(errs)})")
    # Show first 10
    for e in errs[:8]:
        print("  " + e)
    if len(errs) > 8:
        print(f"  ... and {len(errs) - 8} more")
