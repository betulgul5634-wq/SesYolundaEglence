import os, re, json

with open('mobile/lib/data/sound_groups_data.dart', 'r', encoding='utf-8') as f:
    content = f.read()

print("--- AUDITING SOUND STAGES IN sound_groups_data.dart ---")
# Count SoundStage
stage_blocks = re.split(r'SoundStage\(', content)[1:]
print(f"Total SoundStages: {len(stage_blocks)}")

issues = []

for idx, b in enumerate(stage_blocks):
    ph_match = re.search(r"phoneme:\s*['\"](.*?)['\"]", b)
    ph = ph_match.group(1) if ph_match else f"Unknown_{idx+1}"
    
    # Story
    story_title = re.search(r"storyTitle:\s*['\"](.*?)['\"]", b)
    story_text = re.search(r"storyText:\s*['\"](.*?)['\"]", b)
    if not story_title or not story_title.group(1):
        issues.append(f"Stage {ph}: Missing storyTitle")
    if not story_text or len(story_text.group(1)) < 20:
        issues.append(f"Stage {ph}: Story text too short or missing")
        
    # Words
    words_match = re.search(r"words:\s*\[(.*?)\]", b, re.DOTALL)
    if words_match:
        words_raw = words_match.group(1)
        # extract each WordItem or word string
        w_list = re.findall(r"word:\s*['\"](.*?)['\"]", words_raw)
        if len(w_list) < 5:
            issues.append(f"Stage {ph}: Less than 5 words ({len(w_list)})")
        # Check duplicate words within stage
        dups = set([w for w in w_list if w_list.count(w) > 1])
        if dups:
            issues.append(f"Stage {ph}: Duplicate words in word list: {dups}")
    else:
        issues.append(f"Stage {ph}: Missing words list")
        
    # Sentences
    sent_match = re.search(r"sentences:\s*\[(.*?)\]", b, re.DOTALL)
    if sent_match:
        s_raw = sent_match.group(1)
        s_list = re.findall(r"['\"](.*?)['\"]", s_raw)
        clean_s = [s.strip() for s in s_list if len(s.strip()) > 3 and not s.startswith('//')]
        if len(clean_s) < 3:
            issues.append(f"Stage {ph}: Less than 3 sentences ({len(clean_s)})")
    else:
        issues.append(f"Stage {ph}: Missing sentences list")

print(f"Stage Audit Issues Found: {len(issues)}")
for iss in issues:
    print(f"  - {iss}")

print("\n--- AUDITING WORD PICTOGRAM COVERAGE ---")
# Check word_pictogram_helper.dart
with open('mobile/lib/utils/word_pictogram_helper.dart', 'r', encoding='utf-8') as f:
    pic_code = f.read()

# Check all words across all stages
all_stage_words = re.findall(r"word:\s*['\"](.*?)['\"]", content)
unique_words = sorted(list(set(all_stage_words)))
print(f"Unique words across all stages: {len(unique_words)}")

unmatched_words = []
for w in unique_words:
    clean_w = w.lower().strip()
    if f"'{clean_w}':" not in pic_code and f'"{clean_w}":' not in pic_code:
        unmatched_words.append(clean_w)

print(f"Unmatched words in pictogram dictionary: {len(unmatched_words)}")
if unmatched_words:
    print(f"Sample unmatched: {unmatched_words[:10]}")
