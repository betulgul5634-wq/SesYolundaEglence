import os, speech_recognition as sr

r = sr.Recognizer()
pure_dir = "backend/pure_syllables"
sample_syls = ['ab', 'al', 'lü', 'ma', 'mam', 'me', 'mi', 'mü', 'mı', 'ol', 'ul', 'uz', 'çü', 'ül', 'ıl', 'ıv', 'pa', 'ap', 'ba', 'ab', 'ta', 'at', 'da', 'ad', 'ka', 'ak', 'ga', 'ag', 'fa', 'af', 'va', 'av', 'sa', 'as', 'za', 'az', 'şa', 'aş', 'ja', 'aj', 'ha', 'ah', 'ça', 'aç', 'ca', 'ac', 'ma', 'am', 'na', 'an', 'la', 'al', 'ra', 'ar', 'ya', 'ay']

print(f"Testing Google STT (tr-TR) on {len(sample_syls)} syllables...")
success_count = 0
for s in sample_syls:
    wav_p = os.path.join(pure_dir, f"{s}.wav")
    try:
        with sr.AudioFile(wav_p) as source:
            audio = r.record(source)
        # Using recognize_google with language tr-TR
        text = r.recognize_google(audio, language="tr-TR")
        print(f"Syllable '{s}': Recognized as '{text}'")
        success_count += 1
    except sr.UnknownValueError:
        print(f"Syllable '{s}': Inaudible to STT dictionary (isolated syllable burst)")
    except Exception as e:
        print(f"Syllable '{s}': Error {e}")

print(f"STT recognized: {success_count}/{len(sample_syls)}")
