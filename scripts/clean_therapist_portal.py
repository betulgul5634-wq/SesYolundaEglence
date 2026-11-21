import re

with open('mobile/lib/widgets/therapist_portal_dialog.dart', 'r', encoding='utf-8') as f:
    text = f.read()

# 1. Replace stethoscope with speech icon
text = text.replace("Text('🩺', style: TextStyle(fontSize: 22))", "Text('🗣️', style: TextStyle(fontSize: 22))")

# 2. Update StatefulWidget declaration to accept initial parameters
old_class = """class TherapistPortalDialog extends StatefulWidget {
  const TherapistPortalDialog({super.key});

  @override
  State<TherapistPortalDialog> createState() => _TherapistPortalDialogState();
}"""

new_class = """class TherapistPortalDialog extends StatefulWidget {
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

if old_class in text:
    text = text.replace(old_class, new_class, 1)
    print("Updated TherapistPortalDialog constructor with initial parameters")
else:
    print("Could not find old_class")

# 3. Update State variables and initState
old_state_vars = """  // Giriş / Kayıt Durumları
  bool _isLoggedIn = true; // Varsayılan açık veya giriş formlu
  bool _isRegisterMode = false;
  String _therapistName = 'Uzm. DKT Merve Kaya';
  String _clinicName = 'Dil ve Konuşma Danışmanlık Merkezi';

  final TextEditingController _loginEmailCtrl = TextEditingController(text: 'dkt@klinik.com');
  final TextEditingController _loginPassCtrl = TextEditingController(text: '123456');

  // Kayıt Kontrolcüleri
  final TextEditingController _regNameCtrl = TextEditingController(text: 'Uzm. DKT Merve Kaya');
  final TextEditingController _regClinicCtrl = TextEditingController(text: 'Dil ve Konuşma Danışmanlık Merkezi');
  final TextEditingController _regEdevletCtrl = TextEditingController(text: 'YOK-2024-DKT-8921');
  final TextEditingController _regEmailCtrl = TextEditingController(text: 'dkt@klinik.com');
  final TextEditingController _regPassCtrl = TextEditingController(text: '123456');"""

new_state_vars = """  // Giriş / Kayıt Durumları (Gerçek ve Temiz Başlangıç)
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
  final TextEditingController _regPassCtrl = TextEditingController();"""

if old_state_vars in text:
    text = text.replace(old_state_vars, new_state_vars, 1)
    print("Updated state vars to clean empty controllers")
else:
    print("Could not find old_state_vars")

# 4. Update initState to empty list of students
old_init_state_start = "  @override\n  void initState() {"
old_init_state_end = "  @override\n  void dispose() {"

idx_init = text.find(old_init_state_start)
idx_disp = text.find(old_init_state_end)

new_init_state = """  @override
  void initState() {
    super.initState();
    _isLoggedIn = widget.initialLoggedIn;
    _therapistName = widget.initialName ?? 'Dil ve Konuşma Terapisti';
    _clinicName = widget.initialClinic ?? 'Dil ve Konuşma Danışmanlık Merkezi';
    _edevletDocNo = widget.initialEdevlet ?? '';
    _isEdevletVerified = widget.initialEdevlet != null && widget.initialEdevlet!.isNotEmpty;
    _students = []; // Gerçek kullanıcı deneyimi: Danışan listesi sıfırdan başlar!
  }

"""

if idx_init != -1 and idx_disp != -1:
    text = text[:idx_init] + new_init_state + text[idx_disp:]
    print("Replaced dummy students list with empty clean list in initState")
else:
    print("Could not find initState bounds", idx_init, idx_disp)

# 5. Clean _showAddStudentModal controllers
old_modal_ctrls = """  void _showAddStudentModal() {
    final nameCtrl = TextEditingController();
    final parentEmailCtrl = TextEditingController(text: 'veli@gmail.com');
    final ageCtrl = TextEditingController(text: '6');
    final diagCtrl = TextEditingController(text: 'Artikülasyon Güçlüğü');
    final phonemesCtrl = TextEditingController(text: '/r/, /s/');
    String selectedAv = '👦';"""

new_modal_ctrls = """  void _showAddStudentModal() {
    final nameCtrl = TextEditingController();
    final parentEmailCtrl = TextEditingController();
    final ageCtrl = TextEditingController();
    final diagCtrl = TextEditingController();
    final phonemesCtrl = TextEditingController();
    String selectedAv = '👦';"""

if old_modal_ctrls in text:
    text = text.replace(old_modal_ctrls, new_modal_ctrls, 1)
    print("Cleared _showAddStudentModal controllers")

# Update saving in _showAddStudentModal
old_save_modal = """                  setState(() {
                    _students.insert(0, {
                      'id': DateTime.now().millisecondsSinceEpoch,
                      'name': nameCtrl.text.trim(),
                      'age': int.tryParse(ageCtrl.text) ?? 6,
                      'avatar': selectedAv,
                      'diagnosis': diagCtrl.text.trim(),
                      'target_phonemes': phonemesCtrl.text.trim(),
                      'parent_email': parentEmailCtrl.text.trim().isNotEmpty ? parentEmailCtrl.text.trim() : 'veli@gmail.com',
                      'total_stars': 0,
                      'accuracy': 0.0,
                      'sessions_count': 0,
                      'sessions': [],
                    });
                  });"""

new_save_modal = """                  setState(() {
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

if old_save_modal in text:
    text = text.replace(old_save_modal, new_save_modal, 1)
    print("Updated save student modal")

with open('mobile/lib/widgets/therapist_portal_dialog.dart', 'w', encoding='utf-8') as f:
    f.write(text)

print("therapist_portal_dialog.dart successfully updated with clean state")
