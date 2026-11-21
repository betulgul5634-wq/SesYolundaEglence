import re

file_path = 'mobile/lib/data/sound_groups_data.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    text = f.read()

# Let's verify stages by split or regex and do surgical updates.
# 1. /b/ stage fixes
# Empty wordsEnding
b_ending_pattern = r"(id:\s*'sound_b'.*?wordsEnding:\s*\[)(.*?)(\],\s*words1Syllable:)"
m_b = re.search(b_ending_pattern, text, re.DOTALL)
if m_b:
    text = text[:m_b.start(2)] + "\n      " + text[m_b.end(2):]
    print("[/b/] Cleared wordsEnding to []")

# In /b/ words2Syllables: replace 'Fırça' with 'Bebek'
# In /b/ words3Syllables: replace 'Timsah' with 'Biberon'
# In /b/ wordsBeginning: replace second 'Balon' with 'Boru'
# In /b/ wordsMiddle: replace second 'Kelebek' with 'Tabanca'

b_stage_m = re.search(r"(id:\s*'sound_b'.*?storyTitle:)", text, re.DOTALL)
if b_stage_m:
    b_block = b_stage_m.group(0)
    # Replace second Balon
    parts = b_block.split("'Balon'", 2)
    if len(parts) == 3:
        b_block = parts[0] + "'Balon'" + parts[1] + "'Boru'" + parts[2]
        print("[/b/] Replaced duplicate 'Balon' with 'Boru'")
    # Replace second Kelebek in middle
    # Middle starts with wordsMiddle
    mid_idx = b_block.find("wordsMiddle:")
    syl3_idx = b_block.find("words3Syllables:")
    mid_part = b_block[mid_idx:syl3_idx]
    k_parts = mid_part.split("'Kelebek'", 2)
    if len(k_parts) == 3:
        mid_part = k_parts[0] + "'Kelebek'" + k_parts[1] + "'Tabanca'" + k_parts[2]
        b_block = b_block[:mid_idx] + mid_part + b_block[syl3_idx:]
        print("[/b/] Replaced duplicate 'Kelebek' in wordsMiddle with 'Tabanca'")
    
    # Replace 'Fırça' with 'Bebek' in words2Syllables
    syl2_idx = b_block.find("words2Syllables:")
    syl3_idx = b_block.find("words3Syllables:")
    syl2_part = b_block[syl2_idx:syl3_idx]
    syl2_part = syl2_part.replace("'Fırça'", "'Bebek'")
    b_block = b_block[:syl2_idx] + syl2_part + b_block[syl3_idx:]
    print("[/b/] Replaced 'Fırça' in words2Syllables with 'Bebek'")
    
    # Replace 'Timsah' with 'Biberon' in words3Syllables
    end_idx = b_block.find("phrasesBeginning:")
    syl3_part = b_block[syl3_idx:end_idx]
    syl3_part = syl3_part.replace("'Timsah'", "'Barikat'")
    b_block = b_block[:syl3_idx] + syl3_part + b_block[end_idx:]
    print("[/b/] Replaced 'Timsah' in words3Syllables with 'Barikat'")
    
    text = text[:b_stage_m.start(0)] + b_block + text[b_stage_m.end(0):]

# 2. /t/ stage fixes
# Replace second 'Timsah' in wordsBeginning with 'Tenisçi'
# Replace 'Timsah' in words3Syllables with 'Tenisçi'
t_stage_m = re.search(r"(id:\s*'sound_t'.*?storyTitle:)", text, re.DOTALL)
if t_stage_m:
    t_block = t_stage_m.group(0)
    beg_idx = t_block.find("wordsBeginning:")
    mid_idx = t_block.find("wordsMiddle:")
    beg_part = t_block[beg_idx:mid_idx]
    t_parts = beg_part.split("'Timsah'", 2)
    if len(t_parts) == 3:
        beg_part = t_parts[0] + "'Timsah'" + t_parts[1] + "'Tenisçi'" + t_parts[2]
        t_block = t_block[:beg_idx] + beg_part + t_block[mid_idx:]
        print("[/t/] Replaced duplicate 'Timsah' in wordsBeginning with 'Tenisçi'")
        
    s3_idx = t_block.find("words3Syllables:")
    phr_idx = t_block.find("phrasesBeginning:")
    s3_part = t_block[s3_idx:phr_idx]
    s3_part = s3_part.replace("'Timsah'", "'Tenisçi'")
    t_block = t_block[:s3_idx] + s3_part + t_block[phr_idx:]
    print("[/t/] Replaced 'Timsah' in words3Syllables with 'Tenisçi'")
    
    # Also add 'Timsah' to words2Syllables
    s2_idx = t_block.find("words2Syllables:")
    t_block = t_block[:s2_idx + len("words2Syllables: [")] + "\n        'Timsah'," + t_block[s2_idx + len("words2Syllables: ["):]
    print("[/t/] Added 'Timsah' to words2Syllables")
    
    text = text[:t_stage_m.start(0)] + t_block + text[t_stage_m.end(0):]

