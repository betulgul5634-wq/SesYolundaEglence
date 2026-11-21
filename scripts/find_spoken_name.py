with open('mobile/lib/widgets/sound_mini_game.dart', 'r', encoding='utf-8') as f:
    lines = f.readlines()

for i, l in enumerate(lines):
    if '_getSoundSpokenName' in l:
        for j in range(i, min(len(lines), i+30)):
            print(f"{j+1}: {lines[j]}", end='')
        break
