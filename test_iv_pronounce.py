import asyncio, edge_tts, miniaudio, speech_recognition as sr
import io, wave

tests = [
    "iv",
    "iiv",
    "ivv",
    "ivvv",
    "İv",
    "İvv",
    "İvvv",
    "iv.",
    "İv.",
    "i v",
    "iyv",
]

async def test_candidate(t):
    comm = edge_tts.Communicate(t, "tr-TR-EmelNeural")
    data = b""
    async for c in comm.stream():
        if c["type"] == "audio":
            data += c["data"]
            
    decoded = miniaudio.decode(data)
    wav_io = io.BytesIO()
    with wave.open(wav_io, 'wb') as wf:
        wf.setnchannels(decoded.nchannels)
        wf.setsampwidth(decoded.sample_width)
        wf.setframerate(decoded.sample_rate)
        wf.writeframes(decoded.samples)
        
    r = sr.Recognizer()
    with sr.AudioFile(io.BytesIO(wav_io.getvalue())) as source:
        audio = r.record(source)
    try:
        res = r.recognize_google(audio, language="tr-TR")
    except Exception as e:
        res = f"err: {e}"
    print(f"'{t}' (len={len(decoded.samples)}) -> {res}")

async def main():
    for t in tests:
        await test_candidate(t)

asyncio.run(main())
