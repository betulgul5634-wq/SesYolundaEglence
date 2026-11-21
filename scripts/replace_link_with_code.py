with open('mobile/lib/widgets/therapist_portal_dialog.dart', 'r', encoding='utf-8') as f:
    text = f.read()

# Replace comment
text = text.replace('ve veli linklerini', 've danışan kodlarını')

# Replace _showShareLinkDialog with _showStudentCodeDialog
old_method_start = "  void _showShareLinkDialog(Map<String, dynamic> student) {"
old_method_end = "  @override\n  Widget build(BuildContext context) {"

idx_start = text.find(old_method_start)
idx_end = text.find(old_method_end)

new_method = """  void _showStudentCodeDialog(Map<String, dynamic> student) {
    _sfx.playPopSound();
    final studentNameFirst = student['name'].toString().split(' ').first.toUpperCase();
    final studentCode = 'DKT-${student['id']}-$studentNameFirst';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Text(student['avatar'] ?? '👦', style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${student['name']} Danışan Kodu',
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFA5D6A7)),
              ),
              child: Row(
                children: [
                  const Text('🔑', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Veli kendi telefonundan uygulamayı yükleyip açtığında bu kodu girerek ${student['name']} profiliyle doğrudan başlar. Evdeki tüm egzersiz puanları otomatik olarak terapist ekranınıza aktarılır.',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF1B5E20), fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text('Danışan Eşleştirme Kodu:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF475569))),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFCBD5E1), width: 1.5),
              ),
              child: Center(
                child: SelectableText(
                  studentCode,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.0,
                    fontFamily: 'monospace',
                    color: Color(0xFF1565C0),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: studentCode));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('📋 Danışan kodu panoya kopyalandı! Veliye iletebilirsiniz.'),
                          backgroundColor: Color(0xFF2E7D32),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      Navigator.pop(ctx);
                    },
                    icon: const Icon(Icons.copy_rounded, size: 16, color: Colors.white),
                    label: const Text('Kodu Kopyala', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF37474F),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final waText = Uri.encodeComponent(
                        'Merhaba! Uzm. DKT Merve Kaya tarafından Ses Yolunda Eğlence platformunda ${student['name']} için konuşma terapisi egzersizleri tanımlanmıştır. Çocuğunuz uygulamayı açıp kayıt olurken şu Terapist Kodunu giriniz:\\n\\n🔑 Terapist Kodu: ' + studentCode + '\\n\\nBu kod ile evdeki çalışma verileri terapist paneline aktarılacaktır.'
                      );
                      final waUrl = 'https://api.whatsapp.com/send?text=' + waText;
                      if (kIsWeb) {
                        html.window.open(waUrl, '_blank');
                      }
                      Navigator.pop(ctx);
                    },
                    icon: const Icon(Icons.send_rounded, size: 16, color: Colors.white),
                    label: const Text('WhatsApp ile İlet', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF25D366),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

"""

if idx_start != -1 and idx_end != -1:
    text = text[:idx_start] + new_method + text[idx_end:]
    print("Replaced dialog method with _showStudentCodeDialog")
else:
    print("Could not find dialog bounds", idx_start, idx_end)

# Replace callers in student list and detail view
text = text.replace("_showShareLinkDialog(std)", "_showStudentCodeDialog(std)")
text = text.replace("'Link Gönder'", "'Kodu Gör'")
text = text.replace("'Veliye Link Gönder'", "'Danışan Kodu Ver'")
text = text.replace("icon: const Icon(Icons.share_rounded, size: 14)", "icon: const Icon(Icons.vpn_key_rounded, size: 14)")
text = text.replace("icon: const Icon(Icons.share_rounded, size: 16, color: Colors.white)", "icon: const Icon(Icons.vpn_key_rounded, size: 16, color: Colors.white)")

with open('mobile/lib/widgets/therapist_portal_dialog.dart', 'w', encoding='utf-8') as f:
    f.write(text)

# Also check home_screen.dart
with open('mobile/lib/screens/home_screen.dart', 'r', encoding='utf-8') as f:
    hs = f.read()
hs = hs.replace('// Terapist Davet Linki Kontrolü', '// Terapist Davet Kodu Kontrolü')
with open('mobile/lib/screens/home_screen.dart', 'w', encoding='utf-8') as f:
    f.write(hs)

print("therapist_portal_dialog.dart and home_screen.dart updated successfully")
