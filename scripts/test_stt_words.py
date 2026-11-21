import urllib.request, urllib.parse, speech_recognition as sr, io, miniaudio, wave

r = sr.Recognizer()
test_words = [
    'papatya', 'pasta', 'para', 'top', 'kapı', 'köpek',
    'balık', 'bebek', 'bavul', 'tabak',
    'tavşan', 'timsah', 'saat', 'sepet',
    'dünya', 'kedi', 'kalem', 'kitap',
    'gözlük', 'güneş', 'gitar', 'karga',
    'fare', 'fincan', 'vapur', 'vişne'
]

print(f"Testing {len(test_words)} words decoded through miniaudio and Google STT...")
recognized = 0
for w in test_words:
    params = urllib.parse.urlencode({'text': w, 'phoneme': w[0].upper()})
    url = f"http://127.0.0.1:8000/api/tts?{params}"
    try:
        req = urllib.request.Request(url)
        with urllib.request.urlopen(req, timeout=5) as resp:
            mp3_bytes = resp.read()
            
        dec = miniaudio.decode(mp3_bytes)
        wav_buf = io.BytesIO()
        with wave.open(wav_buf, 'wb') as wf:
            wf.setnchannels(dec.nchannels)
            wf.setsampwidth(2)
            wf.setframerate(dec.sample_rate)
            wf.writeframes(dec.samples)
        wav_buf.seek(0)
        
        with sr.AudioFile(wav_buf) as source:
            audio = r.record(source)
        res = r.recognize_google(audio, language="tr-TR")
        match = "MATCH" if res.lower() == w.lower() else f"CLOSE ({res})"
        print(f"Word '{w}' -> STT: '{res}' [{match}]")
        if res.lower() == w.lower():
            recognized += 1
    except Exception as e:
        print(f"Word '{w}' -> Error: {e}")

print(f"Words exact recognition rate: {recognized}/{len(test_words)} ({recognized/len(test_words)*100:.1f}%)")
