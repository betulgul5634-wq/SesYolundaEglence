import asyncio, edge_tts, miniaudio, numpy as np

async def inspect_v():
    for w in ["vazo", "van", "ve"]:
        comm = edge_tts.Communicate(w, "tr-TR-EmelNeural", rate="-3%", pitch="+4Hz")
        data = b""
        async for c in comm.stream():
            if c["type"] == "audio":
                data += c["data"]
        decoded = miniaudio.decode(data)
        samples = np.frombuffer(decoded.samples, dtype=np.int16).copy()
        sr = decoded.sample_rate
        ch = decoded.nchannels
        mono = samples.reshape(-1, ch).mean(axis=1) if ch == 2 else samples
        abs_mono = np.abs(mono)
        window = int(sr * 0.01)
        energy = np.convolve(abs_mono, np.ones(window)/window, mode='same')
        max_e = np.max(energy)
        start = np.where(energy > max_e * 0.05)[0][0]
        print(f"Word: {w}, start: {start/sr:.3f}s")
        # In words starting with 'v', the first 80-120ms is the pure /v/ fricative!
        for t in range(0, 160, 20):
            idx = start + int(t * 0.001 * sr)
            print(f"  +{t}ms: energy={energy[idx]/max_e:.3f}")

asyncio.run(inspect_v())
