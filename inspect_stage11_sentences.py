import sys
sys.stdout.reconfigure(encoding='utf-8')

with open('all_sentences_detailed.txt', 'r', encoding='utf-8') as f:
    text = f.read()

# Let's inspect stage 11 (/ş/) first in detail
start = text.find("STAGE 11: /ş/")
end = text.find("STAGE 12: /j/")
print(text[start:end])
