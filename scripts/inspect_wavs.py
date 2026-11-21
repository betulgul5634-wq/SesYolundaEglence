import os
import wave
import struct

pure_dir = 'backend/pure_syllables'
letters = ['p', 'b', 't', 'd', 'k', 'g', 'f', 'v', 's', 'z', 'ş', 'j', 'h', 'ç', 'c', 'm', 'n', 'l', 'r', 'y']

for l in letters:
    path = os.path.join(pure_dir, f"{l}.wav")
    if os.path.exists(path):
        with wave.open(path, 'rb') as wf:
            frames = wf.getnframes()
            rate = wf.getframerate()
            duration = frames / float(rate)
            raw = wf.readframes(frames)
            samples = struct.unpack(f"{frames * wf.getnchannels()}h", raw)
            max_amp = max(abs(s) for s in samples) if samples else 0
            rms = (sum(s*s for s in samples) / len(samples)) ** 0.5 if samples else 0
            print(f"[{l}.wav] dur={duration:.2f}s, rate={rate}, max={max_amp}, rms={rms:.1f}, size={len(raw)} bytes")
    else:
        print(f"[{l}.wav] NOT FOUND!")
