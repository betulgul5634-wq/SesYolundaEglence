import speech_recognition as sr

r = sr.Recognizer()
for name in ['p_burst_1', 'p_burst_2', 'p_burst_3', 'p_burst_4', 'p_burst_5']:
    with sr.AudioFile(f'{name}.wav') as s:
        audio = r.record(s)
    try:
        txt = r.recognize_google(audio, language='tr-TR')
    except Exception as e:
        txt = f'<unrecognized/pop: {e}>'
    print(f'{name:12} -> heard: "{txt}"')
