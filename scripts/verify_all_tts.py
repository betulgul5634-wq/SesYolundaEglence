import urllib.request
import urllib.parse

phonemes = ['P', 'B', 'T', 'D', 'K', 'G', 'F', 'V', 'S', 'Z', 'Ş', 'J', 'H', 'Ç', 'C', 'M', 'N', 'L', 'R', 'Y']
failed = []

for p in phonemes:
    p_lower = p.lower()
    if p == 'I': p_lower = 'ı'
    if p == 'İ': p_lower = 'i'
    
    # 1. Test phoneme mode: text="/p/", phoneme="P"
    text_val = f"/{p_lower}/"
    url_p = f"http://127.0.0.1:8000/api/tts?text={urllib.parse.quote(text_val)}&phoneme={urllib.parse.quote(p)}&mode=phoneme"
    try:
        with urllib.request.urlopen(url_p, timeout=5) as resp:
            data = resp.read()
            if resp.status != 200 or len(data) < 100:
                failed.append((p, 'phoneme', resp.status, len(data)))
    except Exception as e:
        failed.append((p, 'phoneme', str(e)))

    # 2. Test explain mode
    url_e = f"http://127.0.0.1:8000/api/tts?text=test&phoneme={urllib.parse.quote(p)}&mode=explain"
    try:
        with urllib.request.urlopen(url_e, timeout=5) as resp:
            data = resp.read()
            if resp.status != 200 or len(data) < 100:
                failed.append((p, 'explain', resp.status, len(data)))
    except Exception as e:
        failed.append((p, 'explain', str(e)))

print(f"Total tested: {len(phonemes)*2}, Failed: {len(failed)}")
if failed:
    for f in failed:
        print("FAIL:", f)
else:
    print("SUCCESS: All 20 phonemes successfully return audio in both phoneme and explain modes!")
