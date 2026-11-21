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

target_sounds = ['p', 'b', 't', 'd', 'k', 'g', 'f', 'v', 's', 'z', 'ş', 'j', 'h', 'ç', 'c', 'm', 'n', 'l', 'r', 'y']

out = []
for idx, b in enumerate(stage_blocks):
    target = target_sounds[idx]
    phrases = get_list(b, 'phrases')
    sentences = get_list(b, 'sentences')
    out.append(f"\n==================== STAGE {idx+1}: /{target}/ ====================")
    out.append(f"--- PHRASES ({len(phrases)}) ---")
    for p in phrases:
        out.append(f"  '{p}'")
    out.append(f"--- SENTENCES ({len(sentences)}) ---")
    for s in sentences:
        out.append(f"  '{s}'")

with open('all_text.txt', 'w', encoding='utf-8') as f:
    f.write('\n'.join(out))

print("Written all_text.txt with utf-8 successfully.")
