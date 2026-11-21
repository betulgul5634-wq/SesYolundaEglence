import json

with open(r'C:\Users\ASUS\.gemini\antigravity\brain\ffc530cc-181a-4ee6-9064-662cf989282f\.system_generated\logs\transcript_full.jsonl', encoding='utf-8') as f:
    for line in f:
        if 'pure_syllables/es.wav' in line or 'pure_syllables\\\\es.wav' in line:
            obj = json.loads(line)
            idx = obj.get('step_index')
            if idx and idx < 6050:
                print(f"Step {idx}:", line[:300])
