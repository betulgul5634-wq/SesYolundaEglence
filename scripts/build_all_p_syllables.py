import asyncio
import edge_tts
import miniaudio
import numpy as np
import wave
import os

OUT_DIR = "backend/pure_syllables"
os.makedirs(OUT_DIR, exist_ok=True)

# Standard prompts for all 32 syllables
prompts = {
    # 1. CV (Düz)
    'pa': 'Pa.',
    'pe': 'Pe.',
    'pı': 'Pı.',
    'pi': 'Pi.',
    'po': 'Po.',
    'pö': 'Pö.',
    'pu': 'Pu.',
    'pü': 'Pü.',
    # 2. VC (Ters)
    'ap': 'Ap.',
    'ep': 'Ep.',
    'ıp': 'SPECIAL_VCV_SLICE_IP',  # Cleanly sliced from Ipı
    'ip': 'İp.',
    'op': 'Op.',
    'öp': 'Öp.',
    'up': 'Up.',
    'üp': 'Üp.',
    # 3. VCV (Ara)
    'apa': 'Apa.',
    'epe': 'Epe.',
    'ıpı': 'Ipı.',
    'ipi': 'İpi.',
    'opo': 'Opo.',
    'öpö': 'Öpö.',
    'upu': 'Upu.',
    'üpü': 'Üpü.',
    # 4. CVC (Kapalı)
    'pap': 'Pap.',
    'pep': 'Pep.',
    'pıp': 'Pıp.',
    'pip': 'Pip.',
    'pop': 'Pop.',
    'pöp': 'Pöp.',
    'pup': 'Pup.',
    'püp': 'Püp.',
}

async def synth_pcm(text, rate="-10%", pitch="+2Hz"):
    comm = edge_tts.Communicate(text, 'tr-TR-EmelNeural', rate=rate, pitch=pitch)
    mp3 = b''
    async for c in comm.stream():
        if c['type'] == 'audio':
            mp3 += c['data']
    dec = miniaudio.decode(mp3)
    return np.frombuffer(dec.samples, dtype=np.int16), dec.sample_rate, dec.nchannels

def clean_trim_pad(samples, sr, ch, pad_before_ms=30, pad_after_ms=50):
    mono = samples.reshape(-1, 2).mean(axis=1) if ch == 2 else samples
    abs_m = np.abs(mono)
    win = int(sr * 0.01) # 10ms
    energy = np.convolve(abs_m, np.ones(win)/win, mode='same')
    thresh = np.max(energy) * 0.04
    idx = np.where(energy > thresh)[0]
    if len(idx) == 0:
        return samples
    start = max(0, idx[0] - int(sr * 0.015))
    end = min(len(mono), idx[-1] + int(sr * 0.035))
    
    trimmed = samples[start*ch : end*ch].copy()
    
    # 5ms fade in, 10ms fade out to prevent clicks
    fin = int(sr * 0.005)
    fout = int(sr * 0.015)
    fade_in_curve = np.linspace(0.0, 1.0, fin)
    fade_out_curve = np.linspace(1.0, 0.0, fout)
    for c in range(ch):
        trimmed[c:fin*ch:ch] = (trimmed[c:fin*ch:ch] * fade_in_curve).astype(np.int16)
        trimmed[-fout*ch+c::ch] = (trimmed[-fout*ch+c::ch] * fade_out_curve).astype(np.int16)
        
    # Normalize peak volume to 26000
    peak = np.max(np.abs(trimmed))
    if peak > 0:
        scale = 26000.0 / peak
        trimmed = np.clip(trimmed * scale, -32767, 32767).astype(np.int16)
        
    pad_before = np.zeros(int(sr * pad_before_ms / 1000.0) * ch, dtype=np.int16)
    pad_after = np.zeros(int(sr * pad_after_ms / 1000.0) * ch, dtype=np.int16)
    return np.concatenate([pad_before, trimmed, pad_after]), sr, ch

async def make_sliced_ip():
    samples, sr, ch = await synth_pcm("Ipı.", rate="-10%", pitch="+2Hz")
    mono = samples.reshape(-1, 2).mean(axis=1) if ch == 2 else samples
    abs_m = np.abs(mono)
    win = int(sr * 0.005)
    energy = np.convolve(abs_m, np.ones(win)/win, mode='same')
    thresh = np.max(energy) * 0.05
    idx = np.where(energy > thresh)[0]
    
    speech_start = idx[0]
    speech_end = idx[-1]
    
    mid_start = speech_start + int(sr * 0.08)
    mid_end = speech_end - int(sr * 0.08)
    closure_idx = mid_start + np.argmin(energy[mid_start:mid_end])
    burst_idx = closure_idx + np.argmax(energy[closure_idx : closure_idx + int(sr*0.06)])
    
    ip_end = burst_idx + int(sr * 0.035)
    ip_slice = samples[speech_start*ch : ip_end*ch].copy()
    
    fout = int(sr * 0.012)
    fout_curve = np.linspace(1.0, 0.0, fout)
    for c in range(ch):
        ip_slice[-fout*ch+c::ch] = (ip_slice[-fout*ch+c::ch] * fout_curve).astype(np.int16)
        
    peak = np.max(np.abs(ip_slice))
    if peak > 0:
        scale = 26000.0 / peak
        ip_slice = np.clip(ip_slice * scale, -32767, 32767).astype(np.int16)
        
    pad_before = np.zeros(int(sr * 0.03) * ch, dtype=np.int16)
    pad_after = np.zeros(int(sr * 0.05) * ch, dtype=np.int16)
    return np.concatenate([pad_before, ip_slice, pad_after]), sr, ch

async def build_all():
    print("Building all 32 syllables for /p/...")
    results = {}
    for syl, pr in prompts.items():
        if pr == 'SPECIAL_VCV_SLICE_IP':
            final_audio, sr, ch = await make_sliced_ip()
        else:
            samples, sr, ch = await synth_pcm(pr, rate="-10%", pitch="+2Hz")
            final_audio, sr, ch = clean_trim_pad(samples, sr, ch)
            
        out_path = os.path.join(OUT_DIR, f"{syl}.wav")
        with wave.open(out_path, "wb") as wf:
            wf.setnchannels(ch)
            wf.setsampwidth(2)
            wf.setframerate(sr)
            wf.writeframes(final_audio.tobytes())
            
        dur = len(final_audio) / (sr * ch)
        results[syl] = (len(final_audio), dur, hash(final_audio.tobytes()))
        print(f"  [OK] {syl:<5} -> {dur:.3f}s (saved to {out_path})")
        
    # Check for duplicate files
    hashes = set()
    for syl, (length, dur, h) in results.items():
        if h in hashes:
            print(f"  [WARNING] Syllable {syl} has duplicate audio!")
        hashes.add(h)
    print("All 32 syllables generated successfully and verified unique!")

asyncio.run(build_all())
