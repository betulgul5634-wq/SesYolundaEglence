import re

STAGE_CONSONANTS = [
    ('sound_p', 'p'),
    ('sound_b', 'b'),
    ('sound_t', 't'),
    ('sound_d', 'd'),
    ('sound_k', 'k'),
    ('sound_g', 'g'),
    ('sound_f', 'f'),
    ('sound_v', 'v'),
    ('sound_s', 's'),
    ('sound_z', 'z'),
    ('sound_ş', 'ş'),
    ('sound_j', 'j'),
    ('sound_h', 'h'),
    ('sound_ç', 'ç'),
    ('sound_c', 'c'),
    ('sound_m', 'm'),
    ('sound_n', 'n'),
    ('sound_l', 'l'),
    ('sound_r', 'r'),
    ('sound_y', 'y'),
]

vowels = ['a', 'e', 'ı', 'i', 'o', 'ö', 'u', 'ü']

def build_syllables_code(c):
    cv = [f"{c}{v}" for v in vowels]
    vc = [f"{v}{c}" for v in vowels]
    vcv = [f"{v}{c}{v}" for v in vowels]
    cvc = [f"{c}{v}{c}" for v in vowels]
    all_32 = cv + vc + vcv + cvc
    
    lines = ["      syllables: ["]
    for s in all_32:
        lines.append(f"        '{s}',")
    lines.append("      ],")
    return "\n".join(lines)

with open('mobile/lib/data/sound_groups_data.dart', 'r', encoding='utf-8') as f:
    text = f.read()

# For each stage, replace syllables: [ ... ] within that stage's block
for sid, c in STAGE_CONSONANTS:
    # Match the block starting with id: 'sound_x' up to the next SoundStage or end
    # We find id: 'sid' ... syllables: [ ... ]
    pattern = rf"(id:\s*['\"]{sid}['\"][\s\S]*?)(syllables:\s*\[[\s\S]*?\]\,)"
    match = re.search(pattern, text)
    if not match:
        print(f"ERROR: Could not find block for {sid}")
        continue
    
    new_syl_code = build_syllables_code(c)
    text = text[:match.start(2)] + new_syl_code + text[match.end(2):]
    print(f"Standardized {sid} (/ {c} /) -> 32 syllables")

with open('mobile/lib/data/sound_groups_data.dart', 'w', encoding='utf-8') as f:
    f.write(text)

print("\nSuccessfully updated mobile/lib/data/sound_groups_data.dart!")
