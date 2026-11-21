import os
import speech_recognition as sr
import miniaudio

r = sr.Recognizer()

syls = ['pı', 'pi', 'ıp', 'ip', 'pa', 'pe', 'ap', 'ep', 'po', 'pö', 'op', 'öp', 'pu', 'pü', 'up', 'üp']

for s in syls:
    path = f"backend/pure_syllables/{s}.wav"
    if os.path.exists(path):
        try:
            with sr.AudioFile(path) as source:
                audio = r.record(source)
            heard = r.recognize_google(audio, language="tr-TR")
        except Exception as e:
            heard = f"<no speech detected / {e}>"
        print(f"File {s:4}.wav -> Heard: '{heard}'")
    else:
        print(f"File {s:4}.wav -> NOT FOUND")
