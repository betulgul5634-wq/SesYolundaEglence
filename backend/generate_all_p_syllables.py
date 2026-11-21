import asyncio
import os
import sys
import wave
import edge_tts
import miniaudio
import numpy as np

sys.stdout.reconfigure(encoding='utf-8')

PURE_DIR = os.path.join(os.path.dirname(__file__), "pure_syllables")
os.makedirs(PURE_DIR, exist_ok=True)

# Delete existing glitchy legacy loops if any
legacy_glitch_files = ['ap.wav', 'op.wav', 'pi.wav', 'pı.wav', 'up.wav', 'ıp.wav']
for f in legacy_glitch_files:
    p = os.path.join(PURE_DIR, f)
    if os.path.exists(p):
        try:
            os.remove(p)
            print(f"Removed legacy glitch file: {f}")
        except Exception as e:
            print(f"Could not remove {f}: {e}")

# The 32 clean P syllables
P_SYLLABLES = {
    'pa': 'Paa.',
    'pe': 'Pee.',
    'pı': 'Pıı.',
    'pi': 'Pii.',
    'po': 'Poo.',
    'pö': 'Pöö.',
    'pu': 'Puu.',
    'pü': 'Püü.',
    'ap': 'Aap.',
    'ep': 'Eep.',
    'ıp': 'Iıp.',
    'ip': 'İip.',
    'op': 'Oop.',
    'öp': 'Ööp.',
    'up': 'Uup.',
    'üp': 'Üüp.',
    'apa': 'Apa.',
    'epe': 'Epe.',
    'ıpı': 'Ipı.',
    'ipi': 'İpi.',
    'opo': 'Opo.',
    'öpö': 'Öpö.',
    'upu': 'Upu.',
    'üpü': 'Üpü.',
    'pap': 'Pap.',
    'pep': 'Pep.',
    'pıp': 'Pıp.',
    'pip': 'Pip.',
    'pop': 'Pop.',
    'pöp': 'Pöp.',
    'pup': 'Pup.',
    'püp': 'Püp.'
}

async def synthesize_syllable(text, pitch="+3Hz", rate="-6%", retries=3):
    for attempt in range(retries):
        try:
            comm = edge_tts.Communicate(text, "tr-TR-EmelNeural", pitch=pitch, rate=rate)
            mp3_data = b""
            async for chunk in comm.stream():
                if chunk["type"] == "audio":
                    mp3_data += chunk["data"]
            dec = miniaudio.decode(mp3_data)
            audio = np.frombuffer(dec.samples, dtype=np.int16)
            return audio, dec.sample_rate, dec.nchannels
        except Exception as e:
            if attempt < retries - 1:
                await asyncio.sleep(1.0)
            else:
                raise e

def trim_silence_and_fade(audio, nchannels, sample_rate, threshold=400):
    audio_f = audio.astype(np.float32)
    # Stereo interleaved: reshape to frames
    frames = audio_f.reshape(-1, nchannels) if nchannels > 1 else audio_f.reshape(-1, 1)
    magnitudes = np.max(np.abs(frames), axis=1)
    
    # Find start and end where sound exceeds threshold
    active_indices = np.where(magnitudes > threshold)[0]
    if len(active_indices) > 0:
        start_frame = max(0, active_indices[0] - int(sample_rate * 0.04)) # 40ms lead-in
        end_frame = min(len(frames), active_indices[-1] + int(sample_rate * 0.08)) # 80ms tail
        frames = frames[start_frame:end_frame]
    
    trimmed = frames.flatten()
    
    # 20ms fade-in, 30ms fade-out
    fade_in_len = min(int(sample_rate * 0.02) * nchannels, len(trimmed))
    fade_out_len = min(int(sample_rate * 0.03) * nchannels, len(trimmed))
    
    if fade_in_len > 0:
        in_curve = np.repeat(np.linspace(0, 1, fade_in_len // nchannels), nchannels)
        trimmed[:len(in_curve)] *= in_curve
    if fade_out_len > 0:
        out_curve = np.repeat(np.linspace(1, 0, fade_out_len // nchannels), nchannels)
        trimmed[-len(out_curve):] *= out_curve
        
    # Normalize
    peak = np.max(np.abs(trimmed))
    if peak > 0:
        trimmed = (trimmed / peak) * 27000.0
        
    return trimmed.astype(np.int16)

def save_wav(filename, audio_data, sample_rate, nchannels):
    out_path = os.path.join(PURE_DIR, filename)
    with wave.open(out_path, "wb") as wf:
        wf.setnchannels(nchannels)
        wf.setsampwidth(2)
        wf.setframerate(sample_rate)
        wf.writeframes(audio_data.tobytes())
    dur = len(audio_data) / (sample_rate * nchannels)
    print(f"Generated clean {filename}: {dur:.2f}s", flush=True)

async def main():
    print("Synthesizing all 32 clean, authentic, therapist-quality P syllables...", flush=True)
    for syl, prompt in P_SYLLABLES.items():
        try:
            audio, sr, nc = await synthesize_syllable(prompt)
            clean_audio = trim_silence_and_fade(audio, nc, sr)
            save_wav(f"{syl}.wav", clean_audio, sr, nc)
        except Exception as err:
            print(f"Error on {syl}: {err}")
    print("ALL 32 P SYLLABLES COMPLETED SUCCESSFULLY!", flush=True)

if __name__ == "__main__":
    asyncio.run(main())
