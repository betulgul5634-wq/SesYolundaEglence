import asyncio
import edge_tts
import miniaudio
import numpy as np
import wave
import os

candidates = [
    ("p_burst_1", "P! P! P!"),
    ("p_burst_2", "Pı! Pı! Pı!"),
    ("p_burst_3", "P... P... P..."),
    ("p_burst_4", "Puh! Puh! Puh!"),
    ("p_burst_5", "Pı! Pı! P! P!"),
]

async def gen_candidates():
    for name, text in candidates:
        comm = edge_tts.Communicate(text, "tr-TR-EmelNeural", pitch="+10Hz", rate="+15%")
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
        print(f"Generated {name}.wav (dur: {dur:.2f}s) for prompt '{text}'")

asyncio.run(gen_candidates())
