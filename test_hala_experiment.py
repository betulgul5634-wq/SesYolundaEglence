import asyncio, edge_tts, miniaudio, numpy as np, wave, sys
sys.stdout.reconfigure(encoding='utf-8')

async def test_hala(phonetic):
    comm = edge_tts.Communicate(phonetic, "tr-TR-EmelNeural", pitch="+4Hz", rate="-8%")
    buf = b""
    async for c in comm.stream():
        if c["type"] == "audio": buf += c["data"]
    dec = miniaudio.decode(buf)
    audio = np.frombuffer(dec.samples, dtype=np.int16)
    sr = dec.sample_rate
    ch = dec.nchannels
    mono = audio[0::ch] if ch > 1 else audio
    act = np.where(np.abs(mono) > 500)[0]
    seg = mono[act[0]:act[-1]] if len(act) > 0 else mono
    fft = np.abs(np.fft.rfft(seg))
    freqs = np.fft.rfftfreq(len(seg), 1/sr)
    low_band = np.sum(fft[(freqs >= 600) & (freqs <= 1400)])
    high_band = np.sum(fft[(freqs >= 1700) & (freqs <= 2400)])
    ratio = low_band / (high_band + 1e-6)
    safe = phonetic.replace(" ", "_").replace(".", "").replace(",", "").replace("-", "_")
    with wave.open(f"test_h_{safe}.wav", 'wb') as wf:
        wf.setnchannels(1); wf.setsampwidth(2); wf.setframerate(sr)
        wf.writeframes(seg.tobytes())
    print(f"'{phonetic:30s}' -> ratio: {ratio:5.2f}, dur: {len(seg)/sr:.2f}s")

async def main():
    trials = [
        "hala",
        "halam",
        "hâlâ",
        "hâla",
        "ha la",
        "ha-la",
        "hal la",
        "hal-la",
        "ha lam",
        "ha-lam",
        "hal lam",
        "hal-lam",
        "Hülya halam havuzda hastalandı.",
        "Hülya ha lam havuzda hastalandı.",
        "Hülya ha-lam havuzda hastalandı.",
        "Hülya, halam havuzda hastalandı.",
        "Hasibe Halam",
        "Hasibe ha lam",
        "Hasibe, halam",
        "afiyetle",
        "afiyetle.",
        "afiyetle yediler.",
        "afiyet le",
        "afiyet le.",
        "afiyet-le",
    ]
    for t in trials:
        await test_hala(t)

asyncio.run(main())
