import asyncio
import edge_tts
import speech_recognition as sr
import io
import os

async def gen_audio(text):
    comm = edge_tts.Communicate(text, "tr-TR-EmelNeural")
    data = b""
    async for chunk in comm.stream():
        if chunk["type"] == "audio":
            data += chunk["data"]
    return data

async def main():
    r = sr.Recognizer()
    candidates = [
        "ef", "ef.", "Ef.", "eff", "eff.", "ehf", "Efff", "ef ", "ef-", "e'f", "efs", "e f"
    ]
    for c in candidates:
        audio_bytes = await gen_audio(c)
        # convert mp3 to wav
        import tempfile
        import subprocess
        with tempfile.NamedTemporaryFile(suffix=".mp3", delete=False) as f_mp3:
            f_mp3.write(audio_bytes)
            f_mp3_path = f_mp3.name
        
        f_wav_path = f_mp3_path.replace(".mp3", ".wav")
        # ffmpeg
        res = subprocess.run(["ffmpeg", "-y", "-i", f_mp3_path, f_wav_path], capture_output=True)
        if res.returncode == 0:
            with sr.AudioFile(f_wav_path) as source:
                audio = r.record(source)
            try:
                text_recognized = r.recognize_google(audio, language="tr-TR")
                print(f"Candidate '{c}' -> Recognized as: '{text_recognized}'")
            except Exception as e:
                print(f"Candidate '{c}' -> Error: {e}")
        try:
            os.remove(f_mp3_path)
            os.remove(f_wav_path)
        except:
            pass

asyncio.run(main())
