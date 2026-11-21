import wave
import numpy as np

with wave.open("p_burst_3.wav", "rb") as wf:
    nchannels = wf.getnchannels()
    sr = wf.getframerate()
    frames = wf.getnframes()
    raw = wf.readframes(frames)
    samples = np.frombuffer(raw, dtype=np.int16)
    print(f"p_burst_3.wav: channels={nchannels}, sr={sr}, frames={frames}, dur={frames/sr:.2f}s")
    # find peaks
    mono = samples.reshape(-1, 2).mean(axis=1) if nchannels == 2 else samples
    abs_mono = np.abs(mono)
    window = int(sr * 0.01)
    energy = np.convolve(abs_mono, np.ones(window)/window, mode='same')
    peaks = np.where(energy > np.max(energy) * 0.3)[0]
    print(f"Energy max: {np.max(energy)}, active points: {len(peaks)}")
