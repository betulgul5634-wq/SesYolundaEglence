import asyncio
import os
import sys
import wave
import edge_tts
import miniaudio
import numpy as np

sys.stdout.reconfigure(encoding='utf-8')

PURE_DIR = os.path.join(os.path.dirname(__file__), "pure_syllables")
os.makedirs(PURE_DIR, exist_ok=True)

async def synthesize_word(text, pitch="+4Hz", rate="-8%", retries=4):
    for attempt in range(retries):
        try:
            comm = edge_tts.Communicate(text, "tr-TR-EmelNeural", pitch=pitch, rate=rate)
            mp3_data = b""
            async for chunk in comm.stream():
                if chunk["type"] == "audio":
                    mp3_data += chunk["data"]
            dec = miniaudio.decode(mp3_data)
            audio = np.frombuffer(dec.samples, dtype=np.int16)
            return audio, dec.sample_rate, dec.nchannels
        except Exception as e:
            if attempt < retries - 1:
                await asyncio.sleep(1.5)
            else:
                raise e

def apply_fades_stereo(audio, nchannels, fade_in_frames=220, fade_out_frames=440):
    audio = audio.astype(np.float32)
    fade_in_samples = min(fade_in_frames * nchannels, len(audio))
    fade_out_samples = min(fade_out_frames * nchannels, len(audio))
    
    if fade_in_samples > 0:
        fade_in_curve = np.repeat(np.linspace(0, 1, fade_in_frames), nchannels)
        audio[:len(fade_in_curve)] *= fade_in_curve
    if fade_out_samples > 0:
        fade_out_curve = np.repeat(np.linspace(1, 0, fade_out_frames), nchannels)
        audio[-len(fade_out_curve):] *= fade_out_curve
        
    max_val = np.max(np.abs(audio))
    if max_val > 0:
        audio = audio / max_val * 26000.0
    return audio.astype(np.int16)

def save_wav(filename, audio_data, sample_rate, nchannels):
    out_path = os.path.join(PURE_DIR, filename)
    with wave.open(out_path, "wb") as wf:
        wf.setnchannels(nchannels)
        wf.setsampwidth(2)
        wf.setframerate(sample_rate)
        wf.writeframes(audio_data.tobytes())
    dur = len(audio_data) / (sample_rate * nchannels)
    print(f"Saved {filename}: {dur:.2f}s", flush=True)

