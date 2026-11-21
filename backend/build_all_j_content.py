import asyncio
import os
import sys
import wave
import edge_tts
import miniaudio
import numpy as np

sys.stdout.reconfigure(encoding='utf-8')

PURE_DIR = os.path.join(os.path.dirname(__file__), "pure_syllables")
os.makedirs(PURE_DIR, exist_ok=True)

async def synthesize_word(text, pitch="+6Hz", rate="-8%"):
    comm = edge_tts.Communicate(text, "tr-TR-EmelNeural", pitch=pitch, rate=rate)
    mp3_data = b""
    async for chunk in comm.stream():
        if chunk["type"] == "audio":
            mp3_data += chunk["data"]
    dec = miniaudio.decode(mp3_data)
    audio = np.frombuffer(dec.samples, dtype=np.int16)
    return audio, dec.sample_rate, dec.nchannels

def apply_fades_stereo(audio, nchannels, fade_in_frames=220, fade_out_frames=440):
    audio = audio.astype(np.float32)
    fade_in_samples = min(fade_in_frames * nchannels, len(audio))
    fade_out_samples = min(fade_out_frames * nchannels, len(audio))
    
    if fade_in_samples > 0:
        fade_in_curve = np.repeat(np.linspace(0, 1, fade_in_frames), nchannels)
        audio[:len(fade_in_curve)] *= fade_in_curve
    if fade_out_samples > 0:
        fade_out_curve = np.repeat(np.linspace(1, 0, fade_out_frames), nchannels)
        audio[-len(fade_out_curve):] *= fade_out_curve
        
    peak = np.max(np.abs(audio))
    if peak > 0:
        audio = audio / peak * 28000
    
    # 120ms silent tail
    tail_samples = int(0.12 * 44100) * nchannels
    tail = np.zeros(tail_samples, dtype=np.float32)
    audio = np.concatenate([audio, tail])
    return audio.astype(np.int16)

def save_wav(fname, audio, sr, nchannels):
    path = os.path.join(PURE_DIR, fname)
    with wave.open(path, "wb") as wf:
        wf.setnchannels(nchannels)
        wf.setsampwidth(2)
        wf.setframerate(sr)
        wf.writeframes(audio.tobytes())
    dur = len(audio) / (sr * nchannels)
    print(f"Saved {fname}: {dur:.2f}s", flush=True)

async def build_sustained_j_sound():
    print("Building sustained Turkish [ʒ] motor sound...", flush=True)
    words = ["Masaj", "Bej", "Prestij", "Garaj", "Ruj", "Cıj"]
    audios = {}
    sr, nch = 44100, 2
    for w in words:
        a, sr, nch = await synthesize_word(f"{w}.", rate="-15%")
        audios[w] = a
    
    slices = [
        audios["Masaj"][int(0.74 * sr)*nch : int(0.84 * sr)*nch],   # 100ms
        audios["Bej"][int(0.57 * sr)*nch : int(0.67 * sr)*nch],     # 100ms
        audios["Prestij"][int(0.86 * sr)*nch : int(0.97 * sr)*nch], # 110ms
        audios["Garaj"][int(1.20 * sr)*nch : int(1.32 * sr)*nch],   # 120ms
        audios["Ruj"][int(0.53 * sr)*nch : int(0.63 * sr)*nch],     # 100ms
        audios["Cıj"][int(0.52 * sr)*nch : int(0.62 * sr)*nch],     # 100ms
        audios["Prestij"][int(0.86 * sr)*nch : int(0.97 * sr)*nch], # 110ms
        audios["Masaj"][int(0.74 * sr)*nch : int(0.84 * sr)*nch],   # 100ms
    ]
    
    fade_frames = int(0.04 * sr)
    fade_samples = fade_frames * nch
    t = np.linspace(0, np.pi/2, fade_frames)
    fade_in = np.repeat(np.sin(t), nch).astype(np.float32)
    fade_out = np.repeat(np.cos(t), nch).astype(np.float32)
    
    combined = slices[0].astype(np.float32)
    for s in slices[1:]:
        s_float = s.astype(np.float32)
        combined_tail = combined[-fade_samples:] * fade_out
        s_head = s_float[:fade_samples] * fade_in
        blended = combined_tail + s_head
        combined = np.concatenate([combined[:-fade_samples], blended, s_float[fade_samples:]])
    
    att_frames = int(0.04 * sr)
    rel_frames = int(0.08 * sr)
    att_curve = np.repeat(np.linspace(0, 1, att_frames), nch)
    rel_curve = np.repeat(np.linspace(1, 0, rel_frames), nch)
    combined[:len(att_curve)] *= att_curve
    combined[-len(rel_curve):] *= rel_curve
    
    peak = np.max(np.abs(combined))
    if peak > 0:
        combined = combined / peak * 27000
    
    j_buzz = combined.astype(np.int16)
    save_wav("j.wav", j_buzz, sr, nch)
    return j_buzz, sr, nch

