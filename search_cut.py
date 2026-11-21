import json

with open(r'C:\Users\ASUS\.gemini\antigravity\brain\ffc530cc-181a-4ee6-9064-662cf989282f\.system_generated\logs\transcript_full.jsonl', encoding='utf-8') as f:
    for line in f:
        if 'pure_syllables/es.wav' in line or 'es.wav' in line:
            if 'carrier' in line or 'cut' in line or 'pydub' in line or 'slice' in line or 'samples' in line or 'threshold' in line:
                print(line[:500])
                break
