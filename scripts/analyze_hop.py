import wave
import numpy as np

with wave.open("test_hop_full.wav", "rb") as wf:
    sr = wf.getframerate()
    ch = wf.getnchannels()
    frames = wf.getnframes()
    samples = np.frombuffer(wf.readframes(frames), dtype=np.int16)

mono = samples.reshape(-1, 2).mean(axis=1) if ch == 2 else samples
window = int(sr * 0.005)
energy = np.convolve(np.abs(mono), np.ones(window)/window, mode='same')
max_e = np.max(energy)
print("Max energy:", max_e)

# Find vowel peak
vowel_peak = np.argmax(energy)
print(f"Vowel peak at {vowel_peak/sr:.3f}s")

# After vowel peak, energy drops to closure silence
# Then there is a burst (plosive release)
post_vowel = energy[vowel_peak:]
# find where energy drops below 3% of max_e (closure)
closure_indices = np.where(post_vowel < max_e * 0.03)[0]
if len(closure_indices) > 0:
    closure_start = vowel_peak + closure_indices[0]
    print(f"Closure start at {closure_start/sr:.3f}s")
    # after closure start, find the burst: energy rises above threshold
    burst_indices = np.where(energy[closure_start:] > max_e * 0.05)[0]
    if len(burst_indices) > 0:
        burst_start = closure_start + burst_indices[0]
        # find where burst ends
        burst_end = burst_start + int(sr * 0.08) # 80ms burst
        print(f"Burst detected from {burst_start/sr:.3f}s to {burst_end/sr:.3f}s ({burst_end - burst_start} frames)")
        
        # cut the burst
        burst = samples[burst_start * ch : burst_end * ch].copy()
        # amplify burst so it's crisp
        burst_peak = np.max(np.abs(burst))
        if burst_peak > 0:
            burst = (burst / burst_peak * 26000.0).astype(np.int16)
            
        # save single burst
        with wave.open("single_p_burst.wav", "wb") as out:
            out.setnchannels(ch)
            out.setsampwidth(2)
            out.setframerate(sr)
            out.writeframes(burst.tobytes())
        print("Saved single_p_burst.wav")
        
        # create triple burst: pop ... pop ... pop
        gap = np.zeros(int(sr * 0.18) * ch, dtype=np.int16)
        triple = np.concatenate([burst, gap, burst, gap, burst])
        with wave.open("triple_p_burst.wav", "wb") as out:
            out.setnchannels(ch)
            out.setsampwidth(2)
            out.setframerate(sr)
            out.writeframes(triple.tobytes())
        print(f"Saved triple_p_burst.wav (dur: {len(triple)/(ch*sr):.2f}s)")
    else:
        print("No burst found after closure")
