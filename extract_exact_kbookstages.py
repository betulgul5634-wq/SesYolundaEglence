import json
import sys

sys.stdout.reconfigure(encoding='utf-8')

with open(r'C:\Users\ASUS\.gemini\antigravity\brain\ffc530cc-181a-4ee6-9064-662cf989282f\.system_generated\logs\transcript_full.jsonl', encoding='utf-8') as f:
    for line in f:
        if 'sound_groups_data.dart' in line and 'SoundStage' in line:
            obj = json.loads(line)
            # check content
            c = obj.get('content', '')
            if 'kBookStages = [' in c:
                # find start of kBookStages
                idx = c.find('final List<SoundStage> kBookStages')
                if idx != -1:
                    dart_code = c[idx:]
                    # end is at '];'
                    end_idx = dart_code.find('\n];')
                    if end_idx != -1:
                        dart_code = dart_code[:end_idx+3]
                        with open('pristine_kbookstages.txt', 'w', encoding='utf-8') as out:
                            out.write(dart_code)
                        print("Saved pristine_kbookstages.txt, length:", len(dart_code))
                        break
