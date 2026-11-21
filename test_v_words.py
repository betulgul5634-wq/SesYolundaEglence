import asyncio, edge_tts, miniaudio, io, wave, speech_recognition as sr

async def test_word(w):
    comm = edge_tts.Communicate(w, "tr-TR-EmelNeural")
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
    print(f"'{w}' ({len(decoded.samples)} frames, {decoded.num_frames/decoded.sample_rate:.3f}s) -> {res}")

async def main():
    for w in ["av", "ev", "dev", "ödev", "görev", "av.", "ev."]:
        await test_word(w)

asyncio.run(main())
