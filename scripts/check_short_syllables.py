import re

with open('mobile/lib/data/sound_groups_data.dart', 'r', encoding='utf-8') as f:
    text = f.read()

matches = re.findall(r'syllables:\s*\[(.*?)\]', text, re.DOTALL)
active_sylls = set()
for m in matches:
    tokens = re.findall(r"'([^']+)'|\"([^\"]+)\"", m)
    for t1, t2 in tokens:
        val = (t1 or t2).strip().lower()
        if val:
            active_sylls.add(val)

candidates = ['ag', 'am', 'eg', 'em', 'gig', 'ig', 'il', 'im', 'iv', 'mo', 'mu', 'mö', 'og', 'olo', 'om', 'ug', 'ulu', 'um', 'ög', 'öm', 'üg', 'üm', 'ıg', 'ılı']
in_active = [c for c in candidates if c in active_sylls]
print(f"Total active syllables: {len(active_sylls)}")
print(f"Short candidates active in 20 stages ({len(in_active)}): {in_active}")
