with open('mobile/lib/services/audio_speech_service.dart', 'r', encoding='utf-8') as f:
    lines = f.readlines()

for i, l in enumerate(lines):
    if 'v=32' in l or 'cache' in l.lower() or 'v=' in l:
        print(f"{i+1}: {l.strip()}")
