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

# Common Turkish words that frequently have 's' where 'ş' should be
common_sh_patterns = [
    r'\bsas\w*', r'\bsakal\w*', r'\bseker\w*', r'\bsofor\w*', r'\bkumas\w*',
    r'\bkose\w*', r'\bkosu\w*', r'\bkostu\w*', r'\bpes\b', r'\bpesin\w*',
    r'\btas\b', r'\btasa\b', r'\bbas\b', r'\bbasi\w*', r'\byas\b', r'\byasi\w*',
    r'\bkasin\w*', r'\bsise\w*', r'\bsapka\w*', r'\bsampuan\w*', r'\bsomine\w*',
    r'\bsule\w*', r'\byaris\w*', r'\bsisir\w*', r'\bsisman\w*', r'\bsort\w*',
    r'\bsirine\w*', r'\bsirin\w*', r'\bsengul\w*', r'\benistem\w*', r'\bsovalye\w*',
    r'\basagi\w*', r'\bsimarik\w*', r'\bseftali\w*', r'\bsampiyon\w*',
    r'\bkus\b', r'\bkusa\b', r'\bkusu\b', r'\bdis\b', r'\bdisi\b',
    r'\bgorusme\w*', r'\bduzenlenmis\w*', r'\bgelmis\w*', r'\bgitmis\w*',
    r'\byazmis\w*', r'\bokumus\w*', r'\bolmus\w*', r'\bkalmis\w*',
    r'\bvermis\w*', r'\balmis\w*', r'\bduymus\w*', r'\bbulmus\w*',
    r'\bbulanmis\w*', r'\bdegismis\w*', r'\bbitmis\w*', r'\bdus\w*',
    r'\bagac\w*', r'\bcicek\w*', r'\bcalis\w*', r'\bcik\w*'
]

out = []

for idx, b in enumerate(stage_blocks):
    target = target_sounds[idx]
    id_val = get_field(b, 'id')
    sentences = get_list(b, 'sentences')
    stage_header = f"=== STAGE {idx+1}: /{target}/ ({id_val}) ==="
    stage_out = []
    for s_idx, s in enumerate(sentences):
        # Check against patterns
        matches = []
        for pat in common_sh_patterns:
            m = re.findall(pat, s, re.IGNORECASE)
            if m:
                # filter out false positives like 'tas' in 'tas' (tası -> tas/tasarruf? No, in Turkish tas is bowl, but let's check)
                matches.extend(m)
        if matches:
            stage_out.append(f"  [{s_idx+1}] {s}  --> Matches: {matches}")
    if stage_out:
        out.append(stage_header)
        out.extend(stage_out)

print('\n'.join(out))
