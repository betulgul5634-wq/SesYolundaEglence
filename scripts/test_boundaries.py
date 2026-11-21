import asyncio
import edge_tts
import sys
sys.stdout.reconfigure(encoding='utf-8')

async def check_boundaries():
    c = edge_tts.Communicate("cımbız", voice="tr-TR-EmelNeural")
    async for chunk in c.stream():
        if chunk["type"] != "audio":
            print("Chunk:", chunk)

if __name__ == '__main__':
    asyncio.run(check_boundaries())
