import asyncio
import edge_tts
import miniaudio
import numpy as np
import io, wave, os, sys
sys.stdout.reconfigure(encoding='utf-8')

# Audio processing utilities
def synth_to_mono(text, rate="-4%", pitch="+4Hz"):
    comm = edge_tts.Communicate(text, voice="tr-TR-EmelNeural", rate=rate, pitch=pitch)
    return comm

async def get_audio_data(text, rate="-4%", pitch="+4Hz"):
    comm = synth_to_mono(text, rate=rate, pitch=pitch)
    data = b""
    async for c in comm.stream():
        if c["type"] == "audio":
            data += c["data"]
    decoded = miniaudio.decode(data)
    samples = np.frombuffer(decoded.samples, dtype=np.int16).copy()
    ch = decoded.nchannels
    sr = decoded.sample_rate
    return samples, ch, sr

def get_envelope(samples, ch, sr, win_ms=10):
    if ch == 2:
        mono = samples.reshape(-1, 2).mean(axis=1)
    else:
        mono = samples
    abs_mono = np.abs(mono)
    window = int(sr * (win_ms / 1000.0))
    energy = np.convolve(abs_mono, np.ones(window)/window, mode='same')
    return mono, energy

def save_wav_stereo44k(samples, ch, sr, out_path):
    # Resample or keep standard
    # If 24000Hz, we can save 24000Hz or 44100Hz
    with wave.open(out_path, 'wb') as wf:
        wf.setnchannels(ch)
        wf.setsampwidth(2)
        wf.setframerate(sr)
        wf.writeframes(samples.tobytes())

print("Base utilities loaded.")
