# -*- coding: utf-8 -*-
"""
Field-aware word replacements for 100% position and syllable compliance.
"""

WORD_SPELLING_MAP = {
    'fistik': 'Fıstık',
    'fisek': 'Fişek',
    'fuze': 'Füze',
    'tufek': 'Tüfek',
    'findik': 'Fındık',
    'cicek': 'Çiçek',
    'cilek': 'Çilek',
    'curuk': 'Çürük',
    'bahce': 'Bahçe',
    'tebesir': 'Tebeşir',
    'carsaf': 'Çarşaf',
    'sofor': 'Şoför',
    'kadayif': 'Kadayıf',
    'kizilay': 'Kızılay',
    'sayistay': 'Sayıştay',
    'danistay': 'Danıştay',
    'temizz': 'Temiz',
    'baroskop': 'Mikroskop',
    'knilcim': 'Kıvılcım',
    'eldnen': 'Eldiven',
    'lacnert': 'Lacivert',
    'anoz': 'Kavanoz',
    'cigkofte': 'Çiğ köfte',
    'pîr': 'Pir',
    'hoscakal': 'Hoşça kal',
    'ellibes': 'Elli beş',
    'otuzbes': 'Otuz beş',
    'yetmisbes': 'Yetmişlik',
    'sirine': 'Şirin',
    'innin': 'Engin',
    'ud': 'Ud',
    'kaf': 'Saf',
}

