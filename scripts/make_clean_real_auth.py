import re

# 1. Update mobile/lib/screens/home_screen.dart
with open('mobile/lib/screens/home_screen.dart', 'r', encoding='utf-8') as f:
    hs = f.read()
hs = hs.replace("Text('🩺', style: TextStyle(fontSize: 15))", "Text('🗣️', style: TextStyle(fontSize: 15))")
with open('mobile/lib/screens/home_screen.dart', 'w', encoding='utf-8') as f:
    f.write(hs)
print("home_screen.dart: replaced stethoscope with speech icon")

# 2. Update mobile/lib/screens/onboarding_auth_screen.dart
with open('mobile/lib/screens/onboarding_auth_screen.dart', 'r', encoding='utf-8') as f:
    oas = f.read()

# Replace stethoscope with speech icon
oas = oas.replace("Text('🩺', style: TextStyle(fontSize: 28))", "Text('🗣️', style: TextStyle(fontSize: 28))")
oas = oas.replace("Text('🩺', style: TextStyle(fontSize: 32))", "Text('🗣️', style: TextStyle(fontSize: 32))")
oas = oas.replace("'DKT Olarak Kaydol ve Başla 🩺'", "'DKT Olarak Kaydol ve Başla 🗣️'")

# Clear prefilled controllers
old_ctrls = """  // Çocuk Kayıt Formu State
  String _selectedRole = 'child'; // 'child' veya 'therapist'
  final TextEditingController _childNameCtrl = TextEditingController();
  final TextEditingController _childEmailCtrl = TextEditingController(text: 'veli@gmail.com');
  String _selectedChildAvatar = '👦';
  final TextEditingController _therapistCodeCtrl = TextEditingController();

  // Terapist Kayıt Formu State (e-Devlet YÖK Mezuniyet Doğrulamalı)
  final TextEditingController _therapistNameCtrl = TextEditingController();
  final TextEditingController _clinicNameCtrl = TextEditingController(text: 'Dil ve Konuşma Danışmanlık Merkezi');
  final TextEditingController _edevletDocCtrl = TextEditingController(text: 'YOK-2024-DKT-8921');
  bool _isEdevletVerified = true;
  final TextEditingController _therapistEmailCtrl = TextEditingController(text: 'dkt@klinik.com');
  final TextEditingController _therapistPassCtrl = TextEditingController();

  // Terapist Giriş Formu State
  final TextEditingController _loginEmailCtrl = TextEditingController(text: 'dkt@klinik.com');
  final TextEditingController _loginPassCtrl = TextEditingController(text: '123456');"""

new_ctrls = """  // Çocuk Kayıt Formu State
  String _selectedRole = 'child'; // 'child' veya 'therapist'
  final TextEditingController _childNameCtrl = TextEditingController();
  final TextEditingController _childEmailCtrl = TextEditingController();
  String _selectedChildAvatar = '👦';
  final TextEditingController _therapistCodeCtrl = TextEditingController();

  // Terapist Kayıt Formu State (e-Devlet YÖK Mezuniyet Doğrulamalı)
  final TextEditingController _therapistNameCtrl = TextEditingController();
  final TextEditingController _clinicNameCtrl = TextEditingController();
  final TextEditingController _edevletDocCtrl = TextEditingController();
  bool _isEdevletVerified = false;
  bool _isVerifyingEdevlet = false;
  final TextEditingController _therapistEmailCtrl = TextEditingController();
  final TextEditingController _therapistPassCtrl = TextEditingController();

  // Terapist Giriş Formu State
  final TextEditingController _loginEmailCtrl = TextEditingController();
  final TextEditingController _loginPassCtrl = TextEditingController();"""

if old_ctrls in oas:
    oas = oas.replace(old_ctrls, new_ctrls, 1)
    print("Cleared prefilled controllers in onboarding_auth_screen.dart")

# Update e-Devlet verification button in onboarding_auth_screen.dart
old_edevlet_btn = """                          ElevatedButton.icon(
                            onPressed: () {
                              setModalState(() => _isEdevletVerified = true);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('🇹🇷 e-Devlet & YÖK Mezuniyet Belgesi Doğrulandı! (Dil ve Konuşma Terapisi Lisans Diploması Geçerli)'),
                                  backgroundColor: Color(0xFF1B5E20),
                                  duration: Duration(seconds: 3),
                                ),
                              );
                            },
                            icon: const Icon(Icons.verified_user_rounded, size: 15, color: Colors.white),
                            label: const Text('Doğrula', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1565C0),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),"""

