with open('pristine_kbookstages.txt', encoding='utf-8') as f:
    text = f.read()

import re
stages = re.findall(r"id:\s*'(sound_[a-zğüşöçı]+)'", text)
print('pristine_kbookstages stages:', stages)
