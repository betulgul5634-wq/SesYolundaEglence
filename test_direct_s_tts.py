import asyncio
import edge_tts
import speech_recognition as sr
import io, wave, miniaudio
import sys

sys.stdout.reconfigure(encoding='utf-8')

test_syls = [
    'sa', 'se', 'sı', 'si', 'so', 'sö', 'su', 'sü',
    'as', 'es', 'ıs', 'is', 'os', 'ös', 'us', 'üs',
    'asa', 'ese', 'ısı', 'isi', 'oso', 'ösö', 'usu', 'üsü',
    'sas', 'ses', 'sıs', 'sis', 'sos', 'sös', 'sus', 'süs'
]

async def test_syl(s):
    comm = edge_tts.Communicate(s, "tr-TR-EmelNeural")
    data = b""
    async for c in comm.stream():
        if c["type"] == "audio":
            data += c["data"]
    
    dec = miniaudio.decode(data)
    wav_io = io.BytesIO()
    with wave.open(wav_io, 'wb') as wf:
        wf.setnchannels(dec.nchannels)
        wf.setsampwidth(2)
        wf.setframerate(dec.sample_rate)
        wf.writeframes(dec.samples)
    wav_io.seek(0)
    dur = len(dec.samples) / (dec.sample_rate * dec.nchannels * 2) * 1000
    
    r = sr.Recognizer()
    with sr.AudioFile(wav_io) as source:
        audio = r.record(source)
    try:
        txt = r.recognize_google(audio, language="tr-TR")
        return txt, dur
    except Exception as e:
        return f"[Unrec: {e}]", dur

async def main():
    for s in test_syls:
        txt, dur = await test_syl(s)
        print(f"'{s}': Recognized as '{txt}' ({dur:.0f}ms)")

if __name__ == '__main__':
    asyncio.run(main())
