import wave
import numpy as np

with wave.open('backend/pure_syllables/game_intro_ç.wav', 'rb') as wf:
    print("game_intro_ç.wav:")
    print("  channels:", wf.getnchannels())
    print("  rate:", wf.getframerate())
    print("  duration:", wf.getnframes() / wf.getframerate())

with wave.open('backend/pure_syllables/ç.wav', 'rb') as wf:
    print("ç.wav:")
    print("  channels:", wf.getnchannels())
    print("  rate:", wf.getframerate())
    print("  duration:", wf.getnframes() / wf.getframerate())