# 3. /k/ stage fixes
# In wordsBeginning: replace second 'Kar' with 'Kol'
# In words1Syllable: replace second 'Kar' with 'Kol'
k_stage_m = re.search(r"(id:\s*'sound_k'.*?storyTitle:)", text, re.DOTALL)
if k_stage_m:
    k_block = k_stage_m.group(0)
    beg_idx = k_block.find("wordsBeginning:")
    mid_idx = k_block.find("wordsMiddle:")
    beg_part = k_block[beg_idx:mid_idx]
    parts = beg_part.split("'Kar'", 2)
    if len(parts) == 3:
        beg_part = parts[0] + "'Kar'" + parts[1] + "'Kol'" + parts[2]
        k_block = k_block[:beg_idx] + beg_part + k_block[mid_idx:]
        print("[/k/] Replaced second 'Kar' in wordsBeginning with 'Kol'")
        
    s1_idx = k_block.find("words1Syllable:")
    s2_idx = k_block.find("words2Syllables:")
    s1_part = k_block[s1_idx:s2_idx]
    parts = s1_part.split("'Kar'", 2)
    if len(parts) == 3:
        s1_part = parts[0] + "'Kar'" + parts[1] + "'Kol'" + parts[2]
        k_block = k_block[:s1_idx] + s1_part + k_block[s2_idx:]
        print("[/k/] Replaced second 'Kar' in words1Syllable with 'Kol'")
        
    text = text[:k_stage_m.start(0)] + k_block + text[k_stage_m.end(0):]

# 4. /g/ stage fixes
# Replace 'Şelale' in wordsMiddle with 'Bölge'
# Replace 'Şelale' in words3Syllables with 'Sigara'
g_stage_m = re.search(r"(id:\s*'sound_g'.*?storyTitle:)", text, re.DOTALL)
if g_stage_m:
    g_block = g_stage_m.group(0)
    mid_idx = g_block.find("wordsMiddle:")
    end_idx = g_block.find("wordsEnding:")
    mid_part = g_block[mid_idx:end_idx]
    mid_part = mid_part.replace("'Şelale'", "'Bölge'")
    g_block = g_block[:mid_idx] + mid_part + g_block[end_idx:]
    print("[/g/] Replaced 'Şelale' in wordsMiddle with 'Bölge'")
    
    s3_idx = g_block.find("words3Syllables:")
    phr_idx = g_block.find("phrasesBeginning:")
    s3_part = g_block[s3_idx:phr_idx]
    s3_part = s3_part.replace("'Şelale'", "'Sigara'")
    g_block = g_block[:s3_idx] + s3_part + g_block[phr_idx:]
    print("[/g/] Replaced 'Şelale' in words3Syllables with 'Sigara'")
    
    text = text[:g_stage_m.start(0)] + g_block + text[g_stage_m.end(0):]

