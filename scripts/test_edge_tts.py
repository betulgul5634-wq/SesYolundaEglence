import asyncio
import edge_tts

async def test_edge():
    text = "1. Adım: Dudaklarını birbirine sıkıca bastır. 2. Adım: Boğazına dokun ve dudaklarını açmadan hımm diye titreşimi hisset. 3. Adım: Dudaklarını birden açarak sesi patlat: B!"
    try:
        comm = edge_tts.Communicate(text, voice="tr-TR-EmelNeural")
        audio_data = b""
        async for chunk in comm.stream():
            if chunk["type"] == "audio":
                audio_data += chunk["data"]
        print(f"Edge-TTS SUCCESS! Received {len(audio_data)} bytes")
    except Exception as e:
        print(f"Edge-TTS FAILED: {type(e)}: {e}")

asyncio.run(test_edge())
