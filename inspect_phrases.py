import json

data = json.load(open('missing_sounds.json', encoding='utf-8'))
for k in ['ş', 'ç']:
    print(f"=== {k} ===")
    print("phrases_beg:", data[k]['phrases_beg'][:3])
    print("phrases_cont:", data[k]['phrases_cont'][:3])
    print("sentences_beg:", data[k]['sentences_beg'][:3])
    print("story:", data[k]['story'][:100])
