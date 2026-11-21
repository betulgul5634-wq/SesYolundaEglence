import wave
import numpy as np

for name in ['ic.wav', 'üc.wav']:
    path = f'backend/pure_syllables/{name}'
    with wave.open(path, 'rb') as wf:
        data = wf.readframes(wf.getnframes())
        samples = np.frombuffer(data, dtype=np.int16).reshape(-1, wf.getnchannels()).mean(axis=1)
        sr = wf.getframerate()
        q = np.array_split(samples, 4)
        rms = [int(np.sqrt(np.mean(x**2))) for x in q]
        print(f"{name:8s} len={len(samples)/sr:.3f}s RMS chunks={rms}")
