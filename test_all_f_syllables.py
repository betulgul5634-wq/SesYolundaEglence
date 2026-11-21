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
    f_syllables = [
        "fı", "fi", "fa", "fe", "fo", "fö", "fu", "fü",
        "ıf", "if", "af", "ef", "of", "öf", "uf", "üf",
        "ıfı", "ifi", "afa", "efe", "ofo", "öfö", "ufu", "üfü",
        "fıf", "fif", "faf", "fef", "fof", "föf", "fuf", "füf"
    ]
    for s in f_syllables:
        mp3_data = await get_mp3(s)
        wav_data = mp3_to_wav_bytes(mp3_data)
        with sr.AudioFile(io.BytesIO(wav_data)) as source:
            audio = r.record(source)
        try:
            res = r.recognize_google(audio, language="tr-TR")
            print(f"'{s}' -> '{res}'")
        except Exception as e:
            print(f"'{s}' -> unrecognized")

asyncio.run(main())
