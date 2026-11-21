import re

with open('mobile/lib/data/sound_groups_data.dart', encoding='utf-8') as f:
    sg_content = f.read()

with open('mobile/lib/utils/word_pictogram_helper.dart', encoding='utf-8') as f:
    dict_content = f.read()

stages = re.findall(r"SoundStage\((.*?)\n  \),", sg_content, re.DOTALL)
dict_words = set(re.findall(r"'([A-ZÇĞİÖŞÜa-zçğıöşü]+)':", dict_content))
dict_words_lower = {w.lower() for w in dict_words}

def get_list(block, name):
    m = re.search(name + r':\s*\[(.*?)\]', block, re.DOTALL)
    if not m: return []
    return re.findall(r"'([^']+)'", m.group(1))

def get_val(block, name):
    m = re.search(name + r":\s*'([^']+)'", block)
    return m.group(1) if m else ''

print(f"{'Sound':<8} {'Total Words':<12} {'Exact Matched':<15} {'Missing/Fallback':<18} {'Coverage %':<10}")
print("-" * 65)

for block in stages:
    phoneme = get_val(block, 'phoneme')
    letter = get_val(block, 'soundLetter')
    beg = get_list(block, 'wordsBeginning')
    mid = get_list(block, 'wordsMiddle')
    end = get_list(block, 'wordsEnding')
    
    unique_words = list(dict.fromkeys(beg + mid + end))
    matched = [w for w in unique_words if w.lower() in dict_words_lower]
    missing = [w for w in unique_words if w.lower() not in dict_words_lower]
    
    pct = (len(matched) / len(unique_words) * 100) if unique_words else 0
    print(f"{phoneme:<8} {len(unique_words):<12} {len(matched):<15} {len(missing):<18} {pct:.1f}%")
