import os, wave, numpy as np, re

with open('mobile/lib/data/sound_groups_data.dart', 'r', encoding='utf-8') as f:
    text = f.read()

pattern = r'syllables:\s*\[(.*?)\]'
matches = re.findall(pattern, text, re.DOTALL)

stage_syllables = []
for m in matches:
    for it in m.split(','):
        clean = it.strip().strip("'").strip('"')
        if clean and not clean.startswith('//'):
            stage_syllables.append(clean)

stage_syllables = sorted(list(set(stage_syllables)))
print(f"Total distinct syllables in sound_groups_data: {len(stage_syllables)}")

pure_dir = 'backend/pure_syllables'
flaws = []
for s in stage_syllables:
    fname = f"{s}.wav"
    p = os.path.join(pure_dir, fname)
    if not os.path.exists(p):
        flaws.append((s, "MISSING FILE"))
        continue
    with wave.open(p, 'rb') as wf:
        nf = wf.getnframes()
        sr = wf.getframerate()
        dur = nf / float(sr)
        raw = wf.readframes(nf)
        audio = np.frombuffer(raw, dtype=np.int16)
        if len(audio) == 0:
            flaws.append((s, "EMPTY FILE (0s)"))
            continue
        peak = np.max(np.abs(audio))
        rms = np.sqrt(np.mean(audio.astype(np.float64)**2))
        if dur < 0.15:
            flaws.append((s, f"TOO SHORT: {dur:.3f}s"))
        elif rms < 500 or peak < 5000:
            flaws.append((s, f"TOO QUIET: peak={peak}, rms={rms:.0f}"))

print(f"Total flaws in active stage syllables: {len(flaws)}")
for s, reason in flaws:
    print(f"  - {s}: {reason}")
