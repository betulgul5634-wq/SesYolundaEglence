import sys
sys.stdout.reconfigure(encoding='utf-8')

with open('mobile/lib/data/sound_groups_data.dart', 'r', encoding='utf-8') as f:
    text = f.read()

m = text.find("id: 'sound_l'")
end = text.find("SoundStage(", m + 20)
l_block = text[m:end if end != -1 else m+12000]

with open('l_stage_full.txt', 'w', encoding='utf-8') as out:
    out.write(l_block)
print("Saved l_stage_full.txt, len:", len(l_block))
