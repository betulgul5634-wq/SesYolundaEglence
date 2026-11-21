import re

with open('turkish_wordlist.txt', 'r', encoding='utf-8') as f:
    valid_words = set(line.strip().split('/')[0].strip().replace('I', 'ı').replace('İ', 'i').lower() for line in f if line.strip())

with open('tr_50k.txt', 'r', encoding='utf-8') as f:
    for line in f:
        parts = line.strip().split()
        if parts:
            valid_words.add(parts[0].strip().replace('I', 'ı').replace('İ', 'i').lower())

with open('all_phrases_sentences.txt', 'r', encoding='utf-8') as f:
    lines = f.readlines()

current_stage = ""
for line in lines:
    line_s = line.strip()
    if line_s.startswith("=== STAGE"):
        current_stage = line_s
        print(f"\n{current_stage}")
        continue
    if line_s.startswith("---"):
        continue
    if not line_s:
        continue
        
    # Check words in this phrase/sentence
    # Clean up punctuation and split
    words = re.findall(r"[a-zA-ZçğıöşüÇĞİÖŞÜ]+", line_s)
    bad_in_line = []
    for w in words:
        clean = w.replace('I', 'ı').replace('İ', 'i').lower()
        # skip 1 letter words like 'o', 'e'
        if len(clean) <= 1:
            continue
        if clean not in valid_words:
            bad_in_line.append(w)
            
    if bad_in_line:
        print(f"  Line: {line_s}")
        print(f"    -> Unknown/typo words: {bad_in_line}")
