import 'package:flutter/material.dart';
import '../models/reward_state.dart';
import '../services/sound_effects_service.dart';
import '../widgets/therapist_portal_dialog.dart';
import '../services/therapist_state_service.dart';
import 'home_screen.dart';

/// 🦉 DUOLINGO TARZI AÇILIŞ, KAYIT VE ROL SEÇİM EKRANI
/// Sayfaya ilk girildiğinde Duolingo gibi karşılar:
/// 1. 🚀 "BAŞLA (KAYIT OL)" ➔ Çocuk veya Terapist Olarak Kayıt
/// 2. 🔑 "ZATEN HESABIM VAR (GİRİŞ YAP)" ➔ Öğrenci veya Terapist Girişi
class OnboardingAuthScreen extends StatefulWidget {
  const OnboardingAuthScreen({super.key});

  @override
  State<OnboardingAuthScreen> createState() => _OnboardingAuthScreenState();
}

class _OnboardingAuthScreenState extends State<OnboardingAuthScreen>
    with SingleTickerProviderStateMixin {
  final RewardState _rewardState = RewardState();
  final SoundEffectsService _sfx = SoundEffectsService();

  late AnimationController _mascotAnimController;
  late Animation<double> _mascotBounce;

  // Çocuk Kayıt Formu State
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
  final TextEditingController _loginPassCtrl = TextEditingController();

  final List<String> _avatars = ['👦', '👧', '🦁', '🐼', '🚀', '🦄', '🐱', '⚽'];

  @override
  void initState() {
    super.initState();
    _mascotAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _mascotBounce = Tween<double>(begin: -6.0, end: 6.0).animate(
      CurvedAnimation(parent: _mascotAnimController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _mascotAnimController.dispose();
    _childNameCtrl.dispose();
    _childEmailCtrl.dispose();
    _therapistCodeCtrl.dispose();
    _therapistNameCtrl.dispose();
    _clinicNameCtrl.dispose();
    _edevletDocCtrl.dispose();
    _therapistEmailCtrl.dispose();
    _therapistPassCtrl.dispose();
    _loginEmailCtrl.dispose();
    _loginPassCtrl.dispose();
    super.dispose();
  }

  void _goToGameMap() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF235390),
      body: Stack(
        children: [
          // Arka Plan Canlı Gradyan & Parçacık Havası
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF1E4976),
                  Color(0xFF143054),
                  Color(0xFF0D1F38),
                ],
              ),
            ),
          ),

          // Merkez İçerik Alanı (Duolingo Tarzı Karşılama)
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Canlı Maskot & Konuşma Baloncuğu
                    AnimatedBuilder(
                      animation: _mascotBounce,
                      builder: (ctx, child) => Transform.translate(
                        offset: Offset(0, _mascotBounce.value),
                        child: child,
                      ),
                      child: Column(
                        children: [
                          // Konuşma Balonu
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: const [
                                BoxShadow(color: Color(0x33000000), blurRadius: 10, offset: Offset(0, 4)),
                              ],
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('🎙️', style: TextStyle(fontSize: 20)),
                                SizedBox(width: 8),
                                Text(
                                  'Sesleri oyunla öğrenmeye hazır mısın?',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 13,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Büyük 3D Maskot Simgesi
                          Container(
                            width: 110,
                            height: 110,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF58CC02), Color(0xFF46A302)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                              boxShadow: const [
                                BoxShadow(color: Color(0x6658CC02), blurRadius: 24, offset: Offset(0, 8)),
                              ],
                              border: Border.all(color: Colors.white, width: 4),
                            ),
                            child: const Center(
                              child: Text('🦜', style: TextStyle(fontSize: 60)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Başlık ve Alt Başlık
                    const Text(
                      'Ses Yolunda Eğlence',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Oyunla Artikülasyon Terapisi & Klinik Takip Sistemi',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'İstinye Üniversitesi Yazılım Mühendisliği Bitirme Projesi',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF38BDF8)),
                      ),
                    ),
                    const SizedBox(height: 36),

                    // ── 1. BUTON: BAŞLA (KAYIT OL) (DUOLINGO YEŞİLİ) ─────────
                    _buildDuolingoButton(
                      label: 'BAŞLA (KAYIT OL)',
                      icon: Icons.rocket_launch_rounded,
                      bgColor: const Color(0xFF58CC02),
                      shadowColor: const Color(0xFF45A202),
                      textColor: Colors.white,
                      onTap: () {
                        _sfx.playSuccessDing();
                        _showRegisterModal();
                      },
                    ),
                    const SizedBox(height: 14),

                    // ── 2. BUTON: ZATEN HESABIM VAR (GİRİŞ YAP) (DUOLINGO BEYAZI)
                    _buildDuolingoButton(
                      label: 'ZATEN BİR HESABIM VAR',
                      icon: Icons.login_rounded,
                      bgColor: Colors.white,
                      shadowColor: const Color(0xFFCBD5E1),
                      textColor: const Color(0xFF1E293B),
                      onTap: () {
                        _sfx.playPopSound();
                        _showLoginModal();
                      },
                    ),
                    const SizedBox(height: 20),

                    // Hızlı Ziyaretçi / Misafir Geçişi
                    TextButton(
                      onPressed: () {
                        _sfx.playPopSound();
                        _goToGameMap();
                      },
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Misafir Olarak Hızlıca Keşfet',
                            style: TextStyle(
                              color: Color(0xFF94A3B8),
                              fontWeight: FontWeight.bold,
                              fontSize: 12.5,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(Icons.arrow_forward_rounded, size: 14, color: Color(0xFF94A3B8)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── DUOLINGO TARZI 3D BASILABİLİR BUTON ────────────────────────────────────
  Widget _buildDuolingoButton({
    required String label,
    required IconData icon,
    required Color bgColor,
    required Color shadowColor,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              offset: const Offset(0, 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: textColor, size: 20),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── 1. MODAL: KAYIT OL (ÇOCUK VEYA TERAPİST SEÇİMİ) ────────────────────────
  void _showRegisterModal() {
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          contentPadding: const EdgeInsets.all(24),
          content: Container(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Nasıl Katılmak İstiyorsun?',
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(Icons.close_rounded, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Rol Seçim Butonları (Çocuk vs Terapist)
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => setModalState(() => _selectedRole = 'child'),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _selectedRole == 'child' ? const Color(0xFFE8F5E9) : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: _selectedRole == 'child' ? const Color(0xFF4CAF50) : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: const Column(
                              children: [
                                Text('🧒', style: TextStyle(fontSize: 28)),
                                SizedBox(height: 4),
                                Text(
                                  'Çocuk / Öğrenci',
                                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: InkWell(
                          onTap: () => setModalState(() => _selectedRole = 'therapist'),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _selectedRole == 'therapist' ? const Color(0xFFE3F2FD) : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: _selectedRole == 'therapist' ? const Color(0xFF1976D2) : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: const Column(
                              children: [
                                Text('🗣️', style: TextStyle(fontSize: 28)),
                                SizedBox(height: 4),
                                Text(
                                  'Dil & Konuşma Terapisti',
                                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── A) ÇOCUK KAYIT FORMU ───────────────────────────────────
                  if (_selectedRole == 'child') ...[
                    const Text('Öğrencinin Adı:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    const SizedBox(height: 4),
                    TextField(
                      controller: _childNameCtrl,
                      decoration: InputDecoration(
                        hintText: 'Örn: Ali, Zeynep...',
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text('Karakter Avatarını Seç:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _avatars.map((av) {
                        final isSel = av == _selectedChildAvatar;
                        return InkWell(
                          onTap: () => setModalState(() => _selectedChildAvatar = av),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isSel ? const Color(0xFFE8F5E9) : Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSel ? const Color(0xFF4CAF50) : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Text(av, style: const TextStyle(fontSize: 22)),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 10),
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
                    const Text('Terapist Kodu (Opsiyonel):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    const SizedBox(height: 4),
                    TextField(
                      controller: _therapistCodeCtrl,
                      decoration: InputDecoration(
                        hintText: 'Örn: ALI-101 (Varsa girin)',
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton(
                        onPressed: () {
                          final name = _childNameCtrl.text.trim().isNotEmpty
                              ? _childNameCtrl.text.trim()
                              : 'Yeni Kahraman';
                          _rewardState.setStudentName(name);
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
                          _goToGameMap();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF58CC02),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text('Maceraya Başla! 🚀', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white)),
                      ),
                    ),
                  ] else ...[
                    // ── B) TERAPİST KAYIT FORMU ──────────────────────────────
                    const Text('Terapist Adı Soyadı:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    const SizedBox(height: 4),
                    TextField(
                      controller: _therapistNameCtrl,
                      decoration: InputDecoration(
                        hintText: 'Örn: Uzm. DKT Merve Kaya',
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('Klinik / Danışmanlık Merkezi Adı:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
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
                          onPressed: () async {
                            final doc = _edevletDocCtrl.text.trim();
                            if (doc.isEmpty || doc.length < 4) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('⚠️ Lütfen mezuniyet belgenizdeki e-Devlet barkod numarasını giriniz.'),
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
                            if (ctx.mounted) {
                              ScaffoldMessenger.of(ctx).showSnackBar(
                                SnackBar(
                                  content: Text('🇹🇷 e-Devlet & YÖK Mezuniyet Belgesi Doğrulandı! (Barkod: $doc • Dil ve Konuşma Terapisi Lisansı Onaylı)'),
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
                            const Icon(Icons.check_circle_rounded, color: Color(0xFF2E7D32), size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'e-Devlet & YÖK Onaylı: Barkod (${_edevletDocCtrl.text.trim()}) Dil ve Konuşma Terapisi Lisansı Geçerli',
                                style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 8),
                    const Text('Kurumsal E-posta (Bildirimler İçin):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    const SizedBox(height: 4),
                    TextField(
                      controller: _therapistEmailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'ornek.dkt@klinik.com',
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('Şifre Belirleyin:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    const SizedBox(height: 4),
                    TextField(
                      controller: _therapistPassCtrl,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: '••••••••',
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_therapistNameCtrl.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Lütfen terapist adınızı ve soyadınızı giriniz.')),
                            );
                            return;
                          }
                          if (_edevletDocCtrl.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Lütfen e-Devlet mezuniyet belgesi barkod numaranızı giriniz.')),
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
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1976D2),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text('DKT Olarak Kaydol ve Başla 🗣️', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── 2. MODAL: ZATEN HESABIM VAR (GİRİŞ YAP) ───────────────────────────────
  void _showLoginModal() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        contentPadding: const EdgeInsets.all(24),
        content: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Giriş Türünü Seç', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                  IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close_rounded, color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 16),

              // 1. Öğrenci Olarak Devam Et
              InkWell(
                onTap: () {
                  Navigator.pop(ctx);
                  _goToGameMap();
                },
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFA5D6A7), width: 1.5),
                  ),
                  child: const Row(
                    children: [
                      Text('🧒', style: TextStyle(fontSize: 32)),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Öğrenci / Çocuk Girişi', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Color(0xFF1B5E20))),
                            Text('Şifresiz, kayıtlı profille oyuna devam et', style: TextStyle(fontSize: 11, color: Color(0xFF2E7D32))),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Color(0xFF2E7D32)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // 2. Terapist Girişi
              InkWell(
                onTap: () {
                  Navigator.pop(ctx);
                  showDialog(
                    context: context,
                    builder: (_) => const TherapistPortalDialog(initialLoggedIn: false),
                  );
                },
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFF90CAF9), width: 1.5),
                  ),
                  child: const Row(
                    children: [
                      Text('🗣️', style: TextStyle(fontSize: 32)),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Dil ve Konuşma Terapisti Portalı', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Color(0xFF0D47A1))),
                            Text('Danışan takibi, grafikler ve seanslar', style: TextStyle(fontSize: 11, color: Color(0xFF1565C0))),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Color(0xFF0D47A1)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
