import asyncio
import edge_tts
import miniaudio
import numpy as np
import wave
import io

async def test_vc():
    words = [
        ("ap", "Ap."),
        ("ep", "Ep."),
        ("ıp_1", "Ip."),
        ("ıp_2", "Iıp."),
        ("ıp_3", "Iıp!"),
        ("ıp_4", "I-p"),
        ("ip", "İp."),
        ("op", "Op."),
        ("öp", "Öp."),
        ("up", "Up."),
        ("üp", "Üp.")
    ]
    for tag, w in words:
        comm = edge_tts.Communicate(w, 'tr-TR-EmelNeural', rate='-10%', pitch='+2Hz')
        mp3 = b''
        async for c in comm.stream():
            if c['type'] == 'audio': mp3 += c['data']
        dec = miniaudio.decode(mp3)
        samples = np.frombuffer(dec.samples, dtype=np.int16)
        sr = dec.sample_rate
        ch = dec.nchannels
        mono = samples.reshape(-1, 2).mean(axis=1) if ch == 2 else samples
        energy = np.convolve(np.abs(mono), np.ones(int(sr*0.01))/(sr*0.01), mode='same')
        thresh = np.max(energy) * 0.04
        idx = np.where(energy > thresh)[0]
        speech_dur = (idx[-1] - idx[0]) / sr if len(idx) > 0 else 0
        print(f"'{tag:6}' ('{w:6}') -> dur: {speech_dur:.3f}s, min: {samples.min()}, max: {samples.max()}, hash: {hash(samples.tobytes())}")
        with wave.open(f"test_vc_{tag}.wav", "wb") as wf:
            wf.setnchannels(ch)
            wf.setsampwidth(2)
            wf.setframerate(sr)
            wf.writeframes(samples.tobytes())

asyncio.run(test_vc())
