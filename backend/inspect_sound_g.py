with open('mobile/lib/data/sound_groups_data.dart', 'r', encoding='utf-8') as f:
    lines = f.readlines()

in_g = False
for i, line in enumerate(lines):
    if "'sound_g'" in line or '"sound_g"' in line or "phoneme: '/g/'" in line:
        in_g = True
        print(f"Start G at line {i+1}")
    if in_g:
        print(line, end='')
        if "SoundStage(" in line and i > 370:
            break
        if i > 460:
            break
