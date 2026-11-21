import re
import sys
from fix_all_sounds_core import (
    clean_and_correct_word, correct_sentence, count_vowels
)

sys.stdout.reconfigure(encoding='utf-8')

with open('mobile/lib/data/sound_groups_data.dart', encoding='utf-8') as f:
    text = f.read()

def parse_list(block, field_name):
    m = re.search(rf'{field_name}:\s*\[(.*?)\](?=\s*,\s*\w+:|\s*\))', block, re.DOTALL)
    if not m: return []
    raw = m.group(1)
    items = []
    for match in re.finditer(r"'((?:[^'\\]|\\.)*)'", raw):
        s = match.group(1).replace(r"\'", "'").replace(r"\\", "\\").strip()
        if s and not s.endswith('\\') and s not in [',', '']:
            items.append(s)
    return items

def parse_str(block, field_name):
    m = re.search(rf"{field_name}:\s*'((?:[^'\\]|\\.)*)'", block, re.DOTALL)
    if m:
        return m.group(1).replace(r"\'", "'").replace(r"\\", "\\").strip()
    return ""

def escape_for_dart(s):
    return s.replace('\\', '\\\\').replace("'", "\\'").replace('$', '\\$')

def render_dart_list(lst, indent_spaces=8):
    if not lst: return "const []"
    ind = " " * indent_spaces
    lines = [f"{ind}'{escape_for_dart(x)}'," for x in lst if x]
    return "[\n" + "\n".join(lines) + f"\n{' ' * (indent_spaces - 2)}]"

# Split text into stage blocks
stage_regex = re.compile(r"SoundStage\(\s*id:\s*'(sound_[a-zğüşöçı]+)'", re.DOTALL)
matches = list(stage_regex.finditer(text))

header = text[:matches[0].start()]
output_blocks = [header]

