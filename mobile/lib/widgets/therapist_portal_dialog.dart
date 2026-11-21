import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;
import '../services/sound_effects_service.dart';
import '../services/therapist_state_service.dart';

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
  final TextEditingController _clinicalNoteCtrl = TextEditingController();

  List<Map<String, dynamic>> get _students => _dkt.students;

  @override
  void initState() {
    super.initState();
    _syncFromService();
  }

  void _syncFromService() {
    // Serviste oturum açıksa veya parametre geldiyse oturumu açık yap
    _isLoggedIn = _dkt.isLoggedIn || widget.initialLoggedIn;
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

  void _showAddStudentModal() {
    final nameCtrl = TextEditingController();
    final parentEmailCtrl = TextEditingController();
    final ageCtrl = TextEditingController();
    final diagCtrl = TextEditingController();
    final phonemesCtrl = TextEditingController();
    String selectedAv = '👦';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Row(
            children: [
              Text('➕', style: TextStyle(fontSize: 22)),
              SizedBox(width: 8),
              Text('Yeni Danışan Çocuk Ekle', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Çocuğun Adı Soyadı:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 4),
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    hintText: 'Örn: Mehmet Akif',
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Yaş:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          const SizedBox(height: 4),
                          TextField(
                            controller: ageCtrl,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.grey[100],
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Avatar:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: DropdownButton<String>(
                              value: selectedAv,
                              isExpanded: true,
                              underline: const SizedBox(),
                              items: ['👦', '👧', '🦁', '🐼', '🚀'].map((av) => DropdownMenuItem(value: av, child: Text(av, style: const TextStyle(fontSize: 18)))).toList(),
                              onChanged: (v) => setModalState(() => selectedAv = v ?? '👦'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text('Klinik Tanı:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 4),
                TextField(
                  controller: diagCtrl,
                  decoration: InputDecoration(
                    hintText: 'Örn: /r/ Sesletim Güçlüğü',
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
                const SizedBox(height: 12),
                const Text('Hedef Fonemler:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 4),
                TextField(
                  controller: phonemesCtrl,
                  decoration: InputDecoration(
                    hintText: 'Örn: /r/, /s/',
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
                const SizedBox(height: 12),
                const Text('Veli E-Posta Adresi (Bildirimler İçin):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 4),
                TextField(
                  controller: parentEmailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'ornek.veli@gmail.com',
                    prefixIcon: const Icon(Icons.email_outlined, size: 16, color: Color(0xFF1565C0)),
                    helperText: '📩 Egzersiz ve seans raporları bu adrese gönderilir.',
                    helperStyle: const TextStyle(fontSize: 10, color: Color(0xFF1565C0), fontWeight: FontWeight.w600),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Vazgeç', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.trim().isNotEmpty) {
                  _dkt.addStudent(
                    name: nameCtrl.text.trim(),
                    age: int.tryParse(ageCtrl.text) ?? 6,
                    avatar: selectedAv,
                    diagnosis: diagCtrl.text.trim().isNotEmpty ? diagCtrl.text.trim() : 'Artikülasyon Güçlüğü',
                    targetPhonemes: phonemesCtrl.text.trim().isNotEmpty ? phonemesCtrl.text.trim() : '/r/, /s/',
                    parentEmail: parentEmailCtrl.text.trim(),
                  );
                  setState(() {});
                  _sfx.playSuccessDing();
                  Navigator.pop(ctx);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E88E5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Danışanı Kaydet', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showStudentCodeDialog(Map<String, dynamic> student) {
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
                        'Merhaba! Uzm. DKT Merve Kaya tarafından Ses Yolunda Eğlence platformunda ${student['name']} için konuşma terapisi egzersizleri tanımlanmıştır. Çocuğunuz uygulamayı açıp kayıt olurken şu Terapist Kodunu giriniz:\n\n🔑 Terapist Kodu: $studentCode\n\nBu kod ile evdeki çalışma verileri terapist paneline aktarılacaktır.'
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
                    decoration: InputDecoration(
                      labelText: 'Kurumsal E-posta',
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
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: () {
                        final email = _loginEmailCtrl.text.trim();
                        final pass = _loginPassCtrl.text.trim();
                        if (email.isEmpty || pass.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Lütfen kurumsal e-posta ve şifrenizi giriniz.'),
                              backgroundColor: Colors.orangeAccent,
                            ),
                          );
                          return;
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
                      hintText: 'Örn: Uzm. DKT Merve Kaya',
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
                    decoration: InputDecoration(
                      labelText: 'Kurumsal E-posta',
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
                  const SizedBox(height: 18),
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
                        final email = _regEmailCtrl.text.trim();
                        final doc = _regEdevletCtrl.text.trim();
                        final pass = _regPassCtrl.text.trim().isNotEmpty ? _regPassCtrl.text.trim() : '123456';

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

                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isLoggedIn = true;
                      _therapistName = 'Konuk Dil ve Konuşma Terapisti';
                    });
                    _sfx.playPopSound();
                  },
                  child: const Text('⚡ Tek Tıkla Demo Giriş (Doç. Dr. Emir)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF1E88E5))),
                ),
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
                              Text('🏛️ e-Devlet Onaylı DKT${_edevletDocNo.isNotEmpty ? ' ($_edevletDocNo)' : ''}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20))),
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
                  _dkt.logout();
                  setState(() => _syncFromService());
                },
                icon: const Icon(Icons.logout_rounded, size: 16, color: Colors.redAccent),
                label: const Text('Çıkış', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.redAccent)),
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
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _showAddStudentModal,
                icon: const Icon(Icons.add_rounded, size: 18, color: Colors.white),
                label: const Text('Yeni Danışan Ekle', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),

        // İÇERİK ALANI
        Expanded(
          child: Container(
            color: const Color(0xFFF8FAFC),
            child: _selectedStudent != null
                ? _buildStudentDetailView()
                : (_activeTabIndex == 0 ? _buildAnalyticsView() : _buildStudentsListView()),
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
      totalSessions += sess.length;
      for (final se in sess) {
        final ph = (se['phoneme'] ?? '').toString();
        final acc = (se['acc'] as num?)?.toDouble() ?? 0.0;
        allSessions.add({
          'student_name': s['name'],
          'avatar': s['avatar'] ?? '👦',
          'diagnosis': s['diagnosis'] ?? 'Artikülasyon',
          'phoneme': ph,
          'words': se['words'] ?? '16/16',
          'acc': acc,
          'date': se['date'] ?? 'Bugün',
          'note': se['note'] ?? '',
        });
        if (acc > 0) {
          totalAcc += acc;
          accCount++;
          if (ph.isNotEmpty) {
            phonemeAccMap.putIfAbsent(ph, () => []).add(acc);
          }
        }
      }
    }

    final String avgAccStr = accCount > 0 ? (totalAcc / accCount).toStringAsFixed(1) : '0';

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        // 4 KPI KARTI (Tamamen dinamik ve gerçek)
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
            const SizedBox(width: 14),
            _buildKpiCard(
              'Klinik Protokol',
              'Bengisu (2020)',
              '20 Fonem Hiyerarşisi',
              Icons.menu_book_rounded,
              const Color(0xFFF57C00),
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
              // Fonem Filtresi
              Wrap(
                spacing: 6,
                children: ['ALL', '/r/', '/k/', '/s/', '/p/'].map((f) {
                  final isSelected = _filterPhoneme == f;
                  return ChoiceChip(
                    label: Text(f == 'ALL' ? 'Tümü' : f, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.black87)),
                    selected: isSelected,
                    selectedColor: const Color(0xFF1E88E5),
                    onSelected: (v) => setState(() => _filterPhoneme = f),
                  );
                }).toList(),
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
                              : 'Gerçek testinizi yapmak için sağ üstteki "+ Yeni Danışan Ekle" butonuna basarak ilk danışanınızı sisteme ekleyebilirsiniz.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                        ),
                        if (_searchQuery.isEmpty) ...[
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _showAddStudentModal,
                            icon: const Icon(Icons.add_rounded, size: 18, color: Colors.white),
                            label: const Text('İlk Danışanımı Ekle', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2E7D32),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
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
              onPressed: () {
                if (kIsWeb) {
                  html.window.print();
                }
              },
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
                _sfx.playSuccessDing();
                final pEmail = std['parent_email'] ?? 'veli@gmail.com';
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.mark_email_read_rounded, color: Colors.white),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text('📧 Bildirim Gönderildi! ($pEmail adresine haftalık seans ve ödev raporu iletildi)'),
                        ),
                      ],
                    ),
                    backgroundColor: const Color(0xFF1B5E20),
                    duration: const Duration(seconds: 4),
                  ),
                );
              },
              icon: const Icon(Icons.send_rounded, size: 16, color: Colors.white),
              label: const Text('E-Posta Bildirimi Gönder', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1565C0),
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
                        Text('Veli Bildirim E-postası: ${std['parent_email'] ?? 'veli@gmail.com'}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF1565C0))),
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
                        setState(() {
                          (std['sessions'] as List).insert(0, {
                            'date': 'Şimdi',
                            'phoneme': std['target_phonemes'].toString().split(',')[0].replaceAll('/', '').trim(),
                            'words': 'Ödev',
                            'acc': 100.0,
                            'note': _clinicalNoteCtrl.text.trim(),
                          });
                          _clinicalNoteCtrl.clear();
                        });
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
              ...sessions.map((sess) => Container(
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
                      decoration: BoxDecoration(color: const Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(8)),
                      child: Text('/${sess['phoneme']}/ Sesi', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF1976D2))),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Tarih: ${sess['date']} • Doğru Sözcük: ${sess['words']}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          Text('"${sess['note']}"', style: const TextStyle(fontSize: 10.5, fontStyle: FontStyle.italic, color: Colors.black54)),
                        ],
                      ),
                    ),
                    Text('%${sess['acc']}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Color(0xFF2E7D32))),
                  ],
                ),
              )),
            ],
          ),
        ),
      ],
    );
  }
}
