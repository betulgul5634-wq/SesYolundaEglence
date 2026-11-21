import os

pure_dir = 'backend/pure_syllables'
test_inputs = ['/p/', '/b/', '/t/', '/d/', '/k/', '/g/', '/f/', '/v/', '/s/', '/z/', '/ş/', '/j/', '/h/', '/ç/', '/c/', '/m/', '/n/', '/l/', '/r/', '/y/']

for raw in test_inputs:
    clean_syl = raw.replace("/", "").replace("I", "ı").replace("İ", "i").lower().strip().rstrip(".").rstrip(",").rstrip("?").rstrip("!")
    path = os.path.join(pure_dir, f"{clean_syl}.wav")
    print(f"Input: {raw:6} -> clean_syl: {clean_syl:3} -> {path} -> EXISTS: {os.path.exists(path)}")
