import re

f1 = open('mobile/lib/data/sound_groups_data.dart', encoding='utf-8').read()

# Split into stages by "SoundStage("
stage_blocks = re.findall(r"SoundStage\((.*?)\n  \),", f1, re.DOTALL)
print(f"Total stages found: {len(stage_blocks)}")

vowels = set('aeıioöuüAEIİOÖUÜ')
def count_syllables(w):
    return sum(1 for c in w if c in vowels)

def get_field_list(block, name):
    m = re.search(name + r':\s*\[(.*?)\]', block, re.DOTALL)
    if not m: return []
    return re.findall(r"'([^']+)'", m.group(1))

def get_field_val(block, name):
    m = re.search(name + r":\s*'([^']+)'", block)
    return m.group(1) if m else ''

total_issues = 0

for idx, block in enumerate(stage_blocks):
    phoneme = get_field_val(block, 'phoneme')
    letter = get_field_val(block, 'soundLetter')
    clean_p = letter.lower()
    
    beg = get_field_list(block, 'wordsBeginning')
    mid = get_field_list(block, 'wordsMiddle')
    end = get_field_list(block, 'wordsEnding')
    syl1 = get_field_list(block, 'words1Syllable')
    syl2 = get_field_list(block, 'words2Syllables')
    syl3 = get_field_list(block, 'words3Syllables')
    
    # 1. Check duplicates
    for name, lst in [('beg', beg), ('mid', mid), ('end', end), ('syl1', syl1), ('syl2', syl2), ('syl3', syl3)]:
        seen = set()
        dups = []
        for w in lst:
            if w in seen:
                dups.append(w)
            seen.add(w)
        if dups:
            print(f"[{phoneme}] DUPLICATES in {name}: {dups}")
            total_issues += len(dups)

    # 2. Check position validity
    for w in beg:
        w_lower = w.lower()
        if not w_lower.startswith(clean_p):
            # Turkish dotted/dotless check
            if not (clean_p == 'i' and w_lower.startswith('i')) and not (clean_p == 'ı' and w_lower.startswith('ı')):
                print(f"[{phoneme}] BEG INVALID: '{w}' does not start with '{clean_p}'!")
                total_issues += 1
                
    for w in end:
        w_lower = w.lower()
        if not w_lower.endswith(clean_p):
            print(f"[{phoneme}] END INVALID: '{w}' does not end with '{clean_p}'!")
            total_issues += 1

    for w in mid:
        w_lower = w.lower()
        inner = w_lower[1:-1]
        if clean_p not in inner:
            print(f"[{phoneme}] MID INVALID: '{w}' does not contain '{clean_p}' in middle!")
            total_issues += 1

    # 3. Check syllable counts
    for w in syl1:
        c = count_syllables(w)
        if c != 1:
            print(f"[{phoneme}] SYL1 ERROR: '{w}' has {c} syllables, expected 1!")
            total_issues += 1

    for w in syl2:
        c = count_syllables(w)
        if c != 2:
            print(f"[{phoneme}] SYL2 ERROR: '{w}' has {c} syllables, expected 2!")
            total_issues += 1

    for w in syl3:
        c = count_syllables(w)
        if c != 3:
            print(f"[{phoneme}] SYL3 ERROR: '{w}' has {c} syllables, expected 3!")
            total_issues += 1

    # 4. Check whether words in beg/mid/end are missing from syllable lists
    all_syl = set(syl1 + syl2 + syl3)
    all_pos = set(beg + mid + end)
    missing_from_syl = [w for w in all_pos if w not in all_syl]
    if missing_from_syl:
        print(f"[{phoneme}] WORDS IN POS BUT NOT IN SYL LISTS: {missing_from_syl}")
        total_issues += len(missing_from_syl)

print(f"\nAUDIT COMPLETE. Total issues found: {total_issues}")
