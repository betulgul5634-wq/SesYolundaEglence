import wave
import numpy as np

for name in ['pe', 'pi', 'pa', 'pı']:
    with wave.open(f"test_out_{name}.wav", "rb") as wf:
        sr = wf.getframerate()
        ch = wf.getnchannels()
        samples = np.frombuffer(wf.readframes(wf.getnframes()), dtype=np.int16)
    mono = samples.reshape(-1, 2).mean(axis=1) if ch == 2 else samples
    energy = np.convolve(np.abs(mono), np.ones(int(sr*0.01))/(sr*0.01), mode='same')
    thresh = np.max(energy) * 0.05
    indices = np.where(energy > thresh)[0]
    start = indices[0] / sr
    end = indices[-1] / sr
    speech_dur = end - start
    print(f"{name:4}: speech from {start:.3f}s to {end:.3f}s (duration: {speech_dur:.3f}s)")
