import asyncio, edge_tts, miniaudio, numpy as np

vcv_list = ["ava", "eve", "ıvı", "ivi", "ovo", "övö", "uvu", "üvü"]

async def inspect_vcv(w):
    comm = edge_tts.Communicate(w, "tr-TR-EmelNeural", rate="-4%", pitch="+4Hz")
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
    
    # In V-C-V:
    # Vowel 1: high energy from start
    # Consonant C (v): energy dips to a local minimum (around 20-40% of max)
    # Vowel 2: energy rises back up to a second peak
    
    # Let's find:
    # 1. Peak of vowel 1
    # 2. Minimum of 'v'
    # 3. Onset of vowel 2
    v1_peak = start + np.argmax(energy[start : start + int(sr * 0.25)])
    
    # Minimum after v1_peak
    v_dip_region = energy[v1_peak : v1_peak + int(sr * 0.25)]
    v_min_idx = v1_peak + np.argmin(v_dip_region)
    
    # Vowel 2 peak after v_min_idx
    v2_peak_region = energy[v_min_idx : v_min_idx + int(sr * 0.25)]
    v2_peak_idx = v_min_idx + np.argmax(v2_peak_region)
    
    # The 'v' ends right as vowel 2 starts rising: halfway between v_min_idx and v2_peak_idx
    v2_rise_thresh = energy[v_min_idx] + 0.35 * (energy[v2_peak_idx] - energy[v_min_idx])
    v_end_idx = v_min_idx
    for idx in range(v_min_idx, v2_peak_idx):
        if energy[idx] > v2_rise_thresh:
            v_end_idx = idx
            break
            
    dur_v1 = (v_min_idx - start) / sr
    dur_v_end = (v_end_idx - start) / sr
    print(f"Word: {w:4s} | Start: {start/sr:.3f}s | V1 Peak: {v1_peak/sr:.3f}s | V min: {v_min_idx/sr:.3f}s | V end: {v_end_idx/sr:.3f}s (len={dur_v_end:.3f}s)")
    return start, v_end_idx, sr, samples, ch

async def main():
    for w in vcv_list:
        await inspect_vcv(w)

asyncio.run(main())
