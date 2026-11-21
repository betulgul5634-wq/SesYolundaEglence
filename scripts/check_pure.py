import os
pure_dir = 'backend/pure_syllables'
if os.path.exists(pure_dir):
    files = sorted(os.listdir(pure_dir))
    print(f"Total files in pure_syllables: {len(files)}")
    for f in files:
        if len(f) <= 10:
            print(f)
else:
    print("pure_syllables directory does not exist!")
