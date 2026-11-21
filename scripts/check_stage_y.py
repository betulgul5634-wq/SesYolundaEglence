with open('mobile/lib/data/sound_groups_data.dart', 'r', encoding='utf-8') as f:
    text = f.read()

idx = text.find("id: 'sound_y'")
idx_story = text.find('storyTitle', idx)
print(text[idx_story:idx_story+800])
