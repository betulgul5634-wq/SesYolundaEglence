import asyncio
import edge_tts
import miniaudio
import numpy as np
import wave
import io
import speech_recognition as sr

async def get_audio_samples(text):
    comm = edge_tts.Communicate(text, "tr-TR-EmelNeural")
    data = b""
    async for chunk in comm.stream():
        if chunk["type"] == "audio":
            data += chunk["data"]
    decoded = miniaudio.decode(data)
    samples = np.frombuffer(decoded.samples, dtype=np.int16)
    return samples, decoded.sample_rate, decoded.nchannels

def samples_to_wav(samples, sample_rate, nchannels):
    out = io.BytesIO()
    with wave.open(out, "wb") as wf:
        wf.setnchannels(nchannels)
        wf.setsampwidth(2)
        wf.setframerate(sample_rate)
        wf.writeframes(samples.tobytes())
    return out.getvalue()

async def test():
    # Efsane: E-f-s-a-n-e
    samples, sr_rate, ch = await get_audio_samples("Efsane.")
    # Efe: E-f-e
    samples_efe, sr_efe, ch_efe = await get_audio_samples("Efe.")
    
    print(f"Efsane length: {len(samples)} samples, {len(samples)/sr_rate/ch:.2f}s")
    print(f"Efe length: {len(samples_efe)} samples, {len(samples_efe)/sr_efe/ch_efe:.2f}s")

asyncio.run(test())
