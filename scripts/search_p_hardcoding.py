import re

files_to_check = [
    'backend/main.py',
    'mobile/lib/services/audio_speech_service.dart',
    'mobile/lib/screens/sound_practice_screen.dart',
    'mobile/web/index.html'
]

for file_path in files_to_check:
    print(f"=== CHECKING {file_path} ===")
    with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
        for idx, line in enumerate(f, 1):
            line_str = line.strip()
            # check for hardcoded 'p' comparisons
            if re.search(r'==\s*[\'"][pP][\'"]|==\s*[\'"]/p/[\'"]|sound_p|clean_p\s*==\s*[\'"]p[\'"]', line_str):
                print(f"Line {idx}: {line_str}")
