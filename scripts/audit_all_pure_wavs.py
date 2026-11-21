import os
import wave
import speech_recognition as sr

r = sr.Recognizer()
sounds = ['p', 'b', 't', 'd', 'k', 'g', 'f', 'v', 's', 'z', 'ş', 'j', 'h', 'ç', 'c', 'm', 'n', 'l', 'r', 'y']

print(f"{'Sound':<6} {'Dur':<8} {'Frames':<10} {'Speech Recognition / Content'}")
print("-" * 65)

for s in sounds:
    path = f"backend/pure_syllables/{s}.wav"
    if not os.path.exists(path):
        print(f"/{s}/    NOT FOUND")
        continue
    with wave.open(path, 'rb') as wf:
        frames = wf.getnframes()
        dur = frames / wf.getframerate()
    try:
        with sr.AudioFile(path) as source:
            audio = r.record(source)
        heard = r.recognize_google(audio, language="tr-TR")
    except Exception as e:
        heard = f"<no speech/pure sound: {type(e).__name__}>"
    print(f"/{s}/    {dur:.2f}s   {frames:<10} '{heard}'")
