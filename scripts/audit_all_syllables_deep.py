import re
import os
import wave
import hashlib

with open('mobile/lib/data/sound_groups_data.dart', encoding='utf-8') as f:
    sg_content = f.read()

stages = re.findall(r"SoundStage\((.*?)\n  \),", sg_content, re.DOTALL)
pure_dir = "backend/pure_syllables"

def get_list(block, name):
    m = re.search(name + r':\s*\[(.*?)\]', block, re.DOTALL)
    if not m: return []
    return re.findall(r"'([^']+)'", m.group(1))

def get_val(block, name):
    m = re.search(name + r":\s*'([^']+)'", block)
    return m.group(1) if m else ''

# Map file hashes to names
file_hashes = {}
for fn in os.listdir(pure_dir):
    if fn.endswith('.wav'):
        path = os.path.join(pure_dir, fn)
        with open(path, 'rb') as fp:
            h = hashlib.md5(fp.read()).hexdigest()
        file_hashes[fn] = h

# Reverse hash map: hash -> list of filenames
hash_to_files = {}
for fn, h in file_hashes.items():
    hash_to_files.setdefault(h, []).append(fn)

print(f"{'Sound':<8} {'Total Syls':<12} {'Missing':<10} {'Duplicates Found in Pure Syls':<35}")
print("-" * 75)

all_syl_issues = {}

for block in stages:
    phoneme = get_val(block, 'phoneme')
    letter = get_val(block, 'soundLetter').lower()
    syls = get_list(block, 'syllables')
    
    missing = []
    dups = []
    
    for s in syls:
        filename = f"{s}.wav"
        path = os.path.join(pure_dir, filename)
        if not os.path.exists(path):
            missing.append(s)
        else:
            h = file_hashes.get(filename)
            same_files = [x for x in hash_to_files.get(h, []) if x != filename]
            if same_files:
                dups.append(f"{filename} == {same_files[0]}")
                
    if missing or dups:
        all_syl_issues[phoneme] = {'missing': missing, 'dups': dups}
        print(f"{phoneme:<8} {len(syls):<12} {len(missing):<10} {', '.join(dups[:3])}")
    else:
        print(f"{phoneme:<8} {len(syls):<12} 0          None (All OK)")
