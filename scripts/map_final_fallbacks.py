# -*- coding: utf-8 -*-
import re

FINAL_FALLBACK_MAP = {
    'erciyes': '🏔️', 'eskici': '🛒', 'esnaf': '🏪', 'eşsiz': '💎', 'fan': '🪭', 'fanila': '🎽',
    'fas': '🇲🇦', 'faz': '⚡', 'felaket': '💥', 'fiş': '🔌', 'fol': '🥚', 'form': '📄',
    'fosforlu': '✨', 'fırıldak': '🪁', 'fıskiye': '⛲', 'gaf': '🤦', 'gam': '😢', 'gaz': '⛽',
    'gereksiz': '🗑️', 'gez': '🚶', 'giy': '👕', 'giyecek': '👗', 'giz': '🤫', 'göç': '🧳',
    'göçebe': '⛺', 'güm': '💥', 'gümüş': '🥈', 'gür': '🌳', 'gürültü': '📢', 'güz': '🍂',
    'güzergah': '🛣️', 'had': '📏', 'hafif': '🪶', 'hal': '🍏', 'har': '🔥', 'hareket': '🏃',
    'harika': '✨', 'harp': '⚔️', 'harç': '🧱', 'haç': '➕', 'hece': '🔤', 'hedef': '🎯',
    'hep': '♾️', 'her': '🌐', 'hey': '👋', 'hiciv': '🎭', 'hidrojen': '🫧', 'his': '❤️',
    'hit': '🎵', 'hizmetçi': '🧹', 'hiç': '0️⃣', 'hol': '🚪', 'homojen': '🥣', 'hostes': '👩‍✈️',
    'hurç': '🧳', 'huy': '😊', 'ihlamur': '🍵', 'islak': '💦', 'işık': '💡',
    'iblik': '🐔', 'i̇bik': '🐔', 'icat': '💡', 'i̇cat': '💡', 'ihtiyaç': '🛒', 'i̇htiyaç': '🛒',
    'ilah': '✨', 'i̇lah': '✨', 'ilaç': '💊', 'i̇laç': '💊', 'imaj': '📸', 'i̇maj': '📸',
    'inci': '🦪', 'i̇nci': '🦪', 'incir': '🫐', 'i̇ncir': '🫐', 'inşallah': '🙏', 'i̇nşallah': '🙏',
    'itiraf': '🗣️', 'i̇tiraf': '🗣️', 'izci': '🏕️', 'i̇zci': '🏕️', 'iç': '🥤', 'i̇ç': '🥤',
    'içecek': '🧃', 'i̇çecek': '🧃', 'işaret': '👉', 'i̇şaret': '👉',
    'jaluzi': '🪟', 'janjan': '✨', 'jargon': '💬', 'jel': '🧴', 'jelibon': '🍬', 'jikle': '🚗',
    'jile': '👗', 'jöle': '🍮', 'jön': '🤵', 'jüpon': '👗', 'kabzımal': '🥕', 'kadife': '🧶',
    'kafiye': '🎶', 'kaktüs': '🌵', 'kamuflaj': '🪖', 'kamış': '🎋', 'kaç': '🏃', 'keş': '🌿',
    'keşif': '🔭', 'keşmekeş': '🌀', 'kof': '💨', 'konsolos': '🏛️', 'konvoy': '🚗', 'kucak': '🫂',
    'kulaç': '🏊', 'kullanım': '📱', 'kuvvetli': '💪', 'kör': '🙈', 'körebe': '🙈', 'köy': '🏡',
    'küf': '🍄', 'küs': '😤', 'küvet': '🛁', 'küçük': '🤏', 'kıl': '🪮', 'kılıf': '📱',
    'kılıç': '⚔️', 'kıs': '🔉', 'lacivert': '🔷', 'lades': '🦴', 'laf': '💬', 'lakap': '🏷️',
    'lal': '🔴', 'lastik': '🛞', 'lastikçi': '🛞', 'laz': '⚓', 'lazım': '❗', 'lazımlık': '🚽',
    'leke': '🧼', 'lenf': '🩸', 'lens': '👁️', 'lezzet': '😋', 'lezzetli': '😋', 'leş': '🦴',
    'lig': '⚽', 'lise': '🏫', 'liseli': '🧑‍🎓', 'lodos': '💨', 'lokma': '🍩', 'loş': '💡',
    'löp': '🍖', 'lübnanlı': '🇱🇧', 'lüle': '🪙', 'lüzumlu': '❗', 'majör': '🎵', 'makyaj': '💄',
    'mal': '📦', 'mango': '🥭', 'manken': '💃', 'manto': '🧥', 'mantı': '🥟', 'manzara': '🏞️',
    'marangoz': '🪚', 'mars': '🪐', 'mavi': '🔵', 'maşallah': '🧿', 'melek': '👼', 'meraklı': '🧐',
    'merasim': '🎖️', 'mercimek': '🍲', 'mert': '🦸', 'meç': '🗡️', 'meşale': '🔥', 'mide': '🫄',
    'mil': '⚙️', 'mim': '🎭', 'mis': '🌸', 'misk': '🌺', 'misket': '🔮', 'monolog': '🗣️',
    'muş': '🇹🇷', 'müdavim': '☕', 'mükemmel': '💯', 'mülk': '🏠', 'mıh': '🔨', 'mızıkçı': '😤',
    'nabız': '💓', 'nadide': '💎', 'nakliye': '🚚', 'nam': '⭐', 'naz': '💁‍♀️', 'nazar': '🧿',
    'neden': '❓', 'nem': '💧', 'nergis': '🌼', 'ney': '🪈', 'nezle': '🤧', 'neşe': '😄',
    'nihale': '🍳', 'nijerya': '🇳🇬', 'nil': '🏞️', 'niyet': '🎯', 'nişan': '💍', 'nişasta': '🍚',
    'normal': '👍', 'nostaljik': '📻', 'nuh': '🚢', 'nur': '✨', 'nüfus': '👥', 'obje': '📦',
    'objektif': '📷', 'oje': '💅', 'oksijen': '🫧', 'omurga': '🦴', 'onsekiz': '1️⃣8️⃣', 'org': '🎹',
    'padissah': '👑', 'padişah': '👑', 'pansiyon': '🏨', 'pantomim': '🎭', 'peh': '😏', 'pelvis': '🦴',
    'perspektif': '🔭', 'peyzaj': '🌳', 'piş': '🍳', 'püf': '💨', 'raf': '🪜', 'rahibe': '⛪',
    'rakam': '🔢', 'raket': '🎾', 'rakip': '🤼', 'rakipsiz': '🏆', 'ranza': '🛏️', 'rast': '🎲',
    'rehber': '🧭', 'rejim': '🥗', 'rekabet': '🏁', 'rest': '🛑', 'ret': '❌', 'rezene': '🌿',
    'rezerv': '🏨', 'reçete': '📝', 'rica': '🙏', 'risk': '⚠️', 'roka': '🥗', 'ruh': '👻',
    'ruj': '💄', 'rum': '🏛️', 'rus': '🇷🇺', 'rutubet': '💧', 'saf': '⚪', 'sahici': '💯',
    'saman': '🌾', 'sandık': '📦', 'sap': '🌱', 'sapan': '🎯', 'sav': '🛡️', 'sedef': '🦪',
    'sekiz': '8️⃣', 'sel': '🌊', 'semaver': '🫖', 'sen': '👉', 'seç': '🗳️', 'sihir': '🪄',
    'sim': '✨', 'sivilce': '🩹', 'siyah': '⚫', 'siz': '👥', 'sol': '⬅️', 'solfej': '🎼',
    'sor': '❓', 'soy': '🌳', 'staj': '💼', 'sörf': '🏄', 'sünger': '🧽', 'sık': '🤏',
    'tahıl': '🌾', 'takvim': '📅', 'talih': '🍀', 'taraf': '👥', 'tarafsız': '⚖️', 'tarz': '🕶️',
    'tebessüm': '🙂', 'teessüf': '😔', 'tembih': '☝️', 'temiz': '🧼', 'temizlik': '🧹', 'tesadüf': '🎲',
    'tim': '🪖', 'tiz': '📢', 'ton': '⚖️', 'tos': '💥', 'toy': '🐣', 'tuhaf': '🤨',
    'tüh': '🤦', 'tüketim': '🛒', 'tüy': '🪶', 'ucuz': '🏷️', 'ud': '🪕', 'uzuv': '🧍',
    'vah': '😢', 'vahşi': '🐅', 'vale': '🤵', 'valide': '👩', 'van': '🐱', 'vana': '🚰',
    'vanilya': '🧁', 'vasiyet': '📜', 'vasıflı': '⭐', 'vasıta': '🚗', 'vazife': '💼', 'vaziyet': '📍',
    'vazo': '🏺', 'veda': '👋', 'veli': '👨‍👩‍👦', 'ver': '🤲', 'vesvese': '💭', 'vezir': '♟️',
    'virane': '🏚️', 'vur': '🔨', 'vurucu': '🎯', 'vız': '🐝', 'vızıltı': '🐝', 'yabancı': '👤',
    'yabani': '🐺', 'yahni': '🍲', 'yargıç': '👨‍⚖️', 'yavaş': '🐢', 'yetmişlik': '👴', 'yiv': '🔩',
    'yiyecek': '🥪', 'yoga': '🧘', 'yonca': '🍀', 'yufka': '🥟', 'yulaf': '🥣', 'yum': '🙈',
    'yumak': '🧶', 'yumuşak': '🧸', 'yörünge': '🪐', 'yık': '💥', 'yıkama': '🧼', 'yıkıcı': '🔨',
    'yığ': '📦', 'zabıta': '👮', 'zam': '📈', 'zamir': '🏷️', 'zamk': '🧴', 'zar': '🎲',
    'zerafet': '🪞', 'zerk': '💉', 'zeybek': '🕺', 'zift': '🛣️', 'zonguldak': '⛏️', 'zoolog': '🦁',
    'zıpzıp': '🦘', 'zırh': '🛡️', 'çak': '💥', 'çakı': '🔪', 'çavuş': '🪖', 'çim': '🌱',
    'çiğ': '💧', 'çok': '➕', 'çuval': '🥔', 'çöl': '🏜️', 'çözüm': '💡', 'çık': '🚪',
    'çıngırak': '🔔', 'örf': '📜', 'örgü': '🧶', 'üvey': '👤', 'şad': '😊', 'şah': '👑',
    'şahit': '🗣️', 'şaklaban': '🤡', 'şal': '🧣', 'şalgam': '🥤', 'şan': '⭐', 'şaş': '😲',
    'şef': '👨‍🍳', 'şeffaf': '🪟', 'şen': '😄', 'şeref': '🎖️', 'şerefe': '🥂', 'şerif': '🤠',
    'şişman': '🫄', 'şok': '⚡', 'şom': '🦅', 'şov': '🎪', 'şık': '✨'
}

with open('mobile/lib/utils/word_pictogram_helper.dart', 'r', encoding='utf-8') as f:
    orig = f.read()

existing_keys = set(re.findall(r"['\"]([\wığüşöçİĞÜŞÖÇ]+)['\"]\s*:\s*", orig))

dict_end_pos = orig.find('  };\n\n  static String getPictogram')
if dict_end_pos == -1:
    dict_end_pos = orig.find('  };\r\n\r\n  static String getPictogram')

if dict_end_pos != -1:
    add_lines = ["\n    // ── TÜM HEDEF KELİMELER İÇİN ÖZEL PİKTOGRAMLAR (100% KAPSAMA) ──"]
    added_count = 0
    for k, v in sorted(FINAL_FALLBACK_MAP.items()):
        if k not in existing_keys and len(k) > 1:
            add_lines.append(f"    '{k}': '{v}',")
            added_count += 1
            existing_keys.add(k)
    new_content = orig[:dict_end_pos] + "\n".join(add_lines) + "\n" + orig[dict_end_pos:]
    with open('mobile/lib/utils/word_pictogram_helper.dart', 'w', encoding='utf-8') as f:
        f.write(new_content)
    print(f"Added {added_count} words to word_pictogram_helper.dart!")
