import asyncio
import edge_tts
import miniaudio
import numpy as np
import io, wave, sys, os
sys.stdout.reconfigure(encoding='utf-8')

from audio_helper import synth, save_wav, get_energy

async def extract_vc(vcv_word, target_name):
    # Synthesize vcv_word, e.g. "aca", "ece", "ıcı", "ici", "oco", "öcö", "ucu", "ücü"
    samples, ch, sr = await synth(vcv_word, rate="-4%", pitch="+4Hz")
    mono, energy = get_energy(samples, ch, sr)
    
    thresh = np.max(energy) * 0.05
    speech_indices = np.where(energy > thresh)[0]
    start = max(0, speech_indices[0] - int(sr * 0.01))
    
    # In VCV word (e.g. "aca"):
    # 1. First vowel 'a' has high energy for ~150-200ms
    # 2. Closure for 'c' causes energy dip
    # 3. Burst/affricate of 'c' (friction)
    # 4. Second vowel 'a' rises back up
    
    # Let's find where first vowel ends / closure begins
    vowel1_min_len = int(sr * 0.12)
    closure_start = start + vowel1_min_len
    min_energy_idx = closure_start
    min_val = 1e9
    
    # Search for closure dip between 120ms and 300ms from start
    search_end = min(len(energy), start + int(sr * 0.35))
    for i in range(closure_start, search_end):
        if energy[i] < min_val:
            min_val = energy[i]
            min_energy_idx = i
            
    # Then after closure, burst of 'c' happens (lasts ~50-80ms)
    burst_end = min_energy_idx + int(sr * 0.09)
    # We cut right at the end of the burst of 'c', before second vowel develops full power
    cut_end = min(len(samples)//ch, burst_end)
    
    cut = samples[start * ch : cut_end * ch].copy()
    
    fade_len = int(sr * 0.02)
    f_out = np.linspace(1.0, 0.0, fade_len)
    if ch == 2:
        cut.reshape(-1, 2)[-fade_len:, 0] = (cut.reshape(-1, 2)[-fade_len:, 0] * f_out).astype(np.int16)
        cut.reshape(-1, 2)[-fade_len:, 1] = (cut.reshape(-1, 2)[-fade_len:, 1] * f_out).astype(np.int16)
    else:
        cut[-fade_len:] = (cut[-fade_len:] * f_out).astype(np.int16)
        
    out_path = f"scripts/slices/{target_name}.wav"
    save_wav(cut, ch, sr, out_path)
    dur = len(cut) / (sr * ch)
    print(f"VC: {target_name:4s} from '{vcv_word:5s}': dur={dur:.3f}s (closure={min_energy_idx/sr:.3f}s, burst_end={burst_end/sr:.3f}s)")

async def main():
    pairs = [
        ("aca", "ac"),
        ("ece", "ec"),
        ("ıcı", "ıc"),
        ("ici", "ic"),
        ("oco", "oc"),
        ("öcö", "öc"),
        ("ucu", "uc"),
        ("ücü", "üc"),
    ]
    for w, t in pairs:
        await extract_vc(w, t)

if __name__ == '__main__':
    asyncio.run(main())
