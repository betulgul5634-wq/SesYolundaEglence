import asyncio
import edge_tts
import miniaudio
import numpy as np
import io, wave, sys
import speech_recognition as sr
sys.stdout.reconfigure(encoding='utf-8')

from audio_helper import synth, save_wav, transcribe_wav

async def test_hyphens():
    tests = [
        ("c_dash_o", "c-o"),
        ("c_dash_u", "c-u"),
        ("c_dash_ı", "c-ı"),
        ("ı_dash_c", "ı-c"),
        ("i_dash_c", "i-c"),
        ("c_space_o", "c o"),
        ("c_space_u", "c u"),
        ("c_space_ı", "c ı"),
        ("ı_space_c", "ı c"),
        ("i_space_c", "i c"),
        # Carrier words
        ("cam", "cam"),
        ("ceviz", "ce"),
        ("cop", "cop"),
        ("curcuna", "curcuna"),
    ]
    for name, text in tests:
        samples, ch, sr_val = await synth(text)
        fname = f"scripts/test_{name}.wav"
        save_wav(samples, ch, sr_val, fname)
        dur = len(samples) / (sr_val * ch)
        tr = transcribe_wav(fname)
        print(f"[{name:12s}] '{text:10s}' -> dur={dur:.2f}s, STT='{tr}'", flush=True)

if __name__ == '__main__':
    asyncio.run(test_hyphens())
