import asyncio
import edge_tts

async def test():
    text = "Pı! Pı! Pı! Puf! Pı! Pı!"
    communicate = edge_tts.Communicate(text, "tr-TR-EmelNeural", rate="+15%", pitch="+5Hz")
    await communicate.save("test_p_isolated.mp3")
    print("Saved test_p_isolated.mp3")

asyncio.run(test())
