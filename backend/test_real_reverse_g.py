import asyncio
import edge_tts
import miniaudio
import numpy as np
import wave
import sys
import io
import speech_recognition as sr

sys.stdout.reconfigure(encoding='utf-8')
r = sr.Recognizer()

async def get_word_audio(word):
    comm = edge_tts.Communicate(word, 'tr-TR-EmelNeural')
    data = b''
    async for c in comm.stream():
        if c['type'] == 'audio':
            data += c['data']
    decoded = miniaudio.decode(data)
    samples = np.frombuffer(decoded.samples, dtype=np.int16).copy()
    sr_rate = decoded.sample_rate
    ch = decoded.nchannels
    return samples, sr_rate, ch

async def create_reverse_syllable(carrier_vcv, target_syl):
    samples, sr_rate, ch = await get_word_audio(carrier_vcv)
    mono = samples.reshape(-1, ch).mean(axis=1) if ch > 1 else samples
    frame_len = int(sr_rate * 0.005)
    num_frames = len(mono) // frame_len
    energy = np.array([np.mean(np.abs(mono[i*frame_len : (i+1)*frame_len])) for i in range(num_frames)])
    peak = np.max(energy)
    active = np.where(energy > peak * 0.05)[0]
    start_frame = active[0]
    end_frame = active[-1]
    
    mid_start = start_frame + int(0.12 * sr_rate / frame_len)
    mid_end = end_frame - int(0.12 * sr_rate / frame_len)
    dip_frame = mid_start + np.argmin(energy[mid_start:mid_end])
    
    # Burst is right after dip
    burst_frame = dip_frame
    while burst_frame < end_frame and energy[burst_frame] < peak * 0.20:
        burst_frame += 1
        
    # Cut after burst: burst_frame * frame_len + 15ms
    cut_end_sample = min(len(mono), (burst_frame * frame_len) + int(sr_rate * 0.015))
    fade_len = int(sr_rate * 0.02)
    
    cut_samples = samples[:cut_end_sample * ch].copy()
    fade = np.linspace(1.0, 0.0, fade_len)
    if ch > 1:
        cut_samples.reshape(-1, ch)[-fade_len:, 0] = (cut_samples.reshape(-1, ch)[-fade_len:, 0] * fade).astype(np.int16)
        cut_samples.reshape(-1, ch)[-fade_len:, 1] = (cut_samples.reshape(-1, ch)[-fade_len:, 1] * fade).astype(np.int16)
    else:
        cut_samples[-fade_len:] = (cut_samples[-fade_len:] * fade).astype(np.int16)
        
    wav_io = io.BytesIO()
    with wave.open(wav_io, 'wb') as wf:
        wf.setnchannels(ch)
        wf.setsampwidth(2)
        wf.setframerate(sr_rate)
        wf.writeframes(cut_samples.tobytes())
    wav_io.seek(0)
    with sr.AudioFile(wav_io) as source:
        audio = r.record(source)
    try:
        rec = r.recognize_google(audio, language='tr-TR')
    except Exception as e:
        rec = f'({e})'
        
    dur = len(cut_samples) / (sr_rate * ch * 2)
    print(f"[{target_syl:6}] from '{carrier_vcv:6}' -> dur={dur:.2f}s rec='{rec}'")
    return wav_io.getvalue()

async def main():
    carriers = [
        ("aga", "ag"),
        ("ege", "eg"),
        ("ıgı", "ıg"),
        ("igi", "ig"),
        ("ogo", "og"),
        ("ögö", "ög"),
        ("ugu", "ug"),
        ("ügü", "üg"),
    ]
    for c, t in carriers:
        await create_reverse_syllable(c, t)

asyncio.run(main())
