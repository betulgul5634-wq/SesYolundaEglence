import urllib.request
import time

url = "http://127.0.0.1:8000/api/tts?text=B&phoneme=B&mode=explain&v=54"
print(f"Requesting {url}...")
t0 = time.time()
try:
    req = urllib.request.urlopen(url, timeout=30)
    data = req.read()
    t1 = time.time()
    print(f"SUCCESS in {t1-t0:.2f}s! Status: {req.status}, Size: {len(data)}, Content-Type: {req.headers.get('content-type')}")
except Exception as e:
    t1 = time.time()
    print(f"FAILED in {t1-t0:.2f}s: {e}")
