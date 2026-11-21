import asyncio
import edge_tts
import miniaudio
import wave
import speech_recognition as sr

prompts = [
    ("p_test_a", "Pı. Pı. Pı."),
    ("p_test_b", "P, p, p."),
    ("p_test_c", "P... P... P..."),
    ("p_test_d", "Pı! Pı!"),
    ("p_test_e", "Pı, pı, pı."),
    ("p_test_f", "Pıp. Pıp. Pıp."),
]

async def gen():
    for name, text in prompts:
        comm = edge_tts.Communicate(text, "tr-TR-EmelNeural", rate="+5%", pitch="+5Hz")
        mp3 = b""
        async for chunk in comm.stream():
            if chunk["type"] == "audio": mp3 += chunk["data"]
        dec = miniaudio.decode(mp3)
        with wave.open(f"{name}.wav", "wb") as wf:
            wf.setnchannels(dec.nchannels)
            wf.setsampwidth(2)
            wf.setframerate(dec.sample_rate)
            wf.writeframes(dec.samples)
        dur = len(dec.samples) / (dec.sample_rate * dec.nchannels * 2)
        print(f"Saved {name}.wav (dur: {dur:.2f}s) text: {text}")

asyncio.run(gen())

r = sr.Recognizer()
for name, text in prompts:
    with sr.AudioFile(f"{name}.wav") as s:
        audio = r.record(s)
    try:
        heard = r.recognize_google(audio, language="tr-TR")
    except Exception as e:
        heard = f"<unrecognized/pop: {e}>"
    print(f"{name:10} -> heard: '{heard}'")
