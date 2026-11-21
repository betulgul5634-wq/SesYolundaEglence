import sys
sys.stdout.reconfigure(encoding='utf-8')

with open('mobile/lib/widgets/sound_mini_game.dart', 'r', encoding='utf-8') as f:
    content = f.read()

pos = content.find('_getSoundSpokenName')
print(content[pos:pos+1200])
