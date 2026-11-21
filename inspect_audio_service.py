import sys
sys.stdout.reconfigure(encoding='utf-8')

with open('mobile/lib/services/audio_speech_service.dart', 'r', encoding='utf-8') as f:
    lines = f.readlines()

for i, l in enumerate(lines):
    if 'speakTurkish' in l or 'instruction' in l or 'hece' in l.lower() or 'kelime' in l.lower():
        print(f'{i+1}: {l}', end='')
