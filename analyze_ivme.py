import asyncio, edge_tts, miniaudio, numpy as np

async def analyze_ivme():
    comm = edge_tts.Communicate("ivme", "tr-TR-EmelNeural", rate="-3%", pitch="+4Hz")
    data = b""
    async for c in comm.stream():
        if c["type"] == "audio":
            data += c["data"]
            
    decoded = miniaudio.decode(data)
    samples = np.frombuffer(decoded.samples, dtype=np.int16).copy()
    ch = decoded.nchannels
    sr = decoded.sample_rate
    
    if ch == 2:
        mono = samples.reshape(-1, 2).mean(axis=1)
    else:
        mono = samples
        
    abs_mono = np.abs(mono)
    window = int(sr * 0.01)
    energy = np.convolve(abs_mono, np.ones(window)/window, mode='same')
    max_e = np.max(energy)
    start = np.where(energy > max_e * 0.05)[0][0]
    
    print(f"Total dur: {len(mono)/sr:.3f}s, start: {start/sr:.3f}s")
    for t_ms in range(0, 500, 20):
        idx = start + int(t_ms * 0.001 * sr)
        if idx < len(energy):
            print(f"+{t_ms}ms ({(idx)/sr:.3f}s): energy = {energy[idx]/max_e:.3f}")

asyncio.run(analyze_ivme())
