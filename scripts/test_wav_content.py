import speech_recognition as sr
import os

r = sr.Recognizer()
pure_dir = 'backend/pure_syllables'

for sound in ['p', 'b', 't', 'd', 's']:
    p = os.path.join(pure_dir, f"{sound}.wav")
    if os.path.exists(p):
        try:
            with sr.AudioFile(p) as source:
                audio = r.record(source)
                text = r.recognize_google(audio, language="tr-TR")
                print(f"{sound}.wav recognized as: '{text}'")
        except Exception as e:
            print(f"{sound}.wav failed recognition: {e}")
