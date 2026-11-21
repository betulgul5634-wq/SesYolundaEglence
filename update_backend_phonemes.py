path = 'backend/main.py'
with open(path, 'r', encoding='utf-8') as f:
    c = f.read()

old_block = """    elif (mode == "phoneme" and clean_p == "t") or (len(trimmed_text) == 1 and (clean_p == "t" or trimmed_text.lower() == "t")) or trimmed_text.lower() in ("/t/", "t", "t sesi"):
        # Tek başına 't' tıklandığında kesinlikle "to/tu" demesin! Baskın T ve tıkır tıkır saat sesiyle patlatsın!
        speech_text = "T! Tıkır tıkır saat sesi: Tik tak! Tık tık! T! T!"
        rate = "+8%"
        pitch = "+8Hz"
    elif (mode == "phoneme" and clean_p == "d") or (len(trimmed_text) == 1 and (clean_p == "d" or trimmed_text.lower() == "d")) or trimmed_text.lower() in ("/d/", "d", "d sesi"):
        # Tek başına 'd' tıklandığında eğlenceli düt düt araba ve davul sesiyle patlatsın!
        speech_text = "D! Düt düt araba kornası ve davul sesi: Dan dan! Düm düm! D! D!"
        rate = "+8%"
        pitch = "+8Hz"
    elif (mode == "phoneme" and clean_p == "k") or (len(trimmed_text) == 1 and (clean_p == "k" or trimmed_text.lower() == "k")) or trimmed_text.lower() in ("/k/", "k", "k sesi"):
        # Tek başına 'k' tıklandığında eğlenceli kıkırdama ve kuru boğaz patlamasıyla patlatsın!
        speech_text = "K! Dil ucu aşağıda, boğazdan patlat: Kıkır kıkır! K! K! K!"
        rate = "+8%"
        pitch = "+8Hz"
    elif (mode == "phoneme" and clean_p == "g") or (len(trimmed_text) == 1 and (clean_p == "g" or trimmed_text.lower() == "g")) or trimmed_text.lower() in ("/g/", "g", "g sesi"):
        # Tek başına 'g' tıklandığında tok ve güçlü boğaz patlamasıyla patlatsın!
        speech_text = "G! Dilinin arkasını damağına bas, boğazını titreterek patlat: Tok bir G sesi! G! G! G!"
        rate = "+8%"
        pitch = "+8Hz"
    elif len(trimmed_text) == 1 and (clean_p == "p" or trimmed_text.lower() == "p"):
        speech_text = "P! Dudaklarını birbirine kapat ve puf diye patlat: Pı!"
        rate = "+6%"
        pitch = "+6Hz"
    elif len(trimmed_text) == 1 and (clean_p == "b" or trimmed_text.lower() == "b"):
        speech_text = "B! Dudaklarını bas ve titreterek patlat: B!"
        rate = "+6%"
        pitch = "+6Hz" """

new_block = """    elif (mode == "phoneme" and clean_p == "t") or (len(trimmed_text) == 1 and (clean_p == "t" or trimmed_text.lower() == "t")) or trimmed_text.lower() in ("/t/", "t", "t sesi"):
        t_file = os.path.join(pure_dir, "t.wav")
        if os.path.exists(t_file):
            with open(t_file, "rb") as f:
                wav_bytes = f.read()
            return Response(content=wav_bytes, media_type="audio/wav")
        speech_text = "T! Tıkır tıkır saat sesi: Tik tak! Tık tık! T! T!"
        rate = "+8%"
        pitch = "+8Hz"
    elif (mode == "phoneme" and clean_p == "d") or (len(trimmed_text) == 1 and (clean_p == "d" or trimmed_text.lower() == "d")) or trimmed_text.lower() in ("/d/", "d", "d sesi"):
        d_file = os.path.join(pure_dir, "d.wav")
        if os.path.exists(d_file):
            with open(d_file, "rb") as f:
                wav_bytes = f.read()
            return Response(content=wav_bytes, media_type="audio/wav")
        speech_text = "D! Düt düt araba kornası ve davul sesi: Dan dan! Düm düm! D! D!"
        rate = "+8%"
        pitch = "+8Hz"
    elif (mode == "phoneme" and clean_p == "k") or (len(trimmed_text) == 1 and (clean_p == "k" or trimmed_text.lower() == "k")) or trimmed_text.lower() in ("/k/", "k", "k sesi"):
        k_file = os.path.join(pure_dir, "k.wav")
        if os.path.exists(k_file):
            with open(k_file, "rb") as f:
                wav_bytes = f.read()
            return Response(content=wav_bytes, media_type="audio/wav")
        speech_text = "K! Dil ucu aşağıda, boğazdan patlat: Kıkır kıkır! K! K! K!"
        rate = "+8%"
        pitch = "+8Hz"
    elif (mode == "phoneme" and clean_p == "g") or (len(trimmed_text) == 1 and (clean_p == "g" or trimmed_text.lower() == "g")) or trimmed_text.lower() in ("/g/", "g", "g sesi"):
        g_file = os.path.join(pure_dir, "g.wav")
        if os.path.exists(g_file):
            with open(g_file, "rb") as f:
                wav_bytes = f.read()
            return Response(content=wav_bytes, media_type="audio/wav")
        speech_text = "G! Dilinin arkasını damağına bas, boğazını titreterek patlat: Tok bir G sesi! G! G! G!"
        rate = "+8%"
        pitch = "+8Hz"
    elif (mode == "phoneme" and clean_p == "b") or (len(trimmed_text) == 1 and (clean_p == "b" or trimmed_text.lower() == "b")) or trimmed_text.lower() in ("/b/", "b", "b sesi"):
        b_file = os.path.join(pure_dir, "b.wav")
        if os.path.exists(b_file):
            with open(b_file, "rb") as f:
                wav_bytes = f.read()
            return Response(content=wav_bytes, media_type="audio/wav")
        speech_text = "B! Dudaklarını bas ve titreterek patlat: B!"
        rate = "+6%"
        pitch = "+6Hz"
    elif (mode == "phoneme" and clean_p == "f") or (len(trimmed_text) == 1 and (clean_p == "f" or trimmed_text.lower() == "f")) or trimmed_text.lower() in ("/f/", "f", "f sesi"):
        f_file = os.path.join(pure_dir, "f.wav")
        if os.path.exists(f_file):
            with open(f_file, "rb") as f:
                wav_bytes = f.read()
            return Response(content=wav_bytes, media_type="audio/wav")
        speech_text = "F! Üst dişleri alt dudağa değdir ve sıcak nefes üfle: Fff!"
        rate = "+6%"
        pitch = "+6Hz"
    elif (mode == "phoneme" and clean_p == "v") or (len(trimmed_text) == 1 and (clean_p == "v" or trimmed_text.lower() == "v")) or trimmed_text.lower() in ("/v/", "v", "v sesi"):
        v_file = os.path.join(pure_dir, "v.wav")
        if os.path.exists(v_file):
            with open(v_file, "rb") as f:
                wav_bytes = f.read()
            return Response(content=wav_bytes, media_type="audio/wav")
        speech_text = "V! Diş ve dudak arasından ses tellerini titreterek vızıldat: Vvv!"
        rate = "+6%"
        pitch = "+6Hz" """

c = c.replace(old_block.replace('\r\n', '\n'), new_block.replace('\r\n', '\n'))
c = c.replace(old_block.replace('\n', '\r\n'), new_block.replace('\n', '\r\n'))

with open(path, 'w', encoding='utf-8') as f:
    f.write(c)

print('Updated backend/main.py successfully with all pure phoneme wav handlers')
