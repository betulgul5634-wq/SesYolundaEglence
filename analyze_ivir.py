import asyncio, edge_tts, miniaudio, numpy as np, wave, os

async def analyze_ivir():
    comm = edge_tts.Communicate("ıvır", "tr-TR-EmelNeural", rate="-3%", pitch="+4Hz")
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
    thresh = max_e * 0.05
    speech_indices = np.where(energy > thresh)[0]
    start = speech_indices[0]
    
    print(f"Sample rate: {sr}, speech starts at: {start} ({start/sr:.3f}s)")
    
    # In 'ı-v-ı-r':
    # 1. 'ı' vowel (high energy periodic)
    # 2. 'v' voiced fricative (medium energy, voiced friction)
    # 3. 'ı' vowel 2 (high energy periodic)
    # 4. 'r' tap/flap (dip then tail)
    
    # Let's inspect energy every 20ms from start to start + 0.6s
    for t_ms in range(0, 600, 20):
        idx = start + int(t_ms * 0.001 * sr)
        if idx < len(energy):
            print(f"+{t_ms}ms (at {(idx)/sr:.3f}s): energy = {energy[idx]/max_e:.3f}")

asyncio.run(analyze_ivir())
