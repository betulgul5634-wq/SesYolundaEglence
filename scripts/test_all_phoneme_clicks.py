import urllib.request
import urllib.parse
import io
import wave

consonants = ['p', 'b', 't', 'd', 'k', 'g', 'f', 'v', 's', 'z', 'ş', 'j', 'h', 'ç', 'c', 'm', 'n', 'l', 'r', 'y']

print(f"{'Phoneme':<10} {'Status':<10} {'Size':<10} {'Duration/Info'}")
print("-" * 50)

for c in consonants:
    url = f"http://127.0.0.1:8000/api/tts?text={urllib.parse.quote(c)}&phoneme={urllib.parse.quote(c)}&mode=phoneme"
    try:
        res = urllib.request.urlopen(url)
        data = res.read()
        dur_str = ""
        try:
            with wave.open(io.BytesIO(data), 'rb') as wf:
                dur = wf.getnframes() / wf.getframerate()
                dur_str = f"WAV {dur:.2f}s"
        except Exception:
            dur_str = f"MP3 {len(data)} bytes"
        print(f"/{c}/:       {res.status:<10} {len(data):<10} {dur_str}")
    except Exception as e:
        print(f"/{c}/:       ERROR: {e}")
