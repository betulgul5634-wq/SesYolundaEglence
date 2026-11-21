import re

with open('mobile/lib/data/sound_groups_data.dart', 'r', encoding='utf-8') as f:
    content = f.read()

sound_blocks = content.split('SoundStage(')[1:]

for i, block in enumerate(sound_blocks):
    sub = block.split('SoundStage(')[0]
    id_m = re.search(r"id:\s*['\"](.*?)['\"]", sub)
    p_m = re.search(r"phoneme:\s*['\"](.*?)['\"]", sub)
    story_t_m = re.search(r"storyTitle:\s*['\"](.*?)['\"]", sub)
    story_c_m = re.search(r"storyContent:\s*['\"](.*?)['\"]", sub)
    
    st_t = story_t_m.group(1) if story_t_m else "YOK"
    st_c_len = len(story_c_m.group(1)) if story_c_m else 0
    print(f"[{i+1:02d}] {id_m.group(1)} ({p_m.group(1)}): StoryTitle='{st_t}', ContentLen={st_c_len} chars")
