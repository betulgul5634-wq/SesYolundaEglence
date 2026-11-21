import os
import glob
import hashlib

pure_dir = "backend/pure_syllables"
files = glob.glob(os.path.join(pure_dir, "*.wav"))
print(f"Total WAV files in {pure_dir}: {len(files)}")

hashes = {}
duplicates = []

for f in files:
    with open(f, "rb") as fp:
        data = fp.read()
    h = hashlib.md5(data).hexdigest()
    basename = os.path.basename(f)
    if h in hashes:
        duplicates.append((basename, hashes[h]))
    else:
        hashes[h] = basename

print(f"Total unique file hashes: {len(hashes)}")
print(f"Duplicate pairs ({len(duplicates)}):")
for f1, f2 in duplicates:
    print(f"  - '{f1}' is IDENTICAL to '{f2}'")
