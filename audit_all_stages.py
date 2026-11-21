import sys, re
sys.stdout.reconfigure(encoding='utf-8')

with open('mobile/lib/data/sound_groups_data.dart', 'r', encoding='utf-8') as f:
    text = f.read()

# Load dictionaries
valid_words = set()
with open('turkish_wordlist.txt', 'r', encoding='utf-8') as f:
    for line in f:
        w = line.strip().split('/')[0].strip().replace('I', 'ı').replace('İ', 'i').lower()
        if w: valid_words.add(w)

with open('tr_50k.txt', 'r', encoding='utf-8') as f:
    for line in f:
        p = line.strip().split()
        if p:
            w = p[0].strip().replace('I', 'ı').replace('İ', 'i').lower()
            if w: valid_words.add(w)

stage_blocks = re.findall(r'SoundStage\((.*?)\n  \),', text, re.DOTALL)

def get_list(block, field):
    m = re.search(rf'{field}:\s*\[(.*?)\](?=\s*,\s*\w+:|\s*\))', block, re.DOTALL)
    if not m: return []
    items = re.findall(r"'((?:[^'\\]|\\.)*)'", m.group(1))
    return [i.replace(r"\'", "'").replace(r"\\", "\\").strip() for i in items]

def get_field(block, field):
    m = re.search(rf"{field}:\s*'((?:[^'\\]|\\.)*)'", block)
    return m.group(1) if m else ''

target_sounds = ['p', 'b', 't', 'd', 'k', 'g', 'f', 'v', 's', 'z', 'ş', 'j', 'h', 'ç', 'c', 'm', 'n', 'l', 'r', 'y']

out = []

for idx, b in enumerate(stage_blocks):
    target = target_sounds[idx]
    id_val = get_field(b, 'id')
    out.append(f"\n==================== STAGE {idx+1}: /{target}/ ({id_val}) ====================")
    
    # 1. Words lists
    for list_name in ['wordsBeginning', 'wordsMiddle', 'wordsEnding', 'words1Syllable', 'words2Syllables', 'words3Syllables']:
        words = get_list(b, list_name)
        for w in words:
            w_lower = w.lower()
            issues = []
            if target not in w_lower:
                issues.append(f"no_{target}")
            clean_word = re.sub(r"[^\w\s]", "", w_lower).strip()
            if clean_word not in valid_words:
                issues.append("not_in_dict")
            if issues:
                out.append(f"  [{list_name}] {w}: {', '.join(issues)}")

    # 2. Phrases
    phrases = get_list(b, 'phrases')
    for p in phrases:
        p_clean = re.sub(r"[^\w\s']", " ", p)
        tokens = p_clean.split()
        unknown_tokens = []
        for t in tokens:
            t_clean = t.split("'")[0].lower()
            if t_clean and t_clean not in valid_words:
                unknown_tokens.append(t)
        if unknown_tokens:
            out.append(f"  [PHRASE TYPO?] \"{p}\" -> unknown: {unknown_tokens}")

    # 3. Sentences
    sentences = get_list(b, 'sentences')
    for s in sentences:
        # Check for stuck apostrophe like İpek'iöptü
        if re.search(r"[a-zA-ZçğıöşüÇĞİÖŞÜ]'[a-zA-ZçğıöşüÇĞİÖŞÜ]+[a-zA-ZçğıöşüÇĞİÖŞÜ]", s):
            # check if there's no space after suffix
            m = re.search(r"(\w+'\w+)([A-ZÇĞİÖŞÜa-zçğıöşü]{2,})", s)
            if m:
                out.append(f"  [STUCK APOSTROPHE] \"{s}\" -> match: {m.group(0)}")
        s_clean = re.sub(r"[^\w\s']", " ", s)
        tokens = s_clean.split()
        unknown_tokens = []
        for t in tokens:
            t_clean = t.split("'")[0].lower()
            if t_clean and t_clean not in valid_words:
                unknown_tokens.append(t)
        if unknown_tokens:
            out.append(f"  [SENTENCE TYPO?] \"{s}\" -> unknown: {unknown_tokens}")

with open('full_audit_results.txt', 'w', encoding='utf-8') as f:
    f.write('\n'.join(out))

print(f"Audit completed. Total report lines: {len(out)}")
