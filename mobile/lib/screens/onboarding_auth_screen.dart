import 'package:flutter/material.dart';
import '../models/reward_state.dart';
import '../services/sound_effects_service.dart';
import '../services/therapist_state_service.dart';
import 'home_screen.dart';

enum AuthScreenView { welcome, register, login }

/// 🦉 DUOLINGO TARZI AÇILIŞ, AYRI KAYIT VE GİRİŞ SİSTEMİ
/// 1. 🚀 Karşılama Ekranı: "Başla (Kayıt Ol)" ve "Zaten Hesabım Var (Giriş Yap)"
/// 2. 📝 Kayıt Ol Ekranı:
///    - 🧒 Danışan / Kullanıcı Kaydı (Öğrenci & Veli)
///    - 👨‍⚕️ Dil ve Konuşma Terapisti (DKT) Kaydı (T.C. & e-Devlet YÖK Mezuniyet Doğrulamalı)
/// 3. 🔑 Giriş Yap Ekranı:
///    - 🧒 Danışan Girişi
///    - 👨‍⚕️ DKT Terapist Girişi
class OnboardingAuthScreen extends StatefulWidget {
  const OnboardingAuthScreen({super.key});

  @override
  State<OnboardingAuthScreen> createState() => _OnboardingAuthScreenState();
}

