import re

# 1. Update onboarding_auth_screen.dart
with open('mobile/lib/screens/onboarding_auth_screen.dart', 'r', encoding='utf-8') as f:
    text = f.read()

# Replace doctor emoji with stethoscope
text = text.replace("Text('👨‍⚕️', style: TextStyle(fontSize: 28))", "Text('🩺', style: TextStyle(fontSize: 28))")
text = text.replace("Text('👨‍⚕️', style: TextStyle(fontSize: 32))", "Text('🩺', style: TextStyle(fontSize: 32))")
text = text.replace("'Uzman Terapist'", "'Dil & Konuşma Terapisti'")
text = text.replace("'Uzman Terapist Portalı'", "'Dil ve Konuşma Terapisti Portalı'")
text = text.replace("'Terapist Olarak Kaydol ve Başla 👨‍⚕️'", "'DKT Olarak Kaydol ve Başla 🩺'")

# Remove university name from defaults
text = text.replace("İstinye Üniversitesi DKT Kliniği", "Dil ve Konuşma Danışmanlık Merkezi")
text = text.replace("terapist@istinye.edu.tr", "dkt@klinik.com")

# Update child form to include email
child_target = """                    const SizedBox(height: 12),
                    const Text('Terapist Kodu (Opsiyonel):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),"""

child_replacement = """                    const SizedBox(height: 10),
                    const Text('Veli E-Posta Adresi (Bildirimler İçin):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    const SizedBox(height: 4),
                    TextField(
                      controller: _childEmailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'ornek.veli@gmail.com',
                        prefixIcon: const Icon(Icons.email_outlined, size: 18, color: Color(0xFF2E7D32)),
                        helperText: '📩 Egzersiz başarıları ve terapist ödevleri bu adrese iletilir.',
                        helperStyle: const TextStyle(fontSize: 10.5, color: Color(0xFF2E7D32), fontWeight: FontWeight.w600),
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text('Terapist Kodu (Opsiyonel):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),"""

if child_target in text:
    text = text.replace(child_target, child_replacement, 1)
    print("Child form email field added")
else:
    print("Warning: child_target not found")

# Update child submit to save email
submit_target = """                          _rewardState.setStudentName(name);
                          _sfx.playVictoryFanfare();"""
submit_replacement = """                          _rewardState.setStudentName(name);
                          if (_childEmailCtrl.text.trim().isNotEmpty) {
                            _rewardState.setParentEmail(_childEmailCtrl.text.trim());
                          }
                          _sfx.playVictoryFanfare();"""
if submit_target in text:
    text = text.replace(submit_target, submit_replacement, 1)
    print("Child submit updated to save email")

# Update therapist form to include e-Devlet and no university
therapist_form_target = """                    const Text('Klinik / Üniversite:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    const SizedBox(height: 4),
                    TextField(
                      controller: _clinicNameCtrl,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('Kurumsal E-posta:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),"""

therapist_form_replacement = """                    const Text('Klinik / Danışmanlık Merkezi Adı:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    const SizedBox(height: 4),
                    TextField(
                      controller: _clinicNameCtrl,
                      decoration: InputDecoration(
                        hintText: 'Örn: Özel Dil ve Konuşma Danışmanlık Merkezi',
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('🏛️ e-Devlet Onaylı Mezuniyet Belge No (Barkod):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _edevletDocCtrl,
                            decoration: InputDecoration(
                              hintText: 'Örn: YOK-2024-DKT-8921',
                              filled: true,
                              fillColor: Colors.grey[100],
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
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
                        ),
                      ],
                    ),
                    if (_isEdevletVerified)
                      Container(
                        margin: const EdgeInsets.only(top: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFF81C784)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.check_circle_rounded, color: Color(0xFF2E7D32), size: 16),
                            SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'e-Devlet Onaylı: Dil ve Konuşma Terapisi Lisans Diploması Doğrulandı',
                                style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 8),
                    const Text('Kurumsal E-posta (Bildirimler İçin):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),"""

if therapist_form_target in text:
    text = text.replace(therapist_form_target, therapist_form_replacement, 1)
    print("Therapist form e-Devlet and email updated")
else:
    print("Warning: therapist_form_target not found")

with open('mobile/lib/screens/onboarding_auth_screen.dart', 'w', encoding='utf-8') as f:
    f.write(text)
print("onboarding_auth_screen.dart written successfully")
