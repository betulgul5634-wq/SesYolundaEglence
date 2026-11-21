import asyncio, edge_tts, miniaudio, numpy as np, wave, os

OUT_DIR = "backend/pure_syllables"
os.makedirs(OUT_DIR, exist_ok=True)

flawed_syllables = {
    'ab': 'Ab.',
    'al': 'Al.',
    'lü': 'Lü.',
    'ma': 'Ma.',
    'mam': 'Mam.',
    'me': 'Me.',
    'mi': 'Mi.',
    'mü': 'Mü.',
    'mı': 'Mı.',
    'ol': 'Ol.',
    'ul': 'Ul.',
    'uz': 'Uz.',
    'çü': 'Çü.',
    'ül': 'Ül.',
    'ıl': 'Il.',
    'ıv': 'Iv.',
}

def smart_trim_and_normalize(samples, sr, ch, min_dur=0.25):
    mono = samples.reshape(-1, 2).mean(axis=1) if ch == 2 else samples
    abs_m = np.abs(mono).astype(np.float64)
    win = int(sr * 0.02) # 20ms
    energy = np.convolve(abs_m, np.ones(win)/win, mode='same')
    
    max_e = np.max(energy)
    if max_e < 100:
        return None
        
    thresh = max(150.0, max_e * 0.015)
    idx = np.where(energy > thresh)[0]
    if len(idx) == 0:
        return None
        
    start = max(0, idx[0] - int(sr * 0.035)) # 35ms lead-in
    end = min(len(mono), idx[-1] + int(sr * 0.055)) # 55ms tail
    
    # Ensure minimum duration
    cur_len = end - start
    min_len = int(sr * min_dur)
    if cur_len < min_len:
        deficit = min_len - cur_len
        start = max(0, start - deficit // 2)
        end = min(len(mono), end + (deficit - deficit // 2))
        
    trimmed = samples[start*ch : end*ch].copy().astype(np.float64)
    
    # Fade in / out
    fin = int(sr * 0.008) # 8ms
    fout = int(sr * 0.018) # 18ms
    fade_in = np.linspace(0.0, 1.0, fin)
    fade_out = np.linspace(1.0, 0.0, fout)
    
    for c in range(ch):
        trimmed[c:fin*ch:ch] *= fade_in
        trimmed[-fout*ch+c::ch] *= fade_out
        
    peak = np.max(np.abs(trimmed))
    if peak > 0:
        scale = 26000.0 / peak
        trimmed = np.clip(trimmed * scale, -32767, 32767).astype(np.int16)
        
    # Lead and tail padding
    pad_in = np.zeros(int(sr * 0.025) * ch, dtype=np.int16)
    pad_out = np.zeros(int(sr * 0.040) * ch, dtype=np.int16)
    return np.concatenate([pad_in, trimmed, pad_out])

async def generate_syl(syl, prompt):
    comm = edge_tts.Communicate(prompt, 'tr-TR-EmelNeural', rate='-8%', pitch='+1Hz')
    mp3 = b''
    async for c in comm.stream():
        if c['type'] == 'audio':
            mp3 += c['data']
    dec = miniaudio.decode(mp3)
    samps = np.frombuffer(dec.samples, dtype=np.int16)
    sr = dec.sample_rate
    ch = dec.nchannels
    
    clean = smart_trim_and_normalize(samps, sr, ch)
    if clean is None:
        raise ValueError(f"Failed to process {syl}")
        
    out_p = os.path.join(OUT_DIR, f"{syl}.wav")
    with wave.open(out_p, 'wb') as wf:
        wf.setnchannels(ch)
        wf.setsampwidth(2)
        wf.setframerate(sr)
        wf.writeframes(clean.tobytes())
        
    dur = len(clean) / (sr * ch)
    rms = np.sqrt(np.mean(clean.astype(np.float64)**2))
    peak = np.max(np.abs(clean))
    print(f"FIXED {syl}.wav: dur={dur:.3f}s, peak={peak}, rms={rms:.0f}")

async def main():
    for syl, prompt in flawed_syllables.items():
        await generate_syl(syl, prompt)
    print("RE-SYNTHESIS OF ALL 16 FLAWED SYLLABLES COMPLETE!")

if __name__ == '__main__':
    asyncio.run(main())
