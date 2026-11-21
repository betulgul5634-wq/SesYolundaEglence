import asyncio, edge_tts, miniaudio, numpy as np, wave, os

async def slice_vcv(word, out_filename, cut_ms_start, cut_ms_len):
    comm = edge_tts.Communicate(word, "tr-TR-EmelNeural", rate="-3%", pitch="+4Hz")
    data = b""
    async for c in comm.stream():
        if c["type"] == "audio":
            data += c["data"]
            
    decoded = miniaudio.decode(data)
    samples = np.frombuffer(decoded.samples, dtype=np.int16).copy()
    ch = decoded.nchannels
    sr = decoded.sample_rate
    
    if ch == 2:
        mono = samples.reshape(-1, 2).mean(axis=1)
    else:
        mono = samples
        
    abs_mono = np.abs(mono)
    window = int(sr * 0.01)
    energy = np.convolve(abs_mono, np.ones(window)/window, mode='same')
    
    max_e = np.max(energy)
    thresh = max_e * 0.05
    speech_indices = np.where(energy > thresh)[0]
    start = speech_indices[0]
    
    cut_start = max(0, start - int(sr * 0.01))
    cut_end = start + int(sr * cut_ms_len)
    fade_len = int(sr * 0.02)
    
    cut_samples = samples[cut_start * ch : cut_end * ch].copy()
    fade = np.linspace(1.0, 0.0, fade_len)
    if ch == 2:
        cut_samples.reshape(-1, 2)[-fade_len:, 0] = (cut_samples.reshape(-1, 2)[-fade_len:, 0] * fade).astype(np.int16)
        cut_samples.reshape(-1, 2)[-fade_len:, 1] = (cut_samples.reshape(-1, 2)[-fade_len:, 1] * fade).astype(np.int16)
    else:
        cut_samples[-fade_len:] = (cut_samples[-fade_len:] * fade).astype(np.int16)
        
    os.makedirs(os.path.join("backend", "pure_syllables"), exist_ok=True)
    out_file = os.path.join("backend", "pure_syllables", out_filename)
    with wave.open(out_file, "wb") as wf:
        wf.setnchannels(ch)
        wf.setsampwidth(2)
        wf.setframerate(sr)
        wf.writeframes(cut_samples.tobytes())
        
    dur = len(cut_samples) / (sr * ch)
    print(f"Generated {out_filename}: {dur:.3f}s from '{word}'")

async def main():
    # 'ivi' -> 'iv'
    await slice_vcv("ivi", "iv.wav", 0, 0.16)
    # 'ovo' -> 'ov'
    await slice_vcv("ovo", "ov.wav", 0, 0.16)

asyncio.run(main())
