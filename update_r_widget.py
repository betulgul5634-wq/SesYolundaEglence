import re

with open('mobile/lib/widgets/mouth_anatomy_widget.dart', 'r', encoding='utf-8') as f:
    text = f.read()

# Normalize CRLF to LF
text = text.replace('\r\n', '\n')

# 1. duration
text = re.sub(
    r"if \(cleanP == 'R'\) return \d+;",
    "if (cleanP == 'R') return 19600; // 19.60 sn canlı R sesi yarış arabası motor oyunu",
    text
)

# 2. step thresholds
old_steps = """        } else if (cleanP == 'R') {
          if (v < 0.35) {
            step = 0; // 1. Adım: Dili Diş Yuvasına Yaklaştır (0.0 - 6.3 sn)
          } else if (v < 0.65) {
            step = 1; // 2. Adım: Motoru Çalıştır & Nefes Gönder (6.3 - 11.8 sn)
          } else {
            step = 2; // 3. Adım: Dil Ucunu Titret: Rrr! (11.8 - 18.2 sn)
          }"""

new_steps = """        } else if (cleanP == 'R') {
          if (v < 0.45) {
            step = 0; // 1. Adım: Dili Diş Yuvasına Yaklaştır (0.0 - 8.8 sn)
          } else if (v < 0.68) {
            step = 1; // 2. Adım: Derin Nefes Üfle (8.8 - 13.3 sn)
          } else {
            step = 2; // 3. Adım: Dil Ucunu Titret: Rrr! (13.3 - 19.6 sn)
          }"""

# 3. targetSec
old_target = """      } else if (cleanP == 'R') {
        if (step == 0) targetSec = 0.1;
        if (step == 1) targetSec = 6.4;
        if (step == 2) targetSec = 12.0;"""

new_target = """      } else if (cleanP == 'R') {
        if (step == 0) targetSec = 0.1;
        if (step == 1) targetSec = 8.9;
        if (step == 2) targetSec = 13.4;"""

# 4. narration
old_narr = """    if (cleanP == 'R') {
      if (step == 0) {
        return 'Ağzını hafifçe arala! Dilinin ucunu üst ön dişlerinin arkasındaki damağa yaklaştır. Yan kısımları üst yan dişlerine yapıştır ama dil ucun serbest kalsın!';
      }
      if (step == 1) {
        return 'Elini boğazına koy, ses tellerini çalıştır! Derin bir nefes al ve havayı dilinin ucuna doğru kuvvetlice üfle: Hımm!';
      }
      return 'Dilinin ucunun rüzgarla bayrak gibi hızla titreşmesine izin ver! Yarış arabasının motoru gibi ses patlat: Rrr! R! R!';
    }"""

new_narr = """    if (cleanP == 'R') {
      if (step == 0) {
        return 'Ağzını hafifçe arala! Dilinin ucunu üst ön dişlerinin arkasındaki damağa yaklaştır. Dil ucun serbest kalsın!';
      }
      if (step == 1) {
        return 'Derin bir nefes al ve havayı dilinin ucuna doğru kuvvetlice üfle!';
      }
      return 'Yarış arabasının motoru gibi dil ucunu neşeyle titret: Rrr! R! R!';
    }"""

# 5. painter thresholds
old_painter = """    } else if (cleanP == 'R') {
      isStep1 = progress < 0.35;
      isStep2 = progress >= 0.35 && progress < 0.65;
      isPlosion = progress >= 0.65;
      if (isStep2) stepProgress = (progress - 0.35) / 0.30;
      if (isPlosion) openFactor = ((progress - 0.65) / 0.35).clamp(0.0, 1.0);"""

new_painter = """    } else if (cleanP == 'R') {
      isStep1 = progress < 0.45;
      isStep2 = progress >= 0.45 && progress < 0.68;
      isPlosion = progress >= 0.68;
      if (isStep2) stepProgress = (progress - 0.45) / 0.23;
      if (isPlosion) openFactor = ((progress - 0.68) / 0.32).clamp(0.0, 1.0);"""

for o, n, name in [
    (old_steps, new_steps, 'steps'),
    (old_target, new_target, 'target'),
    (old_narr, new_narr, 'narr'),
    (old_painter, new_painter, 'painter'),
]:
    assert o in text, f'Failed: {name}'
    text = text.replace(o, n, 1)

with open('mobile/lib/widgets/mouth_anatomy_widget.dart', 'w', encoding='utf-8') as f:
    f.write(text)

print('Successfully updated mouth_anatomy_widget.dart!')
