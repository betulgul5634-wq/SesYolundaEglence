import os
import wave
import urllib.request
import urllib.parse
import io

sounds = ['p', 'b', 't', 'd', 'k', 'g', 'f', 'v', 's', 'z', 'ş', 'j', 'h', 'ç', 'c', 'm', 'n', 'l', 'r', 'y']

print(f"{'Sound':<8} {'pure_dir wav':<18} {'Endpoint Status':<18} {'Audio Dur':<12} {'Sample Preview / Info'}")
print("-" * 75)

for s in sounds:
    pure_path = f"backend/pure_syllables/{s}.wav"
    pure_exists = os.path.exists(pure_path)
    if pure_exists:
        try:
            with wave.open(pure_path, 'rb') as wf:
                pure_dur = wf.getnframes() / wf.getframerate()
                pure_info = f"EXISTS ({pure_dur:.2f}s)"
        except Exception:
            pure_info = "EXISTS (non-wav)"
    else:
        pure_info = "MISSING"
        
    # Test /api/tts?text=X&phoneme=X&mode=phoneme
    encoded = urllib.parse.quote(s.upper())
    url = f"http://127.0.0.1:8000/api/tts?text={encoded}&phoneme={s}&mode=phoneme"
    try:
        req = urllib.request.urlopen(url, timeout=4)
        data = req.read()
        status_info = f"HTTP {req.status} ({len(data)}B)"
        ct = req.headers.get("Content-Type", "")
        if "audio/wav" in ct:
            with wave.open(io.BytesIO(data), 'rb') as wf:
                dur = wf.getnframes() / wf.getframerate()
                dur_str = f"{dur:.2f}s"
        else:
            dur_str = f"mp3 ({len(data)}B)"
    except Exception as e:
        status_info = f"ERR: {e}"
        dur_str = "-"
        
    print(f"/{s}/     {pure_info:<18} {status_info:<18} {dur_str:<12}")
