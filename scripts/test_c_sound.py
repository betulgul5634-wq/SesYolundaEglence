import asyncio
import edge_tts
import miniaudio
import numpy as np
import io, wave, sys
sys.stdout.reconfigure(encoding='utf-8')

from audio_helper import synth, save_wav

async def make_c_sound():
    # Let's synthesize words containing clean c onsets
    s_cik, ch, sr = await synth("cık cık")
    s_cam, _, _ = await synth("cam")
    s_can, _, _ = await synth("can")
    
    # Let's inspect s_cik to extract the pure burst of c
    if ch == 2:
        mono = s_cik.reshape(-1, 2).mean(axis=1)
    else:
        mono = s_cik
    thresh = np.max(np.abs(mono)) * 0.05
    indices = np.where(np.abs(mono) > thresh)[0]
    
    # First 'cık': the initial burst of 'c' lasts ~120ms before the vowel stabilizes
    burst1_start = indices[0]
    burst1_len = int(sr * 0.14)
    burst1 = s_cik[burst1_start * ch : (burst1_start + burst1_len) * ch].copy()
    
    # Fade in and fade out
    fade = int(sr * 0.015)
    f_in = np.linspace(0.0, 1.0, fade)
    f_out = np.linspace(1.0, 0.0, fade)
    if ch == 2:
        burst1.reshape(-1, 2)[:fade, 0] = (burst1.reshape(-1, 2)[:fade, 0] * f_in).astype(np.int16)
        burst1.reshape(-1, 2)[:fade, 1] = (burst1.reshape(-1, 2)[:fade, 1] * f_in).astype(np.int16)
        burst1.reshape(-1, 2)[-fade:, 0] = (burst1.reshape(-1, 2)[-fade:, 0] * f_out).astype(np.int16)
        burst1.reshape(-1, 2)[-fade:, 1] = (burst1.reshape(-1, 2)[-fade:, 1] * f_out).astype(np.int16)
    
    # Silence between bursts
    silence = np.zeros(int(sr * 0.08) * ch, dtype=np.int16)
    
    # Repeat for 3 rhythmic bursts: c - c - c
    c_sound = np.concatenate([burst1, silence, burst1, silence, burst1])
    save_wav(c_sound, ch, sr, "scripts/c_sound_test.wav")
    print(f"Generated c_sound_test.wav: dur={len(c_sound)/(sr*ch):.2f}s")

if __name__ == '__main__':
    asyncio.run(make_c_sound())
