import asyncio
import edge_tts
import miniaudio
import numpy as np

async def test_variants():
    rates = ["-15%", "-25%"]
    cases = [
        ("pe", "Pe."),
        ("pe", "Pee."),
        ("pe", "Peh."),
        ("pi", "Pi."),
        ("pi", "Pii."),
        ("pa", "Pa."),
        ("pa", "Paa."),
        ("pı", "Pı."),
        ("pı", "Pıı."),
        ("ıp", "Ip."),
        ("ıp", "Iıp."),
        ("ıp", "Iıp!"),
        ("ip", "İp."),
        ("ip", "İip."),
    ]
    for rate in rates:
        print(f"=== RATE: {rate} ===")
        for name, text in cases:
            comm = edge_tts.Communicate(text, 'tr-TR-EmelNeural', rate=rate, pitch='+1Hz')
            mp3 = b''
            async for c in comm.stream():
                if c['type'] == 'audio': mp3 += c['data']
            dec = miniaudio.decode(mp3)
            samples = np.frombuffer(dec.samples, dtype=np.int16)
            sr = dec.sample_rate
            mono = samples.reshape(-1, 2).mean(axis=1) if dec.nchannels == 2 else samples
            energy = np.convolve(np.abs(mono), np.ones(int(sr*0.01))/(sr*0.01), mode='same')
            thresh = np.max(energy) * 0.05
            indices = np.where(energy > thresh)[0]
            if len(indices) > 0:
                speech_dur = (indices[-1] - indices[0]) / sr
            else:
                speech_dur = 0
            print(f"{name:4} ('{text:6}') -> speech_dur: {speech_dur:.3f}s")

asyncio.run(test_variants())
