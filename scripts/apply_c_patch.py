with open('backend/main.py', 'r', encoding='utf-8') as f:
    content = f.read()

target1 = """    # Kesin Oncelik 5: Ç harfinde veya 'ççç' sesinde ASLA 'çe' denmesin, dogrudan saf 'çççç' sesi calsin!
    if clean_syl in ("ç", "çç", "ççç", "çççç", "ççççç") or (clean_p == "ç" and mode in ("phoneme", "syllable") and clean_syl in ("ç", "çç", "ççç")):
        ch_sound_file = os.path.join(pure_dir, "ç.wav")
        if os.path.exists(ch_sound_file):
            with open(ch_sound_file, "rb") as f:
                wav_bytes = f.read()
            return Response(content=wav_bytes, media_type="audio/wav")"""

replacement1 = target1 + """

    # Kesin Oncelik 5.1: C harfinde veya 'ccc' sesinde ASLA 'ce' denmesin, dogrudan saf 'c.wav' sesi calsin!
    if clean_syl in ("c", "cc", "ccc", "cccc", "ccccc") or (clean_p == "c" and mode in ("phoneme", "syllable") and clean_syl in ("c", "cc", "ccc")):
        c_sound_file = os.path.join(pure_dir, "c.wav")
        if os.path.exists(c_sound_file):
            with open(c_sound_file, "rb") as f:
                wav_bytes = f.read()
            return Response(content=wav_bytes, media_type="audio/wav")"""

assert target1 in content, "target1 not found"
content = content.replace(target1, replacement1, 1)

target2 = """    elif mode == "phoneme" or (len(trimmed_text) == 1 and (clean_p == "ç" or trimmed_text.lower() == "ç")) or trimmed_text.lower() in ("/ç/", "ç", "ç sesi"):
        ch_file = os.path.join(pure_dir, "ç.wav")
        if os.path.exists(ch_file):
            with open(ch_file, "rb") as f:
                wav_bytes = f.read()
            return Response(content=wav_bytes, media_type="audio/wav")
        speech_text = "Ç! Dil ucu damağa bas ve kuvvetli bir nefesle patlat: Ç! Ç! Ç!"
        rate = "+6%"
        pitch = "+6Hz"\n"""

replacement2 = target2 + """    elif mode == "phoneme" or (len(trimmed_text) == 1 and (clean_p == "c" or trimmed_text.lower() == "c")) or trimmed_text.lower() in ("/c/", "c", "c sesi"):
        c_file = os.path.join(pure_dir, "c.wav")
        if os.path.exists(c_file):
            with open(c_file, "rb") as f:
                wav_bytes = f.read()
            return Response(content=wav_bytes, media_type="audio/wav")
        speech_text = "C! Dilinin ön kısmını damağa yapıştır ve neşeyle patlat: C! C! C!"
        rate = "+6%"
        pitch = "+6Hz"\n"""

assert target2 in content, "target2 not found"
content = content.replace(target2, replacement2, 1)

with open('backend/main.py', 'w', encoding='utf-8') as f:
    f.write(content)

print("backend/main.py patched successfully!")
