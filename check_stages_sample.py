import sys
sys.stdout.reconfigure(encoding='utf-8')

with open('all_text.txt', 'r', encoding='utf-8') as f:
    text = f.read()

# Let's inspect stages 7 to 15 which often have most OCR errors
for target in ['f', 'v', 's', 'z', 'ş', 'j', 'h', 'ç', 'c']:
    start = text.find(f"=== STAGE ")
    # Find specific stage
    marker = f"/{target}/"
    pos = text.find(marker)
    if pos != -1:
        # find next stage or end
        next_pos = text.find("==================== STAGE", pos + len(marker))
        if next_pos == -1:
            stage_chunk = text[pos - 25:]
        else:
            stage_chunk = text[pos - 25:next_pos]
        print(f"\n******************* STAGE /{target}/ *******************")
        print(stage_chunk[:1500])
