import os, sys
import speech_recognition as sr

sys.stdout.reconfigure(encoding='utf-8')

r = sr.Recognizer()

s_files = [
    'sa.wav', 'se.wav', 'sı.wav', 'si.wav', 'so.wav', 'sö.wav', 'su.wav', 'sü.wav',
    'as.wav', 'es.wav', 'ıs.wav', 'is.wav', 'os.wav', 'ös.wav', 'us.wav', 'üs.wav',
    'asa.wav', 'ese.wav', 'ısı.wav', 'isi.wav', 'oso.wav', 'ösö.wav', 'usu.wav', 'üsü.wav',
    'sas.wav', 'ses.wav', 'sıs.wav', 'sis.wav', 'sos.wav', 'sös.wav', 'sus.wav', 'süs.wav'
]

pure_dir = 'backend/pure_syllables'

for name in s_files:
    p = os.path.join(pure_dir, name)
    if not os.path.exists(p):
        print(f"{name}: [FILE DOES NOT EXIST]")
        continue
    with sr.AudioFile(p) as source:
        audio = r.record(source)
    try:
        txt = r.recognize_google(audio, language='tr-TR')
        print(f"{name}: \"{txt}\"")
    except sr.UnknownValueError:
        print(f"{name}: [Unrecognized]")
    except Exception as e:
        print(f"{name}: [Error: {e}]")
