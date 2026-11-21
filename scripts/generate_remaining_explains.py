import asyncio
import os
import edge_tts

anatomy_explanations = {
    "s": "İnce ıslık oyunu! 1. Adım: Gülümse ve dişlerini birbirine yaklaştır. 2. Adım: Dilini alt dişlerinin arkasında düz tut. 3. Adım: Dişlerinin arasından ince ve serin bir rüzgar gibi üfle: Ssssss!",
    "z": "Sevimli arı oyunu! 1. Adım: Dişlerini birbirine yaklaştır. 2. Adım: Elini boğazına koy ve titreşimi hisset. 3. Adım: Dişlerinin arasından arı gibi vızıldayarak üfle: Zzzzzzz!",
    "ş": "Rüzgar ve fısıltı oyunu! 1. Adım: Dudaklarını öne doğru yuvarla ve hafifçe uzat. 2. Adım: Dilinin yanlarını kaldırarak üst dişlerine yasla. 3. Adım: Dişlerinin arasından kuvvetli bir rüzgar gibi üfle: Şşşşş!",
    "j": "Titreşen araba motoru oyunu! 1. Adım: Dudaklarını öne doğru yuvarla ve hafifçe uzat. 2. Adım: Dilinin yanlarını kaldırıp üst dişlerine yasla, elini boğazına koy ve titreşimi hisset. 3. Adım: Dişlerinin arasından ses tellerini titreterek araba motoru gibi güçlüce vızılda: Jjjjjjj!",
    "h": "H sesi oyunu! 1. Adım: Ağzını rahatça aç. Dilin ve dudakların tamamen serbest kalsın. 2. Adım: Soğuk havada ellerini ısıtmak için sıcak bir nefes verir gibi boğazından üfle: Ha! Ha! Ha!",
    "p": "1. Adım: Dudaklarını birbirine sıkıca bastır. Dilin ağzının tabanında tamamen rahat ve düz dursun, hiçbir yere değmesin. 2. Adım: Havayı dudaklarının arkasında topla ve biriktir. 3. Adım: Dudaklarını birden açarak havayı puf diye patlat: pı!",
}

pure_dir = 'backend/pure_syllables'

async def generate():
    for p, text in anatomy_explanations.items():
        out_path = os.path.join(pure_dir, f"{p}_explain.mp3")
        print(f"Generating {p}_explain.mp3...")
        comm = edge_tts.Communicate(text, voice="tr-TR-EmelNeural", rate="+6%", pitch="+6Hz")
        data = b""
        async for chunk in comm.stream():
            if chunk["type"] == "audio":
                data += chunk["data"]
        with open(out_path, "wb") as f:
            f.write(data)
        print(f"Done {p}_explain.mp3 ({len(data)} bytes)")

asyncio.run(generate())
