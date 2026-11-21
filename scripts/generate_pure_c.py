import asyncio
import edge_tts
import miniaudio
import numpy as np
import io, wave, os, sys
sys.stdout.reconfigure(encoding='utf-8')

OUT_DIR = os.path.join("backend", "pure_syllables")
os.makedirs(OUT_DIR, exist_ok=True)

async def synth_audio(text, rate="-4%", pitch="+4Hz"):
    comm = edge_tts.Communicate(text, voice="tr-TR-EmelNeural", rate=rate, pitch=pitch)
    data = b""
    async for c in comm.stream():
        if c["type"] == "audio":
            data += c["data"]
    decoded = miniaudio.decode(data)
    samples = np.frombuffer(decoded.samples, dtype=np.int16).copy()
    return samples, decoded.nchannels, decoded.sample_rate

def get_envelope(samples, ch, sr):
    if ch == 2:
        mono = samples.reshape(-1, 2).mean(axis=1)
    else:
        mono = samples
    abs_mono = np.abs(mono)
    window = int(sr * 0.01) # 10ms
    energy = np.convolve(abs_mono, np.ones(window)/window, mode='same')
    return mono, energy

def save_wav(samples, ch, sr, filename):
    filepath = os.path.join(OUT_DIR, filename)
    with wave.open(filepath, 'wb') as wf:
        wf.setnchannels(ch)
        wf.setsampwidth(2)
        wf.setframerate(sr)
        wf.writeframes(samples.tobytes())
    dur = len(samples) / (sr * ch)
    print(f"  [SAVED] {filename:16s} ({dur:.3f}s)")
    return filepath

def apply_fades(samples, ch, sr, in_ms=15, out_ms=25):
    cut = samples.copy()
    fade_in = int(sr * (in_ms / 1000.0))
    fade_out = int(sr * (out_ms / 1000.0))
    
    if len(cut) // ch > fade_in + fade_out:
        f_in = np.linspace(0.0, 1.0, fade_in)
        f_out = np.linspace(1.0, 0.0, fade_out)
        if ch == 2:
            cut.reshape(-1, 2)[:fade_in, 0] = (cut.reshape(-1, 2)[:fade_in, 0] * f_in).astype(np.int16)
            cut.reshape(-1, 2)[:fade_in, 1] = (cut.reshape(-1, 2)[:fade_in, 1] * f_in).astype(np.int16)
            cut.reshape(-1, 2)[-fade_out:, 0] = (cut.reshape(-1, 2)[-fade_out:, 0] * f_out).astype(np.int16)
            cut.reshape(-1, 2)[-fade_out:, 1] = (cut.reshape(-1, 2)[-fade_out:, 1] * f_out).astype(np.int16)
        else:
            cut[:fade_in] = (cut[:fade_in] * f_in).astype(np.int16)
            cut[-fade_out:] = (cut[-fade_out:] * f_out).astype(np.int16)
    return cut