async def build_game_intro(j_buzz, sr, nch):
    print("Building game_intro_j.wav with pure 'jjjj' buzz...", flush=True)
    part1, _, _ = await synthesize_word("Hazır ol! İçinde", pitch="+6Hz", rate="-2%")
    t1 = np.where(np.abs(part1) > 400)[0]
    p1 = part1[t1[0]:t1[-1]]
    
    part2, _, _ = await synthesize_word("sesi bulunan kelimeleri ye ve dev gibi büyü!", pitch="+6Hz", rate="-2%")
    t2 = np.where(np.abs(part2) > 400)[0]
    p2 = part2[t2[0]:t2[-1]]
    
    pause = np.zeros(int(0.14 * sr) * nch, dtype=np.int16)
    
    combined = np.concatenate([p1, pause, j_buzz, pause, p2])
    processed = apply_fades_stereo(combined, nch, 100, 400)
    save_wav("game_intro_j.wav", processed, sr, nch)

async def build_phrases_and_sentences():
    print("Building all 60 J phrases and sentences with validated phonetics...", flush=True)
    j_items = [
        # Phrases Beginning
        ("Jöleli jön", "J.öleli jön."),
        ("Japon jüri", "Japon jüri."),
        ("Jumbo jet", "Jumbo jet."),
        ("Janjanlı jant", "Janjanlı jant."),
        ("Judocu Jale", "Judocu Jale."),
        ("Japon jokey", "Japon jokey."),
        ("Jeolog Jülide", "Jeolog Jülide."),
        ("Jale'nin jetonu", "Jale'nin, jetonu."),
        ("Jaguar'ın jantı", "Jaguar'ın, jantı."),
        ("Jülide'nin jesti", "Jülide'nin, jesti."),
        ("Jelatinli jambon", "J.elatinli, j.ambon."),
        ("Jelibonun jölesi", "J.elibonun, j.ölesi."),
        ("Jandarmanın jileti", "Jandarmanın, jileti."),
        ("Judocuların jübilesi", "Judocuların, j.übilesi."),
        ("Jamaikalı jimnastikçi", "J.amaikalı, j.imnastikçi."),
        
        # Phrases Containing
        ("Ojeli Tijen", "Ojeli Tijen."),
        ("Enerjik jüri", "Enerjik jüri."),
        ("Bej pijama", "Bej pijama."),
        ("Şarjlı abajur", "Şarjlı abajur."),
        ("Japon ejderi", "Japon, ej-deri."),
        ("Enerji masajı", "Enerji masajı."),
        ("Jetonlu bagaj", "Jetonlu bagaj."),
        ("Panjurlu garaj", "Panjurlu garaj."),
        ("Müjdeli mesaj", "Müjdeli mesaj."),
        ("Japon makyajı", "Japon makyajı."),
        ("Jiletin ambalajı", "Jiletin ambalajı."),
        ("Ajanın ajandası", "Ajanın ajandası."),
        ("Jale'nin projesi", "Jale'nin, projesi."),
        ("Ajda'nın alerjisi", "Ajda'nın, alerjisi."),
        ("Hijyenik deterjan", "Hijyenik deterjan."),
        
        # Sentences Beginning
        ("Jet Japonlar'ın mı?", "Jet, Japonların mı?"),
        ("Jokeyin jübilesi jestti.", "Jokeyin, jübilesi, jest idi."),
        ("Jöleli jön jenerikteydi.", "J.öleli jön, jenerik teydi."),
        ("Jale'nin jilesi jarseydi.", "Jale'nin jilesi, jarseydi."),
        ("Jeolog Jale Japonya'da.", "Jeolog Jale, Japonya'da."),
        ("Jöleli jandarma judocuydu.", "J.öleli jandarma, judocuydu."),
        ("Jetin jeneratörü jetonludur.", "Jetin, jeneratörü, jetonlu dur."),
        ("Jumbo jambonlar jelatinliydi.", "Jumbo, j.ambonlar, j.elatinli idi."),
        ("Jamaikalı judocu Japonya'da.", "J.amaikalı judocu, Japonya'da."),
        ("Janset Japonlarla Jüpiter'deydi.", "Janset, Japonlarla, Jüpiter deydi."),
        ("Jülide Jamaika'da jimnastikçiydi.", "Jülide, Jamaika'da, j.imnastikçiydi."),
        ("Jokey Jale jimnastik jürisindeydi.", "Jokey Jale, jimnastik jürisindeydi."),
        ("Judocu jelatinsiz jetonları jelatinledi.", "Judocu, jelatinsiz jetonları, jelatinledi."),
        ("Jamaika'daki jokey Japon jetindeydi.", "Jamaika'daki jokey, Japon jetindeydi."),
        ("Jülide'nin Jaguar'ının jantları janjanlıydı.", "Jülide'nin Jaguar'ının jantları, janjanlıydı."),
        
        # Sentences Containing
        ("Nejat'ın projesi stratejiktir.", "Nejat'ın projesi, stratejiktir."),
        ("Tijen psikoloji stajındaymış.", "Tijen, psikoloji stajındaymış."),
        ("Drajelerin gramajı orijinaldir.", "Drajelerin gramajı, orijinaldir."),
        ("Bagajın ambalajı garajda mı?", "Bagajın ambalajı, garajda mı?"),
        ("Ajda'nın alerjisi pijamadanmış.", "Ajda'nın alerjisi, pijamadanmış."),
        ("Stajyer ferforjeleri montajladı.", "Stajyer, ferforjeleri montajladı."),
        ("Bej ojemle rujum bagajdaymış.", "Bej ojemle rujum, bagajdaymış."),
        ("Ejderhalı pijamalar Müjde'ninmiş.", "Ej-derhalı pijamalar, Müjde'ninmiş."),
        ("Müjdat'ın dublaj ajansı pasajdadır.", "Müjdat'ın dublaj ajansı, pasajdadır."),
        ("Kamyonlar lojmanın garajındadır.", "Kamyonlar, lojmanın garajındadır."),
        ("Kolejdeki deterjanlar hijyenik midir?", "Kolejdeki deterjanlar, hijyenik midir?"),
        ("Sosyoloji arkeolojiden avantajlıdır.", "Sosyoloji, arkeolojiden avantajlıdır."),
        ("Röportajı ajansa mesajla müjdelediler.", "Röportajı ajansa, mesajla müjdelediler."),
        ("Ajandadaki mesajlar ajanın planıymış.", "Ajandadaki mesajlar, ajanın planıymış."),
        ("Enerji masajının orijinali Nijerya'daki plajlardadır.", "Enerji masajının orijinali, Nijerya'daki plajlardadır."),
    ]
    
    for orig_text, phonetic_text in j_items:
        clean_key = orig_text.replace("I", "ı").replace("İ", "i").lower().strip().rstrip(".").rstrip(",").rstrip("?").rstrip("!")
        audio, sr, nch = await synthesize_word(phonetic_text, pitch="+4Hz", rate="-8%")
        processed = apply_fades_stereo(audio, nch, int(0.01 * sr), int(0.04 * sr))
        save_wav(f"{clean_key}.wav", processed, sr, nch)

async def main():
    j_buzz, sr, nch = await build_sustained_j_sound()
    await build_game_intro(j_buzz, sr, nch)
    await build_phrases_and_sentences()
    print("=== All J Audio Assets and Phrases/Sentences Built Successfully! ===", flush=True)

if __name__ == "__main__":
    asyncio.run(main())
