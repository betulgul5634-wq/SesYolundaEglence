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

# 1. Slice initial syllable from carrier word
async def slice_initial(carrier_word, target_name, dur_ms=300):
    samples, ch, sr = await synth_audio(carrier_word, rate="-4%", pitch="+4Hz")
    mono, energy = get_envelope(samples, ch, sr)
    thresh = np.max(energy) * 0.04
    speech_indices = np.where(energy > thresh)[0]
    start = max(0, speech_indices[0] - int(sr * 0.01))
    end = min(len(samples)//ch, start + int(sr * (dur_ms / 1000.0)))
    cut = samples[start * ch : end * ch]
    cut_faded = apply_fades(cut, ch, sr, in_ms=10, out_ms=30)
    save_wav(cut_faded, ch, sr, f"{target_name}.wav")

# 2. Slice second syllable from carrier word (e.g. 'mam' from 'tamam')
async def slice_second_syllable(carrier_word, target_name, dur_ms=360):
    samples, ch, sr = await synth_audio(carrier_word, rate="-4%", pitch="+4Hz")
    mono, energy = get_envelope(samples, ch, sr)
    thresh = np.max(energy) * 0.04
    speech_indices = np.where(energy > thresh)[0]
    start_all = speech_indices[0]
    
    # In 'tamam': vowel 1 'ta' lasts ~200ms, then closure for 'm' drops energy
    vowel1_min = start_all + int(sr * 0.15)
    search_end = min(len(energy), start_all + int(sr * 0.35))
    min_idx = vowel1_min
    min_val = 1e9
    for i in range(vowel1_min, search_end):
        if energy[i] < min_val:
            min_val = energy[i]
            min_idx = i
            
    start_syl2 = min_idx
    end_syl2 = min(len(samples)//ch, start_syl2 + int(sr * (dur_ms / 1000.0)))
    cut = samples[start_syl2 * ch : end_syl2 * ch]
    cut_faded = apply_fades(cut, ch, sr, in_ms=10, out_ms=30)
    save_wav(cut_faded, ch, sr, f"{target_name}.wav")

# 3. Slice VCV syllable
async def slice_vcv(carrier_word, target_name, dur_ms=450):
    samples, ch, sr = await synth_audio(carrier_word, rate="-4%", pitch="+4Hz")
    mono, energy = get_envelope(samples, ch, sr)
    thresh = np.max(energy) * 0.04
    speech_indices = np.where(energy > thresh)[0]
    start = max(0, speech_indices[0] - int(sr * 0.01))
    end_indices = np.where(energy[start:] > thresh)[0]
    if len(end_indices) > 0:
        actual_end = start + end_indices[-1] + int(sr * 0.02)
    else:
        actual_end = start + int(sr * (dur_ms / 1000.0))
    actual_end = min(len(samples)//ch, max(actual_end, start + int(sr * 0.35)))
    cut = samples[start * ch : actual_end * ch]
    cut_faded = apply_fades(cut, ch, sr, in_ms=15, out_ms=25)
    save_wav(cut_faded, ch, sr, f"{target_name}.wav")

# 4. Synthesize 'ım' and 'ımı' by splicing pure Turkish [ɯ] with [m]
async def build_im_and_imi():
    # Splicing 'ı' from 'ılık' with nasal 'm' from 'm.wav'
    s_ilik, ch, sr = await synth_audio("ılık", rate="-4%", pitch="+4Hz")
    mono_i, e_i = get_envelope(s_ilik, ch, sr)
    s_i = np.where(e_i > np.max(e_i)*0.04)[0][0]
    vowel_i = s_ilik[s_i * ch : (s_i + int(sr * 0.16)) * ch] # 160ms pure [ɯ]
    
    # Pure 'm' hum
    s_mmm, _, _ = await synth_audio("Mmm", rate="-5%", pitch="+2Hz")
    mono_m, e_m = get_envelope(s_mmm, ch, sr)
    s_m = np.where(e_m > np.max(e_m)*0.05)[0][0]
    hum_m = s_mmm[s_m * ch : (s_m + int(sr * 0.14)) * ch] # 140ms pure [m]
    
    # ım = [ɯ] + [m]
    im_samples = np.concatenate([vowel_i, hum_m])
    im_faded = apply_fades(im_samples, ch, sr, in_ms=15, out_ms=25)
    save_wav(im_faded, ch, sr, "ım.wav")
    
    # ımı = [ɯ] + [m] + [ɯ]
    vowel_i2 = apply_fades(vowel_i, ch, sr, in_ms=10, out_ms=20)
    imi_samples = np.concatenate([vowel_i, hum_m, vowel_i2])
    imi_faded = apply_fades(imi_samples, ch, sr, in_ms=15, out_ms=25)
    save_wav(imi_faded, ch, sr, "ımı.wav")
    
    # mım = [m] + [ɯ] + [m]
    mim_samples = np.concatenate([hum_m, vowel_i, hum_m])
    mim_faded = apply_fades(mim_samples, ch, sr, in_ms=15, out_ms=25)
    save_wav(mim_faded, ch, sr, "mım.wav")

# 5. Synthesize 'ömö' and 'möm'
async def build_omo_and_mom():
    # Splicing 'ö' from 'ömür' with nasal 'm'
    s_omur, ch, sr = await synth_audio("ömür", rate="-4%", pitch="+4Hz")
    mono_o, e_o = get_envelope(s_omur, ch, sr)
    s_o = np.where(e_o > np.max(e_o)*0.04)[0][0]
    vowel_o = s_omur[s_o * ch : (s_o + int(sr * 0.16)) * ch] # 160ms pure [ø]
    
    s_mmm, _, _ = await synth_audio("Mmm", rate="-5%", pitch="+2Hz")
    mono_m, e_m = get_envelope(s_mmm, ch, sr)
    s_m = np.where(e_m > np.max(e_m)*0.05)[0][0]
    hum_m = s_mmm[s_m * ch : (s_m + int(sr * 0.14)) * ch] # 140ms pure [m]
    
    # ömö = [ø] + [m] + [ø]
    vowel_o2 = apply_fades(vowel_o, ch, sr, in_ms=10, out_ms=20)
    omo_samples = np.concatenate([vowel_o, hum_m, vowel_o2])
    omo_faded = apply_fades(omo_samples, ch, sr, in_ms=15, out_ms=25)
    save_wav(omo_faded, ch, sr, "ömö.wav")
    
    # möm = [m] + [ø] + [m]
    mom_samples = np.concatenate([hum_m, vowel_o, hum_m])
    mom_faded = apply_fades(mom_samples, ch, sr, in_ms=15, out_ms=25)
    save_wav(mom_faded, ch, sr, "möm.wav")

# 6. Build pure m and game intro
async def build_pure_m_and_intro():
    samples, ch, sr = await synth_audio("Mmm", rate="-5%", pitch="+2Hz")
    mono, energy = get_envelope(samples, ch, sr)
    thresh = np.max(energy) * 0.05
    indices = np.where(energy > thresh)[0]
    start = indices[0]
    hum_len = int(sr * 0.60)
    hum = samples[start * ch : (start + hum_len) * ch]
    hum_faded = apply_fades(hum, ch, sr, in_ms=20, out_ms=40)
    save_wav(hum_faded, ch, sr, "m.wav")
    
    part1_samples, ch1, sr1 = await synth_audio("Hazır ol! İçinde ", rate="-2%", pitch="+6Hz")
    part2_samples, ch2, sr2 = await synth_audio(" sesi bulunan kelimeleri ye ve dev gibi büyü!", rate="-2%", pitch="+6Hz")
    
    mono1, e1 = get_envelope(part1_samples, ch1, sr1)
    s1 = np.where(e1 > np.max(e1)*0.03)[0]
    p1 = part1_samples[max(0, s1[0]-int(sr1*0.01))*ch1 : (s1[-1]+int(sr1*0.02))*ch1]
    
    mono2, e2 = get_envelope(part2_samples, ch2, sr2)
    s2 = np.where(e2 > np.max(e2)*0.03)[0]
    p2 = part2_samples[max(0, s2[0]-int(sr2*0.01))*ch2 : (s2[-1]+int(sr2*0.02))*ch2]
    
    gap = np.zeros(int(sr * 0.08) * ch, dtype=np.int16)
    game_intro = np.concatenate([p1, gap, hum_faded, gap, p2])
    save_wav(game_intro, ch, sr, "game_intro_m.wav")

async def main():
    print("=== 1. GENERATING PURE M AND GAME INTRO ===")
    await build_pure_m_and_intro()
    
    print("\n=== 2. GENERATING 8 CV SYLLABLES ===")
    cv_specs = [
        ("masal", "ma", 300),
        ("melek", "me", 300),  # Pure Turkish [e], NEVER English /miː/!
        ("mısır", "mı", 310),  # Authentic Turkish [ɯ]!
        ("misket", "mi", 290),
        ("mor", "mo", 290),
        ("möö", "mö", 300),    # Pure Turkish [mø]!
        ("mum", "mu", 290),
        ("müzik", "mü", 290),
    ]
    for w, s, d in cv_specs:
        await slice_initial(w, s, d)
        
    print("\n=== 3. GENERATING 8 VC SYLLABLES (NO TRAILING 'e') ===")
    vc_specs = [
        ("amca", "am", 280),   # Pure [am], NEVER "A.M." / "Amy" / "a-me"!
        ("emzik", "em", 280),  # Pure [em]!
        ("imza", "im", 280),   # Pure [im], NEVER "i-me"!
        ("omlet", "om", 280),  # Pure [om]!
        ("ömrü", "öm", 280),   # Pure [øm]!
        ("umut", "um", 280),   # Pure [um]!
        ("ümmet", "üm", 280),  # Pure [ym]!
    ]
    for w, s, d in vc_specs:
        await slice_initial(w, s, d)
    # Special: ım
    await build_im_and_imi()
        
    print("\n=== 4. GENERATING 8 VCV SYLLABLES ===")
    vcv_specs = [
        ("ama", "ama", 450),
        ("emek", "eme", 450),
        ("kimi", "imi", 450),
        ("omuz", "omo", 450),
        ("umut", "umu", 450),
        ("ümit", "ümü", 450),
    ]
    for w, s, d in vcv_specs:
        await slice_vcv(w, s, d)
    # Special: ömö (already has ımı from build_im_and_imi)
    await build_omo_and_mom()
        
    print("\n=== 5. GENERATING 8 CVC SYLLABLES ===")
    # mam from tamam
    await slice_second_syllable("tamam", "mam", 360)
    # mem from memur
    await slice_initial("memur", "mem", 360)
    # mim from mim
    await slice_initial("mim", "mim", 350)
    # mom from limon
    await slice_second_syllable("limon", "mom", 360)
    # mum from mum
    await slice_initial("mum", "mum", 350)
    # müm from mümessil
    await slice_initial("mümessil", "müm", 350)
    # (mım and möm are already built by helper functions)
    
    print("\nALL 32 SYLLABLES AND INTROS FOR M GENERATED SUCCESSFULLY!")

if __name__ == '__main__':
    asyncio.run(main())
