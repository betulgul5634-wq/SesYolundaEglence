import asyncio, edge_tts, miniaudio, numpy as np

async def check_raw_words():
    for w in ["av", "ev", "öv", "uv", "üv", "vav", "vev", "viv", "vov", "vuv"]:
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
        # Find active duration
        active = np.where(energy > max_e * 0.03)[0]
        if len(active) > 0:
            dur = (active[-1] - active[0]) / sr
            print(f"'{w}': active duration = {dur:.3f}s, start = {active[0]/sr:.3f}s, end = {active[-1]/sr:.3f}s")

asyncio.run(check_raw_words())
