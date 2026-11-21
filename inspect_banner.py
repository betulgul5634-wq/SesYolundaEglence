import sys
sys.stdout.reconfigure(encoding='utf-8')

with open('mobile/lib/screens/sound_practice_screen.dart', 'r', encoding='utf-8') as f:
    lines = f.readlines()

# Search for _buildStageEndGameBanner and _buildSyllablesGrid
for idx, line in enumerate(lines):
    if '_buildSyllablesGrid' in line or '_buildStageEndGameBanner' in line or 'Basamak: Heceler' in line:
        for j in range(max(0, idx - 5), min(len(lines), idx + 45)):
            print(f'{j+1}: {lines[j]}', end='')
        print('\n' + '='*50 + '\n')
