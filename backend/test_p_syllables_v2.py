import asyncio
import edge_tts
import miniaudio
import wave
import io
import speech_recognition as sr

async def test_text(txt):
    comm = edge_tts.Communicate(txt, 'tr-TR-EmelNeural', pitch='+0Hz', rate='-6%')
    mp3 = b''
    async for chunk in comm.stream():
        if chunk['type'] == 'audio':
            mp3 += chunk['data']
    dec = miniaudio.decode(mp3)
    wav_io = io.BytesIO()
    with wave.open(wav_io, 'wb') as wf:
        wf.setnchannels(dec.nchannels)
        wf.setsampwidth(2)
        wf.setframerate(dec.sample_rate)
        wf.writeframes(dec.samples)
    wav_io.seek(0)
    dur = len(dec.samples) / (dec.sample_rate * dec.nchannels * 2)
    r = sr.Recognizer()
    try:
        with sr.AudioFile(wav_io) as src:
            aud = r.record(src)
            rec = r.recognize_google(aud, language='tr-TR')
    except Exception as e:
        rec = f'None ({e})'
    print(f'"{txt}" (dur={dur:.2f}s) -> Rec: {rec}')

async def main():
    test_list = [
        'paaa', 'peee', 'pııı', 'piii', 'pooo', 'pööö', 'puuu', 'püüü',
        'Pa', 'Pe', 'Pı', 'Pi', 'Po', 'Pö', 'Pu', 'Pü',
        'Pa hecesi.', 'Pe hecesi.',
        'aaap', 'eeep', 'ıııp', 'iiip', 'ooop', 'öööp', 'uuup', 'üüüp',
        'Ap', 'Ep', 'Ip', 'İp', 'Op', 'Öp', 'Up', 'Üp',
    ]
    for t in test_list:
        await test_text(t)

if __name__ == '__main__':
    asyncio.run(main())
