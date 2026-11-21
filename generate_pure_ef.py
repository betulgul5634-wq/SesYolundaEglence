import asyncio
import edge_tts
import miniaudio
import numpy as np
import wave
import io
import os

async def generate_pure_ef():
    comm = edge_tts.Communicate("efe", "tr-TR-EmelNeural", rate="-3%", pitch="+4Hz")
    data = b""
    async for c in comm.stream():
        if c["type"] == "audio":
            data += c["data"]
            
    decoded = miniaudio.decode(data)
    samples = np.frombuffer(decoded.samples, dtype=np.int16).copy()
    ch = decoded.nchannels
    sr_rate = decoded.sample_rate
    
    if ch == 2:
        mono = samples.reshape(-1, 2).mean(axis=1)
    else:
        mono = samples
        
    abs_mono = np.abs(mono)
    window = int(sr_rate * 0.01)
    energy = np.convolve(abs_mono, np.ones(window)/window, mode='same')
    
    threshold = np.max(energy) * 0.05
    speech_indices = np.where(energy > threshold)[0]
    start = speech_indices[0]
    
    # In 'efe':
    # 1. 'e' vowel (high energy, voiced)
    # 2. 'f' fricative (lower energy, no voice formants, pure friction noise)
    # 3. second 'e' vowel (energy rises back up with periodic voicing)
    
    # Let's find where 'f' starts: where vowel energy drops
    vowel1_end = start + int(sr_rate * 0.10)
    for i in range(vowel1_end, len(energy)):
        if energy[i] < np.max(energy) * 0.25:
            vowel1_end = i
            break
            
    # Then 'f' friction continues for around 100-200ms
    # Then second 'e' vowel starts: energy rises back above 30% of max
    f_end = vowel1_end + int(sr_rate * 0.10)
    for i in range(f_end, len(energy) - window):
        # Look for sudden increase in periodic amplitude indicating vowel 2
        if energy[i] > np.max(energy) * 0.35:
            f_end = i
            break
            
    # Cut right before vowel 2, with 20ms fade out on the fricative tail
    cut_end = f_end - int(sr_rate * 0.02)
    cut_start = max(0, start - int(sr_rate * 0.02))
    fade_len = int(sr_rate * 0.02)
    
    cut_samples = samples[cut_start * ch : cut_end * ch].copy()
    if ch == 2:
        fade = np.linspace(1.0, 0.0, fade_len)
        cut_samples.reshape(-1, 2)[-fade_len:, 0] = (cut_samples.reshape(-1, 2)[-fade_len:, 0] * fade).astype(np.int16)
        cut_samples.reshape(-1, 2)[-fade_len:, 1] = (cut_samples.reshape(-1, 2)[-fade_len:, 1] * fade).astype(np.int16)
    else:
        fade = np.linspace(1.0, 0.0, fade_len)
        cut_samples[-fade_len:] = (cut_samples[-fade_len:] * fade).astype(np.int16)

    out_file = os.path.join("backend", "pure_syllables", "ef.wav")
    with wave.open(out_file, "wb") as wf:
        wf.setnchannels(ch)
        wf.setsampwidth(2)
        wf.setframerate(sr_rate)
        wf.writeframes(cut_samples.tobytes())
        
    dur = len(cut_samples) / (sr_rate * ch)
    print(f"Generated pure ef.wav: {dur:.3f}s, start={cut_start/sr_rate:.3f}s, end={cut_end/sr_rate:.3f}s")

asyncio.run(generate_pure_ef())
