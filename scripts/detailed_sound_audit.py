import re

with open('mobile/lib/data/sound_groups_data.dart', encoding='utf-8') as f:
    content = f.read()

stages = re.findall(r"SoundStage\((.*?)\n  \),", content, re.DOTALL)

vowels = set('aeıioöuüAEIİOÖUÜ')
def count_syllables(w):
    return sum(1 for c in w if c in vowels)

def get_list(block, name):
    m = re.search(name + r':\s*\[(.*?)\]', block, re.DOTALL)
    if not m: return []
    return re.findall(r"'([^']+)'", m.group(1))

def get_val(block, name):
    m = re.search(name + r":\s*'([^']+)'", block)
    return m.group(1) if m else ''

report = []

for block in stages:
    phoneme = get_val(block, 'phoneme')
    letter = get_val(block, 'soundLetter').lower()
    
    beg = get_list(block, 'wordsBeginning')
    mid = get_list(block, 'wordsMiddle')
    end = get_list(block, 'wordsEnding')
    s1 = get_list(block, 'words1Syllable')
    s2 = get_list(block, 'words2Syllables')
    s3 = get_list(block, 'words3Syllables')
    
    issues = []
    
    # Check invalid words in beg
    for w in beg:
        if not w.lower().startswith(letter):
            if not (letter == 'i' and w.lower().startswith('i')) and not (letter == 'ı' and w.lower().startswith('ı')):
                issues.append(f"BEG INVALID: '{w}' does not start with '{letter}'")
                
    # Check invalid words in mid
    for w in mid:
        inner = w.lower()[1:-1]
        if letter not in inner:
            issues.append(f"MID INVALID: '{w}' does not contain '{letter}' in middle")
            
    # Check invalid words in end
    for w in end:
        if not w.lower().endswith(letter):
            issues.append(f"END INVALID: '{w}' does not end with '{letter}'")
            
    # Check syllable counts
    for w in s1:
        c = count_syllables(w)
        if c != 1:
            issues.append(f"SYL1 ERROR: '{w}' has {c} syllables")
    for w in s2:
        c = count_syllables(w)
        if c != 2:
            issues.append(f"SYL2 ERROR: '{w}' has {c} syllables")
    for w in s3:
        c = count_syllables(w)
        if c != 3:
            issues.append(f"SYL3 ERROR: '{w}' has {c} syllables")
            
    # Check letter in syllable lists!
    for w in s1 + s2 + s3:
        if letter not in w.lower():
            issues.append(f"SYL WORD MISSING TARGET PHONEME: '{w}' does not contain '{letter}'")
            
    # Check duplicates within each list
    for name, lst in [('beg', beg), ('mid', mid), ('end', end), ('s1', s1), ('s2', s2), ('s3', s3)]:
        seen = set()
        for w in lst:
            if w in seen:
                issues.append(f"DUPLICATE in {name}: '{w}'")
            seen.add(w)
            
    if issues:
        report.append(f"=== {phoneme} ({len(issues)} issues) ===")
        for iss in issues:
            report.append("  - " + iss)

print("\n".join(report))
print(f"\nTotal stages with issues: {len(report)}")
