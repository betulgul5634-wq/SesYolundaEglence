import os
import speech_recognition as sr
import wave

r = sr.Recognizer()
pure_dir = "backend/pure_syllables"
p_files = ["p.wav", "pa.wav", "pe.wav", "pı.wav", "pi.wav", "po.wav", "pö.wav", "pu.wav", "pü.wav",
           "ap.wav", "ep.wav", "ıp.wav", "ip.wav", "op.wav", "öp.wav", "up.wav", "üp.wav"]

for f in p_files:
    path = os.path.join(pure_dir, f)
    if not os.path.exists(path):
        print(f"{f:10} -> NOT FOUND")
        continue
    with wave.open(path, "rb") as wf:
        dur = wf.getnframes() / wf.getframerate()
    try:
        with sr.AudioFile(path) as source:
            audio = r.record(source)
        text = r.recognize_google(audio, language="tr-TR")
    except Exception as e:
        text = f"<unrecognized/short: {e}>"
    print(f"{f:10} (dur: {dur:.2f}s) -> '{text}'")
