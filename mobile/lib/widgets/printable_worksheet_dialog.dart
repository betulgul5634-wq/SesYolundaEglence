import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;
// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:js' as js;
import '../models/reward_state.dart';
import '../models/sound_group.dart';
import '../data/sound_groups_data.dart';
import '../utils/word_pictogram_helper.dart';
import '../services/sound_effects_service.dart';

/// 🖨️ KAPSAMLI YAZDIRILABİLİR KLİNİK ÇALIŞMA VE BOYAMA FORMU (TÜM SESLER)
/// "Heceden Hikayeye Konuşma Sesi Bozuklukları Terapi Alıştırma Kitabı" klinik hiyerarşisine dayalı
/// tam kapsamlı ev ödevi ve klinik takip formu:
/// 1. Harf Takibi & Yazım Kılavuzu
/// 2. Ağız/Dil Anatomik Konumlandırma Rehberi
/// 3. Hece Merdiveni (Açık, Kapalı, Çift Heceler)
/// 4. Başta, Ortada ve Sonda Kelime Tablosu (3'er Tekrar Kutucuklu)
/// 5. İkili Sözceler (Sözcük Öbekleri)
/// 6. Hedef Sesli Terapi Cümleleri
/// 7. Terapi Hikayesi / Tekerlemesi
/// 8. 7 Günlük Haftalık Ev Ödevi Takip Tablosu & Terapist/Veli İmza Alanı
class PrintableWorksheetDialog extends StatefulWidget {
  final String phoneme;
  final String soundTitle;
  final List<String>? words;

  const PrintableWorksheetDialog({
    super.key,
    required this.phoneme,
    required this.soundTitle,
    this.words,
  });

  @override
  State<PrintableWorksheetDialog> createState() => _PrintableWorksheetDialogState();
}

class _PrintableWorksheetDialogState extends State<PrintableWorksheetDialog> {
  late String _selectedSound;
  final SoundEffectsService _sfx = SoundEffectsService();

  static const List<String> kAllSounds = [
    'P', 'B', 'T', 'D', 'K', 'G', 'F', 'V', 'S', 'Z',
    'Ş', 'J', 'H', 'Ç', 'C', 'M', 'N', 'L', 'R', 'Y'
  ];

  @override
  void initState() {
    super.initState();
    final clean = widget.phoneme.replaceAll('/', '').trim().toUpperCase();
    _selectedSound = kAllSounds.contains(clean) ? clean : 'P';
  }

  SoundStage get _currentStage {
    return kBookStages.firstWhere(
      (s) => s.soundLetter.toUpperCase() == _selectedSound.toUpperCase(),
      orElse: () => kBookStages.first,
    );
  }

