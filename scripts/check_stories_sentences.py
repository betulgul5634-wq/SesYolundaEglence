import re

with open('mobile/lib/data/sound_groups_data.dart', encoding='utf-8') as f:
    content = f.read()

stages = re.findall(r"SoundStage\((.*?)\n  \),", content, re.DOTALL)

def get_val(block, name):
    m = re.search(name + r":\s*'([^']*)'", block)
    return m.group(1) if m else ''

def get_list(block, name):
    m = re.search(name + r':\s*\[(.*?)\]', block, re.DOTALL)
    if not m: return []
    return re.findall(r"'([^']*)'", m.group(1))

for block in stages:
    p = get_val(block, 'phoneme')
    letter = get_val(block, 'soundLetter')
    title = get_val(block, 'storyTitle')
    story = get_val(block, 'storyContent')
    sents = get_list(block, 'sentences')
    phrases = get_list(block, 'phrases')
    syls = get_list(block, 'syllables')
    
    print(f"Stage {letter} ({p}): storyTitle='{title}', storyLen={len(story)}, sentences={len(sents)}, phrases={len(phrases)}, syllables={len(syls)}")
    if not title or len(story) < 50:
        print(f"  WARNING: Story missing or too short in {p}!")
    if len(sents) < 5:
        print(f"  WARNING: Sentences count low ({len(sents)}) in {p}!")
    if len(phrases) < 5:
        print(f"  WARNING: Phrases count low ({len(phrases)}) in {p}!")
    if len(syls) < 10:
        print(f"  WARNING: Syllables count low ({len(syls)}) in {p}!")
