import asyncio
import edge_tts
import miniaudio
import wave
import io
import speech_recognition as sr

async def get_mp3(text):
    comm = edge_tts.Communicate(text, "tr-TR-EmelNeural")
    data = b""
    async for chunk in comm.stream():
        if chunk["type"] == "audio":
            data += chunk["data"]
    return data

def mp3_to_wav_bytes(mp3_bytes):
    decoded = miniaudio.decode(mp3_bytes)
    out = io.BytesIO()
    with wave.open(out, "wb") as wf:
        wf.setnchannels(decoded.nchannels)
        wf.setsampwidth(decoded.sample_width)
        wf.setframerate(decoded.sample_rate)
        wf.writeframes(decoded.samples)
    return out.getvalue()

async def main():
    r = sr.Recognizer()
    candidates = [
        "e f", "ehf", "eh f", "e'f", "ef ", "ef..", "efff", "Effff", "Eef", "eee f", "E f.", "e ff"
    ]
    for c in candidates:
        mp3 = await get_mp3(c)
        wav = mp3_to_wav_bytes(mp3)
        with sr.AudioFile(io.BytesIO(wav)) as src:
            audio = r.record(src)
        try:
            res = r.recognize_google(audio, language="tr-TR")
            print(f"'{c}' -> recognized as: '{res}'")
        except Exception as e:
            print(f"'{c}' -> error: {e}")

asyncio.run(main())
