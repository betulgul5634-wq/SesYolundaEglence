import asyncio, io, wave, miniaudio, edge_tts
import speech_recognition as sr

cand_list = ["ıv", "ıvv", "ıvvv", "ııv", "ııvv", "Iv", "Ivv", "ıv.", "ıvv.", "ıvvv."]

async def test_cand(cand):
    c = edge_tts.Communicate(cand, 'tr-TR-EmelNeural')
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
    for c in cand_list:
        res = await test_cand(c)
        print(f"'{c}' -> {res}")

asyncio.run(main())
