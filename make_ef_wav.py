import asyncio
import edge_tts
import miniaudio
import wave
import io
import speech_recognition as sr
import os

async def main():
    comm = edge_tts.Communicate("eh f", "tr-TR-EmelNeural", rate="-3%", pitch="+4Hz")
    data = b""
    async for chunk in comm.stream():
        if chunk["type"] == "audio":
            data += chunk["data"]
            
    decoded = miniaudio.decode(data)
    out_path = os.path.join("backend", "pure_syllables", "ef.wav")
    with wave.open(out_path, "wb") as wf:
        wf.setnchannels(decoded.nchannels)
        wf.setsampwidth(decoded.sample_width)
        wf.setframerate(decoded.sample_rate)
        wf.writeframes(decoded.samples)
    print(f"Saved {out_path}, size: {os.path.getsize(out_path)} bytes")
    
    r = sr.Recognizer()
    with sr.AudioFile(out_path) as src:
        audio = r.record(src)
    res = r.recognize_google(audio, language="tr-TR")
    print(f"ef.wav verification -> recognized as: '{res}'")

asyncio.run(main())
