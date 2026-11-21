import wave
import numpy as np

for name in ['test_ip_Iıp.wav', 'test_ip_ıp.wav', 'test_vc_ip.wav']:
    with wave.open(name, 'rb') as wf:
        sr = wf.getframerate()
        ch = wf.getnchannels()
        samples = np.frombuffer(wf.readframes(wf.getnframes()), dtype=np.int16)
    mono = samples.reshape(-1, 2).mean(axis=1) if ch == 2 else samples
    energy = np.convolve(np.abs(mono), np.ones(int(sr*0.01))/(sr*0.01), mode='same')
    idx = np.where(energy > np.max(energy)*0.05)[0]
    speech = mono[idx[0]:idx[-1]]
    dur = len(speech)/sr
    
    # Calculate spectral centroid (brightness/vowel quality)
    # Turkish 'i' has high F2/F3 (>2500Hz), 'ı' has low F2 (~1400Hz)
    fft_vals = np.abs(np.fft.rfft(speech))
    freqs = np.fft.rfftfreq(len(speech), 1.0/sr)
    centroid = np.sum(freqs * fft_vals) / np.sum(fft_vals)
    print(f"{name:<20}: dur={dur:.3f}s, spectral_centroid={centroid:.1f}Hz, peak={np.max(np.abs(speech))}")
