import json

data = json.load(open('missing_sounds.json', encoding='utf-8'))
for letter, d in data.items():
    print(f"{letter}: w1={len(d['words_1'])}, w2={len(d['words_2'])}, w3={len(d['words_3'])}, phr_b={len(d['phrases_beg'])}, phr_c={len(d['phrases_cont'])}, snt_b={len(d['sentences_beg'])}, snt_c={len(d['sentences_cont'])}, story_len={len(d['story'])}")
