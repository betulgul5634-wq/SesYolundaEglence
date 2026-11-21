import asyncio
import edge_tts
import miniaudio
import numpy as np
import wave
import speech_recognition as sr

async def synth_test(text):
    comm = edge_tts.Communicate(text, 'tr-TR-EmelNeural', rate='-10%', pitch='+2Hz')
    mp3 = b''
    async for c in comm.stream():
        if c['type'] == 'audio': mp3 += c['data']
    dec = miniaudio.decode(mp3)
    return np.frombuffer(dec.samples, dtype=np.int16), dec.sample_rate, dec.nchannels

prompts = [
    ("Iıp", "Iıp"),
    ("Iııp", "Iııp"),
    ("ıııp", "ıııp"),
    ("ıp", "ıp"),
    ("ı p", "ı p"),
    ("zıp", "zıp"),
    ("kıp", "kıp"),
    ("şıp", "şıp"),
    ("tıb", "tıb")
]

r = sr.Recognizer()

for name, pr in prompts:
    samples, sr_val, ch = asyncio.run(synth_test(pr))
    with wave.open(f"test_ip_{name}.wav", "wb") as wf:
        wf.setnchannels(ch)
        wf.setsampwidth(2)
        wf.setframerate(sr_val)
        wf.writeframes(samples.tobytes())
    with sr.AudioFile(f"test_ip_{name}.wav") as source:
        audio = r.record(source)
    try:
        heard = r.recognize_google(audio, language="tr-TR")
    except Exception as e:
        heard = f"err: {e}"
    dur = len(samples) / (sr_val * ch)
    print(f"Prompt '{pr:<8}' -> dur: {dur:.2f}s, heard: '{heard}'")
