import urllib.request, urllib.parse

for text in ['iv', 'ıv', 'av', 'ev', 'ov', 'viv', 'vav']:
    url = f'http://localhost:8000/api/tts?text={urllib.parse.quote(text)}&phoneme=v&mode=syllable&v=12'
    req = urllib.request.Request(url)
    with urllib.request.urlopen(req) as resp:
        ctype = resp.headers.get("content-type")
        data_len = len(resp.read())
        print(f"{text:4s} -> Status: {resp.status}, Type: {ctype}, Len: {data_len}")
