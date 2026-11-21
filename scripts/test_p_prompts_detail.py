import asyncio
import edge_tts
import miniaudio
import numpy as np
import wave
import io
import speech_recognition as sr

async def synth_test(text):
    comm = edge_tts.Communicate(text, 'tr-TR-EmelNeural', rate='-5%', pitch='+2Hz')
    mp3 = b''
    async for c in comm.stream():
        if c['type'] == 'audio': mp3 += c['data']
    dec = miniaudio.decode(mp3)
    return dec.samples, dec.sample_rate, dec.nchannels

def to_wav(samples, sr_val, ch):
    buf = io.BytesIO()
    with wave.open(buf, 'wb') as wf:
        wf.setnchannels(ch)
        wf.setsampwidth(2)
        wf.setframerate(sr_val)
        wf.writeframes(samples)
    buf.seek(0)
    return buf

candidates = [
    # ıp candidates
    ("ıp", "Iıp."),
    ("ıp", "Iıp"),
    ("ıp", "I p."),
    ("ıp", "Iık."),
    ("ıp", "Isparta"),
    # pı candidates
    ("pı", "Pıı."),
    ("pı", "Pı."),
    ("pı", "Pır."),
    # pe candidates
    ("pe", "Pee."),
    ("pe", "Peh."),
    ("pe", "Pes."),
    # pi candidates
    ("pi", "Pii."),
    ("pi", "Pill."),
    ("pi", "Pis."),
    # ip candidates
    ("ip", "İip."),
    ("ip", "İp.")
]

r = sr.Recognizer()

for target, pr in candidates:
    samples, sr_val, ch = asyncio.run(synth_test(pr))
    buf = to_wav(samples, sr_val, ch)
    with sr.AudioFile(buf) as source:
        audio = r.record(source)
    try:
        heard = r.recognize_google(audio, language='tr-TR')
    except Exception as e:
        heard = f"err: {e}"
    dur = len(samples) / (sr_val * ch * 2)
    print(f"Target: {target:4} | Prompt: '{pr:10}' | Heard: '{heard}' | Dur: {dur:.2f}s")
