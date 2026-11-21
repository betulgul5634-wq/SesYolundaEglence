import asyncio, miniaudio, edge_tts, speech_recognition as sr
import io, wave

async def find_slice():
    c = edge_tts.Communicate("ıvır", "tr-TR-EmelNeural")
    chunks = []
    async for chunk in c.stream():
        if chunk['type'] == 'audio':
            chunks.append(chunk['data'])
    data = b''.join(chunks)
    decoded = miniaudio.decode(data)
    
    # 16-bit stereo: 4 bytes per frame (2 bytes per sample * 2 channels)
    rate = decoded.sample_rate
    bytes_per_sec = rate * 4
    
    raw = bytes(decoded.samples)
    total_len = len(raw)
    
    # Let's inspect amplitude to find start and cut point
    import struct
    samples_s16 = struct.unpack(f"{len(raw)//2}h", raw)
    
    # Left channel samples:
    left = [abs(samples_s16[i]) for i in range(0, len(samples_s16), 2)]
    
    # Find onset (> 500)
    onset_idx = 0
    for idx, amp in enumerate(left):
        if amp > 500:
            onset_idx = idx
            break
            
    print(f"Onset frame: {onset_idx} ({onset_idx / rate:.3f}s)")
    
    # Test cuts from onset + 0.25s, 0.30s, 0.35s, 0.40s, 0.45s, 0.50s
    r = sr.Recognizer()
    for cut_dur in [0.25, 0.30, 0.35, 0.40, 0.45, 0.50]:
        end_idx = onset_idx + int(cut_dur * rate)
        slice_samples = samples_s16[onset_idx * 2 : end_idx * 2]
        
        # Apply gentle 20ms fade out
        fade_frames = int(0.02 * rate)
        slice_list = list(slice_samples)
        for f in range(fade_frames):
            factor = (fade_frames - f) / fade_frames
            idx_s = len(slice_list) - 2 * (fade_frames - f)
            if idx_s >= 0 and idx_s + 1 < len(slice_list):
                slice_list[idx_s] = int(slice_list[idx_s] * factor)
                slice_list[idx_s + 1] = int(slice_list[idx_s + 1] * factor)
                
        out_raw = struct.pack(f"{len(slice_list)}h", *slice_list)
        
        wav_io = io.BytesIO()
        with wave.open(wav_io, 'wb') as wf:
            wf.setnchannels(2)
            wf.setsampwidth(2)
            wf.setframerate(rate)
            wf.writeframes(out_raw)
            
        with sr.AudioFile(io.BytesIO(wav_io.getvalue())) as source:
            audio = r.record(source)
        try:
            res = r.recognize_google(audio, language='tr-TR')
        except Exception as e:
            res = f"err: {e}"
            
        print(f"Cut dur {cut_dur:.2f}s -> {res}")

asyncio.run(find_slice())
