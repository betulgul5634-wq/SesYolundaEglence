import asyncio
import edge_tts
import miniaudio
import numpy as np
import wave
import os

async def synth_h():
    # In Turkish, "Hıh... Hıh... Hıh" or soft breath
    # Let's test EdgeTTS breath prompts
    comm = edge_tts.Communicate("Hıh... Hıh... Hıh...", voice="tr-TR-EmelNeural", rate="-5%", pitch="-2Hz")
    data = b""
    async for c in comm.stream():
        if c["type"] == "audio":
            data += c["data"]
    dec = miniaudio.decode(data)
    samples = np.frombuffer(dec.samples, dtype=np.int16).copy()
    sr = dec.sample_rate
    ch = dec.nchannels
    
    mono = samples.reshape(-1, 2).mean(axis=1) if ch == 2 else samples
    energy = np.convolve(np.abs(mono), np.ones(int(sr*0.01))/(sr*0.01), mode='same')
    thresh = np.max(energy) * 0.05
    idx = np.where(energy > thresh)[0]
    
    start = max(0, idx[0] - int(sr * 0.02))
    end = min(len(mono), idx[-1] + int(sr * 0.04))
    
    trimmed = samples[start*ch : end*ch].copy()
    
    # 5ms fade in, 15ms fade out
    fin = int(sr * 0.005)
    fout = int(sr * 0.015)
    fade_in_curve = np.linspace(0.0, 1.0, fin)
    fade_out_curve = np.linspace(1.0, 0.0, fout)
    for c in range(ch):
        trimmed[c:fin*ch:ch] = (trimmed[c:fin*ch:ch] * fade_in_curve).astype(np.int16)
        trimmed[-fout*ch+c::ch] = (trimmed[-fout*ch+c::ch] * fade_out_curve).astype(np.int16)
        
    peak = np.max(np.abs(trimmed))
    if peak > 0:
        scale = 25000.0 / peak
        trimmed = np.clip(trimmed * scale, -32767, 32767).astype(np.int16)
        
    pad_before = np.zeros(int(sr * 0.03) * ch, dtype=np.int16)
    pad_after = np.zeros(int(sr * 0.05) * ch, dtype=np.int16)
    final_audio = np.concatenate([pad_before, trimmed, pad_after])
    
    out_path = "backend/pure_syllables/h.wav"
    with wave.open(out_path, "wb") as wf:
        wf.setnchannels(ch)
        wf.setsampwidth(2)
        wf.setframerate(sr)
        wf.writeframes(final_audio.tobytes())
        
    dur = len(final_audio) / (sr * ch)
    print(f"Generated pure {out_path} (dur: {dur:.3f}s)")

asyncio.run(synth_h())
