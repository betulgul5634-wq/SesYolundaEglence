import sys, re
sys.stdout.reconfigure(encoding='utf-8')
with open('mobile/lib/data/sound_groups_data.dart', 'r', encoding='utf-8') as f:
    text = f.read()

m = re.search(r"id:\s*'sound_v'(.*?)(?=SoundStage|\Z)", text, re.DOTALL)
if m:
    block = m.group(1)
    for field in ['wordsBeginning', 'wordsMiddle', 'wordsEnding', 'words1Syllable', 'words2Syllables', 'words3Syllables']:
        mf = re.search(rf'{field}:\s*\[(.*?)\]', block, re.DOTALL)
        if mf:
            print(f'=== {field} ===\n{mf.group(1)}\n')
