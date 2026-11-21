import urllib.request
import urllib.parse
import json

base = "http://127.0.0.1:8000"

# 1. Root
res = urllib.request.urlopen(f"{base}/")
print("1. Root GET /:", res.status, res.read().decode('utf-8')[:50])

# 2. TTS
url = f"{base}/api/tts?text=pa&phoneme=p&mode=natural"
res = urllib.request.urlopen(url)
print("2. TTS GET /api/tts:", res.status, "Bytes:", len(res.read()))

# 3. Evaluate Audio with Form Data
boundary = "----WebKitFormBoundary7MA4YWxkTrZu0gW"
body = (
    f"--{boundary}\r\n"
    f'Content-Disposition: form-data; name="target_text"\r\n\r\n'
    f"Papatya\r\n"
    f"--{boundary}\r\n"
    f'Content-Disposition: form-data; name="target_phoneme"\r\n\r\n'
    f"p\r\n"
    f"--{boundary}\r\n"
    f'Content-Disposition: form-data; name="spoken_text"\r\n\r\n'
    f"Papatya\r\n"
    f"--{boundary}--\r\n"
).encode('utf-8')

req = urllib.request.Request(
    f"{base}/api/evaluate-audio",
    data=body,
    headers={"Content-Type": f"multipart/form-data; boundary={boundary}"}
)
res = urllib.request.urlopen(req)
print("3. Evaluate Audio POST:", res.status, res.read().decode('utf-8')[:80])

# 4. Evaluate Story with Form Data
story_body = (
    f"--{boundary}\r\n"
    f'Content-Disposition: form-data; name="story_text"\r\n\r\n'
    f"Pazar sabahı kahvaltı yaptık.\r\n"
    f"--{boundary}\r\n"
    f'Content-Disposition: form-data; name="target_phoneme"\r\n\r\n'
    f"p\r\n"
    f"--{boundary}\r\n"
    f'Content-Disposition: form-data; name="spoken_text"\r\n\r\n'
    f"Pazar sabahı kahvaltı yaptık.\r\n"
    f"--{boundary}--\r\n"
).encode('utf-8')

req2 = urllib.request.Request(
    f"{base}/api/evaluate-story",
    data=story_body,
    headers={"Content-Type": f"multipart/form-data; boundary={boundary}"}
)
res2 = urllib.request.urlopen(req2)
print("4. Evaluate Story POST:", res2.status, res2.read().decode('utf-8')[:80])
