import re

with open('mobile/lib/widgets/therapist_portal_dialog.dart', 'r', encoding='utf-8') as f:
    text = f.read()

# Add import
if "import '../services/therapist_state_service.dart';" not in text:
    text = text.replace("import '../services/sound_effects_service.dart';", "import '../services/sound_effects_service.dart';\nimport '../services/therapist_state_service.dart';")

# Replace TherapistPortalDialog definition
old_dialog_def = """class TherapistPortalDialog extends StatefulWidget {
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
}"""

new_dialog_def = """class TherapistPortalDialog extends StatefulWidget {
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
}"""

# Update State variables and sync
old_state_def = """class _TherapistPortalDialogState extends State<TherapistPortalDialog> {
  final SoundEffectsService _sfx = SoundEffectsService();

  // Giriş / Kayıt Durumları (Gerçek ve Temiz Başlangıç)
  late bool _isLoggedIn;
  bool _isRegisterMode = false;
  late String _therapistName;
  late String _clinicName;
  late String _edevletDocNo;
  bool _isEdevletVerified = false;
  bool _isVerifyingEdevlet = false;

  final TextEditingController _loginEmailCtrl = TextEditingController();
  final TextEditingController _loginPassCtrl = TextEditingController();

  // Kayıt Kontrolcüleri (Kullanıcı kendi bilgilerini temizce girer)
  final TextEditingController _regNameCtrl = TextEditingController();
  final TextEditingController _regClinicCtrl = TextEditingController();
  final TextEditingController _regEdevletCtrl = TextEditingController();
  final TextEditingController _regEmailCtrl = TextEditingController();
  final TextEditingController _regPassCtrl = TextEditingController();

  // Aktif Sekme: 0 -> Analitik, 1 -> Danışanlar
  int _activeTabIndex = 0;

  // Danışan Arama ve Filtreleme
  String _searchQuery = '';
  String _filterPhoneme = 'ALL';

  // Seçili Danışan Detayı
  Map<String, dynamic>? _selectedStudent;
  final TextEditingController _clinicalNoteCtrl = TextEditingController();

  // Örnek Danışan Verileri (Klinik Takip Listesi)
  late List<Map<String, dynamic>> _students;

  @override
  void initState() {
    super.initState();
    _isLoggedIn = widget.initialLoggedIn;
    _therapistName = widget.initialName ?? 'Dil ve Konuşma Terapisti';
    _clinicName = widget.initialClinic ?? 'Dil ve Konuşma Danışmanlık Merkezi';
    _edevletDocNo = widget.initialEdevlet ?? '';
    _isEdevletVerified = widget.initialEdevlet != null && widget.initialEdevlet!.isNotEmpty;
    _students = []; // Gerçek kullanıcı deneyimi: Danışan listesi sıfırdan başlar!
  }"""

new_state_def = """class _TherapistPortalDialogState extends State<TherapistPortalDialog> {
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
  }"""

if old_state_def in text:
    text = text.replace(old_state_def, new_state_def, 1)
    print("Updated state definition and _syncFromService")
else:
    print("Could not find old_state_def")

# Update login button
old_login_btn = """                      onPressed: () {
                        if (_loginEmailCtrl.text.trim().isEmpty || _loginPassCtrl.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Lütfen kurumsal e-posta ve şifrenizi giriniz.'),
                              backgroundColor: Colors.orangeAccent,
                            ),
                          );
                          return;
                        }
                        setState(() {
                          _therapistName = _regNameCtrl.text.trim().isNotEmpty
                              ? _regNameCtrl.text.trim()
                              : _loginEmailCtrl.text.trim().split('@').first.toUpperCase();
                          _isLoggedIn = true;
                        });
                        _sfx.playSuccessDing();
                      },"""

new_login_btn = """                      onPressed: () {
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
                      },"""

if old_login_btn in text:
    text = text.replace(old_login_btn, new_login_btn, 1)
    print("Updated login button to use _dkt.loginTherapist")

# Update register submit button
old_reg_btn = """                      onPressed: () {
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
                        setState(() {
                          _therapistName = _regNameCtrl.text.trim();
                          _clinicName = _regClinicCtrl.text.trim().isNotEmpty ? _regClinicCtrl.text.trim() : 'Dil ve Konuşma Danışmanlık Merkezi';
                          _edevletDocNo = _regEdevletCtrl.text.trim();
                          _isLoggedIn = true;
                        });
                        _sfx.playVictoryFanfare();
                      },"""

new_reg_btn = """                      onPressed: () {
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
                      },"""

if old_reg_btn in text:
    text = text.replace(old_reg_btn, new_reg_btn, 1)
    print("Updated register button to use _dkt.registerTherapist")

# Update logout button
old_logout = """              // Çıkış Yap Butonu
              TextButton.icon(
                onPressed: () => setState(() => _isLoggedIn = false),"""

new_logout = """              // Çıkış Yap Butonu
              TextButton.icon(
                onPressed: () {
                  _dkt.logout();
                  setState(() => _syncFromService());
                },"""

if old_logout in text:
    text = text.replace(old_logout, new_logout, 1)
    print("Updated logout button to use _dkt.logout")

# Update add student in modal
old_add_student_save = """                  setState(() {
                    _students.insert(0, {
                      'id': _students.length + 1,
                      'name': nameCtrl.text.trim(),
                      'age': int.tryParse(ageCtrl.text) ?? 6,
                      'avatar': selectedAv,
                      'diagnosis': diagCtrl.text.trim().isNotEmpty ? diagCtrl.text.trim() : 'Artikülasyon Güçlüğü',
                      'target_phonemes': phonemesCtrl.text.trim().isNotEmpty ? phonemesCtrl.text.trim() : '/r/, /s/',
                      'parent_email': parentEmailCtrl.text.trim(),
                      'total_stars': 0,
                      'accuracy': 0.0,
                      'sessions_count': 0,
                      'sessions': [],
                    });
                  });"""

new_add_student_save = """                  _dkt.addStudent(
                    name: nameCtrl.text.trim(),
                    age: int.tryParse(ageCtrl.text) ?? 6,
                    avatar: selectedAv,
                    diagnosis: diagCtrl.text.trim().isNotEmpty ? diagCtrl.text.trim() : 'Artikülasyon Güçlüğü',
                    targetPhonemes: phonemesCtrl.text.trim().isNotEmpty ? phonemesCtrl.text.trim() : '/r/, /s/',
                    parentEmail: parentEmailCtrl.text.trim(),
                  );
                  setState(() {});"""

if old_add_student_save in text:
    text = text.replace(old_add_student_save, new_add_student_save, 1)
    print("Updated add student modal to use _dkt.addStudent")

# Update delete student
old_delete_student = """                onPressed: () {
                  setState(() {
                    _students.removeWhere((s) => s['id'] == std['id']);
                    _selectedStudent = null;
                  });"""

new_delete_student = """                onPressed: () {
                  _dkt.deleteStudent(std['id']);
                  setState(() {
                    _selectedStudent = null;
                  });"""

if old_delete_student in text:
    text = text.replace(old_delete_student, new_delete_student, 1)
    print("Updated delete student to use _dkt.deleteStudent")

with open('mobile/lib/widgets/therapist_portal_dialog.dart', 'w', encoding='utf-8') as f:
    f.write(text)

print("therapist_portal_dialog.dart synced with TherapistStateService successfully!")
