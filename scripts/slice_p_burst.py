import asyncio
import edge_tts
import miniaudio
import numpy as np
import wave
import os

async def synth(text):
    comm = edge_tts.Communicate(text, voice="tr-TR-EmelNeural", rate="-5%", pitch="+5Hz")
    data = b""
    async for c in comm.stream():
        if c["type"] == "audio": data += c["data"]
    dec = miniaudio.decode(data)
    samples = np.frombuffer(dec.samples, dtype=np.int16).copy()
    return samples, dec.nchannels, dec.sample_rate

def save_wav(samples, ch, sr, path):
    with wave.open(path, 'wb') as wf:
        wf.setnchannels(ch)
        wf.setsampwidth(2)
        wf.setframerate(sr)
        wf.writeframes(samples.tobytes())

async def test_slice_p():
    # In Turkish, "hop" or "şip" ends with an unvoiced 'p'
    # Let's synthesize "hop."
    samples, ch, sr = await synth("hop.")
    mono = samples.reshape(-1, 2).mean(axis=1) if ch == 2 else samples
    # find where the vowel 'o' ends and the burst 'p' occurs
    # In 'hop', 'h' is unvoiced, 'o' is voiced (high energy), then closure, then 'p' burst
    window = int(sr * 0.005) # 5ms
    energy = np.convolve(np.abs(mono), np.ones(window)/window, mode='same')
    
    # save full for reference
    save_wav(samples, ch, sr, "test_hop_full.wav")
    print(f"Hop full: {len(samples)//ch} frames, sr={sr}")

asyncio.run(test_slice_p())
