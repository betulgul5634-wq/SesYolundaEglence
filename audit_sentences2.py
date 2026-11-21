import re

with open('turkish_wordlist.txt', 'r', encoding='utf-8') as f:
    valid_words = set(line.strip().split('/')[0].strip().replace('I', 'ı').replace('İ', 'i').lower() for line in f if line.strip())

with open('tr_50k.txt', 'r', encoding='utf-8') as f:
    for line in f:
        parts = line.strip().split()
        if parts:
            valid_words.add(parts[0].strip().replace('I', 'ı').replace('İ', 'i').lower())

with open('mobile/lib/data/sound_groups_data.dart', 'r', encoding='utf-8') as f:
    dart_text = f.read()

stages = re.findall(r"SoundStage\((.*?)\n  \),", dart_text, re.DOTALL)

with open('audit_report.txt', 'w', encoding='utf-8') as out:
    for s in stages:
        ph = re.search(r"phoneme:\s*'([^']+)'", s).group(1)
        out.write(f"\n==================== STAGE {ph} ====================\n")
        
        phrases_m = re.search(r"phrases:\s*\[(.*?)\]", s, re.DOTALL)
        sentences_m = re.search(r"sentences:\s*\[(.*?)\]", s, re.DOTALL)
        
        def parse_list(match):
            if not match: return []
            items = re.findall(r"'((?:[^'\\]|\\.)*)'", match.group(1))
            return [i.replace("\\'", "'") for i in items]
            
        phrases = parse_list(phrases_m)
        sentences = parse_list(sentences_m)
        
        for item in phrases + sentences:
            words = re.findall(r"[a-zA-ZçğıöşüÇĞİÖŞÜ]+", item)
            bad_in_line = []
            for w in words:
                clean = w.replace('I', 'ı').replace('İ', 'i').lower()
                if len(clean) <= 1:
                    continue
                if clean not in valid_words:
                    bad_in_line.append(w)
            if bad_in_line:
                out.write(f"  Item: {item}\n")
                out.write(f"    -> Typos: {bad_in_line}\n")

print("Audit completed successfully! Check audit_report.txt.")