# 5. /f/ stage fixes
f_stage_m = re.search(r"(id:\s*'sound_f'.*?storyTitle:)", text, re.DOTALL)
if f_stage_m:
    f_block = f_stage_m.group(0)
    beg_idx = f_block.find("wordsBeginning:")
    mid_idx = f_block.find("wordsMiddle:")
    beg_part = f_block[beg_idx:mid_idx]
    # Replace second 'Fıstık' with 'Fermuar'
    parts = beg_part.split("'Fıstık'", 2)
    if len(parts) == 3:
        beg_part = parts[0] + "'Fıstık'" + parts[1] + "'Fermuar'" + parts[2]
    # Replace second 'Fiş' with 'Fosil'
    parts = beg_part.split("'Fiş'", 2)
    if len(parts) == 3:
        beg_part = parts[0] + "'Fiş'" + parts[1] + "'Fosil'" + parts[2]
    f_block = f_block[:beg_idx] + beg_part + f_block[mid_idx:]
    print("[/f/] Fixed duplicates in wordsBeginning")
    
    # In wordsMiddle: replace second 'Büfe' with 'Teflon'
    end_idx = f_block.find("wordsEnding:")
    mid_part = f_block[mid_idx:end_idx]
    parts = mid_part.split("'Büfe'", 2)
    if len(parts) == 3:
        mid_part = parts[0] + "'Büfe'" + parts[1] + "'Teflon'" + parts[2]
    f_block = f_block[:mid_idx] + mid_part + f_block[end_idx:]
    print("[/f/] Fixed duplicate 'Büfe' in wordsMiddle")
    
    # In words2Syllables:
    s2_idx = f_block.find("words2Syllables:")
    s3_idx = f_block.find("words3Syllables:")
    s2_part = f_block[s2_idx:s3_idx]
    parts = s2_part.split("'Fıstık'", 2)
    if len(parts) == 3:
        s2_part = parts[0] + "'Fıstık'" + parts[1] + "'Fosil'" + parts[2]
    s2_part = s2_part.replace("'Fiş'", "'Foto'")
    parts = s2_part.split("'Büfe'", 2)
    if len(parts) == 3:
        s2_part = parts[0] + "'Büfe'" + parts[1] + "'Teflon'" + parts[2]
    f_block = f_block[:s2_idx] + s2_part + f_block[s3_idx:]
    print("[/f/] Fixed words2Syllables")
    
    text = text[:f_stage_m.start(0)] + f_block + text[f_stage_m.end(0):]

# 6. /s/ stage fixes
s_stage_m = re.search(r"(id:\s*'sound_s'.*?storyTitle:)", text, re.DOTALL)
if s_stage_m:
    s_block = s_stage_m.group(0)
    end_idx = s_block.find("wordsEnding:")
    s1_idx = s_block.find("words1Syllable:")
    end_part = s_block[end_idx:s1_idx]
    parts = end_part.split("'Tenis'", 2)
    if len(parts) == 3:
        end_part = parts[0] + "'Tenis'" + parts[1] + "'Pelvis'" + parts[2]
    s_block = s_block[:end_idx] + end_part + s_block[s1_idx:]
    
    s2_idx = s_block.find("words2Syllables:")
    s3_idx = s_block.find("words3Syllables:")
    s2_part = s_block[s2_idx:s3_idx]
    parts = s2_part.split("'Tenis'", 2)
    if len(parts) == 3:
        s2_part = parts[0] + "'Tenis'" + parts[1] + "'Pelvis'" + parts[2]
    s_block = s_block[:s2_idx] + s2_part + s_block[s3_idx:]
    print("[/s/] Fixed duplicate 'Tenis' in wordsEnding and words2Syllables")
    
    text = text[:s_stage_m.start(0)] + s_block + text[s_stage_m.end(0):]

