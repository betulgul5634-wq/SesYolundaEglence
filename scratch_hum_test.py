import asyncio
import edge_tts

async def generate_variants():
    tests = [
        ("mmm", "Boğazına dokun ve mmm diye titreşimi hisset."),
        ("hımm", "Boğazına dokun ve hımm diye titreşimi hisset."),
        ("ımm", "Boğazına dokun ve ımm diye titreşimi hisset."),
        ("m", "Boğazına dokun ve m diye titreşimi hisset."),
    ]
    for tag, t in tests:
        c = edge_tts.Communicate(t, "tr-TR-EmelNeural", rate="-2%")
        await c.save(f"test_{tag}.mp3")
        print(f"Saved test_{tag}.mp3")

if __name__ == "__main__":
    asyncio.run(generate_variants())
