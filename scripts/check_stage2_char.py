import re

files = [
    'mobile/lib/widgets/subway_surfers_unlock_dialog.dart',
    'mobile/lib/models/reward_state.dart',
    'mobile/lib/data/sound_groups_data.dart'
]

for fpath in files:
    with open(fpath, encoding='utf-8') as f:
        txt = f.read()
    print(f"=== {fpath} ===")
    for line in txt.splitlines():
        if 'sound_b' in line or 'char_' in line or 'Stage 2' in line or 'soundLetter: \'B\'' in line:
            print(" ", line.strip())
