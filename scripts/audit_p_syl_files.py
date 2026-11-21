import os
import wave

PURE_DIR = "backend/pure_syllables"
syls = [
    'pa', 'pe', 'pı', 'pi', 'po', 'pö', 'pu', 'pü',
    'ap', 'ep', 'ıp', 'ip', 'op', 'öp', 'up', 'üp',
    'apa', 'epe', 'ıpı', 'ipi', 'opo', 'öpö', 'upu', 'üpü',
    'pap', 'pep', 'pıp', 'pip', 'pop', 'pöp', 'pup', 'püp'
]

print(f"{'Syllable':<8} {'Status':<10} {'Frames':<10} {'SampleRate':<12} {'Duration':<10}")
print("-" * 55)

for s in syls:
    path = os.path.join(PURE_DIR, f"{s}.wav")
    if os.path.exists(path):
        with wave.open(path, 'rb') as wf:
            frames = wf.getnframes()
            sr = wf.getframerate()
            dur = frames / sr
            print(f"{s:<8} {'EXISTS':<10} {frames:<10} {sr:<12} {dur:.3f}s")
    else:
        print(f"{s:<8} {'MISSING':<10}")