# 7. /z/ stage fixes
z_stage_m = re.search(r"(id:\s*'sound_z'.*?storyTitle:)", text, re.DOTALL)
if z_stage_m:
    z_block = z_stage_m.group(0)
    
    # wordsBeginning:
    beg_idx = z_block.find("wordsBeginning:")
    mid_idx = z_block.find("wordsMiddle:")
    beg_part = z_block[beg_idx:mid_idx]
    # replace duplicates
    for word, repl in [('Zil', 'Zift'), ('Zamk', 'Zerk'), ('Zeytin', 'Zurna'), ('Zencefil', 'Zambak'), ('Zarif', 'Zariflik')]:
        parts = beg_part.split(f"'{word}'", 2)
        if len(parts) == 3:
            beg_part = parts[0] + f"'{word}'" + parts[1] + f"'{repl}'" + parts[2]
    beg_part = beg_part.replace("'Sevimli',", "").replace("'Neşeli',", "")
    z_block = z_block[:beg_idx] + beg_part + z_block[mid_idx:]
    print("[/z/] Fixed wordsBeginning")
    
    # wordsMiddle:
    end_idx = z_block.find("wordsEnding:")
    mid_part = z_block[mid_idx:end_idx]
    mid_part = mid_part.replace("'Fıstık'", "'Kuzu'")
    z_block = z_block[:mid_idx] + mid_part + z_block[end_idx:]
    print("[/z/] Fixed wordsMiddle ('Fıstık' -> 'Kuzu')")
    
    # wordsEnding:
    s1_idx = z_block.find("words1Syllable:")
    end_part = z_block[end_idx:s1_idx]
    for word, repl in [('Yıldız', 'Sonsuz'), ('Ceviz', 'Yalnız'), ('Kusursuz', 'Uğursuz'), ('Tertemiz', 'Gereksiz')]:
        parts = end_part.split(f"'{word}'", 2)
        if len(parts) == 3:
            end_part = parts[0] + f"'{word}'" + parts[1] + f"'{repl}'" + parts[2]
    z_block = z_block[:end_idx] + end_part + z_block[s1_idx:]
    print("[/z/] Fixed wordsEnding duplicates")
    
    # words1Syllable:
    s2_idx = z_block.find("words2Syllables:")
    s1_part = z_block[s1_idx:s2_idx]
    for word, repl in [('Zil', 'Zift'), ('Zamk', 'Zerk')]:
        parts = s1_part.split(f"'{word}'", 2)
        if len(parts) == 3:
            s1_part = parts[0] + f"'{word}'" + parts[1] + f"'{repl}'" + parts[2]
    z_block = z_block[:s1_idx] + s1_part + z_block[s2_idx:]
    print("[/z/] Fixed words1Syllable duplicates")
    
    # words2Syllables:
    s3_idx = z_block.find("words3Syllables:")
    s2_part = z_block[s2_idx:s3_idx]
    for word, repl in [('Zeytin', 'Zurna'), ('Yıldız', 'Sonsuz'), ('Ceviz', 'Yalnız')]:
        parts = s2_part.split(f"'{word}'", 2)
        if len(parts) == 3:
            s2_part = parts[0] + f"'{word}'" + parts[1] + f"'{repl}'" + parts[2]
    s2_part = s2_part.replace("'Zeytinli'", "'Zehir'")
    s2_part = s2_part.replace("'Zencefil'", "'Zarar'")
    s2_part = s2_part.replace("'Fıstık'", "'Kuzu'")
    z_block = z_block[:s2_idx] + s2_part + z_block[s3_idx:]
    print("[/z/] Fixed words2Syllables")
    
    # words3Syllables:
    phr_idx = z_block.find("phrasesBeginning:")
    s3_part = z_block[s3_idx:phr_idx]
    s3_part = s3_part.replace("'Sevimli',", "").replace("'Neşeli',", "")
    s3_part = s3_part.replace("'Ziyaretçi'", "'Ziyaret'")
    s3_part = s3_part.replace("'Canbaz'", "'Cambazlar'")
    s3_part = s3_part.replace("'Eşsiz'", "'Eşsizlik'")
    s3_part = s3_part.replace("'Tuzsuz'", "'Tuzsuzluk'")
    parts = s3_part.split("'Zarif'", 2)
    if len(parts) == 3:
        s3_part = parts[0] + "'Zariflik'" + parts[1] + "'Zavallı'" + parts[2]
    elif len(parts) == 2:
        s3_part = parts[0] + "'Zariflik'" + parts[1]
    parts = s3_part.split("'Kusursuz'", 2)
    if len(parts) == 3:
        s3_part = parts[0] + "'Kusursuz'" + parts[1] + "'Uğursuz'" + parts[2]
    parts = s3_part.split("'Tertemiz'", 2)
    if len(parts) == 3:
        s3_part = parts[0] + "'Tertemiz'" + parts[1] + "'Gereksiz'" + parts[2]
    z_block = z_block[:s3_idx] + s3_part + z_block[phr_idx:]
    print("[/z/] Fixed words3Syllables")
    
    text = text[:z_stage_m.start(0)] + z_block + text[z_stage_m.end(0):]

