import wave

with wave.open("backend/pure_syllables/p.wav", "rb") as wf:
    print("Channels:", wf.getnchannels())
    print("Sample width:", wf.getsampwidth())
    print("Frame rate:", wf.getframerate())
    print("Frames:", wf.getnframes())
    duration = wf.getnframes() / wf.getframerate()
    print("Duration:", duration, "seconds")

try:
    from faster_whisper import WhisperModel
    model = WhisperModel("base", device="cpu", compute_type="int8")
    segments, info = model.transcribe("backend/pure_syllables/p.wav", language="tr")
    text = " ".join([s.text for s in segments])
    print("Transcription of p.wav:", text)
except Exception as e:
    print("Whisper error:", e)
