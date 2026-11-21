import os

pure_dir = 'backend/pure_syllables'
letters = ['p', 'b', 't', 'd', 'k', 'g', 'f', 'v', 's', 'z', 'ş', 'j', 'h', 'ç', 'c', 'm', 'n', 'l', 'r', 'y']

for l in letters:
    path = os.path.join(pure_dir, f"{l}_explain.wav")
    print(f"{l}_explain.wav: {'EXISTS' if os.path.exists(path) else 'MISSING'}")
