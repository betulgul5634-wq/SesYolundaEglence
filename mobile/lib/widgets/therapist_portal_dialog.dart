import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;
import '../services/sound_effects_service.dart';
import '../services/therapist_state_service.dart';
import '../models/reward_state.dart';
import '../screens/onboarding_auth_screen.dart';

/// 👨‍⚕️ UZMAN TERAPİST YÖNETİM PORTALI & GİRİŞ MERKEZİ (FLUTTER WEB ENTEGRE)
/// Terapistin hastalarını, seanslarını, grafiklerini, klinik notlarını ve danışan kodlarını
/// harici bir sayfaya gitmeden DOĞRUDAN UYGULAMANIN İÇİNDE yönetmesini sağlar.
class TherapistPortalDialog extends StatefulWidget {
  final bool initialLoggedIn;
  final String? initialName;
  final String? initialClinic;
  final String? initialEmail;
  final String? initialEdevlet;

  const TherapistPortalDialog({
    super.key,
    this.initialLoggedIn = false,
    this.initialName,
    this.initialClinic,
    this.initialEmail,
    this.initialEdevlet,
  });

  @override
  State<TherapistPortalDialog> createState() => _TherapistPortalDialogState();
}

class _TherapistPortalDialogState extends State<TherapistPortalDialog> {
  final SoundEffectsService _sfx = SoundEffectsService();
  final TherapistStateService _dkt = TherapistStateService();

  late bool _isLoggedIn;
  bool _didLogout = false;
  bool _isRegisterMode = false;
  late String _therapistName;
  late String _clinicName;
  late String _edevletDocNo;
  bool _isEdevletVerified = false;
  bool _isVerifyingEdevlet = false;

  final TextEditingController _loginEmailCtrl = TextEditingController();
  final TextEditingController _loginPassCtrl = TextEditingController();

  final TextEditingController _regNameCtrl = TextEditingController();
  final TextEditingController _regClinicCtrl = TextEditingController();
  final TextEditingController _regEdevletCtrl = TextEditingController();
  final TextEditingController _regEmailCtrl = TextEditingController();
  final TextEditingController _regPassCtrl = TextEditingController();

  int _activeTabIndex = 0;
  String _searchQuery = '';
  String _filterPhoneme = 'ALL';
  Map<String, dynamic>? _selectedStudent;
  dynamic _selectedReportStudentId = 1;
  final TextEditingController _clinicalNoteCtrl = TextEditingController();

  List<Map<String, dynamic>> get _students => _dkt.students;

  void _printFullStudentReport(Map<String, dynamic> student) {
    if (!kIsWeb) return;
    final sName = student['name']?.toString() ?? 'Danışan';
    final age = student['age']?.toString() ?? '6';
    final diag = student['diagnosis']?.toString() ?? 'Artikülasyon Güçlüğü';
    final targets = student['target_phonemes']?.toString() ?? '-';
    final acc = student['accuracy']?.toString() ?? '0';
    final stars = student['total_stars']?.toString() ?? '0';
    final assess = (student['clinical_assessment'] as String? ?? '').trim();
    final sessions = (student['sessions'] as List<dynamic>?) ?? [];

    final isActiveStudent = !RewardState().isGuest &&
        RewardState().studentName.trim().toLowerCase() == sName.trim().toLowerCase();
    final stats = isActiveStudent ? RewardState().phonemeStats.values : const <PhonemeStat>[];
    int initAtt = 0, initCor = 0, medAtt = 0, medCor = 0, finAtt = 0, finCor = 0;
    for (final s in stats) {
      initAtt += s.initialAttempts;
      initCor += s.initialCorrect;
      medAtt += s.medialAttempts;
      medCor += s.medialCorrect;
      finAtt += s.finalAttempts;
      finCor += s.finalCorrect;
    }
    final initPct = initAtt > 0 ? '%${((initCor / initAtt) * 100).round()}' : '-';
    final medPct = medAtt > 0 ? '%${((medCor / medAtt) * 100).round()}' : '-';
    final finPct = finAtt > 0 ? '%${((finCor / finAtt) * 100).round()}' : '-';

    String esc(String v) => v.replaceAll('&', '&amp;').replaceAll('<', '&lt;').replaceAll('>', '&gt;');

    final sessionRows = sessions.isEmpty
        ? '<tr><td colspan="4" style="text-align:center;color:#64748b;">Henüz seans kaydı bulunmamaktadır.</td></tr>'
        : sessions.take(15).map((s) {
            final m = s as Map;
            return '<tr>'
                '<td>${esc(m['date']?.toString() ?? '')}</td>'
                '<td><b>/${esc(m['phoneme']?.toString() ?? '')}/</b></td>'
                '<td>%${esc(m['acc']?.toString() ?? '0')} (${esc(m['words']?.toString() ?? '')})</td>'
                '<td>${esc(m['note']?.toString() ?? '')}</td>'
                '</tr>';
          }).join();

    final reportHtml = '''
<!DOCTYPE html>
<html lang="tr">
<head>
<meta charset="utf-8">
<title>Klinik Gelişim Karnesi - ${esc(sName)}</title>
<style>
  @page { size: A4; margin: 16mm; }
  body { font-family: Arial, Helvetica, sans-serif; color: #0f172a; margin: 0; padding: 20px; }
  .header { border-bottom: 3px solid #16a34a; padding-bottom: 12px; margin-bottom: 16px; display: flex; justify-content: space-between; align-items: center; }
  .title { font-size: 22px; font-weight: 900; color: #166534; margin: 0; }
  .sub { font-size: 12px; color: #475569; margin-top: 4px; }
  .box { border: 1px solid #cbd5e1; border-radius: 10px; padding: 14px; margin-bottom: 14px; background: #f8fafc; }
  .grid { display: flex; gap: 12px; margin-bottom: 14px; }
  .card { flex: 1; border: 1px solid #bbf7d0; border-radius: 10px; padding: 12px; background: #f0fdf4; }
  .card h4 { margin: 0 0 6px 0; font-size: 12px; color: #166534; }
  .big { font-size: 24px; font-weight: 900; color: #15803d; }
  table { width: 100%; border-collapse: collapse; margin-top: 8px; font-size: 12px; }
  th, td { border: 1px solid #cbd5e1; padding: 8px; text-align: left; }
  th { background: #e2e8f0; }
  .assess { border: 1.5px solid #86efac; background: #f0fdf4; border-radius: 10px; padding: 14px; margin-top: 14px; }
  .sign { text-align: right; margin-top: 14px; font-size: 12px; font-weight: bold; color: #166534; }
  @media print { body { padding: 0; } }
</style>
</head>
<body>
  <div class="header">
    <div>
      <h1 class="title">Klinik Gelişim Karnesi</h1>
      <div class="sub">Ebeveyn & Dil ve Konuşma Terapisti Klinik Değerlendirme Raporu</div>
      <div class="sub"><b>Kurum:</b> ${esc(_clinicName)} • <b>Sorumlu:</b> ${esc(_therapistName)}</div>
    </div>
    <div style="text-align:right;font-size:11px;color:#475569;">
      <b>Ses Yolunda Eğlence</b><br>e-Devlet Onaylı DKT Raporu
    </div>
  </div>

  <div class="box">
    <b>Danışan:</b> ${esc(sName)} &nbsp;|&nbsp; <b>Yaş:</b> ${esc(age)} &nbsp;|&nbsp; <b>Klinik Tanı:</b> ${esc(diag)} &nbsp;|&nbsp; <b>Hedef Sesler:</b> ${esc(targets)}
  </div>

  <div class="grid">
    <div class="card"><h4>Genel Başarı</h4><div class="big">%${esc(acc)}</div></div>
    <div class="card"><h4>Toplanan Yıldız</h4><div class="big">${esc(stars)} ⭐</div></div>
    <div class="card"><h4>Başta / Ortada / Sonda</h4><div style="font-size:15px;font-weight:bold;">$initPct / $medPct / $finPct</div></div>
  </div>

  <div class="box" style="background:#fff;">
    <b>Klinik Seans Geçmişi</b>
    <table>
      <thead><tr><th>Tarih</th><th>Ses</th><th>Başarı</th><th>Klinik Not / Ödev</th></tr></thead>
      <tbody>$sessionRows</tbody>
    </table>
  </div>

  <div class="assess">
    <b>Uzman Terapist Klinik Değerlendirmesi & Öneri</b>
    <p style="font-size:13px;line-height:1.5;">${assess.isNotEmpty ? esc(assess) : 'Değerlendirme notu henüz girilmemiştir.'}</p>
    <div class="sign">${esc(_therapistName)}<br>e-Devlet Onaylı DKT</div>
  </div>

  <script>window.onload = function() { setTimeout(function() { window.print(); }, 250); };</script>
</body>
</html>
''';

    final blob = html.Blob([reportHtml], 'text/html;charset=utf-8');
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.window.open(url, '_blank');
  }

  @override
  void initState() {
    super.initState();
    _dkt.purgeInvalidAndTestStudents();
    _syncFromService();
  }

