import os
import speech_recognition as sr

r = sr.Recognizer()
pure_dir = "backend/pure_syllables"

for f in sorted(os.listdir(pure_dir)):
    if f.endswith(".wav") and not f.startswith("story") and not f.endswith("_explain.wav"):
        path = os.path.join(pure_dir, f)
        try:
            with sr.AudioFile(path) as source:
                audio = r.record(source)
            text = r.recognize_google(audio, language="tr-TR")
        except Exception as e:
            text = f"<error: {e}>"
        print(f"{f:15} -> '{text}'")
