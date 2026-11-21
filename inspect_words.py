import json

data = json.load(open('missing_sounds.json', encoding='utf-8'))
for k in ['ş', 'ç', 'c']:
    print(k, data[k]['words_1'][:10])
