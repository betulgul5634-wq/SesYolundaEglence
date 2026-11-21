import asyncio
import edge_tts
import miniaudio
import numpy as np
import wave
import os

async def synth(text):
    comm = edge_tts.Communicate(text, voice="tr-TR-EmelNeural", rate="+10%", pitch="+6Hz")
    data = b""
    async for c in comm.stream():
        if c["type"] == "audio": data += c["data"]
    dec = miniaudio.decode(data)
    samples = np.frombuffer(dec.samples, dtype=np.int16).copy()
    return samples, dec.nchannels, dec.sample_rate

def get_envelope(samples, ch, sr):
    mono = samples.reshape(-1, 2).mean(axis=1) if ch == 2 else samples
    abs_mono = np.abs(mono)
    window = int(sr * 0.005) # 5ms
    energy = np.convolve(abs_mono, np.ones(window)/window, mode='same')
    return mono, energy

async def make_pure_p_three():
    samples, ch, sr = await synth("pıt pıt")
    mono, energy = get_envelope(samples, ch, sr)
    thresh = np.max(energy) * 0.05
    speech_indices = np.where(energy > thresh)[0]
    
    burst_start = speech_indices[0]
    # The plosive burst of 'p' lasts ~65ms before vowel voicing starts
    burst_len = int(sr * 0.065) 
    burst = samples[burst_start * ch : (burst_start + burst_len) * ch].copy()
    
    # 5ms fade in, 10ms fade out to prevent clicks
    fade_in = int(sr * 0.005)
    fade_out = int(sr * 0.015)
    f_in = np.linspace(0.0, 1.0, fade_in)
    f_out = np.linspace(1.0, 0.0, fade_out)
    burst[:fade_in*ch:ch] = (burst[:fade_in*ch:ch] * f_in).astype(np.int16)
    burst[1:fade_in*ch:ch] = (burst[1:fade_in*ch:ch] * f_in).astype(np.int16)
    burst[-fade_out*ch::ch] = (burst[-fade_out*ch::ch] * f_out).astype(np.int16)
    burst[-fade_out*ch+1::ch] = (burst[-fade_out*ch+1::ch] * f_out).astype(np.int16)
    
    # Normalize burst volume
    peak = np.max(np.abs(burst))
    if peak > 0:
        burst = (burst / peak * 26000.0).astype(np.int16)
        
    silence = np.zeros(int(sr * 0.18) * ch, dtype=np.int16)
    p_three = np.concatenate([burst, silence, burst, silence, burst])
    
    with wave.open("test_pure_p_three.wav", "wb") as wf:
        wf.setnchannels(ch)
        wf.setsampwidth(2)
        wf.setframerate(sr)
        wf.writeframes(p_three.tobytes())
    dur = len(p_three) / (sr * ch)
    print(f"Generated test_pure_p_three.wav (dur: {dur:.3f}s)")

asyncio.run(make_pure_p_three())
