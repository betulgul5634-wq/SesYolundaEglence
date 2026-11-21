import asyncio
import edge_tts
import miniaudio
import numpy as np
import io, wave, sys, os
import speech_recognition as sr
sys.stdout.reconfigure(encoding='utf-8')

from audio_helper import synth, save_wav, transcribe_wav

def slice_cv(samples, ch, sr, end_time):
    # Slice from beginning of speech until end_time
    if ch == 2:
        mono = samples.reshape(-1, 2).mean(axis=1)
    else:
        mono = samples
    thresh = np.max(np.abs(mono)) * 0.05
    indices = np.where(np.abs(mono) > thresh)[0]
    start = max(0, indices[0] - int(sr * 0.01))
    end = start + int(sr * end_time)
    
    cut = samples[start * ch : end * ch].copy()
    fade_len = int(sr * 0.02)
    fade = np.linspace(1.0, 0.0, fade_len)
    if ch == 2:
        cut.reshape(-1, 2)[-fade_len:, 0] = (cut.reshape(-1, 2)[-fade_len:, 0] * fade).astype(np.int16)
        cut.reshape(-1, 2)[-fade_len:, 1] = (cut.reshape(-1, 2)[-fade_len:, 1] * fade).astype(np.int16)
    else:
        cut[-fade_len:] = (cut[-fade_len:] * fade).astype(np.int16)
    return cut

async def test_slices():
    os.makedirs('scripts/slices', exist_ok=True)
    
    # 1. cı from cımbız or cıvata
    s_cimbiz, ch, sr = await synth("cımbız")
    # cı is the first syllable in cımbız (~0.35s)
    c_ci = slice_cv(s_cimbiz, ch, sr, 0.32)
    save_wav(c_ci, ch, sr, "scripts/slices/cı.wav")
    
    # 2. co from cop or coşku
    s_cop, ch, sr = await synth("cop")
    # in cop, 'co' is until p starts (~0.28s)
    c_co = slice_cv(s_cop, ch, sr, 0.28)
    save_wav(c_co, ch, sr, "scripts/slices/co.wav")
    
    # 3. cu from cuma
    s_cuma, ch, sr = await synth("cuma")
    c_cu = slice_cv(s_cuma, ch, sr, 0.28)
    save_wav(c_cu, ch, sr, "scripts/slices/cu.wav")
    
    print("Slices saved successfully.")

if __name__ == '__main__':
    asyncio.run(test_slices())