# 1. Slicing CV syllables from authentic carrier words
async def build_cv(carrier_word, target_name, dur_ms=300):
    samples, ch, sr = await synth_audio(carrier_word, rate="-4%", pitch="+4Hz")
    mono, energy = get_envelope(samples, ch, sr)
    thresh = np.max(energy) * 0.04
    speech_indices = np.where(energy > thresh)[0]
    start = max(0, speech_indices[0] - int(sr * 0.01))
    end = min(len(samples)//ch, start + int(sr * (dur_ms / 1000.0)))
    cut = samples[start * ch : end * ch]
    cut_faded = apply_fades(cut, ch, sr, in_ms=10, out_ms=30)
    save_wav(cut_faded, ch, sr, f"{target_name}.wav")

# 2. Slicing VC syllables from VCV words
async def build_vc(vcv_word, target_name):
    samples, ch, sr = await synth_audio(vcv_word, rate="-4%", pitch="+4Hz")
    mono, energy = get_envelope(samples, ch, sr)
    thresh = np.max(energy) * 0.04
    speech_indices = np.where(energy > thresh)[0]
    start = max(0, speech_indices[0] - int(sr * 0.01))
    
    # In VCV word (e.g. 'aca'):
    # vowel 1 lasts ~120-220ms, then closure dip, then burst of 'c', then vowel 2
    vowel1_min = start + int(sr * 0.10)
    search_end = min(len(energy), start + int(sr * 0.35))
    
    min_energy_idx = vowel1_min
    min_val = 1e9
    for i in range(vowel1_min, search_end):
        if energy[i] < min_val:
            min_val = energy[i]
            min_energy_idx = i
            
    # The burst of 'c' continues for ~75ms after closure dip
    burst_end = min_energy_idx + int(sr * 0.075)
    cut_end = min(len(samples)//ch, burst_end)
    cut = samples[start * ch : cut_end * ch]
    cut_faded = apply_fades(cut, ch, sr, in_ms=15, out_ms=25)
    save_wav(cut_faded, ch, sr, f"{target_name}.wav")

# 3. Slicing VCV syllables
async def build_vcv(vcv_word, target_name, dur_ms=480):
    samples, ch, sr = await synth_audio(vcv_word, rate="-4%", pitch="+4Hz")
    mono, energy = get_envelope(samples, ch, sr)
    thresh = np.max(energy) * 0.04
    speech_indices = np.where(energy > thresh)[0]
    start = max(0, speech_indices[0] - int(sr * 0.01))
    
    # End of second vowel
    end_indices = np.where(energy[start:] > thresh)[0]
    if len(end_indices) > 0:
        actual_end = start + end_indices[-1] + int(sr * 0.02)
    else:
        actual_end = start + int(sr * (dur_ms / 1000.0))
        
    actual_end = min(len(samples)//ch, max(actual_end, start + int(sr * 0.35)))
    cut = samples[start * ch : actual_end * ch]
    cut_faded = apply_fades(cut, ch, sr, in_ms=15, out_ms=25)
    save_wav(cut_faded, ch, sr, f"{target_name}.wav")

# 4. Slicing CVC syllables
async def build_cvc(carrier_word, target_name, dur_ms=380):
    samples, ch, sr = await synth_audio(carrier_word, rate="-4%", pitch="+4Hz")
    mono, energy = get_envelope(samples, ch, sr)
    thresh = np.max(energy) * 0.04
    speech_indices = np.where(energy > thresh)[0]
    start = max(0, speech_indices[0] - int(sr * 0.01))
    end = min(len(samples)//ch, start + int(sr * (dur_ms / 1000.0)))
    cut = samples[start * ch : end * ch]
    cut_faded = apply_fades(cut, ch, sr, in_ms=10, out_ms=30)
    save_wav(cut_faded, ch, sr, f"{target_name}.wav")

async def build_pure_c_and_intro():
    # Build c.wav: 3 voiced affricate bursts [d͡ʒ] - [d͡ʒ] - [d͡ʒ]
    s_cik, ch, sr = await synth_audio("cık cık")
    mono, energy = get_envelope(s_cik, ch, sr)
    thresh = np.max(energy) * 0.05
    speech_indices = np.where(energy > thresh)[0]
    
    burst_start = speech_indices[0]
    burst_len = int(sr * 0.13) # 130ms clean burst
    burst = s_cik[burst_start * ch : (burst_start + burst_len) * ch].copy()
    burst = apply_fades(burst, ch, sr, in_ms=10, out_ms=20)
    
    silence = np.zeros(int(sr * 0.075) * ch, dtype=np.int16)
    c_three = np.concatenate([burst, silence, burst, silence, burst])
    save_wav(c_three, ch, sr, "c.wav")
    
    # Build game_intro_c.wav
    part1_samples, ch1, sr1 = await synth_audio("Hazır ol! İçinde ", rate="-2%", pitch="+6Hz")
    part2_samples, ch2, sr2 = await synth_audio(" sesi bulunan kelimeleri ye ve dev gibi büyü!", rate="-2%", pitch="+6Hz")
    
    # Trim silences
    mono1, e1 = get_envelope(part1_samples, ch1, sr1)
    s1 = np.where(e1 > np.max(e1)*0.03)[0]
    part1_trimmed = part1_samples[max(0, s1[0]-int(sr1*0.01))*ch1 : (s1[-1]+int(sr1*0.02))*ch1]
    
    mono2, e2 = get_envelope(part2_samples, ch2, sr2)
    s2 = np.where(e2 > np.max(e2)*0.03)[0]
    part2_trimmed = part2_samples[max(0, s2[0]-int(sr2*0.01))*ch2 : (s2[-1]+int(sr2*0.02))*ch2]
    
    # Combine part1 + short silence + c_three + short silence + part2
    gap1 = np.zeros(int(sr * 0.06) * ch, dtype=np.int16)
    gap2 = np.zeros(int(sr * 0.08) * ch, dtype=np.int16)
    
    game_intro = np.concatenate([part1_trimmed, gap1, c_three, gap2, part2_trimmed])
    save_wav(game_intro, ch, sr, "game_intro_c.wav")

async def main():
    print("=== 1. GENERATING PURE C AND GAME INTRO ===")
    await build_pure_c_and_intro()
    
    print("\n=== 2. GENERATING 8 CV SYLLABLES ===")
    cv_specs = [
        ("cam", "ca", 300),
        ("ceket", "ce", 300),
        ("cıvıltı", "cı", 310), # authentic Turkish [ɯ], not [i]
        ("cips", "ci", 290),
        ("cop", "co", 290),     # authentic Turkish [d͡ʒ] + [o], not /k/
        ("cömert", "cö", 310),
        ("cuma", "cu", 300),    # authentic Turkish [d͡ʒ] + [u], not 'Ceyo'
        ("cüce", "cü", 290),
    ]
    for w, s, d in cv_specs:
        await build_cv(w, s, d)
        
    print("\n=== 3. GENERATING 8 VC SYLLABLES (NO TRAILING 'e') ===")
    vc_specs = [
        ("aca", "ac"),
        ("ece", "ec"),
        ("ıcı", "ıc"), # pure [ɯ] + [c], NO 'ıce'!
        ("ici", "ic"), # pure [i] + [c], NO 'ice'!
        ("oco", "oc"),
        ("öcö", "öc"),
        ("ucu", "uc"),
        ("ücü", "üc"),
    ]
    for w, s in vc_specs:
        await build_vc(w, s)
        
    print("\n=== 4. GENERATING 8 VCV SYLLABLES ===")
    vcv_specs = [
        ("aca", "aca"),
        ("ece", "ece"),
        ("ıcı", "ıcı"),
        ("ici", "ici"),
        ("oco", "oco"),
        ("öcö", "öcö"),
        ("ucu", "ucu"),
        ("ücü", "ücü"),
    ]
    for w, s in vcv_specs:
        await build_vcv(w, s)
        
    print("\n=== 5. GENERATING 8 CVC SYLLABLES ===")
    cvc_specs = [
        ("cacık", "cac", 380),
        ("ceket", "cec", 350),
        ("cıvıltı", "cıc", 350),
        ("cici", "cic", 350),
        ("cop", "coc", 350),
        ("cömert", "cöc", 350),
        ("curcuna", "cuc", 360),
        ("cüce", "cüc", 350),
    ]
    for w, s, d in cvc_specs:
        await build_cvc(w, s, d)
        
    print("\nALL 32 SYLLABLES AND INTROS GENERATED SUCCESSFULLY!")

if __name__ == '__main__':
    asyncio.run(main())
