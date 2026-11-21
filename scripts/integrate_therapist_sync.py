import os

# 1. Update onboarding_auth_screen.dart
with open('mobile/lib/screens/onboarding_auth_screen.dart', 'r', encoding='utf-8') as f:
    oas = f.read()

# Add import
if "import '../services/therapist_state_service.dart';" not in oas:
    oas = oas.replace("import '../widgets/therapist_portal_dialog.dart';", "import '../widgets/therapist_portal_dialog.dart';\nimport '../services/therapist_state_service.dart';")
    print("Added therapist_state_service import to onboarding_auth_screen.dart")

# Update child registration to sync student to TherapistStateService
old_child_submit = """                          _rewardState.setStudentName(name);
                          if (_childEmailCtrl.text.trim().isNotEmpty) {
                            _rewardState.setParentEmail(_childEmailCtrl.text.trim());
                          }
                          _sfx.playVictoryFanfare();
                          Navigator.pop(ctx);
                          _goToGameMap();"""

new_child_submit = """                          _rewardState.setStudentName(name);
                          if (_childEmailCtrl.text.trim().isNotEmpty) {
                            _rewardState.setParentEmail(_childEmailCtrl.text.trim());
                          }
                          // 🔗 Çocuğu Terapist Sistemine ve DKT Paneline doğrudan eşle
                          TherapistStateService().syncStudentFromOnboarding(
                            name: name,
                            avatar: _selectedChildAvatar,
                            parentEmail: _childEmailCtrl.text.trim(),
                            therapistCode: _therapistCodeCtrl.text.trim(),
                          );
                          _sfx.playVictoryFanfare();
                          Navigator.pop(ctx);
                          _goToGameMap();"""

if old_child_submit in oas:
    oas = oas.replace(old_child_submit, new_child_submit, 1)
    print("Updated child submit to sync student to TherapistStateService")

# Update therapist registration submit to save to TherapistStateService
old_therapist_submit = """                          final tName = _therapistNameCtrl.text.trim();
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
                          );"""

new_therapist_submit = """                          final tName = _therapistNameCtrl.text.trim();
                          final tClinic = _clinicNameCtrl.text.trim().isNotEmpty ? _clinicNameCtrl.text.trim() : 'Dil ve Konuşma Danışmanlık Merkezi';
                          final tEmail = _therapistEmailCtrl.text.trim();
                          final tDoc = _edevletDocCtrl.text.trim();
                          final tPass = _therapistPassCtrl.text.trim().isNotEmpty ? _therapistPassCtrl.text.trim() : '123456';

                          // 🔗 Terapist oturumunu ve profilini tekil servise kaydet
                          TherapistStateService().registerTherapist(
                            name: tName,
                            clinic: tClinic,
                            email: tEmail,
                            edevletDocNo: tDoc,
                            password: tPass,
                          );
                          _rewardState.setTherapistEmail(tEmail);

                          Navigator.pop(ctx);
                          _sfx.playVictoryFanfare();
                          showDialog(
                            context: context,
                            builder: (_) => const TherapistPortalDialog(),
                          );"""

if old_therapist_submit in oas:
    oas = oas.replace(old_therapist_submit, new_therapist_submit, 1)
    print("Updated therapist registration submit to register in TherapistStateService")

with open('mobile/lib/screens/onboarding_auth_screen.dart', 'w', encoding='utf-8') as f:
    f.write(oas)

print("onboarding_auth_screen.dart synced successfully")
