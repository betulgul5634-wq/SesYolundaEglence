import wave
import numpy as np

for name in ['cı', 'co', 'cu']:
    with wave.open(f'scripts/slices/{name}.wav', 'rb') as wf:
        n_frames = wf.getnframes()
        sr = wf.getframerate()
        ch = wf.getnchannels()
        samples = np.frombuffer(wf.readframes(n_frames), dtype=np.int16)
        if ch == 2:
            mono = samples.reshape(-1, 2).mean(axis=1)
        else:
            mono = samples
        dur = len(mono) / sr
        # compute zero crossing rate and RMS
        zcr = np.mean(np.diff(np.signbit(mono)))
        rms = np.sqrt(np.mean(mono**2))
        print(f"Slice {name:5s}: dur={dur:.3f}s, rms={rms:.0f}, zcr={zcr:.3f}")
