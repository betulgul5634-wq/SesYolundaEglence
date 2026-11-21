import re

f = open('mobile/lib/data/sound_groups_data.dart', encoding='utf-8').read()
stages = re.findall(r'SoundStage\((.*?)\n  \),', f, re.DOTALL)
for block in stages:
    p = re.search(r"phoneme:\s*'([^']+)'", block).group(1)
    end = re.search(r'wordsEnding:\s*\[(.*?)\]', block, re.DOTALL)
    end_words = re.findall(r"'([^']+)'", end.group(1)) if end else []
    print(f"{p}: wordsEnding count: {len(end_words)}, sample: {end_words[:4]}")
