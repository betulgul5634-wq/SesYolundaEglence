import json
import sys

sys.stdout.reconfigure(encoding='utf-8')

with open(r'C:\Users\ASUS\.gemini\antigravity\brain\ffc530cc-181a-4ee6-9064-662cf989282f\.system_generated\logs\transcript_full.jsonl', encoding='utf-8') as f:
    for line_no, line in enumerate(f):
        if 'kBookStages = [' in line:
            obj = json.loads(line)
            # recursively search for kBookStages = [ in obj
            def find_str(val):
                if isinstance(val, str):
                    if 'kBookStages = [' in val:
                        return val
                elif isinstance(val, dict):
                    for v in val.values():
                        res = find_str(v)
                        if res: return res
                elif isinstance(val, list):
                    for v in val:
                        res = find_str(v)
                        if res: return res
                return None
            res = find_str(obj)
            if res:
                idx = res.find('final List<SoundStage> kBookStages')
                if idx == -1: idx = res.find('kBookStages = [')
                chunk = res[idx:]
                end_idx = chunk.find('];')
                if end_idx != -1:
                    chunk = chunk[:end_idx+2]
                with open('pristine_kbookstages.txt', 'w', encoding='utf-8') as out:
                    out.write(chunk)
                print(f"Found in line {line_no}, saved pristine_kbookstages.txt ({len(chunk)} chars)")
                break
