# -*- coding: utf-8 -*-
import re

CUSTOM_MAP = {
    'afacan': '👦', 'afiş': '📜', 'ajan': '🕵️', 'ajanda': '📔', 'ajans': '🏢', 'ajda': '💃',
    'akvaryum': '🐠', 'alerji': '🤧', 'alfabe': '🔤', 'anjiyo': '🏥', 'anonim': '👤', 'arif': '🧑',
    'artı': '➕', 'asansör': '🛗', 'avantaj': '⭐', 'bagaj': '🧳', 'bahane': '🤔', 'bank': '🏦',
    'bej': '🟤', 'ben': '🙋', 'bey': '🤵', 'beş': '5️⃣', 'bidon': '🛢️', 'biç': '✂️',
    'blokaj': '🧱', 'bor': '⛏️', 'borç': '💳', 'boz': '🐻', 'burs': '🎓', 'buruşuk': '📜',
    'bölge': '🗺️', 'bölüm': '📑', 'büfe': '🥪', 'bük': '🪢', 'can': '💖', 'canbaz': '🎪',
    'canlı': '🌱', 'cansız': '🪨', 'caz': '🎷', 'cazibe': '✨', 'celp': '✉️', 'cem': '🧑',
    'cenk': '⚔️', 'cep': '📱', 'cephane': '📦', 'cerrah': '👨‍⚕️', 'cet': '👴', 'ceza': '🛑',
    'cezalı': '🟨', 'cila': '✨', 'cilalı': '✨', 'cilveli': '💃', 'cimcime': '👧', 'cip': '🚙',
    'cop': '🦯', 'coş': '🎉', 'cuma': '🕌', 'cümbüş': '🪕', 'cıvıltı': '🐦', 'cızırtı': '📻',
    'daire': '⭕', 'dakika': '⏱️', 'daktilo': '⌨️', 'danışma': 'ℹ️', 'dar': '🤏', 'davlumbaz': '🍳',
    'debriyaj': '🚗', 'deh': '🐴', 'del': '🕳️', 'delik': '🕳️', 'deney': '🧪', 'ders': '📖',
    'dert': '💭', 'direniş': '✊', 'dost': '🤝', 'dosya': '📁', 'doy': '😋', 'doz': '💊',
    'draje': '💊', 'dublaj': '🎙️', 'dul': '👤', 'dur': '🛑', 'duy': '👂', 'duygu': '❤️',
    'duş': '🚿', 'dök': '🫗', 'dön': '🔄', 'dönemeç': '↪️', 'dönüşçü': '🔄', 'dönüşüm': '♻️',
    'döpiyes': '👗', 'dört': '4️⃣', 'döv': '🥊', 'dün': '⏮️', 'düz': '📏', 'düzey': '📊',
    'düşey': '↕️', 'ejderha': '🐉', 'emzik': '🍼', 'enerji': '⚡', 'eşya': '📦', 'facia': '💥',
    'fakir': '🤲', 'fal': '🔮', 'fantezi': '✨', 'farksız': '🟰', 'farsça': '📜', 'fason': '🧵',
    'fayda': '👍', 'fayton': '🐴', 'fazla': '➕', 'faul': '🚫', 'faşing': '🎭', 'fedai': '🤺',
    'felek': '🌌', 'felsefe': '🤔', 'fen': '🔬', 'fenol': '🧪', 'ferah': '🍃', 'ferman': '📜',
    'feyiz': '✨', 'figür': '🗿', 'fikir': '💡', 'filiz': '🌱', 'filo': '🚢', 'fizik': '⚛️',
    'flama': '🚩', 'flaş': '📸', 'flurya': '🐦', 'fobi': '😨', 'folyo': '🥈', 'fon': '💰',
    'forma': '👕', 'formül': '🧪', 'fosil': '🦴', 'fuar': '🎪', 'fular': '🧣', 'fule': '🏃',
    'füze': '🚀', 'fıkra': '😄', 'fırfır': '🎀', 'fıstık': '🥜', 'fıçı': '🛢️', 'garaj': '🚗',
    'gayda': '🎷', 'gece': '🌃', 'gel': '👋', 'gelin': '👰', 'gem': '🐴', 'gen': '🧬',
    'geniş': '↔️', 'gezi': '🧳', 'gider': '💸', 'gir': '🚪', 'giriş': '🚪', 'gişe': '🎟️',
    'gong': '🛎️', 'gonk': '🛎️', 'grafik': '📊', 'gram': '⚖️', 'grev': '🛑', 'grup': '👥',
    'güç': '💪', 'gün': '☀️', 'günah': '🚫', 'güneşli': '☀️', 'güreşçi': '🤼', 'güven': '🛡️',
    'güzel': '✨', 'güzellik': '🌺', 'hafıza': '🧠', 'hak': '⚖️', 'hali': '🛋️', 'halk': '👥',
    'ham': '🍏', 'hamur': '🥟', 'han': '🏰', 'harf': '🔤', 'has': '⭐', 'hava': '💨',
    'hayat': '🌱', 'hayal': '💭', 'hayır': '❌', 'haz': '😊', 'hazine': '🪙', 'hiddet': '😡',
    'hisse': '📈', 'hobi': '🎨', 'hoca': '🧑‍🏫', 'hoş': '🌸', 'hukuk': '⚖️', 'huni': '🌪️',
    'huzur': '🕊️', 'hücum': '⚔️', 'hüküm': '👨‍⚖️', 'hür': '🕊️', 'hüzün': '😢', 'hız': '⚡',
    'hızlı': '🚀', 'ilaç': '💊', 'ilçe': '🏘️', 'inci': '🦪', 'iplik': '🧵', 'iri': '🐘',
    'ispat': '🔎', 'itfaiye': '🚒', 'iyi': '👍', 'iyilik': '💖', 'iz': '👣', 'izin': '📄',
    'jakuzi': '🛁', 'jale': '👧', 'jambon': '🥓', 'jant': '🛞', 'japon': '🗾', 'jartiyer': '🩱',
    'jarse': '👗', 'jeolog': '🌋', 'jest': '👋', 'jet': '✈️', 'jeton': '🪙', 'jilet': '🪒',
    'jokey': '🏇', 'joker': '🃏', 'judo': '🥋', 'jurnal': '📓', 'jübile': '🎉', 'jüri': '👨‍⚖️',
    'kadro': '👥', 'kafile': '🚶‍♂️', 'kaide': '🏛️', 'kakao': '🍫', 'kalite': '⭐', 'kambur': '🐪',
    'kanıt': '🔎', 'kapsül': '💊', 'karar': '⚖️', 'kare': '⏹️', 'kargo': '📦', 'kasa': '🔐',
    'kask': '🪖', 'kasko': '🛡️', 'katkı': '➕', 'kavram': '💡', 'kazanç': '💰', 'kibar': '🎩',
    'kilo': '⚖️', 'kimya': '🧪', 'kira': '🏠', 'kolej': '🏫', 'komik': '😂', 'konser': '🎤',
    'konu': '📝', 'kor': '🔥', 'kral': '👑', 'kredi': '💳', 'kriz': '⚠️', 'kroki': '🗺️',
    'kulüp': '🏆', 'kum': '🏖️', 'kumaş': '🧵', 'kurul': '👥', 'kutup': '🧊', 'kuzey': '🧭',
    'kültür': '🏛️', 'kür': '🧖', 'küt': '🪵', 'kütle': '⚖️', 'lider': '👑', 'liste': '📋',
    'lojman': '🏢', 'lüks': '💎', 'maç': '⚽', 'maden': '⛏️', 'makale': '📄', 'makam': '🏛️',
    'mali': '💰', 'manevi': '✨', 'mantık': '🧠', 'marş': '🎺', 'masal': '📖', 'maske': '🎭',
    'matematik': '🔢', 'mayıs': '🌸', 'mega': '📢', 'mekan': '📍', 'melodi': '🎶', 'memur': '👔',
    'menü': '📜', 'mesafe': '📏', 'mesaj': '💬', 'meslek': '💼', 'metin': '📄', 'metre': '📏',
    'metot': '📋', 'milli': '🇹🇷', 'milyon': '💰', 'minik': '🐥', 'miras': '🏛️', 'misafir': '🤝',
    'mizah': '😄', 'moda': '👗', 'model': '💃', 'modern': '🏢', 'mor': '🟣', 'mola': '☕',
    'motif': '🎨', 'motor': '🏍️', 'müjde': '🎉', 'müzik': '🎵', 'nakit': '💵', 'nasıl': '❓',
    'nazik': '🌸', 'nefis': '😋', 'neşeli': '😄', 'net': '👓', 'nikah': '💍', 'nisan': '🌧️',
    'nitelik': '⭐', 'nobel': '🏅', 'nokta': '🔘', 'numara': '🔢', 'nöbet': '⏰', 'ocak': '🍳',
    'oda': '🚪', 'ofis': '🏢', 'olağan': '✨', 'olay': '📢', 'olumlu': '✅', 'omuz': '💪',
    'on': '🔟', 'onur': '🏅', 'ordu': '🪖', 'orta': '🎯', 'otel': '🏨', 'otoyol': '🛣️',
    'ödev': '📝', 'ödül': '🏆', 'öfke': '😠', 'öğle': '🕛', 'ölçü': '📐', 'ömür': '⏳',
    'ön': '⏩', 'önem': '❗', 'örnek': '🔍', 'övgü': '👏', 'öz': '💧', 'özel': '⭐',
    'özet': '📋', 'özlem': '💌', 'özür': '🙇', 'paket': '📦', 'pakt': '🤝', 'pano': '📌',
    'parça': '🧩', 'parkur': '🏃', 'pasaj': '🏬', 'patika': '🛤️', 'pay': '🍰', 'pazar': '🛒',
    'pazarlık': '🤝', 'peki': '👌', 'periyot': '🔄', 'piston': '⚙️', 'piyasa': '📈', 'plaj': '🏖️',
    'plan': '📐', 'plaket': '🏆', 'posta': '📮', 'potansiyel': '⚡', 'poz': '📸', 'profil': '👤',
    'proje': '📁', 'prova': '🎭', 'puan': '💯', 'radar': '📡', 'radyo': '📻', 'rapor': '📄',
    'rekor': '🏆', 'renk': '🎨', 'resmi': '🏛️', 'ritim': '🥁', 'rol': '🎭', 'roman': '📖',
    'rota': '🧭', 'rütbe': '⭐', 'sabır': '🧘', 'saha': '⚽', 'sahne': '🎭', 'sahte': '🎭',
    'salı': '📅', 'sanat': '🎨', 'saniye': '⏱️', 'sayfa': '📄', 'sayı': '🔢', 'saygı': '🙇',
    'seans': '🎬', 'sebep': '❓', 'sefer': '🚢', 'sektör': '🏭', 'sembol': '🔣', 'sene': '📅',
    'servet': '💰', 'ses': '🔊', 'sezon': '🍂', 'sıra': '🪑', 'sır': '🤫', 'sınav': '📝',
    'sınıf': '🏫', 'sınır': '🚧', 'sıfır': '0️⃣', 'site': '🏘️', 'slogan': '📢', 'sohbet': '💬',
    'son': '🏁', 'soru': '❓', 'sorun': '⚠️', 'sosyal': '👥', 'söz': '💬', 'sözlük': '📖',
    'spor': '🏅', 'standart': '📏', 'stres': '😫', 'stüdyo': '🎙️', 'süre': '⏳', 'sürat': '🏎️',
    'sürpriz': '🎁', 'şaka': '😄', 'şampiyon': '🏆', 'şans': '🍀', 'şarj': '🔋', 'şart': '📝',
    'şebeke': '🌐', 'şehir': '🏙️', 'şekil': '🔷', 'şerit': '🎗️', 'şikayet': '🗣️', 'şöhret': '🌟',
    'şu': '👉', 'şube': '🏦', 'şüphe': '🤨', 'taban': '🦶', 'tabaka': '📑', 'tabir': '💬',
    'tahmin': '🎯', 'taktik': '♟️', 'talep': '🙋', 'tanım': '📖', 'tarih': '📅', 'tarif': '📋',
    'tasarım': '📐', 'tatil': '🏖️', 'tavır': '😎', 'tebrik': '🎉', 'tecrübe': '🧙', 'tedavi': '💉',
    'teklif': '🤝', 'tekrar': '🔁', 'temas': '🤝', 'temel': '🧱', 'tempo': '⏱️', 'teori': '💭',
    'tercih': '👉', 'tesis': '🏭', 'teşekkür': '🙏', 'tiyatro': '🎭', 'tören': '🎖️', 'trafik': '🚦',
    'tüm': '🌐', 'tür': '🏷️', 'uç': '✏️', 'ufuk': '🌅', 'ulaşım': '🚌', 'ulus': '🇹🇷',
    'umut': '🌱', 'unvan': '🏷️', 'usta': '🔨', 'uyarı': '⚠️', 'uyum': '🧩', 'ücret': '💵',
    'üç': '3️⃣', 'ümit': '🌱', 'ün': '🌟', 'ünite': '📦', 'üniversite': '🎓', 'üretim': '🏭',
    'ürün': '📦', 'üst': '🔝', 'üye': '👤', 'vaat': '🤝', 'vakit': '⏰', 'var': '✔️',
    'varlık': '💎', 'vatan': '🇹🇷', 'vefa': '🤝', 'vergi': '🧾', 'veri': '📊', 'vesile': '🌟',
    'vicdan': '💖', 'video': '🎥', 'viraj': '↪️', 'vitrin': '🛍️', 'vurgu': '🗣️', 'vücut': '🧍',
    'yalan': '🤥', 'yalnız': '🚶', 'yan': '👉', 'yangın': '🔥', 'yankı': '🗣️', 'yarar': '👍',
    'yardım': '🤝', 'yarı': '🌗', 'yarın': '⏭️', 'yarış': '🏎️', 'yasak': '🚫', 'yaş': '🎂',
    'yaşam': '🌱', 'yayın': '📡', 'yazar': '✍️', 'yedek': '🔄', 'yeni': '✨', 'yer': '🌍',
    'yeşil': '🟢', 'yetenek': '🌟', 'yıl': '📅', 'yoğun': '⏳', 'yok': '❌', 'yön': '🧭',
    'yöntem': '📋', 'yüksek': '⛰️', 'yüz': '💯', 'zafer': '✌️', 'zaman': '⏰', 'zarar': '📉',
    'zeki': '🧠', 'zemin': '🪵', 'zengin': '💰', 'zirve': '🏔️', 'zor': '🏋️', 'züccaciye': '🍽️'
}

with open('mobile/lib/utils/word_pictogram_helper.dart', 'r', encoding='utf-8') as f:
    orig = f.read()

existing_keys = set(re.findall(r"['\"]([\wığüşöçİĞÜŞÖÇ]+)['\"]\s*:\s*", orig))

dict_end_pos = orig.find('  };\n\n  static String getPictogram')
if dict_end_pos == -1:
    dict_end_pos = orig.find('  };\r\n\r\n  static String getPictogram')

if dict_end_pos != -1:
    add_lines = ["\n    // ── KELİME DAĞARCIĞI VE TÜRKÇE KAVRAMLAR ──"]
    added_count = 0
    for k, v in sorted(CUSTOM_MAP.items()):
        if k not in existing_keys and len(k) > 1:
            add_lines.append(f"    '{k}': '{v}',")
            added_count += 1
            existing_keys.add(k)
    new_content = orig[:dict_end_pos] + "\n".join(add_lines) + "\n" + orig[dict_end_pos:]
    with open('mobile/lib/utils/word_pictogram_helper.dart', 'w', encoding='utf-8') as f:
        f.write(new_content)
    print(f"Added {added_count} words to word_pictogram_helper.dart!")
else:
    print("Could not find dict position")
