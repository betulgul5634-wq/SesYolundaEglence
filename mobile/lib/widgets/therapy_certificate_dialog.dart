import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;
// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:js' as js;
import '../models/reward_state.dart';
import '../services/sound_effects_service.dart';

/// 🎓 KLİNİK BAŞARI DİPLOMASI VE TERAPİST SERTİFİKASI
/// Çocuğun bir sesi başardığında gururla ailesine ve terapistine göstereceği resmi sertifika.
/// Artık sadece metin olarak değil, yüksek kaliteli PNG GÖRSELİ olarak indirilebilir ve yazdırılabilir!
class TherapyCertificateDialog extends StatefulWidget {
  final String phoneme;
  final String soundTitle;

  const TherapyCertificateDialog({
    super.key,
    required this.phoneme,
    required this.soundTitle,
  });

  @override
  State<TherapyCertificateDialog> createState() => _TherapyCertificateDialogState();
}

class _TherapyCertificateDialogState extends State<TherapyCertificateDialog> {
  final GlobalKey _certKey = GlobalKey();
  final SoundEffectsService _sfx = SoundEffectsService();

  Future<void> _downloadAsPng(String cleanP) async {
    _sfx.playSuccessDing();
    try {
      final boundary = _certKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;
      final bytes = byteData.buffer.asUint8List();

      if (kIsWeb) {
        final blob = html.Blob([bytes], 'image/png');
        final url = html.Url.createObjectUrlFromBlob(blob);
        html.AnchorElement(href: url)
          ..setAttribute("download", "Basari_Diplomasi_${cleanP}_Sesi.png")
          ..click();
        html.Url.revokeObjectUrl(url);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🎉 Başarı Diploması yüksek çözünürlüklü RESİM (PNG) olarak indirildi!'),
              backgroundColor: Color(0xFF2E7D32),
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Görsel indirilirken hata: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _printCertificate() {
    _sfx.playSuccessDing();
    if (kIsWeb) {
      try {
        js.context.callMethod('print');
      } catch (_) {}
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('📄 Yazdırma penceresi hazır!'),
          backgroundColor: Color(0xFF2E7D32),
        ),
      );
    }
  }

  void _showShareOptions(BuildContext context, String childName, String dateStr, String cleanP) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(4))),
              const SizedBox(height: 14),
              const Text('🎓 DİPLOMAYI PAYLAŞ & KAYDET', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF5D4037))),
              const SizedBox(height: 6),
              const Text('Diplomanızı resim olarak cihazınıza indirebilir veya yazdırabilirsiniz:', style: TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: const Color(0xFFFFE0B2), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.image_rounded, color: Color(0xFFE65100)),
                ),
                title: const Text('Resim (PNG) Olarak İndir 🖼️', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                subtitle: const Text('Renkli diplomayı yüksek kalitede fotoğraf olarak kaydeder'),
                onTap: () {
                  Navigator.pop(ctx);
                  _downloadAsPng(cleanP);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: const Color(0xFFE1F5FE), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.print_rounded, color: Color(0xFF0288D1)),
                ),
                title: const Text('Yazdır / PDF Olarak Kaydet 🖨️', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                subtitle: const Text('Doğrudan yazıcıya gönderin veya PDF olarak saklayın'),
                onTap: () {
                  Navigator.pop(ctx);
                  _printCertificate();
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.copy_rounded, color: Color(0xFF2E7D32)),
                ),
                title: const Text('Tebrik Metnini Kopyala 📋', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                subtitle: const Text('WhatsApp veya SMS için gurur verici başarı metni'),
                onTap: () {
                  Navigator.pop(ctx);
                  final text = '🎓 *SES YOLUNDA EĞLENCE — BAŞARI DİPLOMASI* 🏆\n'
                      'Öğrenci: $childName\n'
                      'Başarılan Ses: ${widget.soundTitle}\n'
                      'Tarih: $dateStr\n'
                      'Klinik Değerlendirme: Tüm basamaklar tam başarıyla tamamlandı!';
                  Clipboard.setData(ClipboardData(text: text));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ Başarı Diploması panoya kopyalandı!'),
                      backgroundColor: Color(0xFF2E7D32),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rewardState = RewardState();
    final childName = rewardState.studentName.trim().isNotEmpty
        ? rewardState.studentName
        : (rewardState.activeCharacterName.trim().isNotEmpty
            ? rewardState.activeCharacterName
            : 'Sevgili Öğrencimiz');
    final cleanP = widget.phoneme.replaceAll('/', '').trim();
    final now = DateTime.now();
    final dateStr = '${now.day}.${now.month}.${now.year}';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      child: Container(
        width: 480,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          gradient: const LinearGradient(
            colors: [Color(0xFFFFFDE7), Color(0xFFFFF9C4), Color(0xFFFFF8E1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: const Color(0xFFFFB300), width: 4),
          boxShadow: const [
            BoxShadow(color: Color(0x33FFB300), blurRadius: 16, offset: Offset(0, 6)),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // GÖRSEL OLARAK YAKALANACAK DİPLOMA KARTI (RepaintBoundary)
              RepaintBoundary(
                key: _certKey,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFDF5),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFFFD54F), width: 2),
                  ),
                  child: Column(
                    children: [
                      // Tepe Mührü ve Akademi Başlığı
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('🏛️', style: TextStyle(fontSize: 28)),
                          Column(
                            children: const [
                              Text(
                                'SES YOLUNDA EĞLENCE AKADEMİSİ',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.5,
                                  color: Color(0xFF5D4037),
                                ),
                              ),
                              Text(
                                'Resmi Dil ve Konuşma Terapisi Başarı Belgesi',
                                style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: Colors.black54),
                              ),
                            ],
                          ),
                          const Text('👑', style: TextStyle(fontSize: 28)),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Büyük Kupa
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
                        ),
                        child: const Text('🏆', style: TextStyle(fontSize: 44)),
                      ),
                      const SizedBox(height: 10),

                      // Sertifika Başlığı
                      const Text(
                        'ÜSTÜN ARTİKÜLASYON DİPLOMASI',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFE65100),
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Takdim Metni
                      const Text(
                        'Bu resmi başarı belgesi, azimle çalışarak ses yolculuğunu fetheden',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87),
                      ),
                      const SizedBox(height: 6),

                      // Çocuğun Adı & Avatarı
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFFFB300), width: 2),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(rewardState.activeAvatar, style: const TextStyle(fontSize: 24)),
                            const SizedBox(width: 8),
                            Text(
                              childName,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF1B5E20)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Başarılan Ses Bilgisi
                      Text(
                        'öğrencimize, "${widget.soundTitle}" ($cleanP Sesi) artikülasyon ve hece-sözce çalışmalarını başarıyla tamamlayıp akıcı konuşma becerisi kazandığı için takdim edilmiştir.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 12, height: 1.5, fontWeight: FontWeight.w600, color: Color(0xFF37474F)),
                      ),
                      const SizedBox(height: 14),

                      // Mühür ve Tarih Satırı
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                const Text('📅 TARİH', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.grey)),
                                const SizedBox(height: 2),
                                Text(dateStr, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.black87)),
                              ],
                            ),
                            Container(height: 30, width: 1, color: Colors.grey[300]),
                            Column(
                              children: [
                                const Text('⭐ YILDIZLAR', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.grey)),
                                const SizedBox(height: 2),
                                const Text('⭐⭐⭐ 3/3', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFFFF8F00))),
                              ],
                            ),
                            Container(height: 30, width: 1, color: Colors.grey[300]),
                            Column(
                              children: [
                                const Text('🎖️ ONAY', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.grey)),
                                const SizedBox(height: 2),
                                const Text('KLİNİK ONAYLI', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFF2E7D32))),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Butonlar: "Resim İndir / Paylaş" ve "Harika!"
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: Color(0xFFE65100), width: 2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      icon: const Icon(Icons.share_rounded, color: Color(0xFFE65100), size: 18),
                      label: const Text(
                        'Diplomayı Paylaş / İndir',
                        style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFFE65100), fontSize: 12),
                      ),
                      onPressed: () => _showShareOptions(context, childName, dateStr, cleanP),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF58CC02),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 3,
                      ),
                      icon: const Icon(Icons.check_circle_rounded, size: 18),
                      onPressed: () => Navigator.pop(context),
                      label: const Text('HARİKA! 🚀', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12.5)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
