import speech_recognition as sr

r = sr.Recognizer()
for name in ["test_vc_ap.wav", "test_vc_ep.wav", "test_vc_ıp_1.wav", "test_vc_ıp_2.wav", "test_vc_ip.wav", "test_vc_op.wav", "test_vc_öp.wav", "test_vc_up.wav", "test_vc_üp.wav"]:
    with sr.AudioFile(name) as source:
        audio = r.record(source)
    try:
        heard = r.recognize_google(audio, language="tr-TR")
    except Exception as e:
        heard = f"err: {e}"
    print(f"{name:<20} -> heard: '{heard}'")
