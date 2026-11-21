import os

# 1. Update home_screen.dart
with open('mobile/lib/screens/home_screen.dart', 'r', encoding='utf-8') as f:
    hs_text = f.read()

# Replace doctor emoji and text on therapist button
hs_text = hs_text.replace("Text('👨‍⚕️', style: TextStyle(fontSize: 15))", "Text('🩺', style: TextStyle(fontSize: 15))")
hs_text = hs_text.replace("'Terapist Girişi'", "'DKT Girişi'")
with open('mobile/lib/screens/home_screen.dart', 'w', encoding='utf-8') as f:
    f.write(hs_text)
print("Updated home_screen.dart")

# 2. Update therapist_portal_dialog.dart
with open('mobile/lib/widgets/therapist_portal_dialog.dart', 'r', encoding='utf-8') as f:
    tp_text = f.read()

# Replace doctor emoji
tp_text = tp_text.replace("Text('👨‍⚕️', style: TextStyle(fontSize: 22))", "Text('🩺', style: TextStyle(fontSize: 22))")

# Remove university defaults
tp_text = tp_text.replace("Doç. Dr. Emir Seyyedabbasi", "Uzm. DKT Merve Kaya")
tp_text = tp_text.replace("İstinye Üniversitesi Dil ve Konuşma Terapisi Kliniği", "Dil ve Konuşma Danışmanlık Merkezi")
tp_text = tp_text.replace("İstinye Üniversitesi DKT Kliniği", "Dil ve Konuşma Danışmanlık Merkezi")
tp_text = tp_text.replace("terapist@istinye.edu.tr", "dkt@klinik.com")
tp_text = tp_text.replace("İstinye Üniversitesi Terapist Portalı", "Dil ve Konuşma Terapisti (DKT) Klinik Portalı")
tp_text = tp_text.replace("'Klinik / Üniversite'", "'Klinik / Danışmanlık Merkezi Adı'")
tp_text = tp_text.replace("labelText: 'Klinik / Üniversite'", "labelText: 'Klinik / Danışmanlık Merkezi Adı'")

# Add e-Devlet controller to state
old_controllers = """  final TextEditingController _regNameCtrl = TextEditingController();
  final TextEditingController _regClinicCtrl = TextEditingController(text: 'Dil ve Konuşma Danışmanlık Merkezi');
  final TextEditingController _regEmailCtrl = TextEditingController();
  final TextEditingController _regPassCtrl = TextEditingController();"""

new_controllers = """  final TextEditingController _regNameCtrl = TextEditingController(text: 'Uzm. DKT Merve Kaya');
  final TextEditingController _regClinicCtrl = TextEditingController(text: 'Dil ve Konuşma Danışmanlık Merkezi');
  final TextEditingController _regEdevletCtrl = TextEditingController(text: 'YOK-2024-DKT-8921');
  bool _isRegEdevletVerified = true;
  final TextEditingController _regEmailCtrl = TextEditingController(text: 'dkt@klinik.com');
  final TextEditingController _regPassCtrl = TextEditingController(text: '123456');"""

if old_controllers in tp_text:
    tp_text = tp_text.replace(old_controllers, new_controllers, 1)
    print("Added e-Devlet controller in therapist_portal_dialog.dart")

# Add e-Devlet field in registration form
reg_form_old = """                  TextField(
                    controller: _regClinicCtrl,
                    decoration: InputDecoration(
                      labelText: 'Klinik / Danışmanlık Merkezi Adı',
                      labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      prefixIcon: const Icon(Icons.local_hospital_outlined, size: 18),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _regEmailCtrl,"""

reg_form_new = """                  TextField(
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
                  TextField(
                    controller: _regEdevletCtrl,
                    decoration: InputDecoration(
                      labelText: '🏛️ e-Devlet Mezuniyet Barkod No',
                      hintText: 'YOK-2024-DKT-8921',
                      labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      prefixIcon: const Icon(Icons.verified_user_rounded, size: 18, color: Color(0xFF1565C0)),
                      suffixIcon: Container(
                        margin: const EdgeInsets.all(6),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFF81C784)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle_rounded, size: 14, color: Color(0xFF2E7D32)),
                            SizedBox(width: 4),
                            Text('e-Devlet Onaylı', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20))),
                          ],
                        ),
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _regEmailCtrl,"""

if reg_form_old in tp_text:
    tp_text = tp_text.replace(reg_form_old, reg_form_new, 1)
    print("Added e-Devlet field in registration form")

# Update header with e-Devlet badge
header_old = """                    Text(
                      _therapistName,
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF0F172A)),
                    ),"""

header_new = """                    Row(
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
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('🏛️ e-Devlet Onaylı DKT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20))),
                            ],
                          ),
                        ),
                      ],
                    ),"""

if header_old in tp_text:
    tp_text = tp_text.replace(header_old, header_new, 1)
    print("Added e-Devlet verified badge to header")

# Update student sample data to include parent_email
student_old = """        'target_phonemes': '/r/, /l/',
        'total_stars': 42,"""
student_new = """        'target_phonemes': '/r/, /l/',
        'parent_email': 'veli.ali@gmail.com',
        'total_stars': 42,"""
if student_old in tp_text:
    tp_text = tp_text.replace(student_old, student_new, 1)
    print("Added parent_email to Ali")

with open('mobile/lib/widgets/therapist_portal_dialog.dart', 'w', encoding='utf-8') as f:
    f.write(tp_text)
print("Updated therapist_portal_dialog.dart")
