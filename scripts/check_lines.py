with open('mobile/lib/widgets/sound_mini_game.dart', 'r', encoding='utf-8') as f:
    lines = f.readlines()

for i in range(25, 50):
    print(f"{i+1}: {lines[i]}", end='')
