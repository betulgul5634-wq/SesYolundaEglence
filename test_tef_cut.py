import asyncio
import edge_tts
import miniaudio
import numpy as np
import wave
import io
import speech_recognition as sr
import os

async def main():
    comm = edge_tts.Communicate("Tef.", "tr-TR-EmelNeural", rate="-4%", pitch="+4Hz")
    data = b""
    async for chunk in comm.stream():
        if chunk["type"] == "audio":
            data += chunk["data"]
            
    decoded = miniaudio.decode(data)
    samples = np.frombuffer(decoded.samples, dtype=np.int16).reshape(-1, decoded.nchannels)
    sr_rate = decoded.sample_rate
    
    # Let's find where the vowel starts (where energy increases after initial T burst)
    mono = samples.mean(axis=1)
    abs_mono = np.abs(mono)
    
    # Find onset
    onset = np.where(abs_mono > 1500)[0]
    if len(onset) > 0:
        start_idx = onset[0]
        # In 'tef', T burst lasts around 30-60ms. Let's find where vowel starts
        # Vowel has periodic high amplitude
        vowel_start = start_idx
        for i in range(start_idx, min(start_idx + int(0.15 * sr_rate), len(mono))):
            # check zero crossings or local peak
            if abs_mono[i] > 4000:
                vowel_start = i
                break
        
        # Walk back slightly to zero crossing
        while vowel_start > 0 and mono[vowel_start] * mono[vowel_start - 1] > 0:
            vowel_start -= 1
            
        # End is where audio fades
        end_idx = len(mono) - 1
        while end_idx > vowel_start and abs_mono[end_idx] < 500:
            end_idx -= 1
            
        cut_samples = samples[vowel_start:end_idx]
        out_path = os.path.join("backend", "pure_syllables", "ef.wav")
        with wave.open(out_path, "wb") as wf:
            wf.setnchannels(decoded.nchannels)
            wf.setsampwidth(decoded.sample_width)
            wf.setframerate(decoded.sample_rate)
            wf.writeframes(cut_samples.tobytes())
            
        r = sr.Recognizer()
        with sr.AudioFile(out_path) as src:
            aud = r.record(src)
        try:
            res = r.recognize_google(aud, language="tr-TR")
            print(f"Tef cut result -> '{res}'")
        except Exception as e:
            print(f"Tef cut recognition -> {e}")

asyncio.run(main())
