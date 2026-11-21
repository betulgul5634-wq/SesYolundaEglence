import urllib.request
import urllib.parse

sounds = ['/p/', '/b/', '/t/', '/d/', '/k/', '/g/', '/f/', '/v/', '/s/', '/z/', '/ş/']

for s in sounds:
    p = s.replace('/', '')
    url = f"http://127.0.0.1:8000/api/tts?text={urllib.parse.quote(s)}&phoneme={p}&mode=phoneme&v=54"
    try:
        req = urllib.request.urlopen(url)
        data = req.read()
        print(f"text='{s}', phoneme='{p}': HTTP {req.status}, size={len(data)}, type={req.headers.get('content-type')}")
    except Exception as e:
        print(f"text='{s}', phoneme='{p}': ERROR {e}")
