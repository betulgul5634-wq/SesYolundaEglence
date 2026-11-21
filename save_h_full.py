import sys
sys.stdout.reconfigure(encoding='utf-8')

with open('mobile/lib/data/sound_groups_data.dart', 'r', encoding='utf-8') as f:
    text = f.read()

m = text.find("id: 'sound_h'")
end = text.find("SoundStage(", m + 20)
h_block = text[m:end if end != -1 else m+12000]

with open('h_stage_full.txt', 'w', encoding='utf-8') as out:
    out.write(h_block)
print("Saved h_stage_full.txt")
