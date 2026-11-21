import asyncio, edge_tts, miniaudio, numpy as np, wave, os

out_dir = os.path.join("backend", "pure_syllables")
os.makedirs(out_dir, exist_ok=True)

def save_wav(name, samples_s16, sr, ch):
    path = os.path.join(out_dir, f"{name}.wav")
    with wave.open(path, "wb") as wf:
        wf.setnchannels(ch)
        wf.setsampwidth(2)
        wf.setframerate(sr)
        wf.writeframes(samples_s16.tobytes())
    dur = len(samples_s16) / (sr * ch)
    print(f"Saved [{name}.wav]: {dur:.3f}s")

async def get_audio_samples(text):
    comm = edge_tts.Communicate(text, "tr-TR-EmelNeural", rate="-3%", pitch="+4Hz")
    data = b""
    async for c in comm.stream():
        if c["type"] == "audio":
            data += c["data"]
    decoded = miniaudio.decode(data)
    samples = np.frombuffer(decoded.samples, dtype=np.int16).copy()
    return samples, decoded.sample_rate, decoded.nchannels

def trim_direct(samples, sr, ch, v_boost=1.4):
    mono = samples.reshape(-1, ch).mean(axis=1) if ch == 2 else samples
    abs_mono = np.abs(mono)
    window = int(sr * 0.01)
    energy = np.convolve(abs_mono, np.ones(window)/window, mode='same')
    max_e = np.max(energy)
    active = np.where(energy > max_e * 0.04)[0]
    start = max(0, active[0] - int(sr * 0.01))
    end = min(len(mono), active[-1] + int(sr * 0.01))
    
    cut = samples[start * ch : end * ch].copy().astype(np.float32)
    
    # Boost the final 35% of the sound (the 'v' region)
    v_start = int(len(cut) * 0.65)
    boost_len = len(cut) - v_start
    gain = np.linspace(1.0, v_boost, boost_len)
    for c in range(ch):
        cut[v_start + c :: ch] *= gain[::1] if ch == 1 else np.repeat(gain, ch)[c::ch][:len(cut[v_start + c :: ch])]
        
    # Smooth 15ms fade out
    fade_frames = int(sr * 0.015)
    fade = np.linspace(1.0, 0.0, fade_frames)
    for c in range(ch):
        cut[-fade_frames * ch + c :: ch] *= fade
        
    final = np.clip(cut, -32767, 32767).astype(np.int16)
    return final

async def main():
    # 1. Direct VC syllables (av, ev, ov, öv, uv, üv) - NO carrier, direct synthesis!
    for syl in ["av", "ev", "ov", "öv", "uv", "üv"]:
        samples, sr, ch = await get_audio_samples(syl)
        trimmed = trim_direct(samples, sr, ch)
        save_wav(syl, trimmed, sr, ch)
        
    # 2. 'ıv' from 'ıvır' - cut at 0.335s strictly BEFORE second 'ı' at 0.365s!
    samples, sr, ch = await get_audio_samples("ıvır")
    mono = samples.reshape(-1, ch).mean(axis=1) if ch == 2 else samples
    energy = np.convolve(np.abs(mono), np.ones(int(sr*0.01))/(sr*0.01), mode='same')
    start = np.where(energy > np.max(energy) * 0.05)[0][0]
    cut_start = max(0, start - int(sr * 0.01))
    cut_end = start + int(sr * 0.125) # strictly 125ms from start: covers 'ı' + 'v', stops before 2nd 'ı'
    cut = samples[cut_start * ch : cut_end * ch].copy().astype(np.float32)
    # 15ms fade out
    fade_frames = int(sr * 0.015)
    fade = np.linspace(1.0, 0.0, fade_frames)
    for c in range(ch):
        cut[-fade_frames * ch + c :: ch] *= fade
    final_iv = np.clip(cut, -32767, 32767).astype(np.int16)
    save_wav("ıv", final_iv, sr, ch)
    
    # 3. 'iv' from 'ivi' - cut strictly at 170ms from start, BEFORE second 'i' at 200ms!
    samples, sr, ch = await get_audio_samples("ivi")
    mono = samples.reshape(-1, ch).mean(axis=1) if ch == 2 else samples
    energy = np.convolve(np.abs(mono), np.ones(int(sr*0.01))/(sr*0.01), mode='same')
    start = np.where(energy > np.max(energy) * 0.05)[0][0]
    cut_start = max(0, start - int(sr * 0.01))
    cut_end = start + int(sr * 0.170) # strictly 170ms: covers 'i' + 'v', stops BEFORE 2nd 'i' at 200ms!
    cut = samples[cut_start * ch : cut_end * ch].copy().astype(np.float32)
    # 15ms fade out
    fade_frames = int(sr * 0.015)
    fade = np.linspace(1.0, 0.0, fade_frames)
    for c in range(ch):
        cut[-fade_frames * ch + c :: ch] *= fade
    final_i_v = np.clip(cut, -32767, 32767).astype(np.int16)
    save_wav("iv", final_i_v, sr, ch)

    # 4. Direct CVC syllables ending in 'v' (vav, vev, vıv, viv, vov, vöv, vuv, vüv)
    for syl in ["vav", "vev", "vıv", "viv", "vov", "vöv", "vuv", "vüv"]:
        samples, sr, ch = await get_audio_samples(syl)
        trimmed = trim_direct(samples, sr, ch)
        save_wav(syl, trimmed, sr, ch)

asyncio.run(main())
