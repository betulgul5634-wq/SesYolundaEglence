import asyncio
import edge_tts
import miniaudio
import numpy as np
import wave
import io

async def synth_pcm(text, rate="-10%", pitch="+2Hz"):
    comm = edge_tts.Communicate(text, 'tr-TR-EmelNeural', rate=rate, pitch=pitch)
    mp3 = b''
    async for c in comm.stream():
        if c['type'] == 'audio': mp3 += c['data']
    dec = miniaudio.decode(mp3)
    return np.frombuffer(dec.samples, dtype=np.int16), dec.sample_rate, dec.nchannels

def clean_and_pad(samples, sr, ch, pad_before_ms=30, pad_after_ms=60):
    mono = samples.reshape(-1, 2).mean(axis=1) if ch == 2 else samples
    abs_m = np.abs(mono)
    win = int(sr * 0.01) # 10ms
    energy = np.convolve(abs_m, np.ones(win)/win, mode='same')
    thresh = np.max(energy) * 0.04
    idx = np.where(energy > thresh)[0]
    if len(idx) == 0:
        return samples
    start = max(0, idx[0] - int(sr * 0.02))
    end = min(len(mono), idx[-1] + int(sr * 0.04))
    
    trimmed = samples[start*ch : end*ch].copy()
    # 5ms fade in, 10ms fade out
    fin = int(sr * 0.005)
    fout = int(sr * 0.015)
    fade_in_curve = np.linspace(0.0, 1.0, fin)
    fade_out_curve = np.linspace(1.0, 0.0, fout)
    for c in range(ch):
        trimmed[c:fin*ch:ch] = (trimmed[c:fin*ch:ch] * fade_in_curve).astype(np.int16)
        trimmed[-fout*ch+c::ch] = (trimmed[-fout*ch+c::ch] * fade_out_curve).astype(np.int16)
        
    pad_before = np.zeros(int(sr * pad_before_ms / 1000.0) * ch, dtype=np.int16)
    pad_after = np.zeros(int(sr * pad_after_ms / 1000.0) * ch, dtype=np.int16)
    return np.concatenate([pad_before, trimmed, pad_after])

# Let's test the prompts:
# Notice that for ıp, what does EdgeTTS say for:
# "Iıp." or "Iııp." or "I-pı"? Let's test!
async def run():
    tests = [
        ("pa", "Pa."),
        ("pe", "Pee."),
        ("pı", "Pıı."),
        ("pi", "Pii."),
        ("po", "Poo."),
        ("pö", "Pöö."),
        ("pu", "Puu."),
        ("pü", "Püü."),
        ("ap", "Aap."),
        ("ep", "Eep."),
        ("ıp_1", "Iıp."),
        ("ıp_2", "Iııp."),
        ("ıp_3", "I p."),
        ("ip", "İip."),
        ("op", "Oop."),
        ("öp", "Ööp."),
        ("up", "Uup."),
        ("üp", "Üüp."),
        ("apa", "Apa."),
        ("epe", "Epe."),
        ("ıpı", "Ipı."),
        ("ipi", "İpi."),
        ("opo", "Opo."),
        ("öpö", "Öpö."),
        ("upu", "Upu."),
        ("üpü", "Üpü."),
        ("pap", "Pap."),
        ("pep", "Pep."),
        ("pıp", "Pıp."),
        ("pip", "Pip."),
        ("pop", "Pop."),
        ("pöp", "Pöp."),
        ("pup", "Pup."),
        ("püp", "Püp.")
    ]
    for tag, pr in tests:
        samples, sr, ch = await synth_pcm(pr)
        padded = clean_and_pad(samples, sr, ch)
        dur = len(padded) / (sr * ch)
        print(f"{tag:<8} ('{pr:<8}') -> padded dur: {dur:.3f}s, min: {padded.min()}, max: {padded.max()}")

asyncio.run(run())
