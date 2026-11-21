import asyncio
import edge_tts
import miniaudio
import numpy as np
import io, wave, sys, os
import speech_recognition as sr
sys.stdout.reconfigure(encoding='utf-8')

from audio_helper import synth, save_wav, transcribe_wav, get_energy

async def extract_syllable(carrier_word, target_name, start_offset_ms, duration_ms, is_vcv=False):
    samples, ch, sr = await synth(carrier_word, rate="-4%", pitch="+4Hz")
    mono, energy = get_energy(samples, ch, sr)
    
    thresh = np.max(energy) * 0.05
    speech_indices = np.where(energy > thresh)[0]
    first_speech = speech_indices[0]
    
    start_sample = max(0, first_speech + int(sr * (start_offset_ms / 1000.0)))
    end_sample = min(len(samples)//ch, start_sample + int(sr * (duration_ms / 1000.0)))
    
    cut = samples[start_sample * ch : end_sample * ch].copy()
    
    # Apply fade in (10ms) and fade out (25ms)
    fade_in_len = int(sr * 0.015)
    fade_out_len = int(sr * 0.025)
    
    if len(cut) // ch > fade_in_len + fade_out_len:
        f_in = np.linspace(0.0, 1.0, fade_in_len)
        f_out = np.linspace(1.0, 0.0, fade_out_len)
        if ch == 2:
            cut.reshape(-1, 2)[:fade_in_len, 0] = (cut.reshape(-1, 2)[:fade_in_len, 0] * f_in).astype(np.int16)
            cut.reshape(-1, 2)[:fade_in_len, 1] = (cut.reshape(-1, 2)[:fade_in_len, 1] * f_in).astype(np.int16)
            cut.reshape(-1, 2)[-fade_out_len:, 0] = (cut.reshape(-1, 2)[-fade_out_len:, 0] * f_out).astype(np.int16)
            cut.reshape(-1, 2)[-fade_out_len:, 1] = (cut.reshape(-1, 2)[-fade_out_len:, 1] * f_out).astype(np.int16)
        else:
            cut[:fade_in_len] = (cut[:fade_in_len] * f_in).astype(np.int16)
            cut[-fade_out_len:] = (cut[-fade_out_len:] * f_out).astype(np.int16)
            
    out_path = f"scripts/slices/{target_name}.wav"
    save_wav(cut, ch, sr, out_path)
    dur = len(cut) / (sr * ch)
    print(f"Extracted {target_name:6s} from '{carrier_word:10s}': dur={dur:.2f}s")
    return out_path

async def test_all_c():
    os.makedirs("scripts/slices", exist_ok=True)
    
    # CV syllables
    await extract_syllable("cam", "ca", 0, 300)
    await extract_syllable("ceket", "ce", 0, 300)
    await extract_syllable("cıvıltı", "cı", 0, 300)
    await extract_syllable("cips", "ci", 0, 300)
    await extract_syllable("cop", "co", 0, 300)
    await extract_syllable("cömert", "cö", 0, 320)
    await extract_syllable("cuma", "cu", 0, 300)
    await extract_syllable("cüce", "cü", 0, 300)
    
    # VC syllables: extracted from VCV words
    await extract_syllable("amca", "ac", 0, 290)
    await extract_syllable("gece", "ec", 0, 270)
    await extract_syllable("acı", "ıc", 0, 270)
    await extract_syllable("inci", "ic", 0, 270)
    await extract_syllable("kocaman", "oc", 0, 300)
    await extract_syllable("böcek", "öc", 0, 300)
    await extract_syllable("ucuz", "uc", 0, 280)
    await extract_syllable("gücü", "üc", 0, 280)

if __name__ == '__main__':
    asyncio.run(test_all_c())
