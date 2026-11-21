import json

with open('C:/Users/ASUS/.gemini/antigravity/brain/ffc530cc-181a-4ee6-9064-662cf989282f/.system_generated/logs/transcript.jsonl', 'r', encoding='utf-8') as f:
    for line in f:
        obj = json.loads(line)
        if obj.get('step_index') in [7011, 7012, 7013, 7014, 7015]:
            print(f"=== STEP {obj.get('step_index')} {obj.get('type')} ===")
            content = str(obj.get('content', ''))
            print(content[:500])
