import sys, re
sys.stdout.reconfigure(encoding='utf-8')

for path in ['mobile/lib/screens/sound_practice_screen.dart', 'mobile/lib/services/audio_speech_service.dart', 'mobile/lib/data/sound_groups_data.dart']:
    with open(path, 'r', encoding='utf-8') as f:
        text = f.read()
    print(f'=== {path} ===')
    matches = re.finditer(r'([^\n]{0,50}kelime[^\n]{0,50})', text, re.IGNORECASE)
    for m in matches:
        print(' ', m.group(1).strip())
