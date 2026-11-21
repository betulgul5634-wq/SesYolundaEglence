import re

with open('mobile/lib/data/sound_groups_data.dart', 'r', encoding='utf-8') as f:
    text = f.read()

# Extract wordsBeginning, wordsMiddle, wordsEnding
words_raw = re.findall(r"words(?:Beginning|Middle|Ending):\s*\[(.*?)\]", text, re.DOTALL)
all_words = set()
for wr in words_raw:
    w_list = [w.strip().strip("'\"") for w in wr.split(',') if w.strip().strip("'\"")]
    for w in w_list:
        if len(w) > 1 and not w.startswith('//'):
            all_words.add(w.lower())

print(f"Total unique target words across all stages: {len(all_words)}")

with open('mobile/lib/utils/word_pictogram_helper.dart', 'r', encoding='utf-8') as f:
    dict_text = f.read()

dict_keys = set(re.findall(r"['\"]([\wığüşöçİĞÜŞÖÇ]+)['\"]\s*:\s*['\"]([^'\"]+)['\"]", dict_text))
dict_words = {k.lower() for k, v in dict_keys}

unmatched = []
for w in sorted(all_words):
    if w in dict_words:
        continue
    # check prefix
    matched = False
    for dw in dict_words:
        if w.startswith(dw) and len(w) <= len(dw) + 4:
            matched = True
            break
        if dw in w and len(dw) >= 3:
            matched = True
            break
    if not matched:
        unmatched.append(w)

print(f"Unmatched words count: {len(unmatched)}")
with open('unmatched_words.txt', 'w', encoding='utf-8') as f:
    for w in unmatched:
        f.write(w + '\n')
print("Wrote unmatched words to unmatched_words.txt")
