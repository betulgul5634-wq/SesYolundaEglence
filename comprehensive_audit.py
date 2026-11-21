import sys
import re

sys.stdout.reconfigure(encoding='utf-8')

with open('mobile/lib/data/sound_groups_data.dart', 'r', encoding='utf-8') as f:
    text = f.read()

stage_blocks = re.findall(r'SoundStage\((.*?)\n  \),', text, re.DOTALL)

def get_list(block, field):
    m = re.search(rf'{field}:\s*\[(.*?)\](?=\s*,\s*\w+:|\s*\))', block, re.DOTALL)
    if not m: return []
    items = re.findall(r"'((?:[^'\\]|\\.)*)'", m.group(1))
    return [i.replace(r"\'", "'").replace(r"\\", "\\").strip() for i in items]

def get_field(block, field):
    m = re.search(rf"{field}:\s*'((?:[^'\\]|\\.)*)'", block)
    return m.group(1) if m else ''

vowels = set('aeıioöuüAEIİOÖUÜâîû')

def count_vowels(w):
    return sum(1 for c in w if c in vowels)

target_sounds = ['p', 'b', 't', 'd', 'k', 'g', 'f', 'v', 's', 'z', 'ş', 'j', 'h', 'ç', 'c', 'm', 'n', 'l', 'r', 'y']

for idx, b in enumerate(stage_blocks):
    target = target_sounds[idx]
    id_val = get_field(b, 'id')
    name = get_field(b, 'name')
    print(f"\n==================== STAGE {idx+1}: /{target}/ ({id_val} - {name}) ====================")
    
    # 1. Check target presence in words
    for list_name in ['wordsBeginning', 'wordsMiddle', 'wordsEnding', 'words1Syllable', 'words2Syllables', 'words3Syllables']:
        words = get_list(b, list_name)
        # Check target sound
        missing_target = []
        wrong_position = []
        syllable_mismatch = []
        
        for w in words:
            w_lower = w.lower()
            if target not in w_lower:
                missing_target.append(w)
            
            # Position check
            if list_name == 'wordsBeginning' and not w_lower.startswith(target):
                wrong_position.append((w, 'does not start with ' + target))
            elif list_name == 'wordsEnding' and not w_lower.endswith(target):
                wrong_position.append((w, 'does not end with ' + target))
            elif list_name == 'wordsMiddle':
                if w_lower.startswith(target) or w_lower.endswith(target):
                    # In middle, target sound should be medial (not initial, not final)
                    # wait, some words have target sound in multiple places, e.g. 'bebek' (b at start and middle)
                    # but check if it ONLY appears at start or end
                    indices = [i for i, c in enumerate(w_lower) if c == target]
                    medial = any(0 < i < len(w_lower) - 1 for i in indices)
                    if not medial:
                        wrong_position.append((w, 'not medial'))
            
            # Syllable check
            vc = count_vowels(w)
            if list_name == 'words1Syllable' and vc != 1:
                syllable_mismatch.append((w, f'vowels={vc} expected 1'))
            elif list_name == 'words2Syllables' and vc != 2:
                syllable_mismatch.append((w, f'vowels={vc} expected 2'))
            elif list_name == 'words3Syllables' and vc != 3:
                syllable_mismatch.append((w, f'vowels={vc} expected 3'))
        
        if missing_target:
            print(f"  [MISSING TARGET] {list_name}: {missing_target}")
        if wrong_position:
            print(f"  [WRONG POSITION] {list_name}: {wrong_position}")
        if syllable_mismatch:
            print(f"  [SYLLABLE MISMATCH] {list_name}: {syllable_mismatch}")
            
    # Check phrases and sentences
    phrases = get_list(b, 'phrases')
    sentences = get_list(b, 'sentences')
    print(f"  Total phrases: {len(phrases)}, sentences: {len(sentences)}")
