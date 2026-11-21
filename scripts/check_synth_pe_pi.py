import asyncio
import edge_tts
import miniaudio
import numpy as np
import wave

async def synth_test(text):
    comm = edge_tts.Communicate(text, 'tr-TR-EmelNeural', rate='-5%', pitch='+2Hz')
    mp3 = b''
    async for c in comm.stream():
        if c['type'] == 'audio': mp3 += c['data']
    dec = miniaudio.decode(mp3)
    return np.frombuffer(dec.samples, dtype=np.int16), dec.sample_rate, dec.nchannels

tests = [('pe', 'Pe.'), ('pi', 'Pi.'), ('pa', 'Pa.'), ('pı', 'Pı.')]
for name, prompt in tests:
    samples, sr, ch = asyncio.run(synth_test(prompt))
    dur = len(samples) / (sr * ch)
    print(f"{name:4} (from '{prompt}') -> dur: {dur:.3f}s, min: {samples.min()}, max: {samples.max()}, rms: {np.sqrt(np.mean(samples.astype(np.float32)**2)):.1f}")
    # Save to file to examine
    with wave.open(f"test_out_{name}.wav", "wb") as wf:
        wf.setnchannels(ch)
        wf.setsampwidth(2)
        wf.setframerate(sr)
        wf.writeframes(samples.tobytes())
