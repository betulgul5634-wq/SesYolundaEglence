import asyncio
import edge_tts
import miniaudio
import numpy as np
import io, wave, os, sys

sys.stdout.reconfigure(encoding='utf-8')

async def synth(text, rate="-2%", pitch="+4Hz"):
    comm = edge_tts.Communicate(text, voice="tr-TR-EmelNeural", rate=rate, pitch=pitch)
    data = b""
    async for c in comm.stream():
        if c["type"] == "audio":
            data += c["data"]
    decoded = miniaudio.decode(data)
    samples = np.frombuffer(decoded.samples, dtype=np.int16).copy()
    return samples, decoded.nchannels, decoded.sample_rate

def get_envelope(samples, ch, sr):
    mono = samples.reshape(-1, 2).mean(axis=1) if ch == 2 else samples
    abs_mono = np.abs(mono)
    window = int(sr * 0.01)
    energy = np.convolve(abs_mono, np.ones(window)/window, mode='same')
    return mono, energy

async def extract_pure_p():
    # Synthesize "şip şip şip"
    # The 'p' at the end of each 'şip' is a clean unvoiced bilabial plosive release!
    samples, ch, sr = await synth("şip, şip, şip.")
    mono, energy = get_envelope(samples, ch, sr)
    print("Synthesized 'şip, şip, şip.' length:", len(samples)//ch)

asyncio.run(extract_pure_p())
