import sys, re
sys.stdout.reconfigure(encoding='utf-8')

with open('mobile/lib/data/sound_groups_data.dart', 'r', encoding='utf-8') as f:
    text = f.read()

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

with open('all_stages_detail.txt', 'w', encoding='utf-8') as out:
    for idx, b in enumerate(stage_blocks):
        target = target_sounds[idx]
        id_val = get_field(b, 'id')
        name = get_field(b, 'name')
        out.write(f"\n==================== STAGE {idx+1}: /{target}/ ({id_val}) ====================\n")
        for fld in ['wordsBeginning', 'wordsMiddle', 'wordsEnding', 'words1Syllable', 'words2Syllables', 'words3Syllables']:
            wlist = get_list(b, fld)
            out.write(f"--- {fld} ({len(wlist)}) ---\n")
            out.write(", ".join(wlist) + "\n")
        
        phrases = get_list(b, 'phrases')
        out.write(f"--- PHRASES ({len(phrases)}) ---\n")
        for i, p in enumerate(phrases):
            out.write(f"P{i+1}: {p}\n")
            
        sentences = get_list(b, 'sentences')
        out.write(f"--- SENTENCES ({len(sentences)}) ---\n")
        for i, s in enumerate(sentences):
            out.write(f"S{i+1}: {s}\n")

print("Dumped all stages detail to all_stages_detail.txt")
