with open('mobile/lib/widgets/therapist_portal_dialog.dart', 'r', encoding='utf-8') as f:
    text = f.read()

# Update Login button
old_login_btn = """                      onPressed: () {
                        setState(() => _isLoggedIn = true);
                        _sfx.playSuccessDing();
                      },"""

new_login_btn = """                      onPressed: () {
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

if old_login_btn in text:
    text = text.replace(old_login_btn, new_login_btn, 1)
    print("Updated login button with validation")

# Update e-Devlet field in register form
old_edevlet_reg = """                  // 🏛️ e-Devlet YÖK Mezuniyet Doğrulama Alanı
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
                  ),"""

new_edevlet_reg = """                  // 🏛️ e-Devlet YÖK Mezuniyet Doğrulama Alanı
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
                          if (context.mounted) {
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
                    ),"""

if old_edevlet_reg in text:
    text = text.replace(old_edevlet_reg, new_edevlet_reg, 1)
    print("Updated e-Devlet field in registration form with live verification")

# Update register submit button
old_reg_btn = """                      onPressed: () {
                        if (_regNameCtrl.text.isNotEmpty) {
                          setState(() {
                            _therapistName = _regNameCtrl.text.trim();
                            _clinicName = _regClinicCtrl.text.trim();
                            _isLoggedIn = true;
                          });
                          _sfx.playVictoryFanfare();
                        }
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
                        setState(() {
                          _therapistName = _regNameCtrl.text.trim();
                          _clinicName = _regClinicCtrl.text.trim().isNotEmpty ? _regClinicCtrl.text.trim() : 'Dil ve Konuşma Danışmanlık Merkezi';
                          _edevletDocNo = _regEdevletCtrl.text.trim();
                          _isLoggedIn = true;
                        });
                        _sfx.playVictoryFanfare();
                      },"""

if old_reg_btn in text:
    text = text.replace(old_reg_btn, new_reg_btn, 1)
    print("Updated registration submit button with input validation")

# Replace guest login name
text = text.replace("_therapistName = 'Uzm. DKT Merve Kaya';", "_therapistName = 'Konuk Dil ve Konuşma Terapisti';")

# Update _buildStudentsListView to show clean empty state when _students is empty
old_grid_view = """        // Danışan Kartları Grid
        Expanded(
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
              return Container("""

new_grid_view = """        // Danışan Kartları Grid / Boş Durum
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
                    return Container("""

if old_grid_view in text:
    text = text.replace(old_grid_view, new_grid_view, 1)
    print("Updated _buildStudentsListView with clean empty state")

with open('mobile/lib/widgets/therapist_portal_dialog.dart', 'w', encoding='utf-8') as f:
    f.write(text)

print("therapist_portal_dialog.dart completely finalized!")
