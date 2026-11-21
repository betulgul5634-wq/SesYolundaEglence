# -*- coding: utf-8 -*-
import sys
import re

sys.stdout.reconfigure(encoding='utf-8')

from phrase_sentence_corrections import PHRASE_FIXES, SENTENCE_FIXES
from story_corrections import STORY_FIXES
from word_corrections import get_field_aware_replacement

with open('mobile/lib/data/sound_groups_data.dart', 'r', encoding='utf-8') as f:
    text = f.read()

def escape_single_line_dart_str(s):
    s = s.replace('\\', '\\\\')
    s = s.replace("'", "\\'")
    s = s.replace('$', '\\$')
    return s

def clean_phrase(p):
    if p in PHRASE_FIXES:
        return PHRASE_FIXES[p]
    res = p
    for k, v in PHRASE_FIXES.items():
        if k in res:
            res = res.replace(k, v)
    return res

def clean_sentence(s):
    if s in SENTENCE_FIXES:
        return SENTENCE_FIXES[s]
    res = s
    for k, v in SENTENCE_FIXES.items():
        if k in res:
            res = res.replace(k, v)
    return res

stage_pattern = re.compile(r'SoundStage\((.*?)\n  \),', re.DOTALL)

def process_stage(block):
    id_m = re.search(r"id:\s*'([^']+)'", block)
    stage_id = id_m.group(1) if id_m else ""
    
    # 1. Process word lists
    def replace_word_list(m):
        field_name = m.group(1)
        raw_items = m.group(2)
        words = re.findall(r"'((?:[^'\\]|\\.)*)'", raw_items)
        cleaned_words = []
        for w in words:
            w_dec = w.replace(r"\'", "'").replace(r"\\", "\\").strip()
            cw = get_field_aware_replacement(w_dec, stage_id, field_name)
            cleaned_words.append(cw)
        
        seen = set()
        unique_words = []
        for w in cleaned_words:
            if w not in seen:
                seen.add(w)
                unique_words.append(w)
                
        formatted = ",\n        ".join(f"'{escape_single_line_dart_str(w)}'" for w in unique_words)
        return f"{field_name}: [\n        {formatted},\n      ]"

    block = re.sub(r'(wordsBeginning|wordsMiddle|wordsEnding|words1Syllable|words2Syllables|words3Syllables):\s*\[(.*?)\]', replace_word_list, block, flags=re.DOTALL)
    
    # 2. Process phrases
    def replace_phrases(m):
        raw_items = m.group(1)
        phrases = re.findall(r"'((?:[^'\\]|\\.)*)'", raw_items)
        cleaned_phrases = []
        for p in phrases:
            p_dec = p.replace(r"\'", "'").replace(r"\\", "\\").strip()
            cp = clean_phrase(p_dec)
            cleaned_phrases.append(cp)
        formatted = ",\n        ".join(f"'{escape_single_line_dart_str(p)}'" for p in cleaned_phrases)
        return f"phrases: [\n        {formatted},\n      ]"
        
    block = re.sub(r'phrases:\s*\[(.*?)\]', replace_phrases, block, flags=re.DOTALL)

    # 3. Process sentences
    def replace_sentences(m):
        raw_items = m.group(1)
        sentences = re.findall(r"'((?:[^'\\]|\\.)*)'", raw_items)
        cleaned_sentences = []
        for s in sentences:
            s_dec = s.replace(r"\'", "'").replace(r"\\", "\\").strip()
            cs = clean_sentence(s_dec)
            cleaned_sentences.append(cs)
        formatted = ",\n        ".join(f"'{escape_single_line_dart_str(s)}'" for s in cleaned_sentences)
        return f"sentences: [\n        {formatted},\n      ]"
        
    block = re.sub(r'sentences:\s*\[(.*?)\]', replace_sentences, block, flags=re.DOTALL)

    # 4. Process story title & content
    if stage_id in STORY_FIXES:
        fixes = STORY_FIXES[stage_id]
        if 'storyTitle' in fixes:
            new_title = escape_single_line_dart_str(fixes['storyTitle'])
            block = re.sub(r"storyTitle:\s*'.*?',", lambda _: f"storyTitle: '{new_title}',", block)
        if 'storyContent' in fixes:
            content = fixes['storyContent'].replace('\r\n', '\n').replace('\n', '\\n')
            content = content.replace("'", "\\'").replace('$', '\\$')
            block = re.sub(r"storyContent:\s*'.*?',", lambda _: f"storyContent: '{content}',", block)

    return block

def full_replacer(match):
    block = match.group(1)
    new_block = process_stage(block)
    return f"SoundStage({new_block}\n  ),"

new_text = stage_pattern.sub(full_replacer, text)

with open('mobile/lib/data/sound_groups_data.dart', 'w', encoding='utf-8') as f:
    f.write(new_text)

print("Updated mobile/lib/data/sound_groups_data.dart with field-aware corrections successfully!")