# 8. /ş/ stage fixes
sh_stage_m = re.search(r"(id:\s*'sound_ş'.*?storyTitle:)", text, re.DOTALL)
if sh_stage_m:
    sh_block = sh_stage_m.group(0)
    
    # wordsBeginning:
    beg_idx = sh_block.find("wordsBeginning:")
    mid_idx = sh_block.find("wordsMiddle:")
    beg_part = sh_block[beg_idx:mid_idx]
    for word, repl in [('Şeker', 'Şişe'), ('Şimşek', 'Şofben'), ('Şampiyon', 'Şamandıra'), ('Şelale', 'Şemsiye')]:
        parts = beg_part.split(f"'{word}'", 2)
        if len(parts) == 3:
            beg_part = parts[0] + f"'{word}'" + parts[1] + f"'{repl}'" + parts[2]
    sh_block = sh_block[:beg_idx] + beg_part + sh_block[mid_idx:]
    print("[/ş/] Fixed wordsBeginning duplicates")
    
    # wordsMiddle:
    end_idx = sh_block.find("wordsEnding:")
    mid_part = sh_block[mid_idx:end_idx]
    mid_part = mid_part.replace("'Fiş'", "'Işık'")
    sh_block = sh_block[:mid_idx] + mid_part + sh_block[end_idx:]
    print("[/ş/] Fixed wordsMiddle ('Fiş' -> 'Işık')")
    
    # words1Syllable:
    s1_idx = sh_block.find("words1Syllable:")
    s2_idx = sh_block.find("words2Syllables:")
    s1_part = sh_block[s1_idx:s2_idx]
    s1_part = s1_part.replace("'Şerit'", "'Şut'")
    sh_block = sh_block[:s1_idx] + s1_part + sh_block[s2_idx:]
    print("[/ş/] Fixed words1Syllable ('Şerit' -> 'Şut')")
    
    # words2Syllables:
    s3_idx = sh_block.find("words3Syllables:")
    s2_part = sh_block[s2_idx:s3_idx]
    s2_part = s2_part.replace("'Çorap'", "'Kaşık'")
    s2_part = s2_part.replace("'Fiş'", "'Şişe'")
    parts = s2_part.split("'Şimşek'", 2)
    if len(parts) == 3:
        s2_part = parts[0] + "'Şimşek'" + parts[1] + "'Şerit'" + parts[2]
    sh_block = sh_block[:s2_idx] + s2_part + sh_block[s3_idx:]
    print("[/ş/] Fixed words2Syllables ('Çorap' -> 'Kaşık', 'Fiş' -> 'Şişe', duplicate Şimşek -> Şerit)")
    
    # words3Syllables:
    phr_idx = sh_block.find("phrasesBeginning:")
    s3_part = sh_block[s3_idx:phr_idx]
    for word, repl in [('Şampiyon', 'Şamandıra'), ('Şelale', 'Şemsiye')]:
        parts = s3_part.split(f"'{word}'", 2)
        if len(parts) == 3:
            s3_part = parts[0] + f"'{word}'" + parts[1] + f"'{repl}'" + parts[2]
    sh_block = sh_block[:s3_idx] + s3_part + sh_block[phr_idx:]
    print("[/ş/] Fixed words3Syllables duplicates")
    
    text = text[:sh_stage_m.start(0)] + sh_block + text[sh_stage_m.end(0):]

# 9. /h/ stage fixes
h_stage_m = re.search(r"(id:\s*'sound_h'.*?storyTitle:)", text, re.DOTALL)
if h_stage_m:
    h_block = h_stage_m.group(0)
    beg_idx = h_block.find("wordsBeginning:")
    mid_idx = h_block.find("wordsMiddle:")
    beg_part = h_block[beg_idx:mid_idx]
    parts = beg_part.split("'Horoz'", 2)
    if len(parts) == 3:
        beg_part = parts[0] + "'Horoz'" + parts[1] + "'Halka'" + parts[2]
    h_block = h_block[:beg_idx] + beg_part + h_block[mid_idx:]
    print("[/h/] Fixed duplicate 'Horoz' in wordsBeginning")
    
    s2_idx = h_block.find("words2Syllables:")
    s3_idx = h_block.find("words3Syllables:")
    s2_part = h_block[s2_idx:s3_idx]
    s2_part = s2_part.replace("'Yıldız'", "'Havuç'")
    h_block = h_block[:s2_idx] + s2_part + h_block[s3_idx:]
    print("[/h/] Fixed 'Yıldız' in words2Syllables -> 'Havuç'")
    
    text = text[:h_stage_m.start(0)] + h_block + text[h_stage_m.end(0):]

# 10. /ç/ stage fixes
ch_stage_m = re.search(r"(id:\s*'sound_ç'.*?storyTitle:)", text, re.DOTALL)
if ch_stage_m:
    ch_block = ch_stage_m.group(0)
    mid_idx = ch_block.find("wordsMiddle:")
    end_idx = ch_block.find("wordsEnding:")
    mid_part = ch_block[mid_idx:end_idx]
    parts = mid_part.split("'Fırça'", 2)
    if len(parts) == 3:
        mid_part = parts[0] + "'Fırça'" + parts[1] + "'Alçı'" + parts[2]
    ch_block = ch_block[:mid_idx] + mid_part + ch_block[end_idx:]
    print("[/ç/] Fixed duplicate 'Fırça' in wordsMiddle -> 'Alçı'")
    
    s2_idx = ch_block.find("words2Syllables:")
    s3_idx = ch_block.find("words3Syllables:")
    s2_part = ch_block[s2_idx:s3_idx]
    parts = s2_part.split("'Fırça'", 2)
    if len(parts) == 3:
        s2_part = parts[0] + "'Fırça'" + parts[1] + "'Alçı'" + parts[2]
    ch_block = ch_block[:s2_idx] + s2_part + ch_block[s3_idx:]
    print("[/ç/] Fixed duplicate 'Fırça' in words2Syllables -> 'Alçı'")
    
    text = text[:ch_stage_m.start(0)] + ch_block + text[ch_stage_m.end(0):]

