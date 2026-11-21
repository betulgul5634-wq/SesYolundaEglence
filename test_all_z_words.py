import asyncio
import edge_tts
import re
import urllib.parse
import urllib.request

with open('mobile/lib/data/sound_groups_data.dart', 'r', encoding='utf-8') as f:
    text = f.read()

m = re.search(r"id:\s*['\"]sound_z['\"](.*?)(?=SoundStage|\Z)", text, re.DOTALL)
z_block = m.group(1)

def extract_list(name, block):
    lm = re.search(rf"{name}:\s*\[(.*?)\]", block, re.DOTALL)
    if lm:
        return [w.strip("'\" \t\r\n,") for w in lm.group(1).splitlines() if w.strip("'\" \t\r\n,")]
    return []

words = extract_list("wordsBeginning", z_block) + extract_list("wordsMiddle", z_block) + extract_list("wordsEnding", z_block)
print(f"Total words in /z/: {len(words)}")

# Test edge-tts directly on all words
async def test_edge():
    failed = []
    for w in words:
        try:
            c = edge_tts.Communicate(w, 'tr-TR-EmelNeural', rate='+5%', pitch='+6Hz')
            total = 0
            async for chunk in c.stream():
                if chunk['type'] == 'audio':
                    total += len(chunk['data'])
            if total == 0:
                failed.append((w, "empty audio"))
        except Exception as e:
            failed.append((w, str(e)))
    print("Edge-TTS direct failed count:", len(failed))
    for f in failed:
        print(" ", f)

asyncio.run(test_edge())
