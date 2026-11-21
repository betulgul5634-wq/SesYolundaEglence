import os
import wave
import numpy as np

pure_dir = "backend/pure_syllables"

for name in ["pa.wav", "pe.wav", "pı.wav", "pi.wav", "ıp.wav", "ip.wav", "ap.wav", "ep.wav"]:
    path = os.path.join(pure_dir, name)
    if os.path.exists(path):
        with wave.open(path, "rb") as wf:
            frames = wf.getnframes()
            rate = wf.getframerate()
            duration = frames / rate
            raw = wf.readframes(frames)
            data = np.frombuffer(raw, dtype=np.int16)
            max_amp = np.max(np.abs(data)) if len(data) > 0 else 0
            print(f"{name:8}: duration={duration:.3f}s, rate={rate}, max_amp={max_amp}")
