import os
import re

todos = []
for root, dirs, files in os.walk('backend'):
    for f in files:
        if f.endswith('.py'):
            p = os.path.join(root, f)
            with open(p, 'r', encoding='utf-8') as fh:
                lines = fh.readlines()
            for idx, line in enumerate(lines):
                if re.search(r'\b(TODO|FIXME|XXX|HACK)\b', line, re.IGNORECASE):
                    todos.append((f, idx+1, line.strip()))

print(f"TODO/FIXME count in backend: {len(todos)}")
for f, lnum, line in todos[:20]:
    print(f"{f}:{lnum} -> {line}")
