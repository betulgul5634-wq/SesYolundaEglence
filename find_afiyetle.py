import sys
sys.stdout.reconfigure(encoding='utf-8')

with open('mobile/lib/data/sound_groups_data.dart', 'r', encoding='utf-8') as f:
    text = f.read()

idx = 0
while True:
    idx = text.find('afiyetle', idx)
    if idx == -1: break
    print(f"Found 'afiyetle' at {idx}:")
    print(text[max(0, idx-200):min(len(text), idx+300)])
    print("="*60)
    idx += len('afiyetle')
