import asyncio
import edge_tts
import miniaudio
import numpy as np

async def test_pe_pi():
    words = [
        "Pe.",
        "Pi.",
        "Pee.",
        "Pii.",
        "Peh.",
        "Pik.",
        "Pes.",
        "Pel.",
        "Pil."
    ]
    for w in words:
        comm = edge_tts.Communicate(w, 'tr-TR-EmelNeural', rate='-10%', pitch='+2Hz')
        mp3 = b''
        async for c in comm.stream():
            if c['type'] == 'audio': mp3 += c['data']
        dec = miniaudio.decode(mp3)
        samples = np.frombuffer(dec.samples, dtype=np.int16)
        print(f"'{w:6}' -> len: {len(samples)}, min: {samples.min()}, max: {samples.max()}, hash: {hash(samples.tobytes())}")

asyncio.run(test_pe_pi())
