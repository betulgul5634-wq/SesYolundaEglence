from gtts import gTTS
import miniaudio
import io
import wave
import speech_recognition as sr

def test_gtts():
    tts = gTTS(text="ef", lang="tr")
    mp3_fp = io.BytesIO()
    tts.write_to_fp(mp3_fp)
    mp3_fp.seek(0)
    
    decoded = miniaudio.decode(mp3_fp.read())
    out = io.BytesIO()
    with wave.open(out, "wb") as wf:
        wf.setnchannels(decoded.nchannels)
        wf.setsampwidth(decoded.sample_width)
        wf.setframerate(decoded.sample_rate)
        wf.writeframes(decoded.samples)
    
    r = sr.Recognizer()
    with sr.AudioFile(io.BytesIO(out.getvalue())) as source:
        audio = r.record(source)
    try:
        res = r.recognize_google(audio, language="tr-TR")
        print("gTTS 'ef' recognized as:", res)
    except Exception as e:
        print("gTTS 'ef' unrecognized:", e)

test_gtts()
