import json
import re

# Load missing sounds
missing_data = json.load(open('missing_sounds.json', encoding='utf-8'))

# Vowel counting helper
VOWELS = set('aeıioöuüAEIİOÖUÜ')
def count_vowels(word):
    return sum(1 for c in word if c in VOWELS)

# Standard syllable ladders for each Turkish consonant
def generate_syllables(c):
    c_lower = c.lower()
    vowels = ['ı', 'i', 'a', 'e', 'o', 'ö', 'u', 'ü']
    ladder = []
    # CV
    for v in vowels:
        ladder.append(f"{c_lower}{v}")
    # VC
    for v in vowels:
        ladder.append(f"{v}{c_lower}")
    # VCV
    for v in vowels:
        ladder.append(f"{v}{c_lower}{v}")
    # CVC
    for v in vowels:
        ladder.append(f"{c_lower}{v}{c_lower}")
    return ladder

# Clean Turkish text & repair common OCR substitutions for specific letters
def repair_turkish_text(text, letter):
    # Common fixes
    t = text
    t = t.replace("`", "'").replace("’", "'").replace("”", '"').replace("“", '"')
    t = re.sub(r'\s+', ' ', t).strip()
    return t

print("Helper defined.")
