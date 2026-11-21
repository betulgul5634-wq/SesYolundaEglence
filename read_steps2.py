import json

with open('C:/Users/ASUS/.gemini/antigravity/brain/ffc530cc-181a-4ee6-9064-662cf989282f/.system_generated/logs/transcript.jsonl', 'r', encoding='utf-8') as f:
    for line in f:
        obj = json.loads(line)
        idx = obj.get('step_index')
        if idx in range(7015, 7030):
            print(f"=== STEP {idx} {obj.get('type')} ===")
            if obj.get('tool_calls'):
                print("Tool calls:", obj.get('tool_calls'))
            c = str(obj.get('content', ''))
            if c:
                print(c[:300])
