import asyncio
import edge_tts
import miniaudio
import numpy as np
import io, wave, sys
import speech_recognition as sr
sys.stdout.reconfigure(encoding='utf-8')

from audio_helper import synth, save_wav, transcribe_wav

async def test_prompts():
    test_cases = [
        # cı tests
        ("cı_raw", "cı"),
        ("cı_dot", "cı."),
        ("cı_dash", "cı -"),
        ("cı_long", "cıı"),
        ("cımbız", "cımbız"),
        # co tests
        ("co_raw", "co"),
        ("co_dot", "co."),
        ("co_long", "coo"),
        ("cop", "cop"),
        # cu tests
        ("cu_raw", "cu"),
        ("cu_dot", "cu."),
        ("cu_long", "cuu"),
        ("cuma", "cuma"),
        # ıc tests
        ("ıc_raw", "ıc"),
        ("ıc_dot", "ıc."),
        ("ıc_long", "ıcc"),
        # ic tests
        ("ic_raw", "ic"),
        ("ic_dot", "ic."),
        ("ic_long", "icc"),
    ]
    
    for name, text in test_cases:
        samples, ch, sr_val = await synth(text)
        fname = f"scripts/{name}.wav"
        save_wav(samples, ch, sr_val, fname)
        dur = len(samples) / (sr_val * ch)
        tr = transcribe_wav(fname)
        print(f"[{name:10s}] prompt='{text:8s}' -> dur={dur:.2f}s, STT='{tr}'")

if __name__ == '__main__':
    asyncio.run(test_prompts())
