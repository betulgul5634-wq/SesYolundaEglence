import sys, re
sys.stdout.reconfigure(encoding='utf-8')

with open('mobile/lib/data/sound_groups_data.dart', 'r', encoding='utf-8') as f:
    text = f.read()

stage_blocks = re.findall(r'SoundStage\((.*?)\n  \),', text, re.DOTALL)

def get_field(block, field):
    m = re.search(rf"{field}:\s*'((?:[^'\\]|\\.)*)'", block)
    return m.group(1) if m else ''

target_sounds = ['p', 'b', 't', 'd', 'k', 'g', 'f', 'v', 's', 'z', 'ş', 'j', 'h', 'ç', 'c', 'm', 'n', 'l', 'r', 'y']

for idx, b in enumerate(stage_blocks):
    target = target_sounds[idx]
    id_val = get_field(b, 'id')
    story_title = get_field(b, 'storyTitle')
    story_content = get_field(b, 'storyContent')
    print(f"\n=== STAGE {idx+1}: /{target}/ ({story_title}) ===")
    print(story_content[:400] + "...")
