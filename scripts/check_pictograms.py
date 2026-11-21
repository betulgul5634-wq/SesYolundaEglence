import re

with open('mobile/lib/data/sound_groups_data.dart', encoding='utf-8') as f:
    sg_content = f.read()

with open('mobile/lib/utils/word_pictogram_helper.dart', encoding='utf-8') as f:
    dict_content = f.read()

# Extract all words in sound groups
all_words = set(re.findall(r"'([A-ZÇĞİÖŞÜa-zçğıöşü]+)'", sg_content))
# Filter out non-word items (stage ids, properties, etc.)
all_words = {w for w in all_words if len(w) > 1 and not w.startswith('sound_') and not w.startswith('char_')}

dict_words = set(re.findall(r"'([A-ZÇĞİÖŞÜa-zçğıöşü]+)':", dict_content))

missing = []
for w in sorted(all_words):
    if w.lower() not in {dw.lower() for dw in dict_words}:
        missing.append(w)

print(f"Total unique words in sound_groups: {len(all_words)}")
print(f"Total keys in pictogram dict: {len(dict_words)}")
print(f"Missing pictogram words: {len(missing)}")
print("Sample missing words (first 30):", missing[:30])
