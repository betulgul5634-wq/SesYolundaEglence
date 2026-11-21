import asyncio
import edge_tts
import miniaudio
import numpy as np
import wave
import os

OUT_DIR = "backend/pure_syllables"

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
        return samples, sr, ch
    start = max(0, idx[0] - int(sr * 0.015))
    end = min(len(mono), idx[-1] + int(sr * 0.035))
    
    trimmed = samples[start*ch : end*ch].copy()
    
    fin = int(sr * 0.005)
    fout = int(sr * 0.015)
    fade_in_curve = np.linspace(0.0, 1.0, fin)
    fade_out_curve = np.linspace(1.0, 0.0, fout)
    for c in range(ch):
        trimmed[c:fin*ch:ch] = (trimmed[c:fin*ch:ch] * fade_in_curve).astype(np.int16)
        trimmed[-fout*ch+c::ch] = (trimmed[-fout*ch+c::ch] * fade_out_curve).astype(np.int16)
        
    peak = np.max(np.abs(trimmed))
    if peak > 0:
        scale = 26000.0 / peak
        trimmed = np.clip(trimmed * scale, -32767, 32767).astype(np.int16)
        
    pad_before = np.zeros(int(sr * pad_before_ms / 1000.0) * ch, dtype=np.int16)
    pad_after = np.zeros(int(sr * pad_after_ms / 1000.0) * ch, dtype=np.int16)
    return np.concatenate([pad_before, trimmed, pad_after]), sr, ch

def save_wav(samples, sr, ch, filepath):
    with wave.open(filepath, 'wb') as wf:
        wf.setnchannels(ch)
        wf.setsampwidth(2)
        wf.setframerate(sr)
        wf.writeframes(samples.tobytes())

# Slicing VC from VCV for tricky unvoiced consonants or Turkish 'ı'
# For example, for 'ıC', synthesize 'I[C]ı.' and slice the first half!
async def make_sliced_vc(vowel, consonant):
    # e.g. vowel='ı', consonant='f' -> 'Ifı.'
    v_cap = 'I' if vowel == 'ı' else vowel.upper()
    v_low = vowel
    c = consonant
    prompt = f"{v_cap}{c}{v_low}."
    samples, sr, ch = await synth_pcm(prompt, rate="-10%", pitch="+2Hz")
    mono = samples.reshape(-1, 2).mean(axis=1) if ch == 2 else samples
    abs_m = np.abs(mono)
    win = int(sr * 0.008)
    energy = np.convolve(abs_m, np.ones(win)/win, mode='same')
    thresh = np.max(energy) * 0.05
    idx = np.where(energy > thresh)[0]
    if len(idx) == 0:
        return clean_trim_pad(samples, sr, ch)
    
    first_active = idx[0]
    last_active = idx[-1]
    mid_active = first_active + (last_active - first_active) // 2
    
    # In VCV, the consonant is in the middle valley of energy
    # Find local minimum between first 25% and 75%
    search_start = first_active + int((last_active - first_active) * 0.25)
    search_end = first_active + int((last_active - first_active) * 0.75)
    mid_dip = search_start + np.argmin(energy[search_start:search_end])
    
    # Take from start to slightly past mid_dip
    cut_end = min(len(mono), mid_dip + int(sr * 0.04))
    cut_start = max(0, first_active - int(sr * 0.02))
    sliced = samples[cut_start*ch : cut_end*ch].copy()
    
    fout = int(sr * 0.02)
    fade_out_curve = np.linspace(1.0, 0.0, fout)
    for c_i in range(ch):
        sliced[-fout*ch+c_i::ch] = (sliced[-fout*ch+c_i::ch] * fade_out_curve).astype(np.int16)
        
    peak = np.max(np.abs(sliced))
    if peak > 0:
        scale = 26000.0 / peak
        sliced = np.clip(sliced * scale, -32767, 32767).astype(np.int16)
        
    pad_before = np.zeros(int(sr * 0.03) * ch, dtype=np.int16)
    pad_after = np.zeros(int(sr * 0.05) * ch, dtype=np.int16)
    return np.concatenate([pad_before, sliced, pad_after]), sr, ch

async def test_corrupts():
    corrupts = [
        ('şa', 'Şa.'),
        ('bo', 'Bo.'),
        ('bu', 'Bu.'),
        ('zu', 'Zu.'),
        ('zö', 'Zö.'),
        ('öz', 'Öz.'),
        ('ıf', None), # slice
        ('ıy', None), # slice
    ]
    for syl, prompt in corrupts:
        print(f"Synthesizing {syl}...")
        if prompt:
            samps, sr, ch = await synth_pcm(prompt)
            samps, sr, ch = clean_trim_pad(samps, sr, ch)
        else:
            samps, sr, ch = await make_sliced_vc(syl[0], syl[1])
        out_p = os.path.join(OUT_DIR, f"{syl}.wav")
        save_wav(samps, sr, ch, out_p)
        print(f"Saved {syl}.wav ({len(samps)/sr/ch:.2f}s)")

if __name__ == '__main__':
    asyncio.run(test_corrupts())
