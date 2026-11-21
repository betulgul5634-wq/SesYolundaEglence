import fitz
from rapidocr_onnxruntime import RapidOCR
import json
import re

doc = fitz.open('C:/Users/ASUS/.gemini/antigravity/brain/ffc530cc-181a-4ee6-9064-662cf989282f/.user_uploaded/media_1792859488799_1d38bb41.pdf')
ocr = RapidOCR()

sound_ranges = {
    'v': (81, 90),
    'ç': (138, 148),
}

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
            lower_l = l.lower()
            
            # Detect section headers
            if ("tek heceli" in lower_l) or (lower_l.startswith('a.') or lower_l.startswith('a/')):
                current_sec = "A"
                continue
            elif ("iki heceli" in lower_l or "2 heceli" in lower_l) or (lower_l.startswith('b.') or lower_l.startswith('b/')):
                current_sec = "B"
                continue
            elif ("uc heceli" in lower_l or "üç heceli" in lower_l or "ug heceli" in lower_l or "3 heceli" in lower_l) or (lower_l.startswith('c.') or lower_l.startswith('c/')):
                current_sec = "C"
                continue
            elif ("baslayan sozce" in lower_l or "başlayan sözce" in lower_l) or (lower_l.startswith('d.') or lower_l.startswith('d/')):
                current_sec = "D"
                continue
            elif ("iceren sozce" in lower_l or "içeren sözce" in lower_l) or (lower_l.startswith('e.') or lower_l.startswith('e/')):
                current_sec = "E"
                continue
            elif ("baslayan cumle" in lower_l or "başlayan cümle" in lower_l) or (lower_l.startswith('f.') or lower_l.startswith('f/')):
                current_sec = "F"
                continue
            elif ("iceren cumle" in lower_l or "içeren cümle" in lower_l) or (lower_l.startswith('g.') or lower_l.startswith('g/')):
                current_sec = "G"
                continue
            elif ("hikaye" in lower_l) or (lower_l.startswith('h.') or lower_l.startswith('h/')):
                current_sec = "H"
                continue
                
            if current_sec == "A":
                if l.upper() not in ["BASTA", "SONDA", "ORTADA"]:
                    for w in re.split(r'[,\s]+', l):
                        if len(w) > 1 and w.isalpha(): words_1.append(w.capitalize())
            elif current_sec == "B":
                if l.upper() not in ["BASTA", "SONDA", "ORTADA"]:
                    for w in re.split(r'[,\s]+', l):
                        if len(w) > 1 and w.isalpha(): words_2.append(w.capitalize())
            elif current_sec == "C":
                if l.upper() not in ["BASTA", "SONDA", "ORTADA"]:
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

existing = json.load(open('missing_sounds.json', encoding='utf-8'))
for letter in ['v', 'ç']:
    existing[letter] = parse_sound_pages(letter, sound_ranges[letter][0], sound_ranges[letter][1])

with open('missing_sounds.json', 'w', encoding='utf-8') as f:
    json.dump(existing, f, ensure_ascii=False, indent=2)

print("Updated missing_sounds.json for v and ç!")
