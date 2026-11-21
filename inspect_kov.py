import asyncio, edge_tts, miniaudio, numpy as np

async def inspect_kov():
    comm = edge_tts.Communicate("kov", "tr-TR-EmelNeural")
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
    start = np.where(energy > max_e * 0.05)[0][0]
    for t in range(0, 300, 20):
        idx = start + int(t * 0.001 * sr)
        if idx < len(energy):
            print(f"+{t}ms ({(idx)/sr:.3f}s): energy = {energy[idx]/max_e:.3f}")

asyncio.run(inspect_kov())