async def build_all_h_phrases_and_sentences():
    print("Building all 60 H phrases and sentences with validated prominent H phonetics and thick L...", flush=True)
    h_items = [
        # phrasesBeginning
        ("Ham havuç", "Ham, havuç."),
        ("Hızlı horoz", "Hızlı, horoz."),
        ("Hafif helva", "Hafif, hel-va."),
        ("Harika hayal", "Harika, hayal."),
        ("Haftalık haber", "Haftalık, haber."),
        ("Huzurlu hava", "Huzurlu, hava."),
        ("Havuzdaki havlu", "Havuzdaki, hav-lu."),
        ("Hassas hediye", "Hassas, hediye."),
        ("Huysuz horoz", "Huysuz, horoz."),
        ("Hatalı hareket", "Hatalı, hareket."),
        ("Hızlı hokkabaz", "Hızlı, hokkabaz."),
        ("Hastalık hastası", "Hastalık, hastası."),
        ("Hareketli Hülya", "Hareketli, Hülya."),
        ("Heyecanlı hikaye", "Heyecanlı, hikaye."),
        ("Hamarat hizmetçi", "Hamarat, hizmetçi."),
        
        # phrasesContaining
        ("Cahil cihan", "Cahil, cihan."),
        ("Pahalı nohut", "Pahalı, nohut."),
        ("Rahat sahne", "Rahat, sahne."),
        ("Sahte ehliyet", "Sahte, ehliyet."),
        ("İhtiyar muhtar", "İhtiyar, muhtar."),
        ("Sahici sihirbaz", "Sahici, sihirbaz."),
        ("Kahve bahane", "Kahve, bahane."),
        ("Şahane bahçe", "Şahane, bahçe."),
        ("Mahalle kahvesi", "Mahalle, kahvesi."),
        ("Sahanda şehriye", "Sahanda, şehriye."),
        ("Sahildeki ahtapot", "Sahildeki, ahtapot."),
        ("Kahraman Ahmet", "Kahraman, Ahmet."),
        ("Kahverengi anahtar", "Kahverengi, anahtar."),
        ("Baharatlı lahmacun", "Baharatlı, lahmacun."),
        ("Sehpadaki tahtakurusu", "Sehpadaki, tahtakurusu."),
        
        # sentencesBeginning
        ("Hakan horozu hatırladı.", "Hakan, horozu, hatırladı."),
        ("Handan Hanım hıçkırdı.", "Handan Hanım, hıçkırdı."),
        ("Herkesin hediyesi hazır.", "Herkesin hediyesi, hazır."),
        ("Helikopter hızla havalandı.", "Helikopter, hızla, havalandı."),
        ("Halit hayvanları hemen besledi.", "Halit, hayvanları hemen besledi."),
        ("Hastanedeki hemşire hatalıydı.", "Hastanedeki hemşire, hatalıydı."),
        ("Halam helvayı hemen hazırladı.", "Hallam, hel-vayı hemen hazırladı."),
        ("Hülya halam havuzda hastalandı.", "Hülya, hallam havuz-da hastalandı."),
        ("Halıdaki hediyelerin hangisi hafif?", "Halıdaki hediyelerin, hangisi hafif?"),
        ("Heyecanlı Halil hırkasını hırpaladı.", "Heyecanlı Halil, hırkasını hırpaladı."),
        ("Hande hayalindeki hikayeyi hatırladı.", "Hande, hayalindeki hikayeyi hatırladı."),
        ("Hamaktaki Hasan her şeyden habersizdi.", "Hamaktaki Hasan, her şeyden habersizdi."),
        ("Hakan harika hikayelerin hepsini dinledi.", "Hakan, harika hikayelerin hepsini dinledi."),
        ("Hizmetliler havasız hangarı hızla havalandırdılar.", "Hizmetliler, havasız hangarı hızla havalandırdılar."),
        ("Hekimler, hemşireler ve hastabakıcılar hastanedeydi.", "Hekimler, hemşireler ve hastabakıcılar hastanedeydi."),
        
        # sentencesContaining
        ("Nahit tenhada horluyordu.", "Nahit, tenhada horluyordu."),
        ("Pahalı mücevher sahteymiş.", "Pahalı mücevher, sahteymiş."),
        ("Sabiha'nın anahtarı siyahtı.", "Sabiha'nın anahtarı, siyahtı."),
        ("Baharatlı yahni muhteşemdi.", "Baharatlı yahni, muhteşemdi."),
        ("Bahçedeki kahvaltı harikaydı.", "Bahçedeki kahvaltı, harikaydı."),
        ("Baharda havalar hep ferahtır.", "Baharda havalar, hep ferahtır."),
        ("Kahve bahane sohbet şahane.", "Kahve bahane, sohbet şahane."),
        ("Sehpayı tahtakurusu mahvetmiş.", "Sehpayı tahtakurusu, mahvetmiş."),
        ("Saliha Taha'ya ehliyetini hatırlattı.", "Saliha, Taha'ya ehliyetini hatırlattı."),
        ("Bahçıvanın tohumları bahçedeydi.", "Bahçıvanın tohumları, bahçedeydi."),
        ("İhtiyar hokkabazın hikâyesi tuhaftı.", "İhtiyar hokkabazın hikâyesi, tuhaftı."),
        ("Sahandaki lahana Serhat'ın hakkıdır.", "Sahandaki lahana, Serhat'ın hakkıdır."),
        ("Sihirli ejderhanın hikâyesi heyecanlıydı.", "Sihirli ejderhanın hikâyesi, heyecanlıydı."),
        ("Sihirbazın kahkahası hepimizi rahatlattı.", "Sihirbazın kahkahası, hepimizi rahatlattı."),
        ("Ahmet yemekhanede kahvaltı hazırladı.", "Ahmet, yemekhanede kahvaltı hazırladı."),
    ]
    
    for orig_text, phonetic_text in h_items:
        clean_key = orig_text.replace("I", "ı").replace("İ", "i").lower().strip().rstrip(".").rstrip(",").rstrip("?").rstrip("!")
        audio, sr, nch = await synthesize_word(phonetic_text, pitch="+4Hz", rate="-8%")
        processed = apply_fades_stereo(audio, nch, int(0.01 * sr), int(0.04 * sr))
        save_wav(f"{clean_key}.wav", processed, sr, nch)

async def main():
    await build_all_h_phrases_and_sentences()
    print("=== All Fixed H Phrases and Sentences Built Successfully! ===", flush=True)

if __name__ == "__main__":
    asyncio.run(main())