for i, m in enumerate(matches):
    stage_id = m.group(1)
    letter = stage_id.replace('sound_', '')
    start_idx = m.start()
    end_idx = matches[i+1].start() if i + 1 < len(matches) else len(text)
    blk = text[start_idx:end_idx]
    
    # Extract metadata fields
    phoneme = parse_str(blk, 'phoneme')
    sound_letter = parse_str(blk, 'soundLetter')
    cat_title = parse_str(blk, 'categoryTitle')
    main_cat = parse_str(blk, 'mainCategory')
    emoji = parse_str(blk, 'emoji')
    m_color = re.search(r'colorHex:\s*(0x[0-9A-Fa-f]+)', blk)
    color_hex = m_color.group(1) if m_color else '0xFF1E88E5'
    art_hint = parse_str(blk, 'articulationHint')
    story_title = parse_str(blk, 'storyTitle')
    story_content = parse_str(blk, 'storyContent')
    
    syllables = parse_list(blk, 'syllables')
    raw_w1 = parse_list(blk, 'words1Syllable')
    raw_w2 = parse_list(blk, 'words2Syllables')
    raw_w3 = parse_list(blk, 'words3Syllables')
    raw_wbeg = parse_list(blk, 'wordsBeginning')
    raw_wmid = parse_list(blk, 'wordsMiddle')
    raw_wend = parse_list(blk, 'wordsEnding')
    raw_phr_beg = parse_list(blk, 'phrasesBeginning')
    raw_phr_cont = parse_list(blk, 'phrasesContaining')
    raw_phr = parse_list(blk, 'phrases')
    raw_snt_beg = parse_list(blk, 'sentencesBeginning')
    raw_snt_cont = parse_list(blk, 'sentencesContaining')
    raw_snt = parse_list(blk, 'sentences')
    
    # Combine all unique words
    all_raw_words = list(dict.fromkeys(raw_w1 + raw_w2 + raw_w3 + raw_wbeg + raw_wmid + raw_wend))
    corrected_words = []
    for w in all_raw_words:
        cw = clean_and_correct_word(w, letter)
        if cw and len(cw) >= 2:
            corrected_words.append(cw)
    corrected_words = list(dict.fromkeys(corrected_words))
    
    # Sort into exact syllable lengths
    w1 = [w for w in corrected_words if count_vowels(w) == 1]
    w2 = [w for w in corrected_words if count_vowels(w) == 2]
    w3 = [w for w in corrected_words if count_vowels(w) >= 3]
    
    # Position sorting
    w_beg = []
    w_mid = []
    w_end = []
    t_char = letter.lower()
    for w in corrected_words:
        w_low = w.lower()
        if w_low.startswith(t_char):
            w_beg.append(w)
        elif w_low.endswith(t_char):
            w_end.append(w)
        elif t_char in w_low:
            w_mid.append(w)
        else:
            w_beg.append(w)
            
    # For /b/, no ending position in Turkish phonology as noted in book
    if letter == 'b':
        w_end = []
        
    # Correct phrases
    def fix_phrase_list(plist):
        res = []
        for p in plist:
            clean_p = p.strip()
            if not clean_p or clean_p.endswith('\\') or len(clean_p) < 3: continue
            cp = correct_sentence(clean_p, letter)
            if cp: res.append(cp)
        return list(dict.fromkeys(res))
        
    phr_beg = fix_phrase_list(raw_phr_beg if raw_phr_beg else raw_phr[:15])
    phr_cont = fix_phrase_list(raw_phr_cont if raw_phr_cont else raw_phr[15:])
    all_phr = phr_beg + phr_cont
    
    # Correct sentences
    def fix_sentence_list(slist):
        res = []
        for s in slist:
            clean_s = s.strip()
            if not clean_s or clean_s.endswith('\\') or len(clean_s) < 5 or clean_s.startswith(','): continue
            cs = correct_sentence(clean_s, letter)
            if cs:
                if not cs.endswith(('.', '!', '?')): cs += '.'
                res.append(cs)
        return list(dict.fromkeys(res))
        
    snt_beg = fix_sentence_list(raw_snt_beg if raw_snt_beg else raw_snt[:15])
    snt_cont = fix_sentence_list(raw_snt_cont if raw_snt_cont else raw_snt[15:])
    all_snt = snt_beg + snt_cont
    
    # Story title & content correction
    corr_story_title = correct_sentence(story_title, letter) if story_title else f'{sound_letter} Sesi Hikayesi'
    corr_story_content = correct_sentence(story_content, letter) if story_content else ""
    
    # Build stage string
    out = []
    out.append("SoundStage(")
    out.append(f"    id: '{stage_id}',")
    out.append(f"    phoneme: '{phoneme}',")
    out.append(f"    soundLetter: '{sound_letter}',")
    out.append(f"    categoryTitle: '{escape_for_dart(cat_title)}',")
    out.append(f"    mainCategory: '{escape_for_dart(main_cat)}',")
    out.append(f"    emoji: '{emoji}',")
    out.append(f"    colorHex: {color_hex},")
    out.append(f"    articulationHint: '{escape_for_dart(art_hint)}',")
    out.append("    unlockedLevelIndex: 0,")
    out.append("    starsCollected: 0,")
    out.append("    content: SingleSoundLevel(")
    out.append(f"      syllables: {render_dart_list(syllables)},")
    out.append(f"      wordsBeginning: {render_dart_list(w_beg)},")
    out.append(f"      wordsMiddle: {render_dart_list(w_mid)},")
    out.append(f"      wordsEnding: {render_dart_list(w_end)},")
    out.append(f"      words1Syllable: {render_dart_list(w1)},")
    out.append(f"      words2Syllables: {render_dart_list(w2)},")
    out.append(f"      words3Syllables: {render_dart_list(w3)},")
    out.append(f"      phrasesBeginning: {render_dart_list(phr_beg)},")
    out.append(f"      phrasesContaining: {render_dart_list(phr_cont)},")
    out.append(f"      phrases: {render_dart_list(all_phr)},")
    out.append(f"      sentencesBeginning: {render_dart_list(snt_beg)},")
    out.append(f"      sentencesContaining: {render_dart_list(snt_cont)},")
    out.append(f"      sentences: {render_dart_list(all_snt)},")
    out.append(f"      storyTitle: '{escape_for_dart(corr_story_title)}',")
    out.append(f"      storyContent: '{escape_for_dart(corr_story_content)}',")
    out.append("    ),")
    out.append("  ),\n")
    
    output_blocks.append("\n  ".join(out))

final_content = "\n".join(output_blocks) + "\n];\n"

with open('mobile/lib/data/sound_groups_data.dart', 'w', encoding='utf-8') as f:
    f.write(final_content)

print("Applied full Turkish corrections to sound_groups_data.dart successfully!")
