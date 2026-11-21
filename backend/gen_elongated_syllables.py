import asyncio, edge_tts, miniaudio, wave, io, os

async def synthesize(word):
    c = edge_tts.Communicate(text=word, voice='tr-TR-EmelNeural', rate='-14%')
    mp3 = b''
    async for chunk in c.stream():
        if chunk['type'] == 'audio':
            mp3 += chunk['data']
    return mp3

async def generate_elongated_syllables():
    # word, vowel_start_ms, vowel_end_ms, closure_end_ms, repeat_vowel
    sources = {
        # Reverse syllables: vowel first, then closure/burst of /p/
        'ap': ('apaçık', 240, 275, 360, 16),
        'op': ('optuk', 240, 275, 370, 16),
        'up': ('upuzun', 240, 275, 360, 16),
        'ıp': ('ıpıslak', 240, 275, 355, 16),
        # Forward syllables: burst of /p/ first, then vowel
        'pi': ('pide', 260, 310, 365, 14),
        'pı': ('pırasa', 260, 310, 365, 14),
    }

    os.makedirs('pure_syllables', exist_ok=True)
    for syl, (word, v_start_ms, v_end_ms, c_end_ms, repeats) in sources.items():
        mp3 = await synthesize(word)
        dec = miniaudio.mp3_read_s16(mp3)
        sample_rate = dec.sample_rate
        channels = dec.nchannels
        samples = dec.samples

        frame_size = 2 * channels  # 16-bit PCM = 2 bytes per sample
        total_frames = len(samples) // frame_size

        f_start = int((v_start_ms / 1000.0) * sample_rate)
        f_mid = int((v_end_ms / 1000.0) * sample_rate)
        f_end = int((c_end_ms / 1000.0) * sample_rate)

        # Slice the segments
        if syl in ['ap', 'op', 'up', 'ıp']:
            # [Silence 200ms -> v_start] + [vowel repeated] + [closure/plosion: v_end -> c_end]
            prefix = samples[int(0.20 * sample_rate) * frame_size : f_start * frame_size]
            vowel = samples[f_start * frame_size : f_mid * frame_size]
            suffix = samples[f_mid * frame_size : f_end * frame_size]
            extended = bytearray(prefix)
            for _ in range(repeats):
                extended.extend(vowel)
            extended.extend(suffix)
        else:
            # Forward syllables ('pi', 'pı'): [Burst of p: f_start -> f_mid] + [vowel repeated: f_mid -> f_end]
            prefix = samples[int(0.22 * sample_rate) * frame_size : f_mid * frame_size]
            vowel = samples[f_mid * frame_size : f_end * frame_size]
            extended = bytearray(prefix)
            for _ in range(repeats):
                extended.extend(vowel)

        out_wav = os.path.join('pure_syllables', f'{syl}.wav')
        with wave.open(out_wav, 'wb') as wf:
            wf.setnchannels(channels)
            wf.setsampwidth(2)
            wf.setframerate(sample_rate)
            wf.writeframes(extended)

        dur_ms = (len(extended) // frame_size) / sample_rate * 1000
        print(f'Generated elongated {out_wav}: duration={dur_ms:.0f}ms')

asyncio.run(generate_elongated_syllables())