# 11. /c/ stage fixes
# Empty wordsEnding to []
c_ending_pattern = r"(id:\s*'sound_c'.*?wordsEnding:\s*\[)(.*?)(\],\s*words1Syllable:)"
m_c = re.search(c_ending_pattern, text, re.DOTALL)
if m_c:
    text = text[:m_c.start(2)] + "\n      " + text[m_c.end(2):]
    print("[/c/] Cleared wordsEnding to []")

# In /c/ wordsMiddle: replace 'Açacak' with 'Sucuklu'
c_stage_m = re.search(r"(id:\s*'sound_c'.*?storyTitle:)", text, re.DOTALL)
if c_stage_m:
    c_block = c_stage_m.group(0)
    mid_idx = c_block.find("wordsMiddle:")
    end_idx = c_block.find("wordsEnding:")
    mid_part = c_block[mid_idx:end_idx]
    mid_part = mid_part.replace("'Açacak'", "'Sucuklu'")
    c_block = c_block[:mid_idx] + mid_part + c_block[end_idx:]
    print("[/c/] Replaced 'Açacak' in wordsMiddle with 'Sucuklu'")
    text = text[:c_stage_m.start(0)] + c_block + text[c_stage_m.end(0):]

# 12. /n/ stage fixes
# In words3Syllables: replace 'Narenciye' with 'Nohutlu', 'Numaralı' with 'Narince'
n_stage_m = re.search(r"(id:\s*'sound_n'.*?storyTitle:)", text, re.DOTALL)
if n_stage_m:
    n_block = n_stage_m.group(0)
    s3_idx = n_block.find("words3Syllables:")
    phr_idx = n_block.find("phrasesBeginning:")
    s3_part = n_block[s3_idx:phr_idx]
    s3_part = s3_part.replace("'Narenciye'", "'Nohutlu'")
    s3_part = s3_part.replace("'Numaralı'", "'Narince'")
    n_block = n_block[:s3_idx] + s3_part + n_block[phr_idx:]
    print("[/n/] Fixed 'Narenciye' and 'Numaralı' in words3Syllables")
    text = text[:n_stage_m.start(0)] + n_block + text[n_stage_m.end(0):]

# 13. /y/ stage fixes
# In wordsMiddle: replace second 'Oyuncu' with 'Karyola'
# In words3Syllables: replace second 'Oyuncu' with 'Karyola'
y_stage_m = re.search(r"(id:\s*'sound_y'.*?storyTitle:)", text, re.DOTALL)
if y_stage_m:
    y_block = y_stage_m.group(0)
    mid_idx = y_block.find("wordsMiddle:")
    end_idx = y_block.find("wordsEnding:")
    mid_part = y_block[mid_idx:end_idx]
    parts = mid_part.split("'Oyuncu'", 2)
    if len(parts) == 3:
        mid_part = parts[0] + "'Oyuncu'" + parts[1] + "'Karyola'" + parts[2]
    y_block = y_block[:mid_idx] + mid_part + y_block[end_idx:]
    print("[/y/] Fixed duplicate 'Oyuncu' in wordsMiddle")
    
    s3_idx = y_block.find("words3Syllables:")
    phr_idx = y_block.find("phrasesBeginning:")
    s3_part = y_block[s3_idx:phr_idx]
    parts = s3_part.split("'Oyuncu'", 2)
    if len(parts) == 3:
        s3_part = parts[0] + "'Oyuncu'" + parts[1] + "'Karyola'" + parts[2]
    y_block = y_block[:s3_idx] + s3_part + y_block[phr_idx:]
    print("[/y/] Fixed duplicate 'Oyuncu' in words3Syllables")
    
    text = text[:y_stage_m.start(0)] + y_block + text[y_stage_m.end(0):]

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(text)

print("\nSUCCESS: All sound fixes applied successfully to sound_groups_data.dart!")
