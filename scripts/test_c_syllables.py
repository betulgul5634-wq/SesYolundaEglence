import asyncio
import edge_tts
import io
import wave
import miniaudio
import speech_recognition as sr
import sys
sys.stdout.reconfigure(encoding='utf-8')

async def synth(text, rate="-3%", pitch="+4Hz"):
    c = edge_tts.Communicate(text, voice="tr-TR-EmelNeural", rate=rate, pitch=pitch)
    data = b""
    async for chunk in c.stream():
        if chunk["type"] == "audio":
            data += chunk["data"]
    return data

def mp3_to_wav(mp3_bytes):
    decoded = miniaudio.decode(mp3_bytes)
    wav_io = io.BytesIO()
    with wave.open(wav_io, 'wb') as wf:
        wf.setnchannels(decoded.nchannels)
        wf.setsampwidth(decoded.sample_width)
        wf.setframerate(decoded.sample_rate)
        wf.writeframes(decoded.samples)
    wav_io.seek(0)
    return wav_io

def transcribe(mp3_bytes):
    wav_io = mp3_to_wav(mp3_bytes)
    r = sr.Recognizer()
    with sr.AudioFile(wav_io) as source:
        audio = r.record(source)
    try:
        return r.recognize_google(audio, language="tr-TR")
    except Exception as e:
        return f"RECOG_ERROR: {e}"

async def main():
    syls = [
        'cı', 'ci', 'ca', 'ce', 'co', 'cö', 'cu', 'cü',
        'ıc', 'ic', 'ac', 'ec', 'oc', 'öc', 'uc', 'üc',
        'ıcı', 'ici', 'aca', 'ece', 'oco', 'öcö', 'ucu', 'ücü',
        'cıc', 'cic', 'cac', 'cec', 'coc', 'cöc', 'cuc', 'cüc'
    ]
    for s in syls:
        mp3 = await synth(s)
        tr = transcribe(mp3)
        print(f"Syllable: '{s}' -> recognized: '{tr}'")

if __name__ == '__main__':
    asyncio.run(main())
