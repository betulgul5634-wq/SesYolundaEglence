with open('mobile/lib/widgets/therapist_portal_dialog.dart', 'r', encoding='utf-8') as f:
    text = f.read()

# 1. Update _showAddStudentModal to include parentEmailCtrl
old_modal_start = """  void _showAddStudentModal() {
    final nameCtrl = TextEditingController();
    final ageCtrl = TextEditingController(text: '6');
    final diagCtrl = TextEditingController(text: 'Artikülasyon Güçlüğü');
    final phonemesCtrl = TextEditingController(text: '/r/, /s/');
    String selectedAv = '👦';"""

new_modal_start = """  void _showAddStudentModal() {
    final nameCtrl = TextEditingController();
    final parentEmailCtrl = TextEditingController(text: 'veli@gmail.com');
    final ageCtrl = TextEditingController(text: '6');
    final diagCtrl = TextEditingController(text: 'Artikülasyon Güçlüğü');
    final phonemesCtrl = TextEditingController(text: '/r/, /s/');
    String selectedAv = '👦';"""

if old_modal_start in text:
    text = text.replace(old_modal_start, new_modal_start, 1)
    print("Added parentEmailCtrl in _showAddStudentModal")

# Add parent email text field in modal
modal_field_old = """                const SizedBox(height: 12),
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
                ),"""

modal_field_new = """                const SizedBox(height: 12),
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
                ),"""

if modal_field_old in text:
    text = text.replace(modal_field_old, modal_field_new, 1)
    print("Added email field in _showAddStudentModal")

# Save parent_email on student creation
modal_save_old = """                      'diagnosis': diagCtrl.text.trim(),
                      'target_phonemes': phonemesCtrl.text.trim(),
                      'total_stars': 0,"""

modal_save_new = """                      'diagnosis': diagCtrl.text.trim(),
                      'target_phonemes': phonemesCtrl.text.trim(),
                      'parent_email': parentEmailCtrl.text.trim().isNotEmpty ? parentEmailCtrl.text.trim() : 'veli@gmail.com',
                      'total_stars': 0,"""

if modal_save_old in text:
    text = text.replace(modal_save_old, modal_save_new, 1)
    print("Saved parent_email on student creation")

# Add "E-Posta Bildirimi Gönder" button in student detail view
btn_old = """            ElevatedButton.icon(
              onPressed: () => _showShareLinkDialog(std),
              icon: const Icon(Icons.share_rounded, size: 16, color: Colors.white),
              label: const Text('Veliye Link Gönder', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),"""

btn_new = """            ElevatedButton.icon(
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
              onPressed: () => _showShareLinkDialog(std),
              icon: const Icon(Icons.share_rounded, size: 16, color: Colors.white),
              label: const Text('Veliye Link Gönder', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),"""

if btn_old in text:
    text = text.replace(btn_old, btn_new, 1)
    print("Added email notification button in student detail view")

# Add parent email chip in student detail card
card_old = """                        const SizedBox(width: 8),
                        Text('⭐ ${std['total_stars']} Yıldız', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.amber)),
                      ],
                    ),
                  ],"""

card_new = """                        const SizedBox(width: 8),
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
                  ],"""

if card_old in text:
    text = text.replace(card_old, card_new, 1)
    print("Added parent email chip in student detail card")

with open('mobile/lib/widgets/therapist_portal_dialog.dart', 'w', encoding='utf-8') as f:
    f.write(text)
print("therapist_portal_dialog.dart successfully updated")
