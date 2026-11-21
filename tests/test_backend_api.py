import unittest
import urllib.request
import urllib.parse
import json
import wave
import os
import numpy as np

BASE_URL = "http://127.0.0.1:8000"

class TestBackendAPI(unittest.TestCase):
    def test_01_root_health_check(self):
        """1. Backend ana servis sağlık kontrolü"""
        req = urllib.request.Request(f"{BASE_URL}/")
        with urllib.request.urlopen(req, timeout=5) as resp:
            self.assertEqual(resp.status, 200)
            data = json.loads(resp.read().decode())
            self.assertEqual(data.get("status"), "active")
            self.assertIn("Ses Yolunda Eğlence", data.get("service", ""))

    def test_02_phoneme_tts_endpoint(self):
        """2. İzole fonem WAV ses üretimi ve Content-Type doğrulaması"""
        params = urllib.parse.urlencode({"text": "P", "phoneme": "P", "mode": "phoneme"})
        url = f"{BASE_URL}/api/tts?{params}"
        req = urllib.request.Request(url)
        with urllib.request.urlopen(req, timeout=5) as resp:
            self.assertEqual(resp.status, 200)
            self.assertEqual(resp.headers.get("Content-Type"), "audio/wav")
            audio_bytes = resp.read()
            self.assertGreater(len(audio_bytes), 5000, "WAV dosyası boş olmamalıdır")

    def test_03_evaluate_audio_correct(self):
        """3. Doğru telaffuz değerlendirme testi (100 Tam Puan & Eşleşme)"""
        url = f"{BASE_URL}/api/evaluate-audio"
        boundary = "----WebKitFormBoundary7MA4YWxkTrZu0gW"
        body = (
            f"--{boundary}\r\n"
            f'Content-Disposition: form-data; name="target_text"\r\n\r\n'
            f"papatya\r\n"
            f"--{boundary}\r\n"
            f'Content-Disposition: form-data; name="target_phoneme"\r\n\r\n'
            f"P\r\n"
            f"--{boundary}\r\n"
            f'Content-Disposition: form-data; name="spoken_text"\r\n\r\n'
            f"papatya\r\n"
            f"--{boundary}--\r\n"
        ).encode("utf-8")

        req = urllib.request.Request(
            url,
            data=body,
            headers={"Content-Type": f"multipart/form-data; boundary={boundary}"},
            method="POST"
        )
        with urllib.request.urlopen(req, timeout=5) as resp:
            self.assertEqual(resp.status, 200)
            result = json.loads(resp.read().decode())
            self.assertTrue(result.get("is_correct"))
            self.assertEqual(result.get("accuracy_score"), 100)
            self.assertGreaterEqual(result.get("stars_earned", 0), 3)

    def test_04_evaluate_audio_substitution_error(self):
        """4. Hatalı telaffuz (Yerine Koyma /p/ -> /b/) analiz testi"""
        url = f"{BASE_URL}/api/evaluate-audio"
        boundary = "----WebKitFormBoundary7MA4YWxkTrZu0gW"
        body = (
            f"--{boundary}\r\n"
            f'Content-Disposition: form-data; name="target_text"\r\n\r\n'
            f"papatya\r\n"
            f"--{boundary}\r\n"
            f'Content-Disposition: form-data; name="target_phoneme"\r\n\r\n'
            f"P\r\n"
            f"--{boundary}\r\n"
            f'Content-Disposition: form-data; name="spoken_text"\r\n\r\n'
            f"babatya\r\n"
            f"--{boundary}--\r\n"
        ).encode("utf-8")

        req = urllib.request.Request(
            url,
            data=body,
            headers={"Content-Type": f"multipart/form-data; boundary={boundary}"},
            method="POST"
        )
        with urllib.request.urlopen(req, timeout=5) as resp:
            self.assertEqual(resp.status, 200)
            result = json.loads(resp.read().decode())
            self.assertFalse(result.get("is_correct"))
            self.assertTrue(
                "Ötümlülük Değişimi" in result.get("error_type", "") or "Yerine Koyma" in result.get("error_type", ""),
                f"Beklenen hata türü bulunamadı: {result.get('error_type')}"
            )

    def test_05_syllables_cache_integrity(self):
        """5. Pure syllables hece dosyalarının bozulmamış ve standartta olduğunu doğrulama"""
        pure_dir = "backend/pure_syllables"
        test_samples = ["pa", "ba", "ta", "ka", "sa", "ma", "uz", "mam", "lü", "ol"]
        for s in test_samples:
            path = os.path.join(pure_dir, f"{s}.wav")
            self.assertTrue(os.path.exists(path), f"{s}.wav bulunamadı")
            with wave.open(path, "rb") as wf:
                dur = wf.getnframes() / float(wf.getframerate())
                raw = wf.readframes(wf.getnframes())
                audio = np.frombuffer(raw, dtype=np.int16)
                peak = np.max(np.abs(audio))
                self.assertGreater(dur, 0.20, f"{s}.wav çok kısa ({dur:.3f}s)")
                self.assertGreater(peak, 10000, f"{s}.wav çok sessiz (peak: {peak})")

if __name__ == "__main__":
    unittest.main()
