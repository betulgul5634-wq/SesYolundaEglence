import urllib.request
import speech_recognition as sr
import io

syllables_to_test = ["p", "ıp", "ip", "ap", "ep", "op", "öp", "up", "üp", "pa", "pe", "pı", "pi", "po", "pö", "pu", "pü"]

r = sr.Recognizer()

for syl in syllables_to_test:
    url = f"http://127.0.0.1:8000/api/tts?text={syl}&phoneme=p&mode=natural"
    try:
        resp = urllib.request.urlopen(url)
        data = resp.read()
        # transcribe using speech_recognition
        with sr.AudioFile(io.BytesIO(data)) as source:
            audio = r.record(source)
        try:
            text = r.recognize_google(audio, language="tr-TR")
        except Exception:
            text = "<not recognized / sound>"
        print(f"Syllable '{syl}': {len(data)} bytes, Recognizer heard: '{text}'")
    except Exception as e:
        print(f"Syllable '{syl}': Error: {e}")
