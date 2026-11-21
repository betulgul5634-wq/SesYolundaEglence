import asyncio, edge_tts, miniaudio, io, wave, speech_recognition as sr

syls = ['vı', 'vi', 'va', 've', 'vo', 'vö', 'vu', 'vü', 'ıv', 'iv', 'av', 'ev', 'ov', 'öv', 'uv', 'üv']

async def test_syl(s):
    c = edge_tts.Communicate(s, 'tr-TR-EmelNeural')
    chunks = []
    async for chunk in c.stream():
        if chunk['type'] == 'audio':
            chunks.append(chunk['data'])
    data = b''.join(chunks)
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
        res = r.recognize_google(audio, language='tr-TR')
        return res
    except Exception as e:
        return f"err: {e}"

async def main():
    for s in syls:
        res = await test_syl(s)
        print(f"'{s}' -> {res}")

asyncio.run(main())
