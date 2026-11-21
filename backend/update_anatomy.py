with open('mobile/lib/widgets/mouth_anatomy_widget.dart', 'r', encoding='utf-8') as f:
    text = f.read()

# 1. Step detection for K
old_step = """        } else if (cleanP == 'K') {
          if (v < 0.37) {
            step = 0; // 1. Adım: Ağzı Aç & Dili Kaldır (0.0 - 9.2 sn)
          } else if (v < 0.62) {
            step = 1; // 2. Adım: Boğazda Havayı Tut (9.2 - 15.5 sn)
          } else {
            step = 2; // 3. Adım: Gak Gak Karga Gibi Patlat: K! (15.5 - 24.95 sn)
          }
        }"""

new_step = """        } else if (cleanP == 'K') {
          if (v < 0.36) {
            step = 0; // 1. Adım: Dil Ucu Aşağıda (0.0 - 10.2 sn)
          } else if (v < 0.66) {
            step = 1; // 2. Adım: Dil Arkası Damağa Basılı (10.2 - 18.6 sn)
          } else {
            step = 2; // 3. Adım: Boğazdan Patlat: Kıkır Kıkır! K! (18.6 - 28.3 sn)
          }
        }"""

# 2. Seek target seconds for K
old_seek = """      } else if (cleanP == 'K') {
        if (step == 0) targetSec = 0.1;
        if (step == 1) targetSec = 9.2;
        if (step == 2) targetSec = 15.5;
      }"""

new_seek = """      } else if (cleanP == 'K') {
        if (step == 0) targetSec = 0.1;
        if (step == 1) targetSec = 10.2;
        if (step == 2) targetSec = 18.7;
      }"""

# 3. Titles & Subtitles
old_title = "'🦅 Gak Gak Karga Oyunu (K Sesi)'"
new_title = "'😄 Kıkır Kıkır K Sesi Rehberi'"

old_sub = "'Ağzını aç, dil arkasını damağa yapıştır ve karga gibi gakla! 🦅💥'"
new_sub = "'Dilinin ucunu aşağıda tut, arkasını damağa bas ve boğazından patlat: K! 💥'"

# 4. Step pills
old_pill1 = "'1. Ağzı Aç & Dili Bas 👄'"
new_pill1 = "'1. Dili Aşağı Sakla 👅'"

old_pill2 = "'2. Boğazda Tut 🤫'"
new_pill2 = "'2. Arkasını Damağa Bas 🤫'"

old_pill3 = '\'3. "Gak Gak! K!" 🦅\''
new_pill3 = '\'3. "K! K! K!" Patlat 💥\''

# 5. Step Titles
old_st = """    if (cleanP == 'K') {
      if (step == 0) return '1. Adım: Ağzını Kocaman Aç & Dilin Arkasını Kaldır 👄';
      if (step == 1) return '2. Adım: Nefesini Boğazında Sakla, Sessizce Bekle 🤫';
      return '3. Adım: Karga Gibi Boğazından Patlat: Gak! K! 🦅💥';
    }"""

new_st = """    if (cleanP == 'K') {
      if (step == 0) return '1. Adım: Dilinin Ucunu Aşağıya Sakla 👅';
      if (step == 1) return '2. Adım: Dilinin Arkasını Damağa Yapıştır 🤫';
      return '3. Adım: Boğazından Neşeyle Patlat: K! K! K! 💥';
    }"""

# 6. Step Narrations
old_sn = """    if (cleanP == 'K') {
      if (step == 0) {
        return 'Ağzını kocaman aç! Dilinin ucunu aşağıda tut, arkasını yukarı kaldırıp damağa sımsıkı yapıştır!';
      }
      if (step == 1) {
        return 'Nefesini boğazında sakla! Dilinin arkası havayı sımsıkı tutsun, hiç ses çıkarmadan sessizce bekle!';
      }
      return 'Dilini birden bırak ve karga gibi havayı boğazından patlat: Gak gak! Kıkır kıkır! K! K!';
    }"""

new_sn = """    if (cleanP == 'K') {
      if (step == 0) {
        return 'Ağzını rahatça aç. Dilinin ucunu alt ön dişlerinin arkasında, en aşağıda tut. Dil ucunu sakın yukarı kaldırma!';
      }
      if (step == 1) {
        return 'Dilinin arkasını yukarı kaldırıp yumuşak damağına sımsıkı bas! Havayı boğazında tut ve sessizce bekle!';
      }
      return 'Dilini birden aşağı bırak ve boğazındaki havayı neşeyle dışarı patlat: Kıkır kıkır! K! K! K!';
    }"""

# 7. Badges
old_b1 = "text: '🦅 Dil Arkası Damağa Basılı',"
new_b1 = "text: '👅 Dil Arkası Damağa Basılı',"

old_b2 = 'text: \'🦅💥 "Gak! K!" Patlaması!\','
new_b2 = 'text: \'💥 "Kıkır Kıkır! K!" Patlaması!\','

replacements = [
    (old_step, new_step, 'step'),
    (old_seek, new_seek, 'seek'),
    (old_title, new_title, 'title'),
    (old_sub, new_sub, 'sub'),
    (old_pill1, new_pill1, 'pill1'),
    (old_pill2, new_pill2, 'pill2'),
    (old_pill3, new_pill3, 'pill3'),
    (old_st, new_st, 'st'),
    (old_sn, new_sn, 'sn'),
    (old_b1, new_b1, 'b1'),
    (old_b2, new_b2, 'b2'),
]

for o, n, desc in replacements:
    o_crlf = o.replace('\r\n', '\n').replace('\n', '\r\n')
    n_crlf = n.replace('\r\n', '\n').replace('\n', '\r\n')
    if o_crlf in text:
        text = text.replace(o_crlf, n_crlf)
        print(f'Replaced {desc}')
    elif o in text:
        text = text.replace(o, n)
        print(f'Replaced {desc} (LF)')
    else:
        print(f'FAILED to find {desc}')

with open('mobile/lib/widgets/mouth_anatomy_widget.dart', 'w', encoding='utf-8') as f:
    f.write(text)
print('Done!')
