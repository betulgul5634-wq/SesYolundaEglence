import fitz
from rapidocr_onnxruntime import RapidOCR
import json
import re
import os

doc = fitz.open('C:/Users/ASUS/.gemini/antigravity/brain/ffc530cc-181a-4ee6-9064-662cf989282f/.user_uploaded/media_1792859488799_1d38bb41.pdf')
ocr = RapidOCR()

# Mapping of each sound to its PDF page range (0-indexed)
sound_ranges = {
    'p': (16, 25),
    'b': (25, 34),
    't': (34, 43),
    'd': (43, 52),
    'k': (52, 61),
    'g': (61, 71),
    'f': (72, 81),
    'v': (81, 90),
    's': (90, 99),
    'z': (99, 108),
    'ş': (108, 117),
    'j': (117, 126),
    'h': (126, 137),
    'ç': (138, 148),
    'c': (148, 157),
    'm': (158, 168),
    'n': (168, 178),
    'l': (179, 189),
    'r': (190, 201),
    'y': (202, 211),
}

def clean_turkish(text):
    text = text.strip()
    return text

def parse_sound_pages(letter, start_p, end_p):
    print(f"Extracting /{letter}/ from pages {start_p+1} to {end_p+1}...")
    pages_text = []
    for p in range(start_p, end_p + 1):
        if p >= len(doc):
            break
        pix = doc[p].get_pixmap(dpi=110)
        res, _ = ocr(pix.tobytes())
        lines = [l[1] for l in res] if res else []
        pages_text.append((p + 1, lines))
        
    full_text = "\n".join(["\n".join(lines) for _, lines in pages_text])
    
    # Extract sections
    # A. Tek Heceli
    # B. İki Heceli
    # C. Üç Heceli
    # D. Başlayan Sözceler
    # E. İçeren Sözceler
    # F. Başlayan Cümleler
    # G. İçeren Cümleler
    # H. Hikaye
    
    words_1 = []
    words_2 = []
    words_3 = []
    phrases_beg = []
    phrases_cont = []
    sentences_beg = []
    sentences_cont = []
    story_lines = []
    
    current_sec = None
    for p_num, lines in pages_text:
        for line in lines:
            l = line.strip()
            if not l or "Heceden Hikayeye" in l or "Terapi Alistirma Kitabi" in l or l.isdigit():
                continue
            # Detect section headers
            if re.match(r'^[A-H]\.', l) or re.match(r'^[A-H]\s*\/', l):
                if "Tek Heceli" in l:
                    current_sec = "A"
                elif "iki Heceli" in l or "İki Heceli" in l or "2 Heceli" in l:
                    current_sec = "B"
                elif "Uc Heceli" in l or "Üç Heceli" in l or "3 Heceli" in l:
                    current_sec = "C"
                elif "Baslayan Sozceler" in l or "Başlayan Sözceler" in l:
                    current_sec = "D"
                elif "iceren Sozceler" in l or "İçeren Sözceler" in l:
                    current_sec = "E"
                elif "Baslayan Cumleler" in l or "Başlayan Cümleler" in l:
                    current_sec = "F"
                elif "iceren Cumleler" in l or "İçeren Cümleler" in l:
                    current_sec = "G"
                elif "Hikaye" in l:
                    current_sec = "H"
                continue
                
            if current_sec == "A":
                if l not in ["BASTA", "SONDA", "ORTADA"]:
                    for w in re.split(r'[,\s]+', l):
                        if len(w) > 1 and w.isalpha(): words_1.append(w.capitalize())
            elif current_sec == "B":
                if l not in ["BASTA", "SONDA", "ORTADA"]:
                    for w in re.split(r'[,\s]+', l):
                        if len(w) > 1 and w.isalpha(): words_2.append(w.capitalize())
            elif current_sec == "C":
                if l not in ["BASTA", "SONDA", "ORTADA"]:
                    for w in re.split(r'[,\s]+', l):
                        if len(w) > 1 and w.isalpha(): words_3.append(w.capitalize())
            elif current_sec == "D":
                cleaned = re.sub(r'^\d+[\.\)]\s*', '', l)
                if len(cleaned) > 2: phrases_beg.append(cleaned)
            elif current_sec == "E":
                cleaned = re.sub(r'^\d+[\.\)]\s*', '', l)
                if len(cleaned) > 2: phrases_cont.append(cleaned)
            elif current_sec == "F":
                cleaned = re.sub(r'^\d+[\.\)]\s*', '', l)
                if len(cleaned) > 4: sentences_beg.append(cleaned)
            elif current_sec == "G":
                cleaned = re.sub(r'^\d+[\.\)]\s*', '', l)
                if len(cleaned) > 4: sentences_cont.append(cleaned)
            elif current_sec == "H":
                story_lines.append(l)

    return {
        "letter": letter,
        "words_1": list(dict.fromkeys(words_1)),
        "words_2": list(dict.fromkeys(words_2)),
        "words_3": list(dict.fromkeys(words_3)),
        "phrases_beg": phrases_beg,
        "phrases_cont": phrases_cont,
        "sentences_beg": sentences_beg,
        "sentences_cont": sentences_cont,
        "story": " ".join(story_lines),
    }

data = {}
# Let's extract missing sounds first: F, V, Z, Ş, J, H, Ç, C, M, N, L, Y
missing = ['f', 'v', 'z', 'ş', 'j', 'h', 'ç', 'c', 'm', 'n', 'l', 'y']
for m in missing:
    start_p, end_p = sound_ranges[m]
    data[m] = parse_sound_pages(m, start_p, end_p)

with open('missing_sounds.json', 'w', encoding='utf-8') as f:
    json.dump(data, f, ensure_ascii=False, indent=2)

print("Saved missing_sounds.json!")
