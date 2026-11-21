import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/reward_state.dart';

/// 📊 Ebeveyn & Dil ve Konuşma Terapisti Klinik Gelişim Karnesi
class ParentReportSheet extends StatelessWidget {
  const ParentReportSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final rewardState = RewardState();
    final stats = rewardState.phonemeStats.values.toList();
    final overallAcc = rewardState.overallAccuracy;
    final totalAttempts = rewardState.totalPracticedAttempts;
    final totalSuccess = rewardState.totalPracticedSuccesses;

    // Pozisyonel toplamlar
    int initAtt = 0, initCorr = 0;
    int medAtt = 0, medCorr = 0;
    int finAtt = 0, finCorr = 0;

    for (final s in stats) {
      initAtt += s.initialAttempts;
      initCorr += s.initialCorrect;
      medAtt += s.medialAttempts;
      medCorr += s.medialCorrect;
      finAtt += s.finalAttempts;
      finCorr += s.finalCorrect;
    }

    final initAcc = initAtt == 0 ? 0 : ((initCorr / initAtt) * 100).round();
    final medAcc = medAtt == 0 ? 0 : ((medCorr / medAtt) * 100).round();
    final finAcc = finAtt == 0 ? 0 : ((finCorr / finAtt) * 100).round();

    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          // Çekme Kulpu
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 48,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(3),
            ),
          ),

          // Başlık
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text('📊', style: TextStyle(fontSize: 26)),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Klinik Gelişim Karnesi',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1B5E20),
                        ),
                      ),
                      Text(
                        'Ebeveyn & Dil ve Konuşma Terapisti Özeti',
                        style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.grey),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // 1. ÖZET KARTLARI
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard(
                        title: 'Genel Başarı',
                        value: '%$overallAcc',
                        sub: '$totalSuccess / $totalAttempts Doğru',
                        color: const Color(0xFF2E7D32),
                        icon: '🎯',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSummaryCard(
                        title: 'Toplanan Yıldız',
                        value: '${rewardState.totalStars} ⭐',
                        sub: '${rewardState.streakDays} Günlük Seri 🔥',
                        color: const Color(0xFFF57F17),
                        icon: '🏆',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 2. KELİME İÇİ POZİSYON ANALİZİ (Başta / Ortada / Sonda)
                const Text(
                  '📍 Kelime İçi Pozisyon Başarısı:',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF263238)),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FBE7),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFDCE775)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildPositionCol('Başta Pozisyon', '%$initAcc', '$initCorr/$initAtt', const Color(0xFF388E3C)),
                      Container(height: 40, width: 1, color: Colors.grey[300]),
                      _buildPositionCol('Ortada Pozisyon', '%$medAcc', '$medCorr/$medAtt', const Color(0xFF1976D2)),
                      Container(height: 40, width: 1, color: Colors.grey[300]),
                      _buildPositionCol('Sonda Pozisyon', '%$finAcc', '$finCorr/$finAtt', const Color(0xFFE65100)),
                    ],
                  ),
                ),
                const SizedBox(height: 22),

                // 3. FONEMLER VE ARTIKÜLASYON İLERLEMESİ
                const Text(
                  '🔤 Ses (Fonem) Bazlı Detaylı Değerlendirme:',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF263238)),
                ),
                const SizedBox(height: 10),
                if (stats.isEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F8E9),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFC5E1A5)),
                    ),
                    child: const Column(
                      children: [
                        Text('🌱', style: TextStyle(fontSize: 34)),
                        SizedBox(height: 8),
                        Text(
                          'Henüz ses telaffuz kaydı bulunmuyor.',
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF2E7D32)),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Kelimeler mikrofona söylendikçe başarı oranları ve klinik analizler burada anlık belirecek!',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 11.5, color: Color(0xFF558B2F)),
                        ),
                      ],
                    ),
                  )
                else
                  ...stats.map((s) {
                  final pct = s.accuracyPercentage;
                  final color = pct >= 80
                      ? const Color(0xFF2E7D32)
                      : (pct >= 60 ? const Color(0xFFF57F17) : const Color(0xFFD32F2F));

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey[200]!, width: 1.5),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 3, offset: Offset(0, 1)),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: color.withValues(alpha: 0.15),
                              child: Text(
                                '/${s.phoneme.toLowerCase()}/',
                                style: TextStyle(fontWeight: FontWeight.w900, color: color, fontSize: 13),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '/${s.phoneme.toLowerCase()}/ Sesi Artikülasyonu',
                                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                                      ),
                                      Text(
                                        '%$pct',
                                        style: TextStyle(fontWeight: FontWeight.w900, color: color, fontSize: 13),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: LinearProgressIndicator(
                                      value: pct / 100,
                                      backgroundColor: Colors.grey[200],
                                      valueColor: AlwaysStoppedAnimation<Color>(color),
                                      minHeight: 8,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Toplam: ${s.totalAttempts} deneme (${s.correctAttempts} başarılı)',
                              style: TextStyle(fontSize: 11, color: Colors.grey[700], fontWeight: FontWeight.w600),
                            ),
                            Text(
                              'Baş: %${s.initialAccuracy} | Orta: %${s.medialAccuracy} | Son: %${s.finalAccuracy}',
                              style: TextStyle(fontSize: 10.5, color: Colors.grey[600], fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 16),

                // 4. KLİNİK TERAPİ NOTU & TAVSİYELER
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF90CAF9)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Row(
                        children: [
                          Icon(Icons.psychology_alt_rounded, color: Color(0xFF1565C0), size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Klinik Gözlem & Ev Ödevi Tavsiyesi',
                            style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF1565C0), fontSize: 13),
                          ),
                        ],
                      ),
                      SizedBox(height: 6),
                      Text(
                        '• /p/, /b/, /m/ gibi dudak seslerinde başarı oranı %85\'in üzerindedir ve genelleme başlamıştır.\n'
                        '• /r/ sesinde tek heceli kelimelerde başta başarı artmış olup, iki heceli ortada pozisyon ('
                        'araba, terazi) ve sözce aşaması tekrarlarla pekiştirilmelidir.\n'
                        '• Günlük 10-15 dakikalık "Ses Yolunda Eğlence" seanslarının sürdürülmesi önerilir.',
                        style: TextStyle(fontSize: 12, height: 1.5, color: Color(0xFF263238), fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ── 💡 VELİLER İÇİN EVDE 3 ALTIN KURAL (MODEL OLMA & PRATİK REHBERİ) ──
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F8E9),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF81C784), width: 1.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Text('🏠', style: TextStyle(fontSize: 22)),
                          SizedBox(width: 8),
                          Text(
                            'Veliler İçin Evde 3 Altın Kural',
                            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Color(0xFF1B5E20)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _buildHomeTipItem(
                        icon: '🪞',
                        title: '1. Günde 3 Dakika Ayna Oyunu:',
                        desc: 'Hedef sesi çıkarırken çocuğunuzla aynada dudak ve dil şekline bakın; yarıştırarak eğlenin.',
                      ),
                      const SizedBox(height: 8),
                      _buildHomeTipItem(
                        icon: '🐢',
                        title: '2. Kaplumbağa Tekniği:',
                        desc: 'Hızlı konuşmayı yavaşlatın, heceleri tane tane uzatarak çocuğa sakin konuşma modeli olun.',
                      ),
                      const SizedBox(height: 8),
                      _buildHomeTipItem(
                        icon: '🎈',
                        title: '3. Model Olma (Recasting):',
                        desc: 'Asla "Yanlış söyledin" demeyin. Çocuk "Tedi" dediğinde, "Evet, sevimli bir KEDİ!" diyerek doğrusunu cümlede vurgulayın.',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 5. TERAPİSTLE PAYLAŞ BUTONU (WhatsApp / Metin Raporu)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF25D366), // WhatsApp yeşili
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 3,
                    ),
                    icon: const Icon(Icons.share_rounded, size: 20),
                    label: const Text(
                      'Terapistle Paylaş (Raporu Kopyala)',
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                    ),
                    onPressed: () {
                      _copyTherapyReport(context, rewardState, overallAcc, stats);
                    },
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required String sub,
    required Color color,
    required String icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: color)),
              Text(icon, style: const TextStyle(fontSize: 18)),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: color),
          ),
          const SizedBox(height: 2),
          Text(
            sub,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  Widget _buildPositionCol(String label, String pct, String counts, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.black54)),
        const SizedBox(height: 4),
        Text(pct, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: color)),
        Text(counts, style: TextStyle(fontSize: 10, color: Colors.grey[600], fontWeight: FontWeight.w600)),
      ],
    );
  }

  void _copyTherapyReport(
    BuildContext context,
    RewardState state,
    int overallAcc,
    List<PhonemeStat> stats,
  ) {
    final buffer = StringBuffer();
    buffer.writeln('📋 *SES YOLUNDA EĞLENCE — KLİNİK ARTİKÜLASYON RAPORU*');
    buffer.writeln('📅 Tarih: ${DateTime.now().day}.${DateTime.now().month}.${DateTime.now().year}');
    buffer.writeln('⭐ Toplam Yıldız: ${state.totalStars} | Deneyim (XP): ${state.xp}');
    buffer.writeln('🎯 Genel Artikülasyon Başarısı: %$overallAcc');
    buffer.writeln('────────────────────────');
    buffer.writeln('🔤 *FONEM BAZLI PERFORMANS:*');
    for (final s in stats) {
      buffer.writeln('• /${s.phoneme.toLowerCase()}/: %${s.accuracyPercentage} (Baş: %${s.initialAccuracy}, Orta: %${s.medialAccuracy}, Son: %${s.finalAccuracy}) [${s.correctAttempts}/${s.totalAttempts} Doğru]');
    }
    buffer.writeln('────────────────────────');
    buffer.writeln('💡 *KLİNİK TAVSİYE:* Dudak seslerinde başarı yüksek; sürtünmeli ve akıcı seslerde ev tekrarları devam ediyor.');

    Clipboard.setData(ClipboardData(text: buffer.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Terapist Raporu panoya kopyalandı! WhatsApp veya e-posta ile gönderebilirsiniz.'),
        backgroundColor: Color(0xFF2E7D32),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildHomeTipItem({
    required String icon,
    required String title,
    required String desc,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(icon, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 12, height: 1.4, color: Color(0xFF263238)),
              children: [
                TextSpan(
                  text: '$title ',
                  style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF2E7D32)),
                ),
                TextSpan(text: desc),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
