import wave
import numpy as np

with wave.open('scripts/co_raw.wav', 'rb') as wf:
    data = wf.readframes(wf.getnframes())
    samples = np.frombuffer(data, dtype=np.int16).reshape(-1, wf.getnchannels()).mean(axis=1)

# Find onset
sr = 24000
thresh = np.max(np.abs(samples)) * 0.05
indices = np.where(np.abs(samples) > thresh)[0]
start = indices[0]
end = indices[-1]
active = samples[start:end]

# Check onset frequency / zero crossings
# An affricate [d͡ʒ] has high zero-crossing friction noise or burst followed by low formant vowel
zc = np.sum(np.diff(np.signbit(active[:int(sr*0.05)])))
print(f"co_raw active len: {len(active)/sr:.3f}s, zero crossings in first 50ms: {zc}")

with wave.open('scripts/cop.wav', 'rb') as wf:
    data = wf.readframes(wf.getnframes())
    samples_cop = np.frombuffer(data, dtype=np.int16).reshape(-1, wf.getnchannels()).mean(axis=1)

indices_cop = np.where(np.abs(samples_cop) > thresh)[0]
active_cop = samples_cop[indices_cop[0]:indices_cop[-1]]
zc_cop = np.sum(np.diff(np.signbit(active_cop[:int(sr*0.05)])))
print(f"cop active len: {len(active_cop)/sr:.3f}s, zero crossings in first 50ms: {zc_cop}")
