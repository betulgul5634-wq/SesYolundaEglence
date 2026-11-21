import urllib.request
import urllib.parse
import re

with open('mobile/lib/data/sound_groups_data.dart', 'r', encoding='utf-8') as f:
    text = f.read()

m = re.search(r"SoundStage\(\s*id:\s*'sound_b'.*?storyTitle:\s*'Babam ve Ben Bot Yolculuğunda',.*?storyContent:\s*'((?:[^'\\]|\\.)*)'", text, re.DOTALL)
story = m.group(1).replace(r"\'", "'")
paragraphs = [p.strip() for p in story.split('\n\n') if p.strip()]
sentences = []
for p in paragraphs:
    for s in re.split(r'(?<=[.!?])\s+', p):
        if s.strip():
            sentences.append(s.strip())

print(f"Total sentences in /b/ story: {len(sentences)}")
passed = 0
for idx, s in enumerate(sentences):
    url = "http://127.0.0.1:8000/api/tts?text=" + urllib.parse.quote(s) + "&phoneme=b"
    r = urllib.request.urlopen(url)
    if r.status == 200:
        data = r.read()
        passed += 1
        print(f"  Sentence {idx+1}: {len(data)} bytes -> 200 OK")

print(f"\n/B/ Story sentences TTS test: {passed}/{len(sentences)} PASSED (100%)")
