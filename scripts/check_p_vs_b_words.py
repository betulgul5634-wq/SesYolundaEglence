import os

pure_dir = 'backend/pure_syllables'

p_words = ['pas', 'pin', 'pak', 'pil', 'pul', 'pes', 'pim', 'pür']
b_words = ['baba', 'bal', 'buz', 'bel', 'bip', 'ben', 'bebek']

print("P words:")
for w in p_words:
    path = os.path.join(pure_dir, f"{w}.wav")
    print(f"  {w}: {'EXISTS' if os.path.exists(path) else 'NOT FOUND'}")

print("B words:")
for w in b_words:
    path = os.path.join(pure_dir, f"{w}.wav")
    print(f"  {w}: {'EXISTS' if os.path.exists(path) else 'NOT FOUND'}")
