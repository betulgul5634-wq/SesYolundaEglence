import asyncio
import edge_tts
import miniaudio
import wave
import io
import speech_recognition as sr

async def get_mp3(text, voice="tr-TR-EmelNeural"):
    comm = edge_tts.Communicate(text, voice)
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
        "ef", "Ef", "Ef.", "ef.", "eff", "eff.", "e f", "e-f", "effe", "ehf", "Eftelya", "Nefes", "Efe"
    ]
    for c in candidates:
        mp3_data = await get_mp3(c)
        wav_data = mp3_to_wav_bytes(mp3_data)
        with sr.AudioFile(io.BytesIO(wav_data)) as source:
            audio = r.record(source)
        try:
            res = r.recognize_google(audio, language="tr-TR")
            print(f"'{c}' -> recognized as: '{res}'")
        except Exception as e:
            print(f"'{c}' -> unrecognized: {e}")

asyncio.run(main())
