import asyncio, edge_tts, miniaudio, numpy as np, wave, os

async def test_pure_slices():
    # 1. 'av': Edge-TTS natively says 'av' in Turkish (e.g. "av" or "avcı")
    # Let's inspect 'av' directly:
    comm = edge_tts.Communicate("av", "tr-TR-EmelNeural")
    data = b""
    async for c in comm.stream():
        if c["type"] == "audio":
            data += c["data"]
    decoded = miniaudio.decode(data)
    print(f"'av' direct duration: {decoded.num_frames / decoded.sample_rate:.3f}s")
    
    # 2. 'ev': Edge-TTS natively says 'ev'
    comm = edge_tts.Communicate("ev", "tr-TR-EmelNeural")
    data = b""
    async for c in comm.stream():
        if c["type"] == "audio":
            data += c["data"]
    decoded = miniaudio.decode(data)
    print(f"'ev' direct duration: {decoded.num_frames / decoded.sample_rate:.3f}s")

asyncio.run(test_pure_slices())
