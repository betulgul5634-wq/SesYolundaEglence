import asyncio
import edge_tts

async def test_ssml():
    # Test SSML phoneme in Edge-TTS
    # Edge-TTS communicates via WSS with SSML support!
    # Let's see if we can use <phoneme alphabet="ipa" ph="mː">mmm</phoneme> or similar
    ssml = """<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" xml:lang="tr-TR">
        <voice name="tr-TR-EmelNeural">
            Boğazına dokun ve <phoneme alphabet="ipa" ph="m">m</phoneme> diye titreşimi hisset.
        </voice>
    </speak>"""
    c = edge_tts.Communicate(ssml, "tr-TR-EmelNeural")
    await c.save("test_ssml_m.mp3")
    print("SSML test saved.")

if __name__ == "__main__":
    asyncio.run(test_ssml())
