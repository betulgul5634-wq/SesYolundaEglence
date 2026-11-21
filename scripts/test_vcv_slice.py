import asyncio
import edge_tts
import miniaudio
import numpy as np
import wave

async def test_vcv_slice():
    comm = edge_tts.Communicate("Ipı.", 'tr-TR-EmelNeural', rate='-10%', pitch='+2Hz')
    mp3 = b''
    async for c in comm.stream():
        if c['type'] == 'audio': mp3 += c['data']
    dec = miniaudio.decode(mp3)
    samples = np.frombuffer(dec.samples, dtype=np.int16)
    sr = dec.sample_rate
    ch = dec.nchannels
    
    mono = samples.reshape(-1, 2).mean(axis=1) if ch == 2 else samples
    abs_m = np.abs(mono)
    win = int(sr * 0.005)
    energy = np.convolve(abs_m, np.ones(win)/win, mode='same')
    thresh = np.max(energy) * 0.05
    idx = np.where(energy > thresh)[0]
    
    speech_start = idx[0]
    speech_end = idx[-1]
    speech_dur = (speech_end - speech_start) / sr
    print(f"Ipı total speech duration: {speech_dur:.3f}s")
    
    # In 'ı-p-ı', the 'p' closure is a dip in energy in the middle!
    # Let's find the minimum energy region (the plosive closure of 'p')
    mid_start = speech_start + int(sr * 0.08)
    mid_end = speech_end - int(sr * 0.08)
    closure_idx = mid_start + np.argmin(energy[mid_start:mid_end])
    
    # After closure, there is the 'p' burst:
    burst_idx = closure_idx + np.argmax(energy[closure_idx : closure_idx + int(sr*0.06)])
    print(f"Closure at {(closure_idx - speech_start)/sr:.3f}s, burst at {(burst_idx - speech_start)/sr:.3f}s")
    
    # So 'ıp' ends right after the burst!
    ip_end = burst_idx + int(sr * 0.03) # 30ms after burst
    ip_slice = samples[speech_start*ch : ip_end*ch].copy()
    
    # Fade out
    fout = int(sr * 0.01)
    fout_curve = np.linspace(1.0, 0.0, fout)
    for c in range(ch):
        ip_slice[-fout*ch+c::ch] = (ip_slice[-fout*ch+c::ch] * fout_curve).astype(np.int16)
        
    pad_before = np.zeros(int(sr * 0.03)*ch, dtype=np.int16)
    pad_after = np.zeros(int(sr * 0.05)*ch, dtype=np.int16)
    ip_final = np.concatenate([pad_before, ip_slice, pad_after])
    
    with wave.open("test_sliced_ip.wav", "wb") as wf:
        wf.setnchannels(ch)
        wf.setsampwidth(2)
        wf.setframerate(sr)
        wf.writeframes(ip_final.tobytes())
        
    dur = len(ip_final) / (sr * ch)
    print(f"Generated test_sliced_ip.wav (dur: {dur:.3f}s)")

asyncio.run(test_vcv_slice())
