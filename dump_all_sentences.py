import sys
import re

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

with open('all_sentences_detailed.txt', 'w', encoding='utf-8') as out:
    for idx, b in enumerate(stage_blocks):
        target = target_sounds[idx]
        id_val = get_field(b, 'id')
        sentences = get_list(b, 'sentences')
        out.write(f"\n==================== STAGE {idx+1}: /{target}/ ({id_val}) ====================\n")
        for s_idx, s in enumerate(sentences):
            out.write(f"[{s_idx+1}] {s}\n")

print("Dumped all sentences to all_sentences_detailed.txt")
