import re

with open('mobile/lib/data/sound_groups_data.dart', 'r', encoding='utf-8') as f:
    text = f.read()

# Let's find every occurrence of storyTitle and storyContent
for m in re.finditer(r"storyTitle:\s*(.*?),\s*storyContent:\s*(.*?),\s*(words1Syllable|phrases)", text, re.DOTALL):
    title = m.group(1).strip()
    content = m.group(2).strip()
    print(f"TITLE: {title}")
    print(f"CONTENT: {content[:60]}... (Total: {len(content)})")
    print("-" * 50)
