import urllib.request
import urllib.parse

all_sounds = ['P', 'B', 'T', 'D', 'K', 'G', 'F', 'V', 'S', 'Z', 'Ş', 'J', 'H', 'Ç', 'C', 'M', 'N', 'L', 'R', 'Y']

print("=== TESTING ALL 20 PHONEMES ===")
for s in all_sounds:
    # 1. Phoneme mode with /s/
    url1 = f"http://127.0.0.1:8000/api/tts?text={urllib.parse.quote('/' + s.lower() + '/')}&phoneme={urllib.parse.quote(s)}&mode=phoneme&v=55"
    # 2. Phoneme mode with bare letter
    url2 = f"http://127.0.0.1:8000/api/tts?text={urllib.parse.quote(s)}&phoneme={urllib.parse.quote(s)}&mode=phoneme&v=55"
    # 3. Explain mode (Mouth anatomy)
    url3 = f"http://127.0.0.1:8000/api/tts?text={urllib.parse.quote(s)}&phoneme={urllib.parse.quote(s)}&mode=explain&v=55"
    
    try:
        r1 = urllib.request.urlopen(url1)
        r2 = urllib.request.urlopen(url2)
        r3 = urllib.request.urlopen(url3)
        print(f"[{s}] /s/: {r1.status} ({r1.headers.get('content-type')}, {len(r1.read())}b) | bare: {r2.status} ({r2.headers.get('content-type')}, {len(r2.read())}b) | explain: {r3.status} ({r3.headers.get('content-type')}, {len(r3.read())}b)")
    except Exception as e:
        print(f"[{s}] ERROR: {e}")
