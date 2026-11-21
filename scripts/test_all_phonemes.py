import urllib.request
import urllib.parse

kAllSounds = [
    'P', 'B', 'T', 'D', 'K', 'G', 'F', 'V', 'S', 'Z',
    'Ş', 'J', 'H', 'Ç', 'C', 'M', 'N', 'L', 'R', 'Y'
]

for s in kAllSounds:
    url = f'http://127.0.0.1:8000/api/tts?text={urllib.parse.quote(s)}&phoneme={urllib.parse.quote(s)}&mode=phoneme&v=54'
    try:
        req = urllib.request.urlopen(url)
        content = req.read()
        print(f"[{s}] mode=phoneme: status={req.status}, size={len(content)}, ctype={req.headers.get('content-type')}")
    except Exception as e:
        print(f"[{s}] mode=phoneme: ERROR {e}")
