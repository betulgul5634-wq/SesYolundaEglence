import re

file_path = 'mobile/lib/data/sound_groups_data.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    text = f.read()

# 1. /t/: Remove the added duplicate 'Timsah' in words2Syllables
# We added "\n        'Timsah'," right after "words2Syllables: ["
text = text.replace("words2Syllables: [\n        'Timsah',", "words2Syllables: [", 1)
print("[/t/] Removed duplicate 'Timsah' in words2Syllables")

# 2. /f/: DUPLICATE in beg: 'Fermuar'
f_stage_m = re.search(r"(id:\s*'sound_f'.*?storyTitle:)", text, re.DOTALL)
if f_stage_m:
    f_block = f_stage_m.group(0)
    beg_idx = f_block.find("wordsBeginning:")
    mid_idx = f_block.find("wordsMiddle:")
    beg_part = f_block[beg_idx:mid_idx]
    # Replace the duplicate Fermuar with 'Füze'
    parts = beg_part.split("'Fermuar'", 2)
    if len(parts) == 3:
        beg_part = parts[0] + "'Füze'" + parts[1] + "'Fermuar'" + parts[2]
        f_block = f_block[:beg_idx] + beg_part + f_block[mid_idx:]
        print("[/f/] Replaced duplicate 'Fermuar' with 'Füze'")
    text = text[:f_stage_m.start(0)] + f_block + text[f_stage_m.end(0):]

# 3. /z/:
z_stage_m = re.search(r"(id:\s*'sound_z'.*?storyTitle:)", text, re.DOTALL)
if z_stage_m:
    z_block = z_stage_m.group(0)
    beg_idx = z_block.find("wordsBeginning:")
    mid_idx = z_block.find("wordsMiddle:")
    beg_part = z_block[beg_idx:mid_idx]
    # In beg: duplicate 'Zurna' -> replace second with 'Zorba'
    parts = beg_part.split("'Zurna'", 2)
    if len(parts) == 3:
        beg_part = parts[0] + "'Zurna'" + parts[1] + "'Zorba'" + parts[2]
    # In beg: duplicate 'Zambak' -> replace second with 'Zümrüt'
    parts = beg_part.split("'Zambak'", 2)
    if len(parts) == 3:
        beg_part = parts[0] + "'Zambak'" + parts[1] + "'Zümrüt'" + parts[2]
    z_block = z_block[:beg_idx] + beg_part + z_block[mid_idx:]
    print("[/z/] Fixed beg duplicates ('Zurna' -> 'Zorba', 'Zambak' -> 'Zümrüt')")

    # In mid: duplicate 'Kuzu' -> replace second with 'Teyze'
    end_idx = z_block.find("wordsEnding:")
    mid_part = z_block[mid_idx:end_idx]
    parts = mid_part.split("'Kuzu'", 2)
    if len(parts) == 3:
        mid_part = parts[0] + "'Kuzu'" + parts[1] + "'Teyze'" + parts[2]
    z_block = z_block[:mid_idx] + mid_part + z_block[end_idx:]
    print("[/z/] Fixed mid duplicate 'Kuzu' -> 'Teyze'")

    # In s2: duplicate 'Zurna' -> replace second with 'Zorba'
    s2_idx = z_block.find("words2Syllables:")
    s3_idx = z_block.find("words3Syllables:")
    s2_part = z_block[s2_idx:s3_idx]
    parts = s2_part.split("'Zurna'", 2)
    if len(parts) == 3:
        s2_part = parts[0] + "'Zurna'" + parts[1] + "'Zorba'" + parts[2]
    # In s2: duplicate 'Kuzu' -> replace second with 'Teyze'
    parts = s2_part.split("'Kuzu'", 2)
    if len(parts) == 3:
        s2_part = parts[0] + "'Kuzu'" + parts[1] + "'Teyze'" + parts[2]
    z_block = z_block[:s2_idx] + s2_part + z_block[s3_idx:]
    print("[/z/] Fixed s2 duplicates ('Zurna' -> 'Zorba', 'Kuzu' -> 'Teyze')")

    # In s3: duplicate 'Ziyaret' -> replace second with 'Zamanlı'
    phr_idx = z_block.find("phrasesBeginning:")
    s3_part = z_block[s3_idx:phr_idx]
    parts = s3_part.split("'Ziyaret'", 2)
    if len(parts) == 3:
        s3_part = parts[0] + "'Ziyaret'" + parts[1] + "'Zamanlı'" + parts[2]
    z_block = z_block[:s3_idx] + s3_part + z_block[phr_idx:]
    print("[/z/] Fixed s3 duplicate 'Ziyaret' -> 'Zamanlı'")

    text = text[:z_stage_m.start(0)] + z_block + text[z_stage_m.end(0):]

# 4. /ş/: 'Şamandıra' has 4 syllables! Replace with 'Şaşkınlık' (3 syllables) in s3, and with 'Şaşkın' in beg
sh_stage_m = re.search(r"(id:\s*'sound_ş'.*?storyTitle:)", text, re.DOTALL)
if sh_stage_m:
    sh_block = sh_stage_m.group(0)
    beg_idx = sh_block.find("wordsBeginning:")
    mid_idx = sh_block.find("wordsMiddle:")
    beg_part = sh_block[beg_idx:mid_idx]
    beg_part = beg_part.replace("'Şamandıra'", "'Şaşkın'")
    sh_block = sh_block[:beg_idx] + beg_part + sh_block[mid_idx:]
    
    s3_idx = sh_block.find("words3Syllables:")
    phr_idx = sh_block.find("phrasesBeginning:")
    s3_part = sh_block[s3_idx:phr_idx]
    s3_part = s3_part.replace("'Şamandıra'", "'Şaşkınlık'")
    sh_block = sh_block[:s3_idx] + s3_part + sh_block[phr_idx:]
    print("[/ş/] Fixed 'Şamandıra' -> 'Şaşkın' in beg and 'Şaşkınlık' in s3")
    
    text = text[:sh_stage_m.start(0)] + sh_block + text[sh_stage_m.end(0):]

# 5. /h/: duplicate 'Halka' in beg, duplicate 'Havuç' in s2
h_stage_m = re.search(r"(id:\s*'sound_h'.*?storyTitle:)", text, re.DOTALL)
if h_stage_m:
    h_block = h_stage_m.group(0)
    beg_idx = h_block.find("wordsBeginning:")
    mid_idx = h_block.find("wordsMiddle:")
    beg_part = h_block[beg_idx:mid_idx]
    parts = beg_part.split("'Halka'", 2)
    if len(parts) == 3:
        beg_part = parts[0] + "'Halka'" + parts[1] + "'Hırka'" + parts[2]
    h_block = h_block[:beg_idx] + beg_part + h_block[mid_idx:]
    print("[/h/] Fixed duplicate 'Halka' -> 'Hırka' in wordsBeginning")
    
    s2_idx = h_block.find("words2Syllables:")
    s3_idx = h_block.find("words3Syllables:")
    s2_part = h_block[s2_idx:s3_idx]
    parts = s2_part.split("'Havuç'", 2)
    if len(parts) == 3:
        s2_part = parts[0] + "'Havuç'" + parts[1] + "'Hırka'" + parts[2]
    h_block = h_block[:s2_idx] + s2_part + h_block[s3_idx:]
    print("[/h/] Fixed duplicate 'Havuç' -> 'Hırka' in words2Syllables")
    
    text = text[:h_stage_m.start(0)] + h_block + text[h_stage_m.end(0):]

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(text)

print("\nSUCCESS: All remaining sound issues resolved!")
