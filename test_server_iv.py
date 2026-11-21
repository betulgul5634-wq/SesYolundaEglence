import urllib.request, urllib.parse, io, speech_recognition as sr

url = "http://localhost:8000/api/tts?text=iv&phoneme=v&mode=syllable&v=11"
req = urllib.request.Request(url)
with urllib.request.urlopen(req) as resp:
    audio_data = resp.read()
    print("Content-Type:", resp.headers.get("content-type"), "Len:", len(audio_data))

r = sr.Recognizer()
with sr.AudioFile(io.BytesIO(audio_data)) as source:
    audio = r.record(source)

try:
    print("Recognized as:", r.recognize_google(audio, language="tr-TR"))
except Exception as e:
    print("Recognition result/err:", e)
