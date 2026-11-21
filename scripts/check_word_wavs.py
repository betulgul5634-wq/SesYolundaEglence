import os

pure_dir = 'backend/pure_syllables'
files = [f for f in os.listdir(pure_dir) if f.endswith('.wav')]
print(f"Total wav files: {len(files)}")
p_words = [f for f in files if f.startswith('p') and len(f) > 6]
b_words = [f for f in files if f.startswith('b') and len(f) > 6]
print(f"P files (>6 chars): {len(p_words)} e.g. {p_words[:5]}")
print(f"B files (>6 chars): {len(b_words)} e.g. {b_words[:5]}")
