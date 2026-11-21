import asyncio
import edge_tts
import miniaudio
import numpy as np
import wave
import os

PURE_DIR = "backend/pure_syllables"

# Syllable prompts that produce clean, distinct Turkish pronunciation:
# We must use carrier words or clear Turkish phonetic spelling so EdgeTTS doesn't harfle or confuse vowels!
# For CV:
# pa -> "Pas" without s or "Paa" -> let's test "Pa", "Pe", "Pı", "Pi", "Po", "Pö", "Pu", "Pü"
# For VC:
# ap -> "Aap", ep -> "Eep", ıp -> "Iıp", ip -> "İip", op -> "Oop", öp -> "Ööp", up -> "Uup", üp -> "Üüp"
# For VCV:
# apa -> "Apa", epe -> "Epe", ıpı -> "Ipı", ipi -> "İpi", opo -> "Opo", öpö -> "Öpö", upu -> "Upu", üpü -> "Üpü"
# For CVC:
# pap -> "Pap", pep -> "Pep", pıp -> "Pıp", pip -> "Pip", pop -> "Pop", pöp -> "Pöp", pup -> "Pup", püp -> "Püp"

prompts = {
    'pa': 'Pa.',
    'pe': 'Pe.',
    'pı': 'Pı.',
    'pi': 'Pi.',
    'po': 'Po.',
    'pö': 'Pö.',
    'pu': 'Pu.',
    'pü': 'Pü.',
    'ap': 'Ap.',
    'ep': 'Ep.',
    'ıp': 'Ip.',
    'ip': 'İp.',
    'op': 'Op.',
    'öp': 'Öp.',
    'up': 'Up.',
    'üp': 'Üp.',
    'apa': 'Apa.',
    'epe': 'Epe.',
    'ıpı': 'Ipı.',
    'ipi': 'İpi.',
    'opo': 'Opo.',
    'öpö': 'Öpö.',
    'upu': 'Upu.',
    'üpü': 'Üpü.',
    'pap': 'Pap.',
    'pep': 'Pep.',
    'pıp': 'Pıp.',
    'pip': 'Pip.',
    'pop': 'Pop.',
    'pöp': 'Pöp.',
    'pup': 'Pup.',
    'püp': 'Püp.',
}

async def test_prompts():
    for syl, pr in prompts.items():
        comm = edge_tts.Communicate(pr, "tr-TR-EmelNeural", rate="-6%", pitch="+3Hz")
        mp3 = b""
        async for chunk in comm.stream():
            if chunk["type"] == "audio": mp3 += chunk["data"]
        dec = miniaudio.decode(mp3)
        samples = np.frombuffer(dec.samples, dtype=np.int16)
        dur = len(samples) / (dec.sample_rate * dec.nchannels)
        print(f"{syl:4} -> samples={len(samples)}, dur={dur:.3f}s")

asyncio.run(test_prompts())
