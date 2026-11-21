import os

for f in ['s_explain.wav', 'ş_explain.wav', 'z_explain.wav']:
    p = os.path.join('backend/pure_syllables', f)
    if os.path.exists(p):
        print(f"{f}: {os.path.getsize(p)} bytes")
    else:
        print(f"{f}: MISSING")