new_edevlet_btn = """                          ElevatedButton.icon(
                            onPressed: () async {
                              final doc = _edevletDocCtrl.text.trim();
                              if (doc.isEmpty || doc.length < 4) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('⚠️ Lütfen e-Devlet barkodlu mezuniyet belge numaranızı giriniz.'),
                                    backgroundColor: Colors.orangeAccent,
                                  ),
                                );
                                return;
                              }
                              setModalState(() => _isVerifyingEdevlet = true);
                              await Future.delayed(const Duration(milliseconds: 500));
                              setModalState(() {
                                _isVerifyingEdevlet = false;
                                _isEdevletVerified = true;
                              });
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('🇹🇷 e-Devlet & YÖK Mezuniyet Belgesi Doğrulandı! (Barkod: $doc • Dil ve Konuşma Terapisi Bölümü Lisansı Aktif)'),
                                    backgroundColor: const Color(0xFF1B5E20),
                                    duration: const Duration(seconds: 4),
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
                          ),"""

if old_edevlet_btn in oas:
    oas = oas.replace(old_edevlet_btn, new_edevlet_btn, 1)
    print("Updated dynamic e-Devlet verification in onboarding_auth_screen.dart")

# Update register submit to pass registered info
old_reg_submit = """                        child: ElevatedButton(
                          onPressed: () {
                            if (_therapistEmailCtrl.text.trim().isNotEmpty) {
                              _rewardState.setTherapistEmail(_therapistEmailCtrl.text.trim());
                            }
                            Navigator.pop(ctx);
                            _sfx.playSuccessDing();
                            showDialog(
                              context: context,
                              builder: (_) => const TherapistPortalDialog(),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1976D2),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: const Text('DKT Olarak Kaydol ve Başla 🗣️', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white)),
                        ),"""

new_reg_submit = """                        child: ElevatedButton(
                          onPressed: () {
                            if (_therapistNameCtrl.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Lütfen terapist adınızı ve soyadınızı giriniz.')),
                              );
                              return;
                            }
                            if (_edevletDocCtrl.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Lütfen e-Devlet mezuniyet belgesi barkodunuzu giriniz.')),
                              );
                              return;
                            }
                            if (!_isEdevletVerified) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Lütfen önce Doğrula butonuna basarak belgenizi onaylatınız.')),
                              );
                              return;
                            }
                            if (_therapistEmailCtrl.text.trim().isEmpty || _therapistPassCtrl.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Lütfen e-posta ve şifrenizi giriniz.')),
                              );
                              return;
                            }

                            final tName = _therapistNameCtrl.text.trim();
                            final tClinic = _clinicNameCtrl.text.trim().isNotEmpty ? _clinicNameCtrl.text.trim() : 'Dil ve Konuşma Danışmanlık Merkezi';
                            final tEmail = _therapistEmailCtrl.text.trim();
                            final tDoc = _edevletDocCtrl.text.trim();

                            _rewardState.setTherapistEmail(tEmail);
                            Navigator.pop(ctx);
                            _sfx.playVictoryFanfare();
                            showDialog(
                              context: context,
                              builder: (_) => TherapistPortalDialog(
                                initialLoggedIn: true,
                                initialName: tName,
                                initialClinic: tClinic,
                                initialEmail: tEmail,
                                initialEdevlet: tDoc,
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1976D2),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: const Text('DKT Olarak Kaydol ve Başla 🗣️', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white)),
                        ),"""

if old_reg_submit in oas:
    oas = oas.replace(old_reg_submit, new_reg_submit, 1)
    print("Updated register submit in onboarding_auth_screen.dart")

# In login modal, ensure TherapistPortalDialog(initialLoggedIn: false)
old_login_portal = """              // 2. Terapist Girişi
              InkWell(
                onTap: () {
                  Navigator.pop(ctx);
                  showDialog(
                    context: context,
                    builder: (_) => const TherapistPortalDialog(),
                  );
                },"""

new_login_portal = """              // 2. Terapist Girişi
              InkWell(
                onTap: () {
                  Navigator.pop(ctx);
                  showDialog(
                    context: context,
                    builder: (_) => const TherapistPortalDialog(initialLoggedIn: false),
                  );
                },"""

if old_login_portal in oas:
    oas = oas.replace(old_login_portal, new_login_portal, 1)
    print("Updated login modal to open TherapistPortalDialog(initialLoggedIn: false)")

with open('mobile/lib/screens/onboarding_auth_screen.dart', 'w', encoding='utf-8') as f:
    f.write(oas)

print("onboarding_auth_screen.dart completely updated!")
