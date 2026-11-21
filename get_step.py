import json

with open(r'C:\Users\ASUS\.gemini\antigravity\brain\ffc530cc-181a-4ee6-9064-662cf989282f\.system_generated\logs\transcript_full.jsonl', encoding='utf-8') as f:
    for line in f:
        if '"step_index":6054' in line or '"step_index": 6054' in line:
            obj = json.loads(line)
            print(json.dumps(obj['tool_calls'], indent=2))
            break
