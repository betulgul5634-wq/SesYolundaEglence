import speech_recognition as sr

r = sr.Recognizer()
for name in ['co_raw', 'cu_raw', 'ıc_raw', 'ic_raw', 'cı_raw']:
    with sr.AudioFile(f'scripts/{name}.wav') as source:
        audio = r.record(source)
    try:
        tr_en = r.recognize_google(audio, language="en-US")
    except Exception as e:
        tr_en = str(e)
    try:
        tr_tr = r.recognize_google(audio, language="tr-TR")
    except Exception as e:
        tr_tr = str(e)
    print(f"{name:10s} -> TR: '{tr_tr}' | EN: '{tr_en}'")
