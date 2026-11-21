import asyncio
import ssl
import edge_tts
import miniaudio
import numpy as np
import wave
import os

# Windows SSL yapılandırması
_ssl_ctx = ssl.create_default_context()
_ssl_ctx.check_hostname = False
_ssl_ctx.verify_mode = ssl.CERT_NONE
edge_tts.communicate._SSL_CTX = _ssl_ctx
edge_tts.voices._SSL_CTX = _ssl_ctx

OUT_DIR = "backend/pure_syllables"
os.makedirs(OUT_DIR, exist_ok=True)

short_syllables = {
    'ag': 'Ag.',
    'am': 'Am.',
    'eg': 'Eg.',
    'em': 'Em.',
    'gig': 'Gig.',
    'ig': 'İg.',
    'il': 'İl.',
    'im': 'İm.',
    'iv': 'İv.',
    'mo': 'Mo.',
    'mu': 'Mu.',
    'mö': 'Mö.',
    'og': 'Og.',
    'olo': 'O lo.',
    'om': 'Om.',
    'ug': 'Ug.',
    'ulu': 'U lu.',
    'um': 'Um.',
    'ög': 'Ög.',
    'öm': 'Öm.',
    'üg': 'Üg.',
    'üm': 'Üm.',
    'ıg': 'Ig.',
    'ılı': 'I lı.',
}

def smart_trim_and_normalize(samples, sr, ch, min_dur=0.32):
    mono = samples.reshape(-1, 2).mean(axis=1) if ch == 2 else samples
    abs_m = np.abs(mono).astype(np.float64)
    win = int(sr * 0.02)
    energy = np.convolve(abs_m, np.ones(win)/win, mode='same')
    
    max_e = np.max(energy)
    if max_e < 100:
        return None
        
    thresh = max(150.0, max_e * 0.015)
    idx = np.where(energy > thresh)[0]
    if len(idx) == 0:
        return None
        
    start = max(0, idx[0] - int(sr * 0.040))
    end = min(len(mono), idx[-1] + int(sr * 0.060))
    
    cur_len = end - start
    min_len = int(sr * min_dur)
    if cur_len < min_len:
        deficit = min_len - cur_len
        start = max(0, start - deficit // 2)
        end = min(len(mono), end + (deficit - deficit // 2))
        
    trimmed = samples[start*ch : end*ch].copy().astype(np.float64)
    
    fin = int(sr * 0.010)
    fout = int(sr * 0.020)
    fade_in = np.linspace(0.0, 1.0, fin)
    fade_out = np.linspace(1.0, 0.0, fout)
    
    for c in range(ch):
        trimmed[c:fin*ch:ch] *= fade_in
        trimmed[-fout*ch+c::ch] *= fade_out
        
    peak = np.max(np.abs(trimmed))
    if peak > 0:
        scale = 26000.0 / peak
        trimmed = np.clip(trimmed * scale, -32767, 32767).astype(np.int16)
        
    pad_in = np.zeros(int(sr * 0.030) * ch, dtype=np.int16)
    pad_out = np.zeros(int(sr * 0.050) * ch, dtype=np.int16)
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
    
    clean = smart_trim_and_normalize(samps, sr, ch, min_dur=0.32)
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
    print(f"REPAIRED {syl}.wav: dur={dur:.3f}s, peak={peak}, rms={rms:.0f}", flush=True)

async def main():
    print(f"Total syllables to repair: {len(short_syllables)}", flush=True)
    for syl, prompt in short_syllables.items():
        try:
            await generate_syl(syl, prompt)
        except Exception as e:
            print(f"Error {syl}: {e}", flush=True)

if __name__ == '__main__':
    asyncio.run(main())
