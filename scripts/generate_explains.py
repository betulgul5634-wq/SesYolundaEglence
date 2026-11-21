import asyncio
import os
import edge_tts

anatomy_explanations = {
    "b": "1. Adım: Dudaklarını birbirine sıkıca bastır. 2. Adım: Boğazına dokun ve dudaklarını açmadan hımm diye titreşimi hisset. 3. Adım: Dudaklarını birden açarak sesi patlat: B!",
    "t": "Tıkır tıkır saat oyunu! 1. Adım: Gülümse ve dilini üst dişlerinin arkasındaki damağa sımsıkı yapıştır! 2. Adım: Nefesini sakla, sessizce bekle! 3. Adım: Dilini birden bırak ve saatin sesi gibi patlat: Tik tak! Tık! T!",
    "d": "Düt düt araba ve davul oyunu! 1. Adım: Gülümse ve dilinin ucunu üst dişlerinin arkasındaki damağa sımsıkı bastır! 2. Adım: Boğazına dokun ve araba motoru gibi sesini titreterek vızıldat: Hımm! 3. Adım: Dilini birden bırak ve araba kornası gibi patlat: Düt düt! Dan! D!",
    "k": "1. Adım: Ağzını rahatça aç. Dilinin ucunu alt ön dişlerinin arkasında, en aşağıda tut. Dil ucunu sakın yukarı kaldırma! 2. Adım: Dilinin arkasını yukarı kaldırıp yumuşak damağına sımsıkı bas! Havayı boğazında tut ve sessizce bekle! 3. Adım: Dilini birden aşağı bırak ve boğazındaki havayı neşeyle dışarı patlat: Kıkır kıkır! K! K! K!",
    "g": "1. Adım: Ağzını rahatça aç. Dilinin ucunu alt ön dişlerinin arkasında tutarken, dilinin arkasını yukarı kaldırıp damağına bastır! 2. Adım: Elini boğazına koy, havayı boğazında toplarken ses tellerini kuvvetlice titret: Hımm! 3. Adım: Dilini birden serbest bırak ve boğazından tok, güçlü bir ses patlat: G! G! G!",
    "f": "1. Adım: Üst tavşan dişlerini alt dudağının üstüne hafifçe koy. 2. Adım: Dişlerin arasından serin ve ince bir nefes üfle: Ffff!",
    "v": "1. Adım: Üst dişlerini alt dudağına hafifçe değdir. 2. Adım: Boğazındaki motoru çalıştırıp sesini titreterek kuvvetlice vızıldat: Vvvv!",
    "ç": "1. Adım: Dilinin ön kısmını üst damağa bas. 2. Adım: Çuf çuf tren gibi patlatarak sürtünmeli şekilde çıkar: Ç! Ç! Ç!",
    "c": "1. Adım: Dilini damağa yapıştır. 2. Adım: Cik cik neşeyle ses tellerinle birlikte patlat: C! C! C!",
    "m": "1. Adım: Dudaklarını birbirine kapat. 2. Adım: Sesi burnundan çıkararak lezzetli bir dondurma yer gibi mmm de: Mmm!",
    "n": "1. Adım: Dil ucunu üst diş arkasındaki damağa yapıştır. 2. Adım: Sesi burnundan neşeli bir zil gibi vererek söyle: Nnnn!",
    "l": "1. Adım: Dil ucunu üst diş arkasındaki damağa bas. 2. Adım: Havanın dilin kenarlarından şarkı gibi akmasına izin ver: Llll!",
    "r": "1. Adım: Ağzını hafifçe arala! Dilinin ucunu üst ön dişlerinin arkasındaki damağa yaklaştır. Dil ucun serbest kalsın! 2. Adım: Derin bir nefes al ve havayı dilinin ucuna doğru kuvvetlice üfle! 3. Adım: Yarış arabasının motoru gibi dil ucunu neşeyle titret: Rrrr! R! R!",
    "y": "1. Adım: Dilinin ortasını damağa yaklaştır. 2. Adım: Kaydıraktan kayar gibi yumuşakça havayı akıt: Yyyy!",
}

pure_dir = 'backend/pure_syllables'

async def generate_explain_audio(phoneme, text):
    out_path = os.path.join(pure_dir, f"{phoneme}_explain.mp3")
    if os.path.exists(out_path) and os.path.getsize(out_path) > 1000:
        print(f"Skipping {phoneme}_explain.mp3 (already exists, {os.path.getsize(out_path)} bytes)")
        return
    print(f"Generating {phoneme}_explain.mp3...")
    comm = edge_tts.Communicate(text, voice="tr-TR-EmelNeural", rate="+6%", pitch="+6Hz")
    data = b""
    async for chunk in comm.stream():
        if chunk["type"] == "audio":
            data += chunk["data"]
    with open(out_path, "wb") as f:
        f.write(data)
    print(f"Generated {phoneme}_explain.mp3: {len(data)} bytes")

async def main():
    for p, text in anatomy_explanations.items():
        try:
            await generate_explain_audio(p, text)
        except Exception as e:
            print(f"Failed {p}: {e}")

asyncio.run(main())
