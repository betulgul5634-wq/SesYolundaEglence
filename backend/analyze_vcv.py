import asyncio
import edge_tts
import miniaudio
import numpy as np
import wave
import sys

async def get_word_audio(word):
    comm = edge_tts.Communicate(word, 'tr-TR-EmelNeural')
    data = b''
    async for c in comm.stream():
        if c['type'] == 'audio':
            data += c['data']
    decoded = miniaudio.decode(data)
    samples = np.frombuffer(decoded.samples, dtype=np.int16).copy()
    sr = decoded.sample_rate
    ch = decoded.nchannels
    return samples, sr, ch

async def analyze_vcv(word):
    samples, sr, ch = await get_word_audio(word)
    mono = samples.reshape(-1, ch).mean(axis=1) if ch > 1 else samples
    # 5ms energy frames
    frame_len = int(sr * 0.005)
    num_frames = len(mono) // frame_len
    energy = np.array([np.mean(np.abs(mono[i*frame_len : (i+1)*frame_len])) for i in range(num_frames)])
    
    # Threshold for silence
    peak = np.max(energy)
    active = np.where(energy > peak * 0.05)[0]
    start_frame = active[0]
    end_frame = active[-1]
    
    # In VCV (like 'aga'), there are two main energy lobes:
    # First vowel: start_frame to closure
    # Closure dip (g stop): energy drops
    # Burst & second vowel: energy rises again to end_frame
    
    mid_region = energy[start_frame + int(0.15*sr/frame_len) : end_frame - int(0.15*sr/frame_len)]
    dip_frame = start_frame + int(0.15*sr/frame_len) + np.argmin(mid_region)
    
    # The 'g' closure occurs at dip_frame.
    # The burst release is right after the minimum, where energy starts rising.
    burst_frame = dip_frame
    while burst_frame < end_frame and energy[burst_frame] < peak * 0.15:
        burst_frame += 1
        
    print(f"{word}: start={start_frame*0.005:.3f}s, dip={dip_frame*0.005:.3f}s, burst={burst_frame*0.005:.3f}s, end={end_frame*0.005:.3f}s")
    return samples, sr, ch, burst_frame * frame_len

async def main():
    for w in ['aga', 'ege', 'ıgı', 'igi', 'ogo', 'ögö', 'ugu', 'ügü']:
        await analyze_vcv(w)

asyncio.run(main())
