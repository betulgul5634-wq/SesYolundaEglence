import urllib.request
import wave
import io

def check_url(url, label):
    req = urllib.request.urlopen(url)
    data = req.read()
    ct = req.headers.get("Content-Type")
    print(f"{label:<20} -> status: {req.status}, size: {len(data)} bytes, type: {ct}")
    if "audio" in ct:
        try:
            with wave.open(io.BytesIO(data), "rb") as wf:
                dur = wf.getnframes() / wf.getframerate()
                print(f"   duration: {dur:.3f}s, frames: {wf.getnframes()}")
        except Exception as e:
            print(f"   (format info: {e})")

check_url("http://127.0.0.1:8000/api/tts?text=P&phoneme=P&mode=phoneme", "P phoneme")
check_url("http://127.0.0.1:8000/api/tts?text=pe&phoneme=p&mode=natural", "Syllable pe")
check_url("http://127.0.0.1:8000/api/tts?text=pi&phoneme=p&mode=natural", "Syllable pi")
check_url("http://127.0.0.1:8000/api/tts?text=%C4%B1p&phoneme=p&mode=natural", "Syllable ıp")
check_url("http://127.0.0.1:8000/api/tts?text=ip&phoneme=p&mode=natural", "Syllable ip")
check_url("http://127.0.0.1:8080/flutter_bootstrap.js", "Web Bootstrap")
