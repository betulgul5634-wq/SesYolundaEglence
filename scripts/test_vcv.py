import asyncio
import edge_tts
import miniaudio
import numpy as np
import io, wave, sys
import speech_recognition as sr
sys.stdout.reconfigure(encoding='utf-8')

from audio_helper import synth, save_wav, transcribe_wav

async def test_vcv():
    vcv_list = ['acı', 'ıcı', 'ici', 'aca', 'ece', 'oco', 'koco', 'öcö', 'ucu', 'ücü', 'cömert', 'cuma', 'cımbız', 'cop', 'cüce']
    for word in vcv_list:
        samples, ch, sr_val = await synth(word)
        fname = f"scripts/test_{word}.wav"
        save_wav(samples, ch, sr_val, fname)
        dur = len(samples) / (sr_val * ch)
        tr = transcribe_wav(fname)
        print(f"Word: '{word:10s}' -> dur={dur:.2f}s, STT='{tr}'")

if __name__ == '__main__':
    asyncio.run(test_vcv())
