import ssl, asyncio, edge_tts, miniaudio
import speech_recognition as sr
import io, wave

_ssl_ctx = ssl.create_default_context()
_ssl_ctx.check_hostname = False
_ssl_ctx.verify_mode = ssl.CERT_NONE
edge_tts.communicate._SSL_CTX = _ssl_ctx
edge_tts.voices._SSL_CTX = _ssl_ctx

async def test_ssml_ipa(ipa, text='test'):
    ssml = f'''<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" xml:lang="tr-TR">
        <voice name="tr-TR-EmelNeural">
            <phoneme alphabet="ipa" ph="{ipa}">{text}</phoneme>
        </voice>
    </speak>'''
    comm = edge_tts.Communicate(text=ssml, voice='tr-TR-EmelNeural')
    mp3 = b''
    async for ch in comm.stream():
        if ch['type'] == 'audio':
            mp3 += ch['data']
    dec = miniaudio.decode(mp3)
    bio = io.BytesIO()
    with wave.open(bio, 'wb') as wf:
        wf.setnchannels(dec.nchannels)
        wf.setsampwidth(dec.sample_width)
        wf.setframerate(dec.sample_rate)
        wf.writeframes(dec.samples)
    bio.seek(0)
    r = sr.Recognizer()
    rec = 'FAIL'
    try:
        with sr.AudioFile(bio) as source:
            rec = r.recognize_google(r.record(source), language='tr-TR')
    except Exception as e:
        rec = str(e)
    dur = len(dec.samples)/(dec.sample_rate*dec.nchannels)
    print(f'{text:6} -> dur={dur:.2f}s, rec={rec}')

async def main():
    test_cases = [
        ('aɡ', 'ag'),
        ('eɟ', 'eg'),
        ('ɯɡ', 'ıg'),
        ('iɟ', 'ig'),
        ('oɡ', 'og'),
        ('øɟ', 'ög'),
        ('uɡ', 'ug'),
        ('yɟ', 'üg'),
    ]
    for ipa, txt in test_cases:
        await test_ssml_ipa(ipa, txt)

asyncio.run(main())
