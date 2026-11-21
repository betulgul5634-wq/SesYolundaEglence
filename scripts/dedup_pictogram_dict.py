import re

with open('mobile/lib/utils/word_pictogram_helper.dart', 'r', encoding='utf-8') as f:
    text = f.read()

# Match everything between 'static final Map<String, String> _dict = {' and '  };'
start_marker = "static final Map<String, String> _dict = {"
end_marker = "  };\n\n  static String getPictogram"
if end_marker not in text:
    end_marker = "  };\r\n\r\n  static String getPictogram"

s_idx = text.find(start_marker)
e_idx = text.find(end_marker)

dict_body = text[s_idx + len(start_marker) : e_idx]

entries = re.findall(r"['\"]([^'\"]+)['\"]\s*:\s*['\"]([^'\"]+)['\"]", dict_body)

clean_dict = {}
for k, v in entries:
    norm_k = k.strip().lower().replace('\u0307', '')
    if norm_k not in clean_dict or (clean_dict[norm_k] in ['🐴', '🔪'] and v not in ['🐴', '🔪']):
        clean_dict[norm_k] = v

print(f"Total unique normalized keys: {len(clean_dict)}")

new_dict_lines = []
for k in sorted(clean_dict.keys()):
    new_dict_lines.append(f"    '{k}': '{clean_dict[k]}',")

new_body = "\n" + "\n".join(new_dict_lines) + "\n"

new_text = text[:s_idx + len(start_marker)] + new_body + text[e_idx:]

with open('mobile/lib/utils/word_pictogram_helper.dart', 'w', encoding='utf-8') as f:
    f.write(new_text)

print("Saved deduplicated dictionary to mobile/lib/utils/word_pictogram_helper.dart!")