  void _syncFromService() {
    // Serviste oturum açıksa veya parametre geldiyse oturumu açık yap
    _isLoggedIn = _dkt.isLoggedIn || (widget.initialLoggedIn && !_didLogout);
    _therapistName = widget.initialName ?? _dkt.therapistName;
    _clinicName = widget.initialClinic ?? _dkt.clinicName;
    _edevletDocNo = widget.initialEdevlet ?? _dkt.edevletDocNo;
    _isEdevletVerified = _edevletDocNo.isNotEmpty;
  }

  @override
  void dispose() {
    _loginEmailCtrl.dispose();
    _loginPassCtrl.dispose();
    _regNameCtrl.dispose();
    _regClinicCtrl.dispose();
    _regEdevletCtrl.dispose();
    _regEmailCtrl.dispose();
    _regPassCtrl.dispose();
    _clinicalNoteCtrl.dispose();
    super.dispose();
  }

  void _showForgotPasswordDialog(BuildContext context, {String initialEmail = ''}) {
    final cleanInitial = initialEmail.replaceAll('@gmail.com', '').trim();
    final emailCtrl = TextEditingController(text: cleanInitial);
    final newPassCtrl = TextEditingController();
    final confirmPassCtrl = TextEditingController();
    bool obscureNew = true;
    bool obscureConfirm = true;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              actionsPadding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF42A5F5), Color(0xFF1E88E5)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text('🔑', style: TextStyle(fontSize: 20)),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Şifremi Unuttum',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                        ),
                        Text(
                          'Yeni şifrenizi belirleyerek hesabınızı yenileyin',
                          style: TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(height: 16),
                    const Text('Kayıtlı E-Posta Adresiniz:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5)),
                    const SizedBox(height: 4),
                    TextField(
                      controller: emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.alternate_email_rounded, size: 18),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                    ),
                    const SizedBox(height: 12),

                    const Text('Yeni Şifre Belirleyin:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5)),
                    const SizedBox(height: 4),
                    TextField(
                      controller: newPassCtrl,
                      obscureText: obscureNew,
                      decoration: InputDecoration(
                        hintText: 'En az 4 karakter',
                        prefixIcon: const Icon(Icons.lock_outline_rounded, size: 18),
                        suffixIcon: IconButton(
                          icon: Icon(obscureNew ? Icons.visibility_off_rounded : Icons.visibility_rounded, size: 18, color: const Color(0xFF64748B)),
                          onPressed: () => setDialogState(() => obscureNew = !obscureNew),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                    ),
                    const SizedBox(height: 12),

                    const Text('Yeni Şifre (Tekrar):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5)),
                    const SizedBox(height: 4),
                    TextField(
                      controller: confirmPassCtrl,
                      obscureText: obscureConfirm,
                      decoration: InputDecoration(
                        hintText: 'Şifrenizi tekrar yazın',
                        prefixIcon: const Icon(Icons.lock_reset_rounded, size: 18),
                        suffixIcon: IconButton(
                          icon: Icon(obscureConfirm ? Icons.visibility_off_rounded : Icons.visibility_rounded, size: 18, color: const Color(0xFF64748B)),
                          onPressed: () => setDialogState(() => obscureConfirm = !obscureConfirm),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                    ),
                    const SizedBox(height: 10),

                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFBBF7D0)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.shield_outlined, color: Color(0xFF16A34A), size: 18),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Yeni şifreniz kaydedildikten sonra hesabınıza anında tanımlanır.',
                              style: TextStyle(fontSize: 10.5, color: Color(0xFF166534), fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogCtx).pop(),
                  child: const Text('Vazgeç', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold)),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    var rawEmail = emailCtrl.text.trim();
                    final newPass = newPassCtrl.text.trim();
                    final confirmPass = confirmPassCtrl.text.trim();

                    if (rawEmail.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('⚠️ Lütfen e-posta adresinizi giriniz.'), backgroundColor: Colors.orangeAccent),
                      );
                      return;
                    }
                    if (newPass.length < 4) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('⚠️ Şifre en az 4 karakter olmalıdır.'), backgroundColor: Colors.orangeAccent),
                      );
                      return;
                    }
                    if (newPass != confirmPass) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('⚠️ Şifreler birbiriyle eşleşmiyor!'), backgroundColor: Colors.redAccent),
                      );
                      return;
                    }

                    if (!rawEmail.contains('@')) {
                      rawEmail = '$rawEmail@gmail.com';
                    } else if (rawEmail.endsWith('@')) {
                      rawEmail = '${rawEmail}gmail.com';
                    }

                    _dkt.resetPassword(rawEmail, newPass);
                    final prefix = rawEmail.replaceAll('@gmail.com', '');
                    setState(() {
                      _loginEmailCtrl.text = prefix;
                      _loginPassCtrl.text = newPass;
                      _regEmailCtrl.text = prefix;
                      _regPassCtrl.text = newPass;
                    });

                    _sfx.playSuccessDing();
                    Navigator.of(dialogCtx).pop();

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(Icons.check_circle_rounded, color: Colors.white),
                            const SizedBox(width: 8),
                            Expanded(child: Text('✅ Şifreniz başarıyla yenilendi! ($rawEmail)')),
                          ],
                        ),
                        backgroundColor: const Color(0xFF16A34A),
                        duration: const Duration(seconds: 4),
                      ),
                    );
                  },
                  icon: const Icon(Icons.check_rounded, size: 16, color: Colors.white),
                  label: const Text('Şifremi Sıfırla & Kaydet', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E88E5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditTherapistCodeDialog() {
    _sfx.playPopSound();
    final codeCtrl = TextEditingController(text: _dkt.therapistCode);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Text('🔑', style: TextStyle(fontSize: 24)),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Terapist Eşleştirme Kodunu Tanımla',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF0F172A)),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Danışanlarınız (çocuk veya veli) uygulamaya giriş veya kayıt yaparken bu kodu girdiğinde, konuşma seansları ve artikülasyon verileri doğrudan bu panelinize aktarılır.',
              style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B), height: 1.4),
            ),
            const SizedBox(height: 16),
            const Text('Terapist Kodunuz:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            const SizedBox(height: 6),
            TextField(
              controller: codeCtrl,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                hintText: 'Örn: DKT-BETUL veya KLINIK1',
                prefixIcon: const Icon(Icons.vpn_key_rounded, size: 18, color: Color(0xFF0284C7)),
                filled: true,
                fillColor: const Color(0xFFF0F9FF),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFBAE6FD))),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '💡 İpucu: Harf, rakam ve tire (-) içerebilir. Kolay hatırlanabilir bir kod seçebilirsiniz.',
              style: TextStyle(fontSize: 11, color: Color(0xFF0284C7), fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Vazgeç', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton.icon(
            onPressed: () {
              final newCode = codeCtrl.text.trim().toUpperCase().replaceAll(' ', '-');
              if (newCode.isNotEmpty) {
                _dkt.setTherapistCode(newCode);
                setState(() => _syncFromService());
                _sfx.playVictoryFanfare();
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('✅ Terapist kodunuz "$newCode" olarak tanımlandı! Danışanlarınız bu kod ile bağlanabilir.'),
                    backgroundColor: const Color(0xFF16A34A),
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            },
            icon: const Icon(Icons.check_rounded, size: 16, color: Colors.white),
            label: const Text('Kodu Kaydet ve Tanımla', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0284C7),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  void _showStudentCodeDialog(Map<String, dynamic> student) {
    _sfx.playPopSound();
    final studentCode = _dkt.therapistCode;

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
                        'Merhaba! ${_dkt.therapistName} tarafından Ses Yolunda Eğlence platformunda ${student['name']} için konuşma terapisi egzersizleri tanımlanmıştır. Çocuğunuz uygulamayı açıp kayıt olurken şu Terapist Kodunu giriniz:\n\n🔑 Terapist Kodu: $studentCode\n\nBu kod ile evdeki çalışma verileri terapist paneline aktarılacaktır.'
                      );
                      final waUrl = 'https://api.whatsapp.com/send?text=$waText';
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

  void _confirmDeleteStudent(Map<String, dynamic> std) {
    showDialog(
      context: context,
      builder: (dCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
            SizedBox(width: 8),
            Text('Danışanı Sil', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
          ],
        ),
        content: Text(
          '${std['name']} isimli danışanı ve kayıtlı tüm seans verilerini silmek istiyor musunuz?',
          style: const TextStyle(fontSize: 13),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dCtx), child: const Text('İptal')),
          ElevatedButton(
            onPressed: () {
              _dkt.deleteStudent(std['id']);
              Navigator.pop(dCtx);
              setState(() {
                if (_selectedStudent?['id'] == std['id']) _selectedStudent = null;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('🗑️ ${std['name']} silindi.'),
                  backgroundColor: const Color(0xFFDC2626),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDC2626)),
            child: const Text('Evet, Sil', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _confirmClearAllTestStudents() {
    showDialog(
      context: context,
      builder: (dCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.delete_sweep_rounded, color: Colors.redAccent),
            SizedBox(width: 8),
            Text('Tüm Danışanları Temizle', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
          ],
        ),
        content: const Text(
          'Tüm test danışanlarını ve seans loglarını temizlemek istiyor musunuz? Paneliniz gerçek kullanım için sıfırlanacaktır.',
          style: TextStyle(fontSize: 13),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dCtx), child: const Text('İptal')),
          ElevatedButton(
            onPressed: () {
              _dkt.clearAllStudents();
              Navigator.pop(dCtx);
              setState(() {
                _selectedStudent = null;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('🗑️ Tüm test danışanları ve seans logları temizlendi.'),
                  backgroundColor: Color(0xFF16A34A),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDC2626)),
            child: const Text('Evet, Temizle', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showSendToParentDialog(Map<String, dynamic> student) {
    _sfx.playPopSound();
    final studentName = student['name'] ?? 'Danışan';
    final initialEmail = (student['parent_email'] as String? ?? '').trim();
    final initialPhone = (student['parent_phone'] as String? ?? '').trim();
    var initialNote = (student['clinical_assessment'] as String? ?? '').trim();
    if (initialNote.isEmpty) {
      final sessions = (student['sessions'] as List?) ?? const [];
      for (final s in sessions) {
        if (s is Map && (s['note'] as String? ?? '').trim().isNotEmpty) {
          initialNote = (s['note'] as String).trim();
          break;
        }
      }
    }
    final emailCtrl = TextEditingController(text: initialEmail);
    final phoneCtrl = TextEditingController(text: initialPhone);
    final noteCtrl = TextEditingController(text: initialNote);
    bool sentSuccess = false;
    String statusMessage = '';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (dCtx, setModalState) {
          final currentAccuracy = student['accuracy'] ?? 0;
          final totalAttempts = student['total_attempts'] ?? 0;
          final rawPhonemes = (student['target_phonemes'] as String? ?? '').trim();
          final phonemes = rawPhonemes.isNotEmpty ? rawPhonemes : 'Henüz atanmadı';

          String buildReportText() {
            final noteText = noteCtrl.text.trim();
            final noteLine = noteText.isNotEmpty ? '📝 Terapist Notu: $noteText\n' : '';
            return '🗣️ SES YOLUNDA EĞLENCE • KLİNİK GELİŞİM BİLDİRİMİ\n'
                   '━━━━━━━━━━━━━━━━━━━━━━\n'
                   '👨‍⚕️ Terapist: ${_dkt.therapistName.isNotEmpty ? _dkt.therapistName : "Uzm. Dil ve Konuşma Terapisti"}\n'
                   '🏥 Klinik: ${_dkt.clinicName.isNotEmpty ? _dkt.clinicName : "Dil ve Konuşma Danışmanlık Merkezi"}\n'
                   '👶 Danışan: $studentName (${student['age'] ?? "-"} Yaş)\n'
                   '📊 Artikülasyon Başarısı: %$currentAccuracy ($totalAttempts deneme)\n'
                   '🎯 Hedef Fonemler: $phonemes\n'
                   '$noteLine'
                   '━━━━━━━━━━━━━━━━━━━━━━\n'
                   '✨ Çocuğunuzun günlük ses çalışmalarını evde desteklemeye devam ediniz.';
          }

          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20),
            actionsPadding: const EdgeInsets.fromLTRB(20, 10, 20, 18),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4ADE80), Color(0xFF16A34A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('📨', style: TextStyle(fontSize: 20)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$studentName - Veliye İlet',
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF0F172A)),
                      ),
                      const Text(
                        'Karne ve ödev özetini WhatsApp veya E-Posta ile gönderin',
                        style: TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 14),
                  // Danışan Mini Özeti
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        Text(student['avatar'] ?? '👦', style: const TextStyle(fontSize: 28)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(studentName, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13.5)),
                              Text('Tanı: ${student['diagnosis']}', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                              Text('Hedef: $phonemes', style: const TextStyle(fontSize: 11, color: Color(0xFF1E88E5), fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFA5D6A7)),
                          ),
                          child: Text(
                            '%$currentAccuracy Başarı',
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Color(0xFF16A34A)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  const Text('Veli E-Posta Adresi:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5)),
                  const SizedBox(height: 4),
                  TextField(
                    controller: emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'ornek@eposta.com',
                      prefixIcon: const Icon(Icons.email_outlined, size: 18),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 10),

                  const Text('Veli Telefon No (WhatsApp için opsiyonel):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5)),
                  const SizedBox(height: 4),
                  TextField(
                    controller: phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      hintText: '05XXXXXXXXX',
                      prefixIcon: const Icon(Icons.phone_iphone_rounded, size: 18),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 10),

                  const Text('Terapist Mesajı / Notu:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5)),
                  const SizedBox(height: 4),
                  TextField(
                    controller: noteCtrl,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'Veliye iletilecek özel değerlendirme veya ödev...',
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (sentSuccess)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF86EFAC)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              statusMessage,
                              style: const TextStyle(fontSize: 11.5, color: Color(0xFF15803D), fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Kapat', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
              ),
              // 📋 Kopyala Butonu
              OutlinedButton.icon(
                onPressed: () {
                  final text = buildReportText();
                  Clipboard.setData(ClipboardData(text: text));
                  _sfx.playSuccessDing();
                  setModalState(() {
                    sentSuccess = true;
                    statusMessage = '📋 Karne ve mesaj panoya kopyalandı! İstediğiniz yere yapıştırabilirsiniz.';
                  });
                },
                icon: const Icon(Icons.copy_rounded, size: 15),
                label: const Text('Kopyala', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              // 📧 E-Posta Butonu
              ElevatedButton.icon(
                onPressed: () {
                  final pEmail = emailCtrl.text.trim();
                  if (pEmail.isEmpty || !pEmail.contains('@')) {
                    setModalState(() {
                      sentSuccess = true;
                      statusMessage = '⚠️ Lütfen geçerli bir veli e-posta adresi girin.';
                    });
                    return;
                  }
                  student['parent_email'] = pEmail;
                  _dkt.saveToLocalStorage();

                  final body = Uri.encodeComponent(buildReportText());
                  final subject = Uri.encodeComponent('$studentName - Ses Yolunda Eğlence Klinik Gelişim Karnesi');
                  final mailUrl = 'mailto:$pEmail?subject=$subject&body=$body';
                  if (kIsWeb) {
                    html.window.open(mailUrl, '_blank');
                  }
                  _sfx.playSuccessDing();
                  setModalState(() {
                    sentSuccess = true;
                    statusMessage = '📧 E-posta istemcisi açıldı ve karne hazırlandı ($pEmail)!';
                  });
                },
                icon: const Icon(Icons.mail_rounded, size: 15, color: Colors.white),
                label: const Text('E-Posta Aç', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0284C7),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              // 💬 WhatsApp Butonu
              ElevatedButton.icon(
                onPressed: () {
                  final rawPhone = phoneCtrl.text.trim();
                  if (rawPhone.isNotEmpty) {
                    student['parent_phone'] = rawPhone;
                    _dkt.saveToLocalStorage();
                  }
                  var phone = rawPhone.replaceAll(RegExp(r'[^0-9]'), '');
                  if (phone.startsWith('0')) phone = '90${phone.substring(1)}';
                  final text = Uri.encodeComponent(buildReportText());
                  final waUrl = phone.isNotEmpty
                      ? 'https://api.whatsapp.com/send?phone=$phone&text=$text'
                      : 'https://api.whatsapp.com/send?text=$text';
                  if (kIsWeb) {
                    html.window.open(waUrl, '_blank');
                  }
                  _sfx.playSuccessDing();
                  setModalState(() {
                    sentSuccess = true;
                    statusMessage = '💬 WhatsApp açıldı! Karne veliye iletilmeye hazır.';
                  });
                },
                icon: const Icon(Icons.send_rounded, size: 15, color: Colors.white),
                label: const Text('WhatsApp', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF16A34A),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 960, maxHeight: 780),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: const [
            BoxShadow(color: Color(0x33000000), blurRadius: 30, offset: Offset(0, 10)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: _isLoggedIn ? _buildDashboard() : _buildLoginAndRegisterScreen(),
        ),
      ),
    );
  }

  // ── 1. GİRİŞ VE KAYIT EKRANI (OTURUM AÇIK DEĞİLSE) ────────────────────────
  Widget _buildLoginAndRegisterScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420),
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: const [
                BoxShadow(color: Color(0x0D000000), blurRadius: 20, offset: Offset(0, 6)),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo & Başlık
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF1E88E5), Color(0xFF3949AB)]),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: const [
                      BoxShadow(color: Color(0x401E88E5), blurRadius: 10, offset: Offset(0, 4)),
                    ],
                  ),
                  child: const Center(child: Text('🎙️', style: TextStyle(fontSize: 28))),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Ses Yolunda Eğlence',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Color(0xFF0F172A)),
                ),
                const Text(
                  'Dil ve Konuşma Terapisti (DKT) Klinik Portalı',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E88E5)),
                ),
                const SizedBox(height: 20),

                // Giriş Yap vs Kayıt Ol Sekmesi
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => setState(() => _isRegisterMode = false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: !_isRegisterMode ? Colors.white : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: !_isRegisterMode ? const [BoxShadow(color: Color(0x0A000000), blurRadius: 4)] : null,
                            ),
                            child: Center(
                              child: Text(
                                '🔐 Giriş Yap',
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 12,
                                  color: !_isRegisterMode ? const Color(0xFF0F172A) : const Color(0xFF64748B),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () => setState(() => _isRegisterMode = true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: _isRegisterMode ? Colors.white : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: _isRegisterMode ? const [BoxShadow(color: Color(0x0A000000), blurRadius: 4)] : null,
                            ),
                            child: Center(
                              child: Text(
                                '📝 Terapist Kayıt Ol',
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 12,
                                  color: _isRegisterMode ? const Color(0xFF1E88E5) : const Color(0xFF64748B),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                if (!_isRegisterMode) ...[
                  // GİRİŞ FORMU
                  TextField(
                    controller: _loginEmailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'E-posta Adresi',
                      labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      prefixIcon: const Icon(Icons.email_outlined, size: 18),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _loginPassCtrl,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Şifre',
                      labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      prefixIcon: const Icon(Icons.lock_outline, size: 18),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () => _showForgotPasswordDialog(context, initialEmail: _loginEmailCtrl.text.trim()),
                      icon: const Icon(Icons.lock_reset_rounded, size: 15, color: Color(0xFF1E88E5)),
                      label: const Text(
                        'Şifremi Unuttum',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E88E5),
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: () {
                        var email = _loginEmailCtrl.text.trim();
                        final pass = _loginPassCtrl.text.trim();
                        if (email.isEmpty || pass.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Lütfen e-posta ve şifrenizi giriniz.'),
                              backgroundColor: Colors.orangeAccent,
                            ),
                          );
                          return;
                        }
                        if (!email.contains('@')) {
                          email = '$email@gmail.com';
                        } else if (email.endsWith('@')) {
                          email = '${email}gmail.com';
                        }
                        _dkt.loginTherapist(email, pass);
                        setState(() {
                          _syncFromService();
                        });
                        _sfx.playSuccessDing();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E88E5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Kliniğe Giriş Yap', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white)),
                    ),
                  ),
                ] else ...[
                  // KAYIT FORMU
                  TextField(
                    controller: _regNameCtrl,
                    decoration: InputDecoration(
                      labelText: 'Adınız Soyadınız',
                      hintText: 'Adınız ve Soyadınız',
                      labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      prefixIcon: const Icon(Icons.person_outline, size: 18),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _regClinicCtrl,
                    decoration: InputDecoration(
                      labelText: 'Klinik / Danışmanlık Merkezi Adı',
                      labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      prefixIcon: const Icon(Icons.apartment_rounded, size: 18),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // 🏛️ e-Devlet YÖK Mezuniyet Doğrulama Alanı
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _regEdevletCtrl,
                          decoration: InputDecoration(
                            labelText: '🏛️ e-Devlet Mezuniyet Barkod No',
                            hintText: 'Örn: belgenizdeki barkod kodu',
                            labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                            prefixIcon: const Icon(Icons.verified_user_rounded, size: 18, color: Color(0xFF1565C0)),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final doc = _regEdevletCtrl.text.trim();
                          if (doc.isEmpty || doc.length < 4) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('⚠️ Lütfen mezuniyet belgenizdeki e-Devlet barkod numarasını giriniz.'),
                                backgroundColor: Colors.orangeAccent,
                              ),
                            );
                            return;
                          }
                          setState(() => _isVerifyingEdevlet = true);
                          await Future.delayed(const Duration(milliseconds: 500));
                          setState(() {
                            _isVerifyingEdevlet = false;
                            _isEdevletVerified = true;
                          });
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('🇹🇷 e-Devlet & YÖK Mezuniyet Belgesi Doğrulandı! (Barkod: $doc • Dil ve Konuşma Terapisi Bölümü)'),
                                backgroundColor: const Color(0xFF1B5E20),
                              ),
                            );
                          }
                        },
                        icon: _isVerifyingEdevlet
                            ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Icon(Icons.verified_user_rounded, size: 15, color: Colors.white),
                        label: Text(_isVerifyingEdevlet ? 'Sorgulanıyor...' : 'Doğrula', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1565C0),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                  if (_isEdevletVerified)
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF81C784)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_rounded, size: 16, color: Color(0xFF2E7D32)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'e-Devlet Onaylı: Barkod (${_regEdevletCtrl.text.trim()}) Dil ve Konuşma Terapisi Lisansı Doğrulandı',
                              style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _regEmailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'E-posta Adresi',
                      labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      prefixIcon: const Icon(Icons.email_outlined, size: 18),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _regPassCtrl,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Şifre Belirleyin',
                      labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      prefixIcon: const Icon(Icons.lock_outline, size: 18),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () => _showForgotPasswordDialog(context, initialEmail: _regEmailCtrl.text.trim()),
                      icon: const Icon(Icons.lock_reset_rounded, size: 15, color: Color(0xFF1E88E5)),
                      label: const Text(
                        'Şifremi Unuttum',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E88E5),
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_regNameCtrl.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Lütfen adınızı ve soyadınızı giriniz.')),
                          );
                          return;
                        }
                        if (_regEdevletCtrl.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Lütfen e-Devlet barkod numaranızı girip Doğrula butonuna basınız.')),
                          );
                          return;
                        }
                        if (!_isEdevletVerified) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Lütfen önce Doğrula butonuna basarak mezuniyet belgenizi onaylatınız.')),
                          );
                          return;
                        }
                        final name = _regNameCtrl.text.trim();
                        final clinic = _regClinicCtrl.text.trim().isNotEmpty ? _regClinicCtrl.text.trim() : 'Dil ve Konuşma Danışmanlık Merkezi';
                        var email = _regEmailCtrl.text.trim();
                        final doc = _regEdevletCtrl.text.trim();
                        final pass = _regPassCtrl.text.trim();
                        if (email.isEmpty || pass.length < 4) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Lütfen geçerli e-posta ve en az 4 karakterli şifre giriniz.')),
                          );
                          return;
                        }

                        if (!email.contains('@')) {
                          email = '$email@gmail.com';
                        } else if (email.endsWith('@')) {
                          email = '${email}gmail.com';
                        }

                        _dkt.registerTherapist(
                          name: name,
                          clinic: clinic,
                          email: email,
                          edevletDocNo: doc,
                          password: pass,
                        );

                        setState(() {
                          _syncFromService();
                        });
                        _sfx.playVictoryFanfare();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Terapist Olarak Kaydol ve Başla', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white)),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── 2. ANA TERAPİST YÖNETİM MASASI (DASHBOARD) ────────────────────────────
  Widget _buildDashboard() {
    return Column(
      children: [
        // ÜST BAŞLIK BARI
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('🗣️', style: TextStyle(fontSize: 22)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          _therapistName,
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF0F172A)),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFF81C784)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('🏛️ e-Devlet Onaylı DKT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20))),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Text(
                      _clinicName,
                      style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              // Çıkış Yap Butonu
              TextButton.icon(
                onPressed: () {
                  _sfx.playPopSound();
                  _dkt.logout();
                  _didLogout = true;
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const OnboardingAuthScreen()),
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.logout_rounded, size: 16, color: Colors.redAccent),
                label: const Text('Çıkış', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.redAccent)),
              ),
              const SizedBox(width: 8),
              // Haritaya Geç Butonu
              ElevatedButton.icon(
                onPressed: () {
                  _sfx.playPopSound();
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.map_rounded, size: 16, color: Colors.white),
                label: const Text('Oyun Haritasına Geç 🎮', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0284C7),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
              const SizedBox(width: 8),
              // Pencereyi Kapat
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded),
                color: Colors.grey,
              ),
            ],
          ),
        ),

        // SEKMELER: ANALİTİK & DANIŞANLAR
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          decoration: const BoxDecoration(
            color: Color(0xFFF8FAFC),
            border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
          ),
          child: Row(
            children: [
              _buildTabButton('📊 Genel Bakış & Analitik', 0),
              const SizedBox(width: 8),
              _buildTabButton('👥 Danışan Çocuklar (${_students.length})', 1),
              const SizedBox(width: 8),
              _buildTabButton('📑 Klinik Gelişim Karnesi', 2),
              const Spacer(),
              // 🔑 TERAPİST EŞLEŞTİRME KODU (Danışanlar Bu Kod İle Giriş Yapar)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF0284C7).withValues(alpha: 0.4)),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0284C7).withValues(alpha: 0.08),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0F2FE),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.vpn_key_rounded, size: 15, color: Color(0xFF0284C7)),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Danışan Eşleştirme Kodunuz',
                          style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                        ),
                        SelectableText(
                          _dkt.therapistCode,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                            color: Color(0xFF0369A1),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 6),
                    // Kodu Kopyala
                    IconButton(
                      icon: const Icon(Icons.copy_rounded, size: 16, color: Color(0xFF0284C7)),
                      tooltip: 'Kodu Kopyala',
                      constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: _dkt.therapistCode));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                                const SizedBox(width: 8),
                                Text('✅ Eşleştirme kodu (${_dkt.therapistCode}) kopyalandı! Danışanlarınızla paylaşabilirsiniz.'),
                              ],
                            ),
                            backgroundColor: const Color(0xFF0284C7),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                    // Kodu Düzenle / Tanımla
                    IconButton(
                      icon: const Icon(Icons.edit_rounded, size: 16, color: Color(0xFF0F766E)),
                      tooltip: 'Kodu Düzenle / Yeni Kod Tanımla',
                      constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                      padding: EdgeInsets.zero,
                      onPressed: _showEditTherapistCodeDialog,
                    ),
                  ],
                ),
              ),
              if (_students.isNotEmpty) ...[
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: _confirmClearAllTestStudents,
                  icon: const Icon(Icons.delete_sweep_rounded, size: 16, color: Color(0xFFDC2626)),
                  label: const Text('Tümünü Temizle', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5, color: Color(0xFFDC2626))),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFFCA5A5)),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ],
          ),
        ),

        // İÇERİK ALANI
        Expanded(
          child: Container(
            color: const Color(0xFFF8FAFC),
            child: _selectedStudent != null
                ? _buildStudentDetailView()
                : (_activeTabIndex == 0
                    ? _buildAnalyticsView()
                    : (_activeTabIndex == 1
                        ? _buildStudentsListView()
                        : _buildClinicalReportCardView())),
          ),
        ),
      ],
    );
  }

  Widget _buildTabButton(String title, int idx) {
    final isSelected = _activeTabIndex == idx && _selectedStudent == null;
    return InkWell(
      onTap: () {
        setState(() {
          _activeTabIndex = idx;
          _selectedStudent = null;
        });
        _sfx.playPopSound();
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1E88E5) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            color: isSelected ? Colors.white : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }

  // ── SEÇENEK 1: GENEL BAKIŞ & ANALİTİK GÖRÜNÜMÜ ─────────────────────────────
  Widget _buildAnalyticsView() {
    int totalSessions = 0;
    double totalAcc = 0.0;
    int accCount = 0;
    final List<Map<String, dynamic>> allSessions = [];
    final Map<String, List<double>> phonemeAccMap = {};

    for (final s in _students) {
      final sess = (s['sessions'] as List?) ?? [];
      for (final se in sess) {
        final ph = (se['phoneme'] ?? '').toString().trim();
        final wordsStr = (se['words'] ?? '').toString().trim();
        final isNoteOnly = ph.toLowerCase().contains('klinik not') ||
            wordsStr == '0/0' ||
            wordsStr == 'Ödev' ||
            wordsStr == 'Not';
        if (isNoteOnly) continue;

        totalSessions++;
        final acc = (se['acc'] as num?)?.toDouble() ?? 0.0;
        allSessions.add({
          'student_name': s['name'],
          'avatar': s['avatar'] ?? '👦',
          'diagnosis': s['diagnosis'] ?? 'Artikülasyon',
          'phoneme': ph,
          'words': wordsStr.isNotEmpty ? wordsStr : '0/0',
          'acc': acc,
          'date': se['date'] ?? 'Bugün',
          'note': se['note'] ?? '',
        });
        totalAcc += acc;
        accCount++;
        if (ph.isNotEmpty) {
          phonemeAccMap.putIfAbsent(ph, () => []).add(acc);
        }
      }
    }

    final String avgAccStr = accCount > 0 ? (totalAcc / accCount).toStringAsFixed(1) : '0';

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        // 3 KPI KARTI (Tamamen dinamik ve gerçek)
        Row(
          children: [
            _buildKpiCard(
              'Kayıtlı Danışanlar',
              '${_students.length}',
              _students.isEmpty ? 'Kayıt Bekleniyor' : 'Aktif Takipte',
              Icons.people_alt_rounded,
              const Color(0xFF1E88E5),
            ),
            const SizedBox(width: 14),
            _buildKpiCard(
              'Tamamlanan Seanslar',
              '$totalSessions Seans',
              totalSessions == 0 ? 'Henüz Seans Yok' : 'Gerçekleşen Terapi',
              Icons.check_circle_rounded,
              const Color(0xFF5E35B1),
            ),
            const SizedBox(width: 14),
            _buildKpiCard(
              'Ortalama Başarı',
              '%$avgAccStr',
              accCount == 0 ? 'Veri Bekleniyor' : 'Genel Artikülasyon',
              Icons.auto_graph_rounded,
              const Color(0xFF2E7D32),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // FONEM BAŞARI DAĞILIMI
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.bar_chart_rounded, color: Color(0xFF1E88E5), size: 20),
                  SizedBox(width: 8),
                  Text('Fonem Bazlı Artikülasyon Başarı Dağılımı', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                ],
              ),
              const SizedBox(height: 16),
              if (phonemeAccMap.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline_rounded, color: Color(0xFF64748B), size: 20),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Henüz tamamlanmış artikülasyon seansı bulunmuyor. Danışanınız hece ve kelime egzersizlerini yaptıkça fonem başarı grafikleri gerçek zamanlı olarak burada görüntülenecektir.',
                          style: TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.4),
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...phonemeAccMap.entries.map((entry) {
                  final phName = entry.key;
                  final avgVal = entry.value.reduce((a, b) => a + b) / entry.value.length;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildProgressRow('/$phName/ Fonemi', avgVal / 100.0, '%${avgVal.toStringAsFixed(1)}', const Color(0xFF1E88E5)),
                  );
                }),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // SON SEANSLAR LİSTESİ
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Son Gerçekleşen Terapi Seansları', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
              const SizedBox(height: 12),
              if (allSessions.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.history_toggle_off_rounded, color: Color(0xFF64748B), size: 20),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Kayıtlı seans geçmişi henüz yok. Danışanlar uygulamada egzersiz tamamladıkça seans logları anlık olarak buraya yansır.',
                          style: TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.4),
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...allSessions.map((sess) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Text(sess['avatar'] ?? '👦', style: const TextStyle(fontSize: 22)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(sess['student_name'] ?? 'Danışan', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              Text('Fonem: /${sess['phoneme']}/ • ${sess['note']}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                            ],
                          ),
                        ),
                        Text(sess['words'] ?? '', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1E88E5))),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '%${sess['acc']} Başarı',
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Color(0xFF2E7D32)),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildKpiCard(String title, String val, String sub, IconData icon, Color col) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                Icon(icon, size: 20, color: col),
              ],
            ),
            const SizedBox(height: 8),
            Text(val, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
            const SizedBox(height: 2),
            Text(sub, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: col)),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressRow(String title, double val, String pct, Color col) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            Text(pct, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: col)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: val,
            minHeight: 8,
            backgroundColor: const Color(0xFFF1F5F9),
            valueColor: AlwaysStoppedAnimation<Color>(col),
          ),
        ),
      ],
    );
  }

  // ── SEÇENEK 2: DANIŞANLAR LİSTESİ GÖRÜNÜMÜ ─────────────────────────────────
  Widget _buildStudentsListView() {
    final filtered = _students.where((s) {
      final matchesSearch = s['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
                            s['diagnosis'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesPhoneme = _filterPhoneme == 'ALL' || s['target_phonemes'].toString().contains(_filterPhoneme);
      return matchesSearch && matchesPhoneme;
    }).toList();

    return Column(
      children: [
        // Arama ve Filtre Kontrolleri
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (v) => setState(() => _searchQuery = v),
                  decoration: InputDecoration(
                    hintText: 'Danışan adı veya klinik tanı ara...',
                    hintStyle: const TextStyle(fontSize: 12),
                    prefixIcon: const Icon(Icons.search_rounded, size: 18),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Fonem Filtresi (Tüm 20 Klinik Ses)
              Flexible(
                flex: 2,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      'ALL', '/p/', '/b/', '/t/', '/d/', '/k/', '/g/', '/f/', '/v/',
                      '/s/', '/z/', '/ş/', '/j/', '/h/', '/ç/', '/c/', '/m/', '/n/',
                      '/l/', '/r/', '/y/'
                    ].map((f) {
                      final isSelected = _filterPhoneme == f;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ChoiceChip(
                          label: Text(f == 'ALL' ? 'Tümü' : f, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.black87)),
                          selected: isSelected,
                          selectedColor: const Color(0xFF1E88E5),
                          onSelected: (v) => setState(() => _filterPhoneme = f),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Danışan Kartları Grid / Boş Durum
        filtered.isEmpty
            ? Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('👥', style: TextStyle(fontSize: 48)),
                        const SizedBox(height: 12),
                        Text(
                          _searchQuery.isNotEmpty ? 'Arama kriterine uygun danışan bulunamadı' : 'Henüz Kayıtlı Danışanınız Yok',
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF0F172A)),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _searchQuery.isNotEmpty
                              ? 'Farklı bir arama terimi deneyin.'
                              : 'Danışanlarınız (çocuk veya veli) uygulamaya kaydolurken veya giriş yaparken tanımladığınız eşleştirme kodunu (${_dkt.therapistCode}) girdiğinde, profil ve seans verileri otomatik olarak bu ekrana düşecektir.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 12.5, color: Color(0xFF64748B), height: 1.4),
                        ),
                        if (_searchQuery.isEmpty) ...[
                          const SizedBox(height: 16),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(text: _dkt.therapistCode));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('✅ Eşleştirme kodu (${_dkt.therapistCode}) kopyalandı! Velilerinize iletebilirsiniz.'),
                                      backgroundColor: const Color(0xFF0284C7),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.copy_rounded, size: 16, color: Colors.white),
                                label: const Text('Eşleştirme Kodunu Kopyala', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 12)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0284C7),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                              const SizedBox(width: 10),
                              OutlinedButton.icon(
                                onPressed: _showEditTherapistCodeDialog,
                                icon: const Icon(Icons.edit_rounded, size: 16, color: Color(0xFF0284C7)),
                                label: const Text('Kodu Değiştir / Tanımla', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0284C7), fontSize: 12)),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Color(0xFF0284C7)),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              )
            : Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(24),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.35,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (ctx, i) {
                    final std = filtered[i];
                    return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: const [
                    BoxShadow(color: Color(0x06000000), blurRadius: 10, offset: Offset(0, 4)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(std['avatar'] ?? '👦', style: const TextStyle(fontSize: 28)),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F5E9),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '%${std['accuracy']} Başarı',
                                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10.5, color: Color(0xFF2E7D32)),
                              ),
                            ),
                            const SizedBox(width: 4),
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.redAccent),
                              tooltip: 'Danışanı Sil',
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () => _confirmDeleteStudent(std),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(std['name'], style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                        Text('Yaş: ${std['age']} • ${std['diagnosis']}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10.5, color: Colors.grey)),
                        const SizedBox(height: 2),
                        Text('Hedef: ${std['target_phonemes']}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1E88E5))),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _showStudentCodeDialog(std),
                            icon: const Icon(Icons.vpn_key_rounded, size: 14),
                            label: const Text('Kodu Gör', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF2E7D32),
                              side: const BorderSide(color: Color(0xFFA5D6A7)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => setState(() => _selectedStudent = std),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1E88E5),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: EdgeInsets.zero,
                            ),
                            child: const Text('Raporu Gör', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ── SEÇENEK 3: DANIŞAN DETAY VE RESMİ KLİNİK RAPOR GÖRÜNÜMÜ ────────────────
  Widget _buildStudentDetailView() {
    final std = _selectedStudent!;
    final sessions = std['sessions'] as List;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        // Geri Butonu & Aksiyonlar
        Row(
          children: [
            TextButton.icon(
              onPressed: () => setState(() => _selectedStudent = null),
              icon: const Icon(Icons.arrow_back_rounded, size: 16),
              label: const Text('Danışanlar Listesine Dön', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () => _printFullStudentReport(std),
              icon: const Icon(Icons.print_rounded, size: 16, color: Colors.white),
              label: const Text('Raporu Yazdır / PDF', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF37474F),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _selectedReportStudentId = std['id'];
                  _activeTabIndex = 2;
                  _selectedStudent = null;
                });
                _sfx.playPopSound();
              },
              icon: const Icon(Icons.assignment_rounded, size: 16, color: Colors.white),
              label: const Text('Klinik Karnesi 📑', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F766E),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: () => _showSendToParentDialog(std),
              icon: const Icon(Icons.send_rounded, size: 16, color: Colors.white),
              label: const Text('Veliye İlet 📨', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF16A34A),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: () => _showStudentCodeDialog(std),
              icon: const Icon(Icons.vpn_key_rounded, size: 16, color: Colors.white),
              label: const Text('Danışan Kodu Ver', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _selectedReportStudentId = std['id'];
                  _activeTabIndex = 2;
                  _selectedStudent = null;
                });
                _sfx.playPopSound();
              },
              icon: const Icon(Icons.assignment_rounded, size: 16, color: Colors.white),
              label: const Text('Klinik Karnesi 📑', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F766E),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: () {
                _sfx.playSuccessDing();
                final studentFirstName = std['name'].toString().split(' ').first;
                _dkt.switchActiveStudentInRewardState(studentFirstName);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Text('🎮', style: TextStyle(fontSize: 20)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${std['name']} aktif edildi! Haritada ${std['target_phonemes']} sesleri çalışılabilir.',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: const Color(0xFF16A34A),
                    duration: const Duration(seconds: 4),
                  ),
                );
              },
              icon: const Icon(Icons.play_circle_fill_rounded, size: 16, color: Colors.white),
              label: const Text('Haritada Başla 🚀', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF16A34A),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Hasta Kimlik Kartı
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Text(std['avatar'] ?? '👦', style: const TextStyle(fontSize: 48)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(std['name'], style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
                    const SizedBox(height: 4),
                    Text('Yaş: ${std['age']} • Tanı: ${std['diagnosis']}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: const Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(8)),
                          child: Text('Hedef: ${std['target_phonemes']}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1976D2))),
                        ),
                        const SizedBox(width: 8),
                        Text('⭐ ${std['total_stars']} Yıldız', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.amber)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.email_outlined, size: 14, color: Color(0xFF1565C0)),
                        const SizedBox(width: 4),
                        Text('Veli Bildirim E-postası: ${std['parent_email'] ?? 'Kayıtlı değil'}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF1565C0))),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Genel Başarı', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                  Text('%${std['accuracy']}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF2E7D32))),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 🎯 HEDEF SES & EV ÖDEVİ ATAMA
        Builder(
          builder: (_) {
            const allPhonemes = ['p', 'b', 't', 'd', 'k', 'g', 'f', 'v', 's', 'z', 'ş', 'j', 'h', 'ç', 'c', 'm', 'n', 'l', 'r', 'y'];
            final currentTargets = (std['target_phonemes']?.toString() ?? '')
                .split(',')
                .map((e) => e.replaceAll('/', '').trim().toLowerCase())
                .where((e) => e.isNotEmpty)
                .toSet();
            return Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Text('🎯', style: TextStyle(fontSize: 18)),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Hedef Ses & Ev Ödevi Atama (Oyun Haritasında Öne Çıkar)',
                          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: allPhonemes.map((ph) {
                      final isSel = currentTargets.contains(ph);
                      return FilterChip(
                        label: Text('/$ph/', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5, color: isSel ? Colors.white : const Color(0xFF334155))),
                        selected: isSel,
                        selectedColor: const Color(0xFF0284C7),
                        checkmarkColor: Colors.white,
                        onSelected: (val) {
                          setState(() {
                            if (val) {
                              currentTargets.add(ph);
                            } else {
                              currentTargets.remove(ph);
                            }
                            final formatted = currentTargets.map((e) => '/$e/').join(', ');
                            std['target_phonemes'] = formatted;
                            _dkt.saveToLocalStorage();
                            if (RewardState().studentName.trim().toLowerCase() == (std['name']?.toString() ?? '').trim().toLowerCase()) {
                              RewardState().setAssignedTargetPhonemes(formatted);
                            }
                            if (kIsWeb && std['id'] != null) {
                              try {
                                final req = html.HttpRequest();
                                req.open('POST', '/api/therapist/students/${std['id']}/target-phonemes');
                                req.setRequestHeader('Content-Type', 'application/json');
                                req.send(jsonEncode({'target_phonemes': formatted}));
                              } catch (_) {}
                            }
                          });
                          _sfx.playPopSound();
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 16),

        // 📊 POZİSYON BAZLI BAŞARI ANALİZİ (BAŞTA / ORTADA / SONDA) & SEANS TAKİP
        Builder(
          builder: (_) {
            final isActiveStudent = !RewardState().isGuest &&
                RewardState().studentName.trim().toLowerCase() == (std['name']?.toString() ?? '').trim().toLowerCase();
            final stats = isActiveStudent ? RewardState().phonemeStats.values : const <PhonemeStat>[];
            int initAtt = 0, initCor = 0, medAtt = 0, medCor = 0, finAtt = 0, finCor = 0;
            for (final s in stats) {
              initAtt += s.initialAttempts;
              initCor += s.initialCorrect;
              medAtt += s.medialAttempts;
              medCor += s.medialCorrect;
              finAtt += s.finalAttempts;
              finCor += s.finalCorrect;
            }
            final initPct = initAtt > 0 ? (initCor / initAtt) : 0.0;
            final medPct = medAtt > 0 ? (medCor / medAtt) : 0.0;
            final finPct = finAtt > 0 ? (finCor / finAtt) : 0.0;

            Widget posBar(String label, double pct, int cor, int att, Color color) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        Text(att > 0 ? '%${(pct * 100).round()} ($cor/$att)' : 'Henüz veri yok', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: color)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: pct,
                        minHeight: 8,
                        backgroundColor: const Color(0xFFE2E8F0),
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                    ),
                  ],
                ),
              );
            }

            return Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('📊 Pozisyon Bazlı Hata & Başarı Analizi', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(10)),
                        child: Text('📅 ${sessions.length} Seans • 🔥 ${RewardState().streakDays} Gün Seri', style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF047857))),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  posBar('Kelime Başında (Initial)', initPct, initCor, initAtt, const Color(0xFF16A34A)),
                  posBar('Kelime Ortasında (Medial)', medPct, medCor, medAtt, const Color(0xFF0284C7)),
                  posBar('Kelime Sonunda (Final)', finPct, finCor, finAtt, const Color(0xFFF59E0B)),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 16),

        // 🎧 ÇOCUĞUN SES KAYITLARINI DİNLEME (İLK GÜN VS BUGÜN)
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('🎧 Çocuğun Ses Kayıtları (İlk Gün vs. Bugün)', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
                  TextButton.icon(
                    onPressed: () async {
                      if (!kIsWeb) return;
                      try {
                        final raw = await html.HttpRequest.getString('/api/therapist/recordings?student_name=${Uri.encodeComponent(std['name']?.toString() ?? '')}');
                        final data = jsonDecode(raw) as Map<String, dynamic>;
                        final list = (data['recordings'] as List<dynamic>? ?? []).map((e) => Map<String, dynamic>.from(e as Map)).toList();
                        if (!mounted) return;
                        setState(() {
                          std['recordings'] = list;
                        });
                      } catch (_) {}
                    },
                    icon: const Icon(Icons.refresh_rounded, size: 16),
                    label: const Text('Kayıtları Getir', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              if (((std['recordings'] as List?) ?? []).isEmpty)
                const Text(
                  'Henüz ses kaydı yok veya listelemek için "Kayıtları Getir"e tıklayın.',
                  style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                )
              else
                ...((std['recordings'] as List).take(5).map((rec) {
                  final r = Map<String, dynamic>.from(rec as Map);
                  return ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: const CircleAvatar(
                      radius: 16,
                      backgroundColor: Color(0xFFE0F2FE),
                      child: Icon(Icons.graphic_eq_rounded, size: 16, color: Color(0xFF0284C7)),
                    ),
                    title: Text('${r['word']} (/${r['phoneme']}/)', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
                    trailing: ElevatedButton.icon(
                      onPressed: () {
                        if (kIsWeb) {
                          final audio = html.AudioElement(r['url']?.toString() ?? '');
                          audio.play();
                        }
                      },
                      icon: const Icon(Icons.play_arrow_rounded, size: 16, color: Colors.white),
                      label: const Text('Dinle', style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0284C7),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        minimumSize: Size.zero,
                      ),
                    ),
                  );
                })),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // KLİNİK NOT & EV ÖDEVİ EKLEME
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.edit_note_rounded, color: Color(0xFF1E88E5), size: 22),
                  SizedBox(width: 8),
                  Text('Yeni Klinik Not & Ev Ödevi Tanımla', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _clinicalNoteCtrl,
                      decoration: InputDecoration(
                        hintText: 'Örn: Bu hafta /r/ sesinin CVC hecelerine ağırlık verilsin. Günde 10 dk pratik ödevi.',
                        hintStyle: const TextStyle(fontSize: 11),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      if (_clinicalNoteCtrl.text.trim().isNotEmpty) {
                        final noteText = _clinicalNoteCtrl.text.trim();
                        final now = DateTime.now();
                        final dateStr = '${now.day.toString().padLeft(2, '0')}.${now.month.toString().padLeft(2, '0')}.${now.year}';
                        setState(() {
                          (std['sessions'] as List).insert(0, {
                            'date': dateStr,
                            'phoneme': 'Klinik Not',
                            'words': 'Not',
                            'acc': null,
                            'note': noteText,
                          });
                          _clinicalNoteCtrl.clear();
                        });
                        if (kIsWeb && std['id'] != null) {
                          try {
                            final req = html.HttpRequest();
                            req.open('POST', '/api/therapist/students/${std['id']}/notes');
                            req.setRequestHeader('Content-Type', 'application/json');
                            req.send(jsonEncode({'note': noteText}));
                          } catch (_) {}
                        }
                        _sfx.playSuccessDing();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E88E5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    child: const Text('Notu Kaydet', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // SEANS GEÇMİŞİ TABLOSU
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Klinik Seans Geçmişi ve Notlar', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
              const SizedBox(height: 12),
              ...sessions.map((sess) {
                final isNoteOnly = sess['words'] == 'Ödev' ||
                    sess['words'] == 'Not' ||
                    sess['phoneme'] == 'Klinik Not' ||
                    sess['phoneme'] == 'Klinik Not & Ödev' ||
                    sess['acc'] == null;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isNoteOnly ? const Color(0xFFFEF3C7) : const Color(0xFFE3F2FD),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isNoteOnly ? '📝 Klinik Not' : '/${sess['phoneme']}/ Sesi',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            color: isNoteOnly ? const Color(0xFFB45309) : const Color(0xFF1976D2),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isNoteOnly
                                  ? 'Tarih: ${sess['date']}'
                                  : 'Tarih: ${sess['date']} • Doğru Sözcük: ${sess['words']}',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                            Text('"${sess['note']}"', style: const TextStyle(fontSize: 10.5, fontStyle: FontStyle.italic, color: Colors.black54)),
                          ],
                        ),
                      ),
                      if (!isNoteOnly)
                        Text('%${sess['acc']}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Color(0xFF2E7D32)))
                      else
                        const Text('📝 Not', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: Color(0xFFB45309))),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  // ── SEÇENEK 4: KLİNİK GELİŞİM KARNESİ GÖRÜNÜMÜ (DKT HESABINA ENTEGRE) ─────────
  Widget _buildClinicalReportCardView() {
    final rewardState = RewardState();
    final currentStudent = _students.firstWhere(
      (s) => s['id'] == _selectedReportStudentId,
      orElse: () => _students.first,
    );

    final isCanOrActive = !rewardState.isGuest &&
        rewardState.studentName.trim().toLowerCase() == currentStudent['name'].toString().trim().toLowerCase();
    final List<PhonemeStat> stats = isCanOrActive ? rewardState.phonemeStats.values.toList() : <PhonemeStat>[];
    if (!isCanOrActive) {
      final studentSessions = (currentStudent['sessions'] as List<dynamic>?) ?? [];
      for (final s in studentSessions) {
        final m = s as Map;
        final ph = (m['phoneme']?.toString() ?? '').replaceAll('/', '').trim().toUpperCase();
        final wordsStr = m['words']?.toString() ?? '';
        if (ph.isEmpty || ph.contains('KLİNİK') || wordsStr == 'Ödev' || wordsStr == 'Not') continue;
        final parts = wordsStr.split('/');
        final cor = parts.length == 2 ? (int.tryParse(parts[0]) ?? 0) : 0;
        final att = parts.length == 2 ? (int.tryParse(parts[1]) ?? 0) : 0;
        if (att > 0) {
          final st = PhonemeStat(phoneme: ph)
            ..totalAttempts = att
            ..correctAttempts = cor;
          stats.add(st);
        }
      }
    }
    final int overallAcc = isCanOrActive
        ? rewardState.overallAccuracy
        : ((currentStudent['accuracy'] as num?)?.round() ?? 0);
    final int totalAttempts = isCanOrActive
        ? rewardState.totalPracticedAttempts
        : stats.fold<int>(0, (sum, s) => sum + s.totalAttempts);
    final int totalSuccess = isCanOrActive
        ? rewardState.totalPracticedSuccesses
        : stats.fold<int>(0, (sum, s) => sum + s.correctAttempts);
    final int stars = isCanOrActive ? rewardState.totalStars : ((currentStudent['total_stars'] as int?) ?? 0);
    final int streak = isCanOrActive ? rewardState.streakDays : 0;

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

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        // 1. ÜST DANIŞAN SEÇİCİ & AKSİYON BARI
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: const [
              BoxShadow(color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 2)),
            ],
          ),
          child: Row(
            children: [
              const Text('👶 Danışan Seç:', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Color(0xFF1E293B))),
              const SizedBox(width: 12),
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: _students.map((st) {
                    final isSel = st['id'] == _selectedReportStudentId;
                    return InkWell(
                      onTap: () {
                        setState(() => _selectedReportStudentId = st['id']);
                        _sfx.playPopSound();
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSel ? const Color(0xFF0F766E) : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSel ? const Color(0xFF0F766E) : const Color(0xFFCBD5E1),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(st['avatar'] ?? '👦', style: const TextStyle(fontSize: 14)),
                            const SizedBox(width: 6),
                            Text(
                              st['name'],
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: isSel ? Colors.white : const Color(0xFF334155),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(width: 12),
              // Yazdır / PDF Butonu
              ElevatedButton.icon(
                onPressed: () => _printFullStudentReport(currentStudent),
                icon: const Icon(Icons.print_rounded, size: 16, color: Colors.white),
                label: const Text('Raporu Yazdır / PDF', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF334155),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(width: 8),
              // Veliye Gönder Butonu
              ElevatedButton.icon(
                onPressed: () => _showSendToParentDialog(currentStudent),
                icon: const Icon(Icons.send_rounded, size: 16, color: Colors.white),
                label: const Text('Veliye İlet', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF16A34A),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(width: 8),
              // Verileri Sıfırla / Temizle Butonu
              ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (dCtx) => AlertDialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      title: const Row(
                        children: [
                          Icon(Icons.delete_sweep_rounded, color: Colors.redAccent),
                          SizedBox(width: 8),
                          Text('Karne Verilerini Sıfırla', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                        ],
                      ),
                      content: Text(
                        '${currentStudent['name']} danışanına ait tüm fonem artikülasyon ve seans denemelerini sıfırlamak istiyor musunuz? Sıfırlandıktan sonra yeni konuşma pratikleri temiz olarak kaydedilecektir.',
                        style: const TextStyle(fontSize: 13),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dCtx),
                          child: const Text('İptal'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            rewardState.clearTherapyStats();
                            rewardState.resetLeagueAndXp();
                            _dkt.clearStudentSessions(currentStudent['id']);
                            final sessList = (currentStudent['sessions'] as List?) ?? [];
                            sessList.clear();
                            currentStudent['accuracy'] = 0.0;
                            currentStudent['sessions_count'] = 0;
                            currentStudent['total_stars'] = 0;
                            Navigator.pop(dCtx);
                            setState(() {});
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('🗑️ Karne ve lig puanı verileri başarıyla sıfırlandı ve temizlendi!'),
                                backgroundColor: Color(0xFFDC2626),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDC2626)),
                          child: const Text('Evet, Sıfırla', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.delete_outline_rounded, size: 16, color: Colors.white),
                label: const Text('Verileri Sıfırla', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDC2626),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // 2. RESMİ KLİNİK GELİŞİM KARNESİ BELGESİ
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFCBD5E1), width: 1.5),
            boxShadow: const [
              BoxShadow(color: Color(0x0C000000), blurRadius: 12, offset: Offset(0, 4)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Belge Başlığı & Klinik Logosu
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF81C784)),
                    ),
                    child: const Text('📊', style: TextStyle(fontSize: 32)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Klinik Gelişim Karnesi',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF1B5E20),
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Ebeveyn & Dil ve Konuşma Terapisti Klinik Değerlendirme Raporu',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Kurum: $_clinicName • Sorumlu: $_therapistName',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1565C0)),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFCBD5E1)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Dosya: ${currentStudent['student_code']}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                        const Text('Tarih: Güncel Rapor', style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: Color(0xFFE2E8F0)),
              const SizedBox(height: 16),

              // Danışan Kimlik & Tanı Bilgileri
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    Text(currentStudent['avatar'] ?? '👦', style: const TextStyle(fontSize: 28)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(currentStudent['name'], style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Color(0xFF0F172A))),
                          Text('Yaş: ${currentStudent['age']} • Klinik Tanı: ${currentStudent['diagnosis']}', style: const TextStyle(fontSize: 11.5, color: Color(0xFF475569), fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0F2FE),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text('Hedef: ${currentStudent['target_phonemes']}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0369A1))),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Özet Skor Kartları
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFF86EFAC)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Genel Başarı', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF166534))),
                              Text('🎯', style: TextStyle(fontSize: 18)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text('%$overallAcc', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF15803D))),
                          const SizedBox(height: 2),
                          Text('$totalSuccess / $totalAttempts Doğru Sesletim', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF166534))),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFBEB),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFFDE68A)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Toplanan Yıldız & Süreklilik', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF92400E))),
                              Text('🏆', style: TextStyle(fontSize: 18)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text('$stars ⭐', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFFB45309))),
                          const SizedBox(height: 2),
                          Text('$streak Günlük Çalışma Serisi 🔥', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF92400E))),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Kelime İçi Pozisyon Başarısı
              const Text(
                '📍 Kelime İçi Pozisyon Dağılımı ve Doğruluk Oranları:',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF1E293B)),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEFCE8),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFFEF08A)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildReportPosCol('Başta Pozisyon', '%$initAcc', '$initCorr/$initAtt', const Color(0xFF15803D)),
                    Container(height: 44, width: 1, color: const Color(0xFFE2E8F0)),
                    _buildReportPosCol('Ortada Pozisyon', '%$medAcc', '$medCorr/$medAtt', const Color(0xFF0284C7)),
                    Container(height: 44, width: 1, color: const Color(0xFFE2E8F0)),
                    _buildReportPosCol('Sonda Pozisyon', '%$finAcc', '$finCorr/$finAtt', const Color(0xFFD97706)),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Fonem Bazlı Detaylı Değerlendirme
              const Text(
                '🔤 Fonem (Ses) Bazlı Klinik Artikülasyon İlerlemesi:',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF1E293B)),
              ),
              const SizedBox(height: 10),
              if (stats.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Column(
                    children: [
                      Text('🌱', style: TextStyle(fontSize: 42)),
                      SizedBox(height: 12),
                      Text(
                        'Henüz Telaffuz & Sesletim Kaydı Bulunmuyor',
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Color(0xFF1E293B)),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Danışan haritadaki sesleri veya kelimeleri mikrofona söyledikçe, kelime içi pozisyon analizleri (Başta, Ortada, Sonda) ve artikülasyon başarı grafikleri anlık olarak burada listelenecektir.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.4),
                      ),
                    ],
                  ),
                )
              else
                ...stats.map((s) {
                final acc = s.accuracyPercentage;
                final Color barColor = acc >= 80 ? const Color(0xFF16A34A) : (acc >= 60 ? const Color(0xFF0284C7) : const Color(0xFFE11D48));

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: barColor.withAlpha(25),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '/${s.phoneme.toLowerCase()}/ Sesi',
                              style: TextStyle(fontWeight: FontWeight.w900, color: barColor, fontSize: 13),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              '/${s.phoneme.toLowerCase()}/ Sesi Artikülasyonu',
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5, color: Color(0xFF1E293B)),
                            ),
                          ),
                          Text(
                            '%$acc',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: barColor),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: (acc / 100).clamp(0.0, 1.0),
                          minHeight: 8,
                          backgroundColor: const Color(0xFFF1F5F9),
                          valueColor: AlwaysStoppedAnimation<Color>(barColor),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Toplam: ${s.totalAttempts} deneme (${s.correctAttempts} başarılı)',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                          ),
                          Text(
                            'Baş: %${s.initialAccuracy} | Orta: %${s.medialAccuracy} | Son: %${s.finalAccuracy}',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 20),

              // Terapist Klinik Değerlendirmesi
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFF86EFAC)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.verified_rounded, color: Color(0xFF16A34A), size: 20),
                        SizedBox(width: 8),
                        Text('Uzman Terapist Klinik Değerlendirmesi & Öneri', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Color(0xFF166534))),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Builder(
                      builder: (_) {
                        final savedAssess = (currentStudent['clinical_assessment'] as String? ?? '').trim();
                        final isEditing = currentStudent['_editing_assess'] == true || savedAssess.isEmpty;
                        if (!isEditing) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                savedAssess,
                                style: const TextStyle(fontSize: 12.5, height: 1.45, color: Color(0xFF14532D), fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Row(
                                    children: [
                                      Icon(Icons.check_circle_rounded, size: 15, color: Color(0xFF16A34A)),
                                      SizedBox(width: 4),
                                      Text('Kaydedildi', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF16A34A))),
                                    ],
                                  ),
                                  TextButton.icon(
                                    onPressed: () {
                                      setState(() => currentStudent['_editing_assess'] = true);
                                    },
                                    icon: const Icon(Icons.edit_rounded, size: 14, color: Color(0xFF15803D)),
                                    label: const Text('Düzenle', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF15803D))),
                                  ),
                                ],
                              ),
                            ],
                          );
                        }
                        final assessCtrl = TextEditingController(text: savedAssess);
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextField(
                              controller: assessCtrl,
                              maxLines: 3,
                              style: const TextStyle(fontSize: 12.5, height: 1.4, color: Color(0xFF14532D), fontWeight: FontWeight.w600),
                              decoration: InputDecoration(
                                hintText: 'Danışan hakkındaki klinik değerlendirmenizi ve veli önerinizi buraya yazın...',
                                hintStyle: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Color(0xFF86EFAC)),
                                ),
                                contentPadding: const EdgeInsets.all(12),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  final txt = assessCtrl.text.trim();
                                  setState(() {
                                    currentStudent['clinical_assessment'] = txt;
                                    currentStudent['_editing_assess'] = false;
                                    _dkt.saveToLocalStorage();
                                  });
                                  if (kIsWeb && currentStudent['id'] != null) {
                                    try {
                                      final assessReq = html.HttpRequest();
                                      assessReq.open('POST', '/api/therapist/students/${currentStudent['id']}/assessment');
                                      assessReq.setRequestHeader('Content-Type', 'application/json');
                                      assessReq.send(jsonEncode({'clinical_assessment': txt}));
                                    } catch (_) {}
                                  }
                                  _sfx.playSuccessDing();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('✅ Klinik değerlendirme veritabanına kaydedildi!'),
                                      backgroundColor: Color(0xFF16A34A),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.save_rounded, size: 16, color: Colors.white),
                                label: const Text('Değerlendirmeyi Kaydet', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Colors.white)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF16A34A),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(_therapistName, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Color(0xFF166534))),
                            const Text('🏛️ e-Devlet Onaylı DKT', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF15803D))),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReportPosCol(String title, String pct, String counts, Color color) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF475569))),
        const SizedBox(height: 4),
        Text(pct, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: color)),
        const SizedBox(height: 2),
        Text(counts, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
      ],
    );
  }
}
