import re

with open('mobile/lib/data/sound_groups_data.dart', 'r', encoding='utf-8') as f:
    text = f.read()

stage_chunks = text.split("SoundStage(")[1:]
print(f"Total Stage chunks: {len(stage_chunks)}")

for idx, chunk in enumerate(stage_chunks):
    phoneme = re.search(r"phoneme:\s*['\"](.*?)['\"]", chunk)
    letter = re.search(r"soundLetter:\s*['\"](.*?)['\"]", chunk)
    story_t = re.search(r"storyTitle:\s*['\"](.*?)['\"]", chunk)
    story_c = re.search(r"storyContent:\s*['\"](.*?)['\"]", chunk)
    
    p_str = phoneme.group(1) if phoneme else f"Stage {idx+1}"
    l_str = letter.group(1) if letter else "?"
    st_t = story_t.group(1) if story_t else "YOK"
    st_c_len = len(story_c.group(1)) if story_c else 0
    
    # Check syllables
    syls = re.search(r"syllables:\s*\[(.*?)\]", chunk, re.DOTALL)
    syl_count = len([s for s in syls.group(1).split(',') if s.strip() and not s.strip().startswith('//')]) if syls else 0
    
    # Check words
    wb = re.search(r"wordsBeginning:\s*\[(.*?)\]", chunk, re.DOTALL)
    wm = re.search(r"wordsMiddle:\s*\[(.*?)\]", chunk, re.DOTALL)
    we = re.search(r"wordsEnding:\s*\[(.*?)\]", chunk, re.DOTALL)
    
    wb_count = len([w for w in wb.group(1).split(',') if w.strip() and not w.strip().startswith('//')]) if wb else 0
    wm_count = len([w for w in wm.group(1).split(',') if w.strip() and not w.strip().startswith('//')]) if wm else 0
    we_count = len([w for w in we.group(1).split(',') if w.strip() and not w.strip().startswith('//')]) if we else 0
    
    # Check sentences
    sb = re.search(r"sentencesBeginning:\s*\[(.*?)\]", chunk, re.DOTALL)
    sc = re.search(r"sentencesContaining:\s*\[(.*?)\]", chunk, re.DOTALL)
    sb_count = len([s for s in sb.group(1).split(',') if s.strip() and not s.strip().startswith('//')]) if sb else 0
    sc_count = len([s for s in sc.group(1).split(',') if s.strip() and not s.strip().startswith('//')]) if sc else 0
    
    print(f"Stage {idx+1:02d} [{p_str} - {l_str}]: Syls: {syl_count:02d} | Words: B={wb_count:02d}, M={wm_count:02d}, E={we_count:02d} | Sentences: {sb_count}+{sc_count} | Story: '{st_t}' ({st_c_len} chars)")
