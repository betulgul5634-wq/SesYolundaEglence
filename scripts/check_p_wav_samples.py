import wave
import numpy as np

for name in ["pa.wav", "pe.wav", "pı.wav", "pi.wav", "ap.wav", "ep.wav", "ıp.wav", "ip.wav"]:
    path = f"backend/pure_syllables/{name}"
    with wave.open(path, "rb") as wf:
        n = wf.getnframes()
        sr = wf.getframerate()
        data = np.frombuffer(wf.readframes(n), dtype=np.int16)
        print(f"{name:8}: frames={n}, sr={sr}, dur={n/sr:.3f}s, min={np.min(data)}, max={np.max(data)}")
