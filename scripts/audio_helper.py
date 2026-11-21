import asyncio
import edge_tts
import miniaudio
import numpy as np
import io
import wave
import sys
import speech_recognition as sr
sys.stdout.reconfigure(encoding='utf-8')

async def synth(text, rate="-4%", pitch="+4Hz"):
    c = edge_tts.Communicate(text, voice="tr-TR-EmelNeural", rate=rate, pitch=pitch)
    data = b""
    async for chunk in c.stream():
        if chunk["type"] == "audio":
            data += chunk["data"]
    decoded = miniaudio.decode(data)
    samples = np.frombuffer(decoded.samples, dtype=np.int16).copy()
    ch = decoded.nchannels
    sr = decoded.sample_rate
    return samples, ch, sr

def get_energy(samples, ch, sr):
    if ch == 2:
        mono = samples.reshape(-1, 2).mean(axis=1)
    else:
        mono = samples
    abs_mono = np.abs(mono)
    window = int(sr * 0.01)
    energy = np.convolve(abs_mono, np.ones(window)/window, mode='same')
    return mono, energy

def save_wav(samples, ch, sr, filename):
    with wave.open(filename, 'wb') as wf:
        wf.setnchannels(ch)
        wf.setsampwidth(2)
        wf.setframerate(sr)
        wf.writeframes(samples.tobytes())

def transcribe_wav(filename):
    r = sr.Recognizer()
    with sr.AudioFile(filename) as source:
        audio = r.record(source)
    try:
        return r.recognize_google(audio, language="tr-TR")
    except Exception as e:
        return f"ERR({e})"

print("Test script setup ready.")
