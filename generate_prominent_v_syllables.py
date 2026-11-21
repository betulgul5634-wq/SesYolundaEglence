import asyncio, edge_tts, miniaudio, numpy as np, wave, os

# Map target syllable to source carrier and syllable name
VC_PAIRS = [
    ("av", "ava"),
    ("ev", "eve"),
    ("ıv", "ıvı"),
    ("iv", "ivi"),
    ("ov", "ovo"),
    ("öv", "övö"),
    ("uv", "uvu"),
    ("üv", "üvü"),
]

CVC_PAIRS = [
    ("vav", "vav"),
    ("vev", "vev"),
    ("vıv", "vıv"),
    ("viv", "viv"),
    ("vov", "vov"),
    ("vöv", "vöv"),
    ("vuv", "vuv"),
    ("vüv", "vüv"),
]

async def create_prominent_v_syllables():
    out_dir = os.path.join("backend", "pure_syllables")
    os.makedirs(out_dir, exist_ok=True)
    
    # 1. Process VC syllables from VCV carriers
    for syl, carrier in VC_PAIRS:
        comm = edge_tts.Communicate(carrier, "tr-TR-EmelNeural", rate="-4%", pitch="+4Hz")
        data = b""
        async for c in comm.stream():
            if c["type"] == "audio":
                data += c["data"]
        decoded = miniaudio.decode(data)
        samples = np.frombuffer(decoded.samples, dtype=np.int16).copy()
        sr = decoded.sample_rate
        ch = decoded.nchannels
        
        mono = samples.reshape(-1, ch).mean(axis=1) if ch == 2 else samples
        abs_mono = np.abs(mono)
        window = int(sr * 0.01)
        energy = np.convolve(abs_mono, np.ones(window)/window, mode='same')
        max_e = np.max(energy)
        start = np.where(energy > max_e * 0.05)[0][0]
        
        # Find v1_peak, v_min_idx, v2_peak_idx
        v1_peak = start + np.argmax(energy[start : start + int(sr * 0.35)])
        v_dip_region = energy[v1_peak : v1_peak + int(sr * 0.35)]
        v_min_idx = v1_peak + np.argmin(v_dip_region)
        v2_peak_region = energy[v_min_idx : v_min_idx + int(sr * 0.35)]
        v2_peak_idx = v_min_idx + np.argmax(v2_peak_region)
        
        # Cut point right as second vowel starts rising (captures entire 'v')
        # We go slightly past v_min_idx to ensure full, rich 'v' friction
        v2_rise_thresh = energy[v_min_idx] + 0.30 * (energy[v2_peak_idx] - energy[v_min_idx])
        v_end_idx = v_min_idx
        for idx in range(v_min_idx, v2_peak_idx):
            if energy[idx] > v2_rise_thresh:
                v_end_idx = idx
                break
                
        cut_start = max(0, start - int(sr * 0.01))
        cut_end = v_end_idx
        
        raw_cut = samples[cut_start * ch : cut_end * ch].copy().astype(np.float32)
        
        # BOOST THE 'V' REGION (Make V dominant and prominent!):
        # From v1_peak to cut_end, apply a smooth gain boost up to 1.7x (+5 dB)
        boost_start = (v1_peak - cut_start) * ch
        boost_len = len(raw_cut) - boost_start
        if boost_len > 0:
            gain = np.linspace(1.0, 1.75, boost_len)
            raw_cut[boost_start:] *= gain
            
        # Also sustain the terminal 'v' by appending a 60ms rich 'v' tail before fade
        # Take the last 40ms of 'v' and loop it once with crossfade
        v_tail_len = int(sr * 0.05) * ch
        if len(raw_cut) > v_tail_len:
            v_tail = raw_cut[-v_tail_len:].copy()
            # Append tail
            raw_cut = np.concatenate([raw_cut, v_tail * 1.5])
            
        # Smooth 25ms fade-out at the very end
        fade_frames = int(sr * 0.025)
        fade = np.linspace(1.0, 0.0, fade_frames)
        for c_idx in range(ch):
            raw_cut[-fade_frames * ch + c_idx :: ch] *= fade
            
        # Clip to 16-bit range
        final_samples = np.clip(raw_cut, -32767, 32767).astype(np.int16)
        
        out_path = os.path.join(out_dir, f"{syl}.wav")
        with wave.open(out_path, "wb") as wf:
            wf.setnchannels(ch)
            wf.setsampwidth(2)
            wf.setframerate(sr)
            wf.writeframes(final_samples.tobytes())
            
        dur = len(final_samples) / (sr * ch)
        print(f"Generated VC [{syl}.wav] from '{carrier}': {dur:.3f}s with prominent V!")

    # 2. Process CVC syllables (vav, vev, viv, etc.)
    # In CVC, Edge-TTS says the whole syllable, but swallows the final v.
    # We synthesize carrier or CVC word, detect vowel peak and end of final v, boost final v!
    for syl, carrier in CVC_PAIRS:
        comm = edge_tts.Communicate(carrier, "tr-TR-EmelNeural", rate="-3%", pitch="+4Hz")
        data = b""
        async for c in comm.stream():
            if c["type"] == "audio":
                data += c["data"]
        decoded = miniaudio.decode(data)
        samples = np.frombuffer(decoded.samples, dtype=np.int16).copy().astype(np.float32)
        sr = decoded.sample_rate
        ch = decoded.nchannels
        
        mono = samples.reshape(-1, ch).mean(axis=1) if ch == 2 else samples
        abs_mono = np.abs(mono)
        window = int(sr * 0.01)
        energy = np.convolve(abs_mono, np.ones(window)/window, mode='same')
        max_e = np.max(energy)
        start = np.where(energy > max_e * 0.05)[0][0]
        
        # Find vowel peak (the maximum energy in the middle of CVC)
        vowel_peak = start + np.argmax(energy[start:])
        
        # Find where sound ends (drops below 5% of max)
        end_indices = np.where(energy[vowel_peak:] < max_e * 0.04)[0]
        if len(end_indices) > 0:
            end = vowel_peak + end_indices[0]
        else:
            end = len(energy) - 1
            
        cut_start = max(0, start - int(sr * 0.01))
        cut_end = min(len(samples)//ch, end + int(sr * 0.04))
        
        raw_cut = samples[cut_start * ch : cut_end * ch].copy()
        
        # Boost final V region (from halfway between vowel_peak and end)
        v_boost_start = (vowel_peak + (end - vowel_peak) // 3 - cut_start) * ch
        v_boost_len = len(raw_cut) - v_boost_start
        if v_boost_len > 0:
            gain = np.linspace(1.0, 1.8, v_boost_len)
            raw_cut[v_boost_start:] *= gain
            
        fade_frames = int(sr * 0.025)
        fade = np.linspace(1.0, 0.0, fade_frames)
        for c_idx in range(ch):
            raw_cut[-fade_frames * ch + c_idx :: ch] *= fade
            
        final_samples = np.clip(raw_cut, -32767, 32767).astype(np.int16)
        out_path = os.path.join(out_dir, f"{syl}.wav")
        with wave.open(out_path, "wb") as wf:
            wf.setnchannels(ch)
            wf.setsampwidth(2)
            wf.setframerate(sr)
            wf.writeframes(final_samples.tobytes())
            
        dur = len(final_samples) / (sr * ch)
        print(f"Generated CVC [{syl}.wav]: {dur:.3f}s with prominent V!")

asyncio.run(create_prominent_v_syllables())