  void _triggerPrint(BuildContext context) {
    _sfx.playSuccessDing();

    final stage = _currentStage;
    final studentName = RewardState().studentName.trim().isNotEmpty
        ? RewardState().studentName.trim()
        : '__________________';
    final dateStr = '${DateTime.now().day.toString().padLeft(2, '0')}.${DateTime.now().month.toString().padLeft(2, '0')}.${DateTime.now().year}';

    final htmlContent = _generateWorksheetHtml(stage, studentName, dateStr);

    if (kIsWeb) {
      try {
        final blob = html.Blob([htmlContent], 'text/html;charset=utf-8');
        final url = html.Url.createObjectUrlFromBlob(blob);
        html.window.open(url, '_blank');
      } catch (e) {
        debugPrint('Yazdırma penceresi hatası: $e');
        try {
          js.context.callMethod('print');
        } catch (_) {}
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('📄 Detaylı çalışma formu hazırlandı!'),
          backgroundColor: Color(0xFF2E7D32),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final stage = _currentStage;
    final sound = stage.soundLetter;
    final syllables = stage.content.syllables.take(8).toList();
    final reverseSyllables = stage.content.syllables.length > 8
        ? stage.content.syllables.sublist(8).take(8).toList()
        : ['A$sound', 'E$sound', 'I$sound', 'İ$sound', 'O$sound', 'Ö$sound', 'U$sound', 'Ü$sound'];

    final wordsBeginning = stage.content.wordsBeginning.take(6).toList();
    final wordsMiddle = stage.content.wordsMiddle.take(6).toList();
    final wordsEnd = stage.content.wordsEnding.take(6).toList();
    final wordPairs = stage.content.phrases.take(4).toList();
    final sentences = stage.content.sentences.take(4).toList();
    final storyTitle = stage.content.storyTitle;
    final storyText = stage.content.storyContent;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 720, maxHeight: 860),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: const Color(0xFF0288D1), width: 3),
          boxShadow: const [
            BoxShadow(color: Colors.black38, blurRadius: 24, offset: Offset(0, 10)),
          ],
        ),
        child: Column(
          children: [
            // ÜST BAŞLIK BARI
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: const BoxDecoration(
                color: Color(0xFF0288D1),
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Row(
                children: [
                  const Text('🖨️', style: TextStyle(fontSize: 26)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Klinik Artikülasyon Ev Ödevi & Terapi Formu',
                          style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w900),
                        ),
                        Text(
                          'Klinik Artikülasyon Hiyerarşisi • [${stage.phoneme}] ${stage.categoryTitle}',
                          style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // SES SEÇİM YATAY ŞERİDİ (20 Ses)
            Container(
              color: const Color(0xFF01579B),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              child: Row(
                children: [
                  const Text('Ses Seç:', style: TextStyle(color: Colors.white70, fontSize: 11.5, fontWeight: FontWeight.w800)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SizedBox(
                      height: 32,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: kAllSounds.length,
                        itemBuilder: (ctx, idx) {
                          final s = kAllSounds[idx];
                          final isSel = s == _selectedSound;
                          return GestureDetector(
                            onTap: () {
                              setState(() => _selectedSound = s);
                              _sfx.playPopSound();
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.only(right: 6),
                              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 4),
                              decoration: BoxDecoration(
                                color: isSel ? Colors.white : Colors.white.withAlpha(50),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSel ? Colors.amberAccent : Colors.white30,
                                  width: isSel ? 2 : 1,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  s,
                                  style: TextStyle(
                                    color: isSel ? const Color(0xFF01579B) : Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // A4 KAĞIDI DETAYLI ÖNİZLEME SAHNESİ
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.black26, width: 1.5),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Başlık & Öğrenci Bilgisi
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'SES YOLUNDA EĞLENCE • KLİNİK TERAPİ ÖDEVİ',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Colors.grey[800]),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Konu: [${stage.phoneme}] Sesi Artikülasyon & Fonoloji Ev Çalışması',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.blueGrey),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE1F5FE),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFF0288D1), width: 1.5),
                            ),
                            child: Text(
                              '${stage.phoneme} SESİ',
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFF0288D1)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDottedField(
                              'Öğrenci: ${RewardState().studentName.trim().isNotEmpty ? RewardState().studentName : '__________________'}',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildDottedField(
                              'Tarih: ${DateTime.now().day.toString().padLeft(2, '0')}.${DateTime.now().month.toString().padLeft(2, '0')}.${DateTime.now().year}',
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 18, thickness: 1.5),

                      // BÖLÜM 1: Ağız ve Dil Pozisyonu Rehberi
                      _buildSectionHeader('1. BÖLÜM: Ağız ve Dil Nasıl Konumlandırılmalı? 👄', const Color(0xFF00897B)),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0F2F1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF80CBC4)),
                        ),
                        child: Text(
                          stage.articulationHint,
                          style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFF004D40), height: 1.4),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // BÖLÜM 2: Harf Çizgi Takibi (Tracing)
                      _buildSectionHeader('2. BÖLÜM: Harf Yazım ve Çizgi Kılavuzu ✍️', const Color(0xFF5E35B1)),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEDE7F6),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFD1C4E9)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(sound, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.black87)),
                            Text(sound, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.grey[400])),
                            Text(sound, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.grey[300])),
                            Container(width: 1.5, height: 26, color: Colors.grey[400]),
                            Text(sound.toLowerCase(), style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.black87)),
                            Text(sound.toLowerCase(), style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.grey[400])),
                            Text(sound.toLowerCase(), style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.grey[300])),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // BÖLÜM 3: Hece Merdiveni
                      _buildSectionHeader('3. BÖLÜM: Hece Merdiveni (Açık & Kapalı Heceler) 🪜', const Color(0xFFF57F17)),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFDE7),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFFFF59D)),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: syllables.map((s) => _buildSyllableBox(s)).toList(),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: reverseSyllables.map((s) => _buildSyllableBox(s)).toList(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // BÖLÜM 4: Pozisyona Göre Sınıflandırılmış Sözcükler (Başta, Ortada, Sonda)
                      _buildSectionHeader('4. BÖLÜM: Pozisyona Göre Kelimeler & 3 Tekrar Kutucuğu 🎯', const Color(0xFFD81B60)),
                      Text(
                        '💡 Her kelimeyi 3 kez seslendirip yanındaki kutucukları (🔲) boyayınız.',
                        style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Colors.grey[700]),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildWordColumn('🟢 BAŞTA', wordsBeginning, const Color(0xFFE8F5E9), const Color(0xFF4CAF50)),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildWordColumn('🟡 ORTADA', wordsMiddle, const Color(0xFFFFF8E1), const Color(0xFFFFA000)),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildWordColumn('🔴 SONDA', wordsEnd, const Color(0xFFFFEBEE), const Color(0xFFE53935)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // BÖLÜM 5: İkili Sözceler (Sözcük Öbekleri)
                      if (wordPairs.isNotEmpty) ...[
                        _buildSectionHeader('5. BÖLÜM: İkili Sözceler (Sözcük Öbekleri) 💬', const Color(0xFF3949AB)),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8EAF6),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFC5CAE9)),
                          ),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: wordPairs.map((p) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFF9FA8DA)),
                              ),
                              child: Text(
                                '• $p  [ 🔲 🔲 ]',
                                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: Color(0xFF1A237E)),
                              ),
                            )).toList(),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],

                      // BÖLÜM 6: Terapi Cümleleri
                      if (sentences.isNotEmpty) ...[
                        _buildSectionHeader('6. BÖLÜM: Terapi Cümleleri (Vurgulayarak Oku) 📝', const Color(0xFFE65100)),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF3E0),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFFFCC80)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: sentences.map((sent) => Padding(
                              padding: const EdgeInsets.only(bottom: 5),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('⭐', style: TextStyle(fontSize: 12)),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      '$sent  [ 🔲 🔲 ]',
                                      style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF424242)),
                                    ),
                                  ),
                                ],
                              ),
                            )).toList(),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],

                      // BÖLÜM 7: Terapi Hikayesi
                      if (storyText.isNotEmpty) ...[
                        _buildSectionHeader('7. BÖLÜM: Terapi Hikayesi & Sesli Okuma Parçası 📖', const Color(0xFF0277BD)),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE1F5FE),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF81D4FA)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                storyTitle,
                                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Color(0xFF01579B)),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                storyText,
                                style: const TextStyle(fontSize: 10.5, height: 1.4, fontWeight: FontWeight.w600, color: Color(0xFF263238)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],

                      // BÖLÜM 8: 7 Günlük Haftalık Ev Ödevi Takip Çizelgesi
                      _buildSectionHeader('8. BÖLÜM: 7 Günlük Ev Egzersizi Takip Çizelgesi 📅', const Color(0xFF2E7D32)),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFA5D6A7)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: const [
                            _WeeklyDayBox(day: 'Pzt'),
                            _WeeklyDayBox(day: 'Sal'),
                            _WeeklyDayBox(day: 'Çar'),
                            _WeeklyDayBox(day: 'Per'),
                            _WeeklyDayBox(day: 'Cum'),
                            _WeeklyDayBox(day: 'Cmt'),
                            _WeeklyDayBox(day: 'Paz'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Terapist & Veli Klinik İmza Alanı
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[400]!),
                        ),
                        child: Row(
                          children: [
                            const Text('📋', style: TextStyle(fontSize: 22)),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Klinik Öneri: Günlük düzenli egzersiz yapılması ve hedef sesin doğal konuşmada pekiştirilmesi önerilir.',
                                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 10.5, color: Color(0xFF2E7D32)),
                                  ),
                                  Text(
                                    'Dudak/dil temasında zorlanma olursa aynadan yardım alınız.',
                                    style: TextStyle(fontSize: 10, color: Color(0xFF555555)),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[400]!),
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.white,
                              ),
                              child: const Text('Veli İmzası\n____/____', textAlign: TextAlign.center, style: TextStyle(fontSize: 9, color: Colors.grey)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ALT AKSİYON BARI (YAZDIR / PDF)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: const BoxDecoration(
                color: Color(0xFFECEFF1),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0288D1),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 3,
                      ),
                      icon: const Icon(Icons.print_rounded, size: 22),
                      label: Text(
                        '/${stage.soundLetter}/ DETAYLI FORMUNU YAZDIR / PDF İNDİR 🖨️',
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                      ),
                      onPressed: () => _triggerPrint(context),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: color),
      ),
    );
  }

  Widget _buildDottedField(String label) {
    return Text(
      label,
      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: Colors.black87),
    );
  }

  Widget _buildSyllableBox(String syl) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFFBC02D)),
      ),
      child: Text(
        syl,
        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11.5, color: Color(0xFFF57F17)),
      ),
    );
  }

  Widget _buildWordColumn(String title, List<String> words, Color bg, Color border) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border.withAlpha(120)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(title, style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900, color: border)),
          ),
          const SizedBox(height: 4),
          ...words.map((w) {
            final emoji = WordPictogramHelper.getPictogram(w);
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.5),
              child: Row(
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 13)),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      w,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.black87),
                    ),
                  ),
                  const Text('🔲🔲🔲', style: TextStyle(fontSize: 8)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  /// Yazdırma ve PDF için saf, vektörel A4 HTML şablonu üretir
  String _generateWorksheetHtml(SoundStage stage, String studentName, String dateStr) {
    final sound = stage.soundLetter;
    final syllables = stage.content.syllables.take(8).toList();
    final reverseSyllables = stage.content.syllables.length > 8
        ? stage.content.syllables.sublist(8).take(8).toList()
        : ['A$sound', 'E$sound', 'I$sound', 'İ$sound', 'O$sound', 'Ö$sound', 'U$sound', 'Ü$sound'];

    final wordsBeginning = stage.content.wordsBeginning.take(6).toList();
    final wordsMiddle = stage.content.wordsMiddle.take(6).toList();
    final wordsEnd = stage.content.wordsEnding.take(6).toList();
    final wordPairs = stage.content.phrases.take(4).toList();
    final sentences = stage.content.sentences.take(4).toList();
    final storyTitle = stage.content.storyTitle;
    final storyText = stage.content.storyContent;

    return '''
<!DOCTYPE html>
<html lang="tr">
<head>
  <meta charset="utf-8">
  <title>Ses Yolunda Eğlence - [/${stage.soundLetter}/] Sesi Klinik Terapi Ödevi</title>
  <style>
    @page {
      size: A4;
      margin: 10mm 12mm;
    }
    body {
      font-family: 'Segoe UI', Arial, sans-serif;
      color: #1a1a1a;
      margin: 0;
      padding: 0;
      font-size: 10pt;
      line-height: 1.35;
    }
    .header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      border-bottom: 2px solid #0288D1;
      padding-bottom: 6px;
      margin-bottom: 8px;
    }
    .header h1 {
      margin: 0;
      font-size: 14pt;
      color: #01579B;
    }
    .badge {
      background: #E1F5FE;
      color: #0288D1;
      border: 1.5px solid #0288D1;
      padding: 4px 10px;
      border-radius: 8px;
      font-weight: bold;
      font-size: 13pt;
    }
    .info-bar {
      display: flex;
      justify-content: space-between;
      font-size: 9.5pt;
      margin-bottom: 8px;
      color: #333;
    }
    .section-title {
      background: #f0f4f8;
      border-left: 4px solid #0288D1;
      padding: 3px 6px;
      font-weight: bold;
      font-size: 10pt;
      margin-top: 8px;
      margin-bottom: 4px;
    }
    .box {
      border: 1px solid #ddd;
      border-radius: 6px;
      padding: 6px;
      margin-bottom: 6px;
      background: #fff;
    }
    .syllable-row {
      display: flex;
      justify-content: space-around;
      margin: 3px 0;
    }
    .syl-pill {
      border: 1px solid #ccc;
      padding: 2px 8px;
      border-radius: 4px;
      font-weight: bold;
    }
    .word-grid {
      display: flex;
      gap: 8px;
    }
    .word-col {
      flex: 1;
      border: 1px solid #ccc;
      border-radius: 6px;
      padding: 5px;
      background: #fafafa;
    }
    .word-col h4 {
      margin: 0 0 4px 0;
      text-align: center;
      font-size: 9pt;
      border-bottom: 1px solid #ddd;
      padding-bottom: 2px;
    }
    .word-item {
      display: flex;
      justify-content: space-between;
      padding: 1.5px 0;
      font-size: 9pt;
    }
    .checkboxes {
      letter-spacing: 2px;
      font-size: 8pt;
    }
    .table-weekly {
      width: 100%;
      border-collapse: collapse;
      text-align: center;
      margin-top: 4px;
      font-size: 8.5pt;
    }
    .table-weekly th, .table-weekly td {
      border: 1px solid #bbb;
      padding: 4px;
    }
    .table-weekly th {
      background: #E8F5E9;
    }
    .footer-note {
      display: flex;
      justify-content: space-between;
      align-items: center;
      border: 1px dashed #999;
      padding: 6px;
      border-radius: 6px;
      margin-top: 8px;
      font-size: 8.5pt;
      background: #fafafa;
    }
  </style>
</head>
<body>
  <div class="header">
    <div>
      <h1>SES YOLUNDA EĞLENCE • KLİNİK TERAPİ FORMU</h1>
      <small style="color: #666;">Klinik Artikülasyon Hiyerarşisi | ${stage.phoneme} ${stage.categoryTitle}</small>
    </div>
    <div class="badge">${stage.phoneme} SESİ</div>
  </div>

  <div class="info-bar">
    <div><strong>Öğrenci Adı:</strong> $studentName</div>
    <div><strong>Tarih:</strong> $dateStr</div>
    <div><strong>Hedef Fonem:</strong> /${stage.soundLetter}/</div>
  </div>

  <div class="section-title">1. Ağız ve Dil Nasıl Konumlandırılmalı? (Anatomi Rehberi)</div>
  <div class="box" style="background: #E0F2F1; border-color: #80CBC4;">
    <strong>Yönerge:</strong> ${stage.articulationHint}
  </div>

  <div class="section-title">2. Harf Yazım ve Çizgi Kılavuzu</div>
  <div class="box" style="text-align: center; font-size: 16pt; letter-spacing: 12px; font-weight: bold; color: #444;">
    $sound &nbsp; <span style="color:#aaa;">$sound</span> &nbsp; <span style="color:#ddd;">$sound</span> &nbsp;&nbsp;|&nbsp;&nbsp;
    ${sound.toLowerCase()} &nbsp; <span style="color:#aaa;">${sound.toLowerCase()}</span> &nbsp; <span style="color:#ddd;">${sound.toLowerCase()}</span>
  </div>

  <div class="section-title">3. Hece Merdiveni (Açık ve Kapalı Heceler)</div>
  <div class="box">
    <div class="syllable-row">
      ${syllables.map((s) => '<span class="syl-pill">$s</span>').join(' ')}
    </div>
    <div class="syllable-row">
      ${reverseSyllables.map((s) => '<span class="syl-pill">$s</span>').join(' ')}
    </div>
  </div>

  <div class="section-title">4. Pozisyona Göre Kelimeler & 3 Tekrar Kutucuğu (Her kelimeyi 3 kez seslendirip kutucuğu işaretleyin)</div>
  <div class="word-grid">
    <div class="word-col">
      <h4 style="color: #2E7D32;">🟢 BAŞTA</h4>
      ${wordsBeginning.map((w) => '<div class="word-item"><span>${WordPictogramHelper.getPictogram(w)} $w</span><span class="checkboxes">[ ] [ ] [ ]</span></div>').join('')}
    </div>
    <div class="word-col">
      <h4 style="color: #F57F17;">🟡 ORTADA</h4>
      ${wordsMiddle.map((w) => '<div class="word-item"><span>${WordPictogramHelper.getPictogram(w)} $w</span><span class="checkboxes">[ ] [ ] [ ]</span></div>').join('')}
    </div>
    <div class="word-col">
      <h4 style="color: #C62828;">🔴 SONDA</h4>
      ${wordsEnd.map((w) => '<div class="word-item"><span>${WordPictogramHelper.getPictogram(w)} $w</span><span class="checkboxes">[ ] [ ] [ ]</span></div>').join('')}
    </div>
  </div>

  <div class="section-title">5. İkili Sözceler & Terapi Cümleleri</div>
  <div class="box">
    <div style="margin-bottom: 4px;"><strong>Sözceler:</strong> ${wordPairs.map((p) => '$p [   ]').join(' &nbsp;•&nbsp; ')}</div>
    <div><strong>Cümleler:</strong></div>
    ${sentences.map((s) => '<div style="margin: 2px 0;">• $s <span style="float:right;">[   ] [   ]</span></div>').join('')}
  </div>

  <div class="section-title">6. Terapi Hikayesi & Okuma Parçası: $storyTitle</div>
  <div class="box" style="font-size: 8.5pt; font-style: italic;">
    $storyText
  </div>

  <div class="section-title">7. Haftalık 7 Günlük Ev Egzersizi Takip Tablosu</div>
  <table class="table-weekly">
    <tr>
      <th>Pazartesi</th><th>Salı</th><th>Çarşamba</th><th>Perşembe</th><th>Cuma</th><th>Cumartesi</th><th>Pazar</th>
    </tr>
    <tr>
      <td>[ ] Tamamlandı<br>⭐⭐⭐⭐⭐<br>İmza: ____</td>
      <td>[ ] Tamamlandı<br>⭐⭐⭐⭐⭐<br>İmza: ____</td>
      <td>[ ] Tamamlandı<br>⭐⭐⭐⭐⭐<br>İmza: ____</td>
      <td>[ ] Tamamlandı<br>⭐⭐⭐⭐⭐<br>İmza: ____</td>
      <td>[ ] Tamamlandı<br>⭐⭐⭐⭐⭐<br>İmza: ____</td>
      <td>[ ] Tamamlandı<br>⭐⭐⭐⭐⭐<br>İmza: ____</td>
      <td>[ ] Tamamlandı<br>⭐⭐⭐⭐⭐<br>İmza: ____</td>
    </tr>
  </table>

  <div class="footer-note">
    <div>
      <strong>Klinik Not:</strong> Günlük düzenli tekrar artikülasyon alışkanlığını pekiştirir. Dudak/dil temasında zorlanma olursa aynadan faydalanınız.
    </div>
    <div style="border-left: 1px solid #ccc; padding-left: 10px; text-align: center; white-space: nowrap;">
      Terapist / Veli İmzası<br>_____ / _____
    </div>
  </div>
  <script>
    window.onload = function() {
      setTimeout(function() {
        window.print();
      }, 500);
    };
  </script>
</body>
</html>
''';
  }
}

class _WeeklyDayBox extends StatelessWidget {
  final String day;
  const _WeeklyDayBox({required this.day});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Text(day, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900, color: Colors.black54)),
          const SizedBox(height: 2),
          const Text('Tekrar [ ]', style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w700, color: Color(0xFF2E7D32))),
          const SizedBox(height: 2),
          const Text('⭐⭐⭐⭐⭐', style: TextStyle(fontSize: 8, color: Colors.black38)),
        ],
      ),
    );
  }
}