def get_field_aware_replacement(w, stage_id, field_name):
    wl = w.lower()
    
    # Stage /p/
    if stage_id == 'sound_p':
        if w == 'Baroskop':
            return 'Mikroskop'

    # Stage /b/
    if stage_id == 'sound_b':
        if w == 'Harap' and field_name in ('wordsBeginning', 'words2Syllables'):
            return 'Balık'

    # Stage /t/
    if stage_id == 'sound_t':
        if w == 'Limonata' and field_name == 'words3Syllables':
            return 'Salata'

    # Stage /g/
    if stage_id == 'sound_g':
        if w == 'Arkeolog' and field_name == 'words3Syllables':
            return 'Katalog'

    # Stage /f/
    if stage_id == 'sound_f':
        if w == 'Kaf':
            return 'Saf'
        if w == 'Lokomotif' and field_name == 'words3Syllables':
            return 'Paragraf'
        if w == 'Maalesef' and field_name == 'words3Syllables':
            return 'İtiraf'

    # Stage /v/
    if stage_id == 'sound_v':
        if w in ('Tun', 'Tün'):
            return 'Van' if field_name == 'wordsBeginning' else 'Tav'
        if w == 'Alet':
            return 'Valiz' if field_name in ('wordsBeginning', 'words2Syllables') else 'Tava'
        if w in ('Knilcim', 'Kıvılcım'):
            return 'Vurgun' if field_name in ('wordsBeginning', 'words2Syllables') else 'Kıvılcım'
        if w in ('Eldnen', 'Eldiven'):
            return 'Varlık' if field_name in ('wordsBeginning', 'words2Syllables') else 'Eldiven'
        if w in ('Lacnert', 'Lacivert'):
            return 'Vurucu' if field_name == 'wordsBeginning' else ('Vurgu' if field_name == 'words2Syllables' else 'Lacivert')
        if w in ('Anoz', 'Kavanoz'):
            return 'Vasiyet' if field_name == 'wordsBeginning' else ('Vagon' if field_name == 'words2Syllables' else 'Kavanoz')

    # Stage /s/
    if stage_id == 'sound_s':
        if field_name == 'wordsBeginning':
            rep = {'Şen': 'Sen', 'Şok': 'Son', 'Baş': 'Söz', 'Kuş': 'Saç', 'Şiş': 'Sis', 'Taş': 'Sır', 'Yaş': 'Süt',
                   'Bas': 'Söz', 'Kas': 'Saç', 'Tas': 'Sır', 'Yas': 'Süt'}
            if w in rep: return rep[w]
        if field_name == 'wordsEnding':
            rep = {'Baş': 'Bas', 'Kuş': 'Kas', 'Şiş': 'Sis', 'Taş': 'Tas', 'Yaş': 'Yas', 'Saç': 'Kas'}
            if w in rep: return rep[w]
        if field_name == 'words1Syllable':
            rep = {'Şen': 'Sen', 'Şok': 'Son', 'Baş': 'Bas', 'Kuş': 'Kas', 'Şiş': 'Sis', 'Taş': 'Tas', 'Yaş': 'Yas',
                   'Saç': 'Kas'}
            if w in rep: return rep[w]

    # Stage /z/
    if stage_id == 'sound_z':
        if w == 'Kizilay': return 'Kızılay'
        if w == 'Sayistay': return 'Sayıştay'

    # Stage /ş/
    if stage_id == 'sound_ş':
        if field_name == 'wordsBeginning':
            rep = {'İns': 'Şan', 'Ka': 'Şut', 'Ye': 'Şal', 'Sil': 'Şen', 'Aş': 'Şan', 'Kış': 'Şut', 'Yaş': 'Şal',
                   'Ellibes': 'Şeftali', 'Otuzbes': 'Şampiyon', 'Yetmisbes': 'Şömine', 'Sirine': 'Şempanze',
                   'Menekşe': 'Şeftali', 'Güneşlik': 'Şampiyon'}
            if w in rep: return rep[w]
        if field_name == 'wordsMiddle':
            if w in ('Şeftali', 'Ellibes', 'Sirine'):
                return 'Kaşık'
        if field_name == 'wordsEnding':
            rep = {'Şal': 'Kış', 'Şut': 'Taş', 'Ka': 'Kış', 'Ye': 'Yaş', 'Sil': 'Baş'}
            if w in rep: return rep[w]
        if field_name == 'words1Syllable':
            rep = {'İns': 'Şan', 'Ka': 'Kış', 'Ye': 'Yaş', 'Sil': 'Şen', 'Şal': 'Şan', 'Şut': 'Taş'}
            if w in rep: return rep[w]
        if field_name == 'words3Syllables':
            rep = {'Ellibes': 'Şeftali', 'Otuzbes': 'Şampiyon', 'Yetmisbes': 'Şömine', 'Sirine': 'Şempanze'}
            if w in rep: return rep[w]

    # Stage /j/
    if stage_id == 'sound_j':
        if field_name == 'wordsMiddle':
            if w in ('Orijinal', 'Jimnastik'): return 'Pijama'
            if w in ('Sosyoloji', 'Kamuflaj'): return 'Ajanda'
        if field_name == 'wordsEnding':
            if w in ('Orijinal', 'Jimnastik'): return 'Kamuflaj'
            if w in ('Sosyoloji', 'Pijama'): return 'Kolej'
        if field_name == 'words3Syllables':
            if w == 'Orijinal': return 'Pijama'
            if w == 'Sosyoloji': return 'Ajanda'

    # Stage /h/
    if stage_id == 'sound_h':
        if field_name == 'wordsBeginning':
            if w in ('Civan', 'Livan', 'Hoscakal', 'Kahkaha', 'Hamsi'): return 'Halı'
        if field_name == 'words3Syllables':
            if w in ('Hoscakal', 'Hamsi'): return 'Kahkaha'
        if field_name == 'wordsEnding':
            if w == 'Bah': return 'Şah'

    # Stage /ç/
    if stage_id == 'sound_ç':
        if field_name == 'wordsBeginning':
            rep = {'Ving': 'Çay', 'Hing': 'Çöl', 'Ding': 'Çit', 'Tung': 'Çöp', 'Cigkofte': 'Çekirdek'}
            if w in rep: return rep[w]
        if field_name == 'words1Syllable':
            rep = {'Ving': 'Çay', 'Hing': 'Çöl', 'Ding': 'Çit', 'Tung': 'Çöp'}
            if w in rep: return rep[w]
        if field_name == 'words3Syllables':
            if w == 'Cigkofte': return 'Çekirdek'

    # Stage /c/
    if stage_id == 'sound_c':
        if w == 'Çam': return 'Cam'
        if w == 'Çan': return 'Can'

    # Stage /m/
    if stage_id == 'sound_m':
        if field_name == 'wordsBeginning':
            rep = {'Aç': 'Mum', 'Yağ': 'Muz', 'Mur': 'Mor', 'Ke': 'Maç', 'Mik': 'Meyve'}
            if w in rep: return rep[w]
        if field_name == 'words1Syllable':
            rep = {'Aç': 'Mum', 'Yağ': 'Muz', 'Mur': 'Mor', 'Ke': 'Maç', 'Mik': 'Mum', 'Meyve': 'Mum', 'Mal': 'Mum'}
            if w in rep: return rep[w]
        if field_name == 'words2Syllables':
            rep = {'Temizz': 'Temiz', 'Mik': 'Meyve', 'Mal': 'Meyve'}
            if w in rep: return rep[w]

    # Stage /n/
    if stage_id == 'sound_n':
        if w == 'İnnin': return 'Engin'

    # Stage /y/
    if stage_id == 'sound_y':
        if w == 'Mid': return 'Yay'
        if w == 'Yetmisbes': return 'Yetmişlik'
        if w == 'Sayistay': return 'Sayıştay'

    # Default spelling map
    if wl in WORD_SPELLING_MAP:
        return WORD_SPELLING_MAP[wl]

    return w
