import json

data = json.load(open('missing_sounds.json', encoding='utf-8'))
for k in ['j', 'h', 'c', 'm', 'n', 'l', 'y', 'z', 'f', 'v']:
    print(f"=== {k} ===")
    print("w1:", data[k]['words_1'][:5])
    print("phr_b:", data[k]['phrases_beg'][:2])
    print("snt_b:", data[k]['sentences_beg'][:2])
