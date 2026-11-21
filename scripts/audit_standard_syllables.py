import os

consonants = ['p', 'b', 't', 'd', 'k', 'g', 'f', 'v', 's', 'z', 'ş', 'j', 'h', 'ç', 'c', 'm', 'n', 'l', 'r', 'y']
vowels = ['a', 'e', 'ı', 'i', 'o', 'ö', 'u', 'ü']

all_standard_syllables = {}
for c in consonants:
    cv = [f"{c}{v}" for v in vowels]
    vc = [f"{v}{c}" for v in vowels]
    vcv = [f"{v}{c}{v}" for v in vowels]
    cvc = [f"{c}{v}{c}" for v in vowels]
    all_standard_syllables[c] = cv + vc + vcv + cvc

pure_files = set(os.listdir('backend/pure_syllables'))

missing_by_c = {}
total_missing = 0
total_sylls = 0

for c, syls in all_standard_syllables.items():
    missing = []
    for s in syls:
        total_sylls += 1
        fname = f"{s}.wav"
        if fname not in pure_files:
            missing.append(s)
    missing_by_c[c] = missing
    total_missing += len(missing)
    print(f"/{c}/: {len(missing)} missing out of {len(syls)} -> {missing}")

print(f"\nTotal Standard Syllables: {total_sylls}")
print(f"Total Missing Syllables: {total_missing}")
