from gtts import gTTS
import io, wave, sys
import miniaudio
import numpy as np
import speech_recognition as sr
sys.stdout.reconfigure(encoding='utf-8')

def test_gtts(text):
    tts = gTTS(text=text, lang='tr', tld='com.tr')
    mp3_fp = io.BytesIO()
    tts.write_to_fp(mp3_fp)
    mp3_fp.seek(0)
    
    decoded = miniaudio.decode(mp3_fp.read())
    samples = np.frombuffer(decoded.samples, dtype=np.int16)
    dur = len(samples) / (decoded.sample_rate * decoded.nchannels)
    
    # Save wav
    wav_io = io.BytesIO()
    with wave.open(wav_io, 'wb') as wf:
        wf.setnchannels(decoded.nchannels)
        wf.setsampwidth(decoded.sample_width)
        wf.setframerate(decoded.sample_rate)
        wf.writeframes(decoded.samples)
    wav_io.seek(0)
    
    r = sr.Recognizer()
    with sr.AudioFile(wav_io) as source:
        audio = r.record(source)
    try:
        tr = r.recognize_google(audio, language="tr-TR")
    except Exception as e:
        tr = f"ERR({e})"
        
    return dur, tr

for s in ['cı', 'ci', 'ca', 'ce', 'co', 'cö', 'cu', 'cü', 'ıc', 'ic', 'ac', 'ec', 'oc', 'öc', 'uc', 'üc']:
    dur, tr = test_gtts(s)
    print(f"gTTS '{s:4s}' -> dur={dur:.2f}s, STT='{tr}'", flush=True)
