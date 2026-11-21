import wave
import numpy as np
import speech_recognition as sr

r = sr.Recognizer()
for name in ['ac', 'ec', 'ıc', 'ic', 'oc', 'öc', 'uc', 'üc']:
    path = f'scripts/slices/{name}.wav'
    with wave.open(path, 'rb') as wf:
        dur = wf.getnframes() / wf.getframerate()
    with sr.AudioFile(path) as source:
        audio = r.record(source)
    try:
        tr_tr = r.recognize_google(audio, language="tr-TR")
    except Exception as e:
        tr_tr = f"ERR({e})"
    try:
        tr_en = r.recognize_google(audio, language="en-US")
    except Exception as e:
        tr_en = f"ERR({e})"
    print(f"VC '{name:2s}': dur={dur:.3f}s | TR: '{tr_tr}' | EN: '{tr_en}'")
