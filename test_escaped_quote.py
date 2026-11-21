import re

test = r"""
sentences: [
  'Pelin\'in perdeleri püsküllü.',
  'Polat pazartesi Paris\'teydi.',
  'Pelin peynirli poğaçayı Pervin\'le paylaştı.',
]
"""

# Regex that respects escaped single quotes:
pattern = re.compile(r"'((?:[^'\\]|\\.)*)'")
items = [m.group(1).replace(r"\'", "'").replace(r"\\", "\\") for m in pattern.finditer(test)]
print("Parsed items:", items)
