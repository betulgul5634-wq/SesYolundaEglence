import re

test = r"""
phrases: [
  'Pullu palto', 'Pembe pike', 'Pelin\'in perdeleri'
],
sentences: [
  'Pelin\'in perdeleri püsküllü.',
  'Polat pazartesi Paris\'teydi.'
],
storyTitle: 'Pazar Sabahı ve Kırpık',
storyContent: 'Pazar günleri...',
"""

def extract_list(block, field_name):
    m = re.search(rf'{field_name}:\s*\[(.*?)\](?=\s*,\s*\w+:|\s*\))', block, re.DOTALL)
    if not m: return []
    raw = m.group(1)
    items = [m.replace(r"\'", "'") for m in re.findall(r"'((?:[^'\\]|\\.)*)'", raw)]
    return items

print("phrases:", extract_list(test, 'phrases'))
print("sentences:", extract_list(test, 'sentences'))
