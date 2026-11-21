import asyncio
import edge_tts
import miniaudio
import wave
import speech_recognition as sr
import io

async def test_candidate(target, candidate):
    comm = edge_tts.Communicate(candidate, 'tr-TR-EmelNeural', pitch='+0Hz', rate='-4%')
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
    r = sr.Recognizer()
    try:
        with sr.AudioFile(wav_io) as src:
            aud = r.record(src)
            return r.recognize_google(aud, language='tr-TR')
    except Exception as e:
        return f'Err: {e}'

async def main():
    pairs = [
        ('pa', 'Pa.'),
        ('pa', 'Paa.'),
        ('pe', 'Pe.'),
        ('pı', 'Pı.'),
        ('pi', 'Pi.'),
        ('po', 'Po.'),
        ('pö', 'Pö.'),
        ('pu', 'Pu.'),
        ('pü', 'Pü.'),
        ('ap', 'Ap.'),
        ('ep', 'Ep.'),
        ('ıp', 'Ip.'),
        ('ip', 'İp.'),
        ('op', 'Op.'),
        ('öp', 'Öp.'),
        ('up', 'Up.'),
        ('üp', 'Üp.'),
        ('apa', 'Apa.'),
        ('epe', 'Epe.'),
        ('pap', 'Pap.'),
        ('pep', 'Pep.'),
    ]
    for target, cand in pairs:
        rec = await test_candidate(target, cand)
        print(f'{target} with "{cand}" -> Rec: {rec}')

if __name__ == '__main__':
    asyncio.run(main())
