import asyncio, edge_tts, miniaudio, numpy as np

async def inspect_direct():
    for w in ["av", "ev", "öv", "uv", "üv", "kov"]:
        comm = edge_tts.Communicate(w, "tr-TR-EmelNeural")
        data = b""
        async for c in comm.stream():
            if c["type"] == "audio":
                data += c["data"]
        decoded = miniaudio.decode(data)
        samples = np.frombuffer(decoded.samples, dtype=np.int16)
        sr = decoded.sample_rate
        ch = decoded.nchannels
        mono = samples.reshape(-1, ch).mean(axis=1) if ch == 2 else samples
        abs_mono = np.abs(mono)
        window = int(sr * 0.01)
        energy = np.convolve(abs_mono, np.ones(window)/window, mode='same')
        max_e = np.max(energy)
        active = np.where(energy > max_e * 0.04)[0]
        start = active[0]
        end = active[-1]
        print(f"'{w}': start={start/sr:.3f}s, end={end/sr:.3f}s, len={(end-start)/sr:.3f}s")

asyncio.run(inspect_direct())
