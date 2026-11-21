import re

with open('mobile/lib/data/sound_groups_data.dart', 'r', encoding='utf-8') as f:
    text = f.read()

stages = text.split('SoundStage(')[1:]
print(f"{'Phoneme':<8} {'Story Title':<35} {'Len':<6} {'Sentences':<10} {'Content Preview'}")
print("-" * 80)

for s in stages:
    sub = s.split('SoundStage(')[0]
    p_m = re.search(r"phoneme:\s*['\"](.*?)['\"]", sub)
    title_m = re.search(r"storyTitle:\s*['\"](.*?)['\"]", sub)
    
    # storyContent can be single quote or multiline with backslashes
    # Find storyContent: '...'
    sc_start = sub.find("storyContent:")
    content = ""
    if sc_start != -1:
        # find the end of content
        rest = sub[sc_start + len("storyContent:"):].strip()
        quote_char = rest[0]
        # find matching end quote that isn't escaped
        end_idx = 1
        while end_idx < len(rest):
            if rest[end_idx] == quote_char and rest[end_idx-1] != '\\':
                break
            end_idx += 1
        content = rest[1:end_idx]
    
    # sentences count
    sent_m = re.search(r"sentences:\s*\[(.*?)\]", sub, re.DOTALL)
    sent_count = 0
    if sent_m:
        sents = [x.strip() for x in sent_m.group(1).split("',") if x.strip()]
        sent_count = len(sents)

    ph = p_m.group(1) if p_m else '?'
    title = title_m.group(1) if title_m else 'YOK'
    preview = content.replace('\n', ' ')[:40]
    print(f"{ph:<8} {title:<35} {len(content):<6} {sent_count:<10} {preview}...")