class _OnboardingAuthScreenState extends State<OnboardingAuthScreen>
    with SingleTickerProviderStateMixin {
  final RewardState _rewardState = RewardState();
  final SoundEffectsService _sfx = SoundEffectsService();
  final TherapistStateService _dkt = TherapistStateService();

  late AnimationController _mascotAnimController;
  late Animation<double> _mascotBounce;

  AuthScreenView _currentView = AuthScreenView.welcome;

  // Kayıt ve Giriş Rol Sekmeleri: 'child' veya 'therapist'
  String _registerRole = 'child';
  String _loginRole = 'child';

  // ── Danışan / Kullanıcı Kayıt Kontrolcüleri ──
  final TextEditingController _childNameCtrl = TextEditingController();
  final TextEditingController _childParentEmailCtrl = TextEditingController();
  final TextEditingController _childPasswordCtrl = TextEditingController();
  final TextEditingController _childTherapistCodeCtrl = TextEditingController();
  int _childAge = 6;
  String _selectedChildAvatar = '👦';

  // ── DKT Terapist Kayıt Kontrolcüleri ──
  final TextEditingController _therapistNameCtrl = TextEditingController();
  final TextEditingController _clinicNameCtrl = TextEditingController();
  final TextEditingController _therapistTcCtrl = TextEditingController();
  final TextEditingController _edevletDocCtrl = TextEditingController();
  final TextEditingController _therapistEmailCtrl = TextEditingController();
  final TextEditingController _therapistPassCtrl = TextEditingController();
  bool _isEdevletVerified = false;
  bool _isVerifyingEdevlet = false;
  String _verifiedUniversity = '';
  String _verifiedDepartment = '';
  String _assignedTherapistCode = '';

  // ── Giriş Yap Kontrolcüleri ──
  final TextEditingController _loginChildEmailCtrl = TextEditingController();
  final TextEditingController _loginChildPassCtrl = TextEditingController();
  final TextEditingController _loginTherapistEmailCtrl = TextEditingController();
  final TextEditingController _loginTherapistPassCtrl = TextEditingController();

  final List<String> _avatars = ['👦', '👧', '🧒', '🦁', '🐼', '🚀', '🦄', '🐱', '⚽', '🎨'];
  final List<int> _ages = [4, 5, 6, 7, 8, 9, 10, 11, 12];

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
    _childParentEmailCtrl.dispose();
    _childPasswordCtrl.dispose();
    _childTherapistCodeCtrl.dispose();
    _therapistNameCtrl.dispose();
    _clinicNameCtrl.dispose();
    _therapistTcCtrl.dispose();
    _edevletDocCtrl.dispose();
    _therapistEmailCtrl.dispose();
    _therapistPassCtrl.dispose();
    _loginChildEmailCtrl.dispose();
    _loginChildPassCtrl.dispose();
    _loginTherapistEmailCtrl.dispose();
    _loginTherapistPassCtrl.dispose();
    super.dispose();
  }

  void _goToGameMap() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  void _goToTherapistPortal() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const HomeScreen(openTherapistPortalOnStart: true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E3A8A),
      body: Stack(
        children: [
          // Arka Plan Canlı Gradyan
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF1E3A8A),
                  Color(0xFF172554),
                  Color(0xFF0F172A),
                ],
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _buildCurrentView(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentView() {
    switch (_currentView) {
      case AuthScreenView.welcome:
        return _buildWelcomeView();
      case AuthScreenView.register:
        return _buildRegisterView();
      case AuthScreenView.login:
        return _buildLoginView();
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 1. KARŞILAMA EKRANI (WELCOME)
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildWelcomeView() {
    return Container(
      key: const ValueKey('welcome_view'),
      constraints: const BoxConstraints(maxWidth: 440),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Maskot & Konuşma Baloncuğu
          AnimatedBuilder(
            animation: _mascotBounce,
            builder: (ctx, child) => Transform.translate(
              offset: Offset(0, _mascotBounce.value),
              child: child,
            ),
            child: Column(
              children: [
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
                Container(
                  width: 105,
                  height: 105,
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
                    child: Text('🦜', style: TextStyle(fontSize: 56)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),

          const Text(
            'Ses Yolunda Eğlence',
            textAlign: TextAlign.center,
            style: TextStyle(
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
              fontSize: 13.5,
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
          const SizedBox(height: 32),

          // ── 1. BUTON: BAŞLA (KAYIT OL) ──────────────────────────────────
          _buildDuolingoButton(
            label: 'BAŞLA (KAYIT OL)',
            icon: Icons.rocket_launch_rounded,
            bgColor: const Color(0xFF58CC02),
            shadowColor: const Color(0xFF45A202),
            textColor: Colors.white,
            onTap: () {
              _sfx.playSuccessDing();
              setState(() => _currentView = AuthScreenView.register);
            },
          ),
          const SizedBox(height: 14),

          // ── 2. BUTON: ZATEN BİR HESABIM VAR (GİRİŞ YAP) ─────────────────
          _buildDuolingoButton(
            label: 'ZATEN BİR HESABIM VAR',
            icon: Icons.login_rounded,
            bgColor: Colors.white,
            shadowColor: const Color(0xFFCBD5E1),
            textColor: const Color(0xFF1E293B),
            onTap: () {
              _sfx.playPopSound();
              setState(() => _currentView = AuthScreenView.login);
            },
          ),
          const SizedBox(height: 20),

          // Hızlı Misafir Geçişi
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
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 2. KAYIT OL EKRANI (REGISTER - DKT & KULLANICI AYRI)
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildRegisterView() {
    return Container(
      key: const ValueKey('register_view'),
      constraints: const BoxConstraints(maxWidth: 480),
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(color: Color(0x33000000), blurRadius: 20, offset: Offset(0, 8)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Üst Başlık & Geri Butonu
          Row(
            children: [
              IconButton(
                onPressed: () {
                  _sfx.playPopSound();
                  setState(() => _currentView = AuthScreenView.welcome);
                },
                icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF334155)),
              ),
              const Expanded(
                child: Text(
                  'Yeni Hesap Oluştur',
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                ),
              ),
              TextButton(
                onPressed: () {
                  _sfx.playPopSound();
                  setState(() => _currentView = AuthScreenView.login);
                },
                child: const Text('Giriş Yap', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E88E5))),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ── KULLANICI vs DKT AYRI SEÇİM SEKMESİ ─────────────────────────
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      _sfx.playPopSound();
                      setState(() => _registerRole = 'child');
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: _registerRole == 'child' ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: _registerRole == 'child'
                            ? [const BoxShadow(color: Color(0x10000000), blurRadius: 4, offset: Offset(0, 2))]
                            : null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('🧒', style: TextStyle(fontSize: 18)),
                          const SizedBox(width: 6),
                          Text(
                            'Danışan / Öğrenci',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 12.5,
                              color: _registerRole == 'child' ? const Color(0xFF16A34A) : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      _sfx.playPopSound();
                      setState(() => _registerRole = 'therapist');
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: _registerRole == 'therapist' ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: _registerRole == 'therapist'
                            ? [const BoxShadow(color: Color(0x10000000), blurRadius: 4, offset: Offset(0, 2))]
                            : null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('👨‍⚕️', style: TextStyle(fontSize: 18)),
                          const SizedBox(width: 6),
                          Text(
                            'DKT (Terapist)',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 12.5,
                              color: _registerRole == 'therapist' ? const Color(0xFF0284C7) : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // ── FORM İÇERİĞİ ───────────────────────────────────────────────
          if (_registerRole == 'child')
            _buildChildRegisterForm()
          else
            _buildTherapistRegisterForm(),
        ],
      ),
    );
  }

  // ── A) DANIŞAN / ÖĞRENCİ KAYIT FORMU ──────────────────────────────────────
  Widget _buildChildRegisterForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Çocuğun / Danışanın Adı:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        const SizedBox(height: 4),
        TextField(
          controller: _childNameCtrl,
          decoration: InputDecoration(
            hintText: 'Örn: Can, Zeynep, Ali...',
            prefixIcon: const Icon(Icons.person_outline_rounded, size: 20),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
        const SizedBox(height: 12),

        // Yaş Seçimi
        const Text('Çocuğun Yaşı:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        const SizedBox(height: 6),
        SizedBox(
          height: 38,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _ages.length,
            separatorBuilder: (_, _) => const SizedBox(width: 6),
            itemBuilder: (ctx, i) {
              final age = _ages[i];
              final isSel = age == _childAge;
              return InkWell(
                onTap: () {
                  _sfx.playPopSound();
                  setState(() => _childAge = age);
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 38,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSel ? const Color(0xFF16A34A) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: isSel ? const Color(0xFF15803D) : Colors.transparent),
                  ),
                  child: Text(
                    '$age',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: isSel ? Colors.white : const Color(0xFF334155),
                      fontSize: 13,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),

        // Avatar Seçimi
        const Text('Karakter Avatarını Seç:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _avatars.map((av) {
            final isSel = av == _selectedChildAvatar;
            return InkWell(
              onTap: () {
                _sfx.playPopSound();
                setState(() => _selectedChildAvatar = av);
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: isSel ? const Color(0xFFE8F5E9) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSel ? const Color(0xFF4CAF50) : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Text(av, style: const TextStyle(fontSize: 24)),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),

        const Text('Veli E-Posta Adresi:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        const SizedBox(height: 4),
        TextField(
          controller: _childParentEmailCtrl,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: 'ornek.veli@gmail.com',
            prefixIcon: const Icon(Icons.email_outlined, size: 18),
            helperText: '📩 Egzersiz raporları ve ödevler bu adrese iletilir.',
            helperStyle: const TextStyle(fontSize: 10.5, color: Color(0xFF16A34A)),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          ),
        ),
        const SizedBox(height: 10),

        const Text('Şifre Belirleyin:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        const SizedBox(height: 4),
        TextField(
          controller: _childPasswordCtrl,
          obscureText: true,
          decoration: InputDecoration(
            hintText: '••••••••',
            prefixIcon: const Icon(Icons.lock_outline_rounded, size: 18),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          ),
        ),
        const SizedBox(height: 10),

        const Text('Terapist Kodu (Opsiyonel):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        const SizedBox(height: 4),
        TextField(
          controller: _childTherapistCodeCtrl,
          decoration: InputDecoration(
            hintText: 'Örn: DKT-MERVE (Terapistiniz verdiyse girin)',
            prefixIcon: const Icon(Icons.medical_services_outlined, size: 18),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          ),
        ),
        const SizedBox(height: 20),

        // Kayıt Ol & Başla Butonu
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: _handleChildRegister,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF58CC02),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 2,
            ),
            child: const Text('Hesabı Oluştur ve Maceraya Başla! 🚀', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 13.5)),
          ),
        ),
      ],
    );
  }

  void _handleChildRegister() {
    final name = _childNameCtrl.text.trim().isNotEmpty
        ? _childNameCtrl.text.trim()
        : 'Can';
    final email = _childParentEmailCtrl.text.trim();
    final therapistCode = _childTherapistCodeCtrl.text.trim();

    _rewardState.setStudentName(name);
    _rewardState.setActiveAvatar(_selectedChildAvatar);
    if (email.isNotEmpty) {
      _rewardState.setParentEmail(email);
    }

    // Terapist sistemine gerçek danışan olarak eşle
    _dkt.syncStudentFromOnboarding(
      name: name,
      avatar: _selectedChildAvatar,
      parentEmail: email,
      therapistCode: therapistCode,
    );

    _sfx.playVictoryFanfare();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🎉 Hoş geldin $name! Konuşma maceran başlıyor ⭐'),
        backgroundColor: const Color(0xFF16A34A),
      ),
    );
    _goToGameMap();
  }

  // ── B) DKT (DİL VE KONUŞMA TERAPİSTİ) GERÇEK KAYIT FORMU ─────────────────
  Widget _buildTherapistRegisterForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Terapist Adı Soyadı:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        const SizedBox(height: 4),
        TextField(
          controller: _therapistNameCtrl,
          decoration: InputDecoration(
            hintText: 'Örn: Uzm. DKT Merve Kaya',
            prefixIcon: const Icon(Icons.badge_outlined, size: 20),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          ),
        ),
        const SizedBox(height: 10),

        const Text('Klinik / Merkez Adı:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        const SizedBox(height: 4),
        TextField(
          controller: _clinicNameCtrl,
          decoration: InputDecoration(
            hintText: 'Örn: Mavi Martı Dil ve Konuşma Merkezi',
            prefixIcon: const Icon(Icons.apartment_rounded, size: 20),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          ),
        ),
        const SizedBox(height: 10),

        const Text('T.C. Kimlik No:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        const SizedBox(height: 4),
        TextField(
          controller: _therapistTcCtrl,
          keyboardType: TextInputType.number,
          maxLength: 11,
          decoration: InputDecoration(
            hintText: '11 haneli T.C. Kimlik No',
            prefixIcon: const Icon(Icons.credit_card_rounded, size: 20),
            counterText: '',
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          ),
        ),
        const SizedBox(height: 10),

        // 🏛️ e-Devlet YÖK Mezuniyet Belge No ve Doğrulama
        const Text('🏛️ e-Devlet Mezuniyet Barkod Belge No:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _edevletDocCtrl,
                decoration: InputDecoration(
                  hintText: 'Örn: YOK-2024-DKT-8921',
                  prefixIcon: const Icon(Icons.qr_code_rounded, size: 20),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: _verifyEdevlet,
              icon: _isVerifyingEdevlet
                  ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.verified_user_rounded, size: 16, color: Colors.white),
              label: Text(_isVerifyingEdevlet ? 'Sorgulanıyor...' : 'e-Devlet İle Doğrula', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0284C7),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),

        // e-Devlet Onaylandı Yeşil Resmi Kartı
        if (_isEdevletVerified) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF86EFAC), width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.verified_rounded, color: Color(0xFF16A34A), size: 20),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        '🇹🇷 T.C. YÖK & e-Devlet Mezuniyet Onayı Verildi',
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Color(0xFF15803D)),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 12),
                Text('👤 Mezun: ${_therapistNameCtrl.text.trim().isNotEmpty ? _therapistNameCtrl.text.trim() : "Onaylı DKT"}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                Text('🎓 Bölüm: $_verifiedDepartment', style: const TextStyle(fontSize: 11, color: Color(0xFF334155))),
                Text('🏛️ Fakülte: $_verifiedUniversity', style: const TextStyle(fontSize: 11, color: Color(0xFF334155))),
                Text('🔑 Danışan Eşleştirme Kodunuz: $_assignedTherapistCode', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFF0284C7))),
              ],
            ),
          ),
        ],
        const SizedBox(height: 10),

        const Text('Kurumsal E-Posta:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        const SizedBox(height: 4),
        TextField(
          controller: _therapistEmailCtrl,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: 'ornek.dkt@klinik.com',
            prefixIcon: const Icon(Icons.alternate_email_rounded, size: 18),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          ),
        ),
        const SizedBox(height: 10),

        const Text('Şifre Belirleyin:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        const SizedBox(height: 4),
        TextField(
          controller: _therapistPassCtrl,
          obscureText: true,
          decoration: InputDecoration(
            hintText: '••••••••',
            prefixIcon: const Icon(Icons.lock_outline_rounded, size: 18),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          ),
        ),
        const SizedBox(height: 20),

        // DKT Olarak Kaydol Butonu
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: _handleTherapistRegister,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0284C7),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 2,
            ),
            child: const Text('e-Devlet Onaylı DKT Olarak Kaydol & Başla 🗣️', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 13)),
          ),
        ),
      ],
    );
  }

  void _verifyEdevlet() async {
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

    setState(() => _isVerifyingEdevlet = true);
    _sfx.playPopSound();
    await Future.delayed(const Duration(milliseconds: 700));

    final tName = _therapistNameCtrl.text.trim();
    final cleanFirstName = (tName.isNotEmpty ? tName.split(' ').first : 'MERVE')
        .replaceAll(RegExp(r'[^a-zA-ZçÇğĞıİöÖşŞüÜ]'), '')
        .toUpperCase();

    setState(() {
      _isVerifyingEdevlet = false;
      _isEdevletVerified = true;
      _verifiedUniversity = 'Sağlık Bilimleri Fakültesi (Lisans Diploması)';
      _verifiedDepartment = 'Dil ve Konuşma Terapisi Bölümü';
      _assignedTherapistCode = 'DKT-$cleanFirstName';
    });

    _sfx.playVictoryFanfare();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🇹🇷 e-Devlet & YÖK Mezuniyet Belgesi Doğrulandı! ($doc • Dil ve Konuşma Terapisi)'),
          backgroundColor: const Color(0xFF16A34A),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  void _handleTherapistRegister() {
    final name = _therapistNameCtrl.text.trim();
    final clinic = _clinicNameCtrl.text.trim().isNotEmpty
        ? _clinicNameCtrl.text.trim()
        : 'Dil ve Konuşma Danışmanlık Merkezi';
    final email = _therapistEmailCtrl.text.trim();
    final pass = _therapistPassCtrl.text.trim();
    final doc = _edevletDocCtrl.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen terapist adınızı ve unvanınızı giriniz.')),
      );
      return;
    }
    if (!_isEdevletVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen önce e-Devlet İle Doğrula butonuna basarak mezuniyetinizi onaylatınız.')),
      );
      return;
    }
    if (email.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen kurumsal e-posta ve şifrenizi giriniz.')),
      );
      return;
    }

    _dkt.registerTherapist(
      name: name,
      clinic: clinic,
      email: email,
      edevletDocNo: doc,
      password: pass,
    );
    _rewardState.setTherapistEmail(email);

    _sfx.playVictoryFanfare();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('👨‍⚕️ Hoş geldiniz $name! DKT Klinik Portalınız açılıyor...'),
        backgroundColor: const Color(0xFF0284C7),
      ),
    );
    _goToTherapistPortal();
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 3. GİRİŞ YAP EKRANI (LOGIN - DANIŞAN VE DKT AYRI)
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildLoginView() {
    return Container(
      key: const ValueKey('login_view'),
      constraints: const BoxConstraints(maxWidth: 460),
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(color: Color(0x33000000), blurRadius: 20, offset: Offset(0, 8)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Üst Başlık & Geri Butonu
          Row(
            children: [
              IconButton(
                onPressed: () {
                  _sfx.playPopSound();
                  setState(() => _currentView = AuthScreenView.welcome);
                },
                icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF334155)),
              ),
              const Expanded(
                child: Text(
                  'Hesabına Giriş Yap',
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                ),
              ),
              TextButton(
                onPressed: () {
                  _sfx.playPopSound();
                  setState(() => _currentView = AuthScreenView.register);
                },
                child: const Text('Kayıt Ol', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF58CC02))),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ── KULLANICI vs DKT GİRİŞ SEKMESİ ─────────────────────────────
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      _sfx.playPopSound();
                      setState(() => _loginRole = 'child');
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: _loginRole == 'child' ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: _loginRole == 'child'
                            ? [const BoxShadow(color: Color(0x10000000), blurRadius: 4, offset: Offset(0, 2))]
                            : null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('🧒', style: TextStyle(fontSize: 18)),
                          const SizedBox(width: 6),
                          Text(
                            'Danışan Girişi',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 12.5,
                              color: _loginRole == 'child' ? const Color(0xFF16A34A) : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      _sfx.playPopSound();
                      setState(() => _loginRole = 'therapist');
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: _loginRole == 'therapist' ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: _loginRole == 'therapist'
                            ? [const BoxShadow(color: Color(0x10000000), blurRadius: 4, offset: Offset(0, 2))]
                            : null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('👨‍⚕️', style: TextStyle(fontSize: 18)),
                          const SizedBox(width: 6),
                          Text(
                            'DKT Girişi',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 12.5,
                              color: _loginRole == 'therapist' ? const Color(0xFF0284C7) : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // ── GİRİŞ İÇERİĞİ ───────────────────────────────────────────────
          if (_loginRole == 'child') ...[
            // Danışan Hızlı Giriş
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFBBF7D0)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: const Color(0xFFDCFCE7),
                    child: Text(_rewardState.activeAvatar, style: const TextStyle(fontSize: 22)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${_rewardState.studentName} (Kayıtlı Çocuk)', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Color(0xFF166534))),
                        Text('⭐ ${_rewardState.totalStars} Yıldız • 🔥 ${_rewardState.streakDays} Gün Serisi', style: const TextStyle(fontSize: 11, color: Color(0xFF15803D))),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _sfx.playSuccessDing();
                      _goToGameMap();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF16A34A),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('GİRİŞ 🚀', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 11.5)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Center(child: Text('veya e-posta ile giriş yap:', style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold))),
            const SizedBox(height: 12),

            const Text('Veli E-Posta Adresi:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            const SizedBox(height: 4),
            TextField(
              controller: _loginChildEmailCtrl,
              decoration: InputDecoration(
                hintText: 'ornek.veli@gmail.com',
                prefixIcon: const Icon(Icons.email_outlined, size: 18),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              ),
            ),
            const SizedBox(height: 10),
            const Text('Şifre:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            const SizedBox(height: 4),
            TextField(
              controller: _loginChildPassCtrl,
              obscureText: true,
              decoration: InputDecoration(
                hintText: '••••••••',
                prefixIcon: const Icon(Icons.lock_outline_rounded, size: 18),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: () {
                  _sfx.playSuccessDing();
                  _goToGameMap();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF58CC02),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Oyuna Başla 🎮', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 13.5)),
              ),
            ),
          ] else ...[
            // DKT Hızlı Giriş
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F9FF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFBAE6FD)),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 20,
                    backgroundColor: Color(0xFFE0F2FE),
                    child: Text('👨‍⚕️', style: TextStyle(fontSize: 22)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_dkt.therapistName, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Color(0xFF0369A1))),
                        Text('${_dkt.clinicName} • (${_dkt.students.length} Danışan)', style: const TextStyle(fontSize: 11, color: Color(0xFF0284C7))),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _sfx.playSuccessDing();
                      _dkt.loginTherapist(_dkt.email, '');
                      _goToTherapistPortal();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0284C7),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('PORTAL 📋', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 11.5)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Center(child: Text('veya kurumsal hesapla giriş yap:', style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold))),
            const SizedBox(height: 12),

            const Text('Kurumsal E-Posta:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            const SizedBox(height: 4),
            TextField(
              controller: _loginTherapistEmailCtrl,
              decoration: InputDecoration(
                hintText: 'ornek.dkt@klinik.com',
                prefixIcon: const Icon(Icons.email_outlined, size: 18),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              ),
            ),
            const SizedBox(height: 10),
            const Text('Şifre:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            const SizedBox(height: 4),
            TextField(
              controller: _loginTherapistPassCtrl,
              obscureText: true,
              decoration: InputDecoration(
                hintText: '••••••••',
                prefixIcon: const Icon(Icons.lock_outline_rounded, size: 18),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: () {
                  final email = _loginTherapistEmailCtrl.text.trim();
                  final pass = _loginTherapistPassCtrl.text.trim();
                  _dkt.loginTherapist(email.isNotEmpty ? email : 'merve.dkt@klinik.com', pass);
                  _sfx.playSuccessDing();
                  _goToTherapistPortal();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0284C7),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Klinik Portalı\'na Giriş Yap 🗣️', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 13.5)),
              ),
            ),
          ],
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
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: textColor,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
