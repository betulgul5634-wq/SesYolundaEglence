with open('recovered.txt', encoding='utf-8') as f:
    text = f.read()

import re
stages = re.findall(r'id:\s*[\"\\\']+(sound_[a-zğüşöçı]+)', text)
print('Stages in recovered.txt:', stages)
