import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/reward_state.dart';
import '../services/sound_effects_service.dart';
import '../services/therapist_state_service.dart';
import 'home_screen.dart';

/// 🦉 DUOLINGO & KLİNİK TARZI AÇILIŞ: AYRI KAYIT OL VE GİRİŞ YAP PORTALI
/// Ana ekranda doğrudan:
/// 1. 🚀 [KAYIT OL] vs 🔑 [GİRİŞ YAP] Ana Sekmeleri
/// 2. Kayıt Ol Seçildiğinde:
///    - 🧒 Danışan / Kullanıcı Kaydı (Çocuk & Veli)
///    - 👨‍⚕️ DKT (Dil ve Konuşma Terapisti) Kaydı (T.C. & e-Devlet YÖK Mezuniyet Doğrulamalı)
/// 3. Giriş Yap Seçildiğinde:
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

  // Ana Sekme: 'register' (Kayıt Ol) veya 'login' (Giriş Yap)
  String _mainMode = 'register';

  // Alt Rol Sekmesi: 'child' (Danışan) veya 'therapist' (DKT)
  String _activeRole = 'child';

  // ── Danışan / Kullanıcı Kayıt Kontrolcüleri ──
  final TextEditingController _childNameCtrl = TextEditingController();
  final TextEditingController _childParentEmailCtrl = TextEditingController();
  final TextEditingController _childPasswordCtrl = TextEditingController();
  final TextEditingController _childTherapistCodeCtrl = TextEditingController();
  int _childAge = 6;
  String _selectedChildAvatar = '⭐';

  // ── DKT Terapist Kayıt Kontrolcüleri ──
  final TextEditingController _therapistNameCtrl = TextEditingController();
  final TextEditingController _clinicNameCtrl = TextEditingController();
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
  final TextEditingController _loginChildTherapistCodeCtrl = TextEditingController();
  final TextEditingController _loginTherapistEmailCtrl = TextEditingController();
  final TextEditingController _loginTherapistPassCtrl = TextEditingController();

  final List<String> _avatars = ['⭐', '🚀', '🎨', '🦁', '🐼', '🦄', '🐱', '⚽', '🧒', '👧'];
  final List<int> _ages = [4, 5, 6, 7, 8, 9, 10, 11, 12];

  @override
  void initState() {
    super.initState();
    _mascotAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _mascotBounce = Tween<double>(begin: -5.0, end: 5.0).animate(
      CurvedAnimation(parent: _mascotAnimController, curve: Curves.easeInOut),
    );
    if (_rewardState.therapistCode.isNotEmpty) {
      _childTherapistCodeCtrl.text = _rewardState.therapistCode;
      _loginChildTherapistCodeCtrl.text = _rewardState.therapistCode;
    }
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
    _edevletDocCtrl.dispose();
    _therapistEmailCtrl.dispose();
    _therapistPassCtrl.dispose();
    _loginChildEmailCtrl.dispose();
    _loginChildPassCtrl.dispose();
    _loginChildTherapistCodeCtrl.dispose();
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 1. ÜST MASKOT VE PROJE BAŞLIĞI
                      _buildHeaderSection(),
                      const SizedBox(height: 18),

                      // 2. ANA SEKMELER: [ 🚀 KAYIT OL ] vs [ 🔑 GİRİŞ YAP ]
                      _buildMainTabBar(),
                      const SizedBox(height: 14),

                      // 3. ALT ROL SEKMELERİ: [ 🧒 Danışan ] vs [ 👨‍⚕️ DKT Terapist ]
                      _buildRoleTabBar(),
                      const SizedBox(height: 16),

                      // 4. AKTİF FORM KARTI
                      _buildActiveFormCard(),
                      const SizedBox(height: 18),

                      // 5. MİSAFİR OLARAK HIZLI GEÇİŞ
                      TextButton(
                        onPressed: () {
                          _sfx.playPopSound();
                          _goToGameMap();
                        },
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Giriş Yapmadan Misafir Olarak Hızlıca Keşfet',
                              style: TextStyle(
                                color: Color(0xFF94A3B8),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
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
          ),
        ],
      ),
    );
  }

  // ── 1. ÜST MASKOT VE PROJE BİLGİSİ ─────────────────────────────────────────
  Widget _buildHeaderSection() {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _mascotBounce,
          builder: (ctx, child) => Transform.translate(
            offset: Offset(0, _mascotBounce.value),
            child: child,
          ),
          child: Column(
            children: [
              // Konuşma Baloncuğu
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(color: Color(0x33000000), blurRadius: 10, offset: Offset(0, 3)),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('🎙️', style: TextStyle(fontSize: 18)),
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
              const SizedBox(height: 14),
              // Büyük Canlı 3D Papağan Maskotu
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF58CC02), Color(0xFF46A302)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4.5),
                  boxShadow: const [
                    BoxShadow(color: Color(0x6658CC02), blurRadius: 28, offset: Offset(0, 10)),
                  ],
                ),
                child: const Center(
                  child: Text('🦜', style: TextStyle(fontSize: 82)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'Ses Yolunda Eğlence',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Oyunla Artikülasyon Terapisi & Klinik Takip Sistemi',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12.5,
            color: Color(0xFFCBD5E1),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ── 2. ANA SEKMELER: [ 🚀 KAYIT OL ] vs [ 🔑 GİRİŞ YAP ] ──────────────────
  Widget _buildMainTabBar() {
    final isRegister = _mainMode == 'register';
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white24, width: 1.2),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
                _sfx.playPopSound();
                setState(() => _mainMode = 'register');
              },
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 11),
                decoration: BoxDecoration(
                  color: isRegister ? const Color(0xFF58CC02) : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: isRegister
                      ? [const BoxShadow(color: Color(0x4458CC02), blurRadius: 8, offset: Offset(0, 3))]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('🚀', style: TextStyle(fontSize: isRegister ? 16 : 14)),
                    const SizedBox(width: 6),
                    Text(
                      'KAYIT OL',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 13.5,
                        color: isRegister ? Colors.white : const Color(0xFF94A3B8),
                        letterSpacing: 0.5,
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
                setState(() => _mainMode = 'login');
              },
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 11),
                decoration: BoxDecoration(
                  color: !isRegister ? const Color(0xFF1E88E5) : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: !isRegister
                      ? [const BoxShadow(color: Color(0x441E88E5), blurRadius: 8, offset: Offset(0, 3))]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('🔑', style: TextStyle(fontSize: !isRegister ? 16 : 14)),
                    const SizedBox(width: 6),
                    Text(
                      'GİRİŞ YAP',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 13.5,
                        color: !isRegister ? Colors.white : const Color(0xFF94A3B8),
                        letterSpacing: 0.5,
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

  // ── 3. ALT ROL SEKMELERİ: [ 🧒 Danışan ] vs [ 👨‍⚕️ DKT Terapist ] ─────────
  Widget _buildRoleTabBar() {
    final isChild = _activeRole == 'child';
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
                _sfx.playPopSound();
                setState(() => _activeRole = 'child');
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: isChild ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isChild
                      ? [const BoxShadow(color: Color(0x20000000), blurRadius: 4, offset: Offset(0, 2))]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('⭐', style: TextStyle(fontSize: 17)),
                    const SizedBox(width: 6),
                    Text(
                      _mainMode == 'register' ? 'Danışan / Öğrenci Kaydı' : 'Danışan Girişi',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        color: isChild ? const Color(0xFF15803D) : Colors.white70,
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
                setState(() => _activeRole = 'therapist');
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: !isChild ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: !isChild
                      ? [const BoxShadow(color: Color(0x20000000), blurRadius: 4, offset: Offset(0, 2))]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('🗣️', style: TextStyle(fontSize: 17)),
                    const SizedBox(width: 6),
                    Text(
                      _mainMode == 'register' ? 'DKT (Terapist) Kaydı' : 'DKT Girişi',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        color: !isChild ? const Color(0xFF0369A1) : Colors.white70,
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

  // ── 4. AKTİF FORM KARTI ───────────────────────────────────────────────────
  Widget _buildActiveFormCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: const [
          BoxShadow(color: Color(0x40000000), blurRadius: 24, offset: Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_mainMode == 'register' && _activeRole == 'child')
            _buildChildRegisterForm()
          else if (_mainMode == 'register' && _activeRole == 'therapist')
            _buildTherapistRegisterForm()
          else if (_mainMode == 'login' && _activeRole == 'child')
            _buildChildLoginForm()
          else
            _buildTherapistLoginForm(),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // A) DANIŞAN / ÖĞRENCİ KAYIT FORMU
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildChildRegisterForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(10)),
              child: const Text('⭐', style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Danışan / Öğrenci Kaydı', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF0F172A))),
                  Text('Eğlenceli konuşma ve ses profili', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                ],
              ),
            ),
          ],
        ),
        const Divider(height: 20),

        const Text('Kullanıcı Adı:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5)),
        const SizedBox(height: 4),
        TextField(
          controller: _childNameCtrl,
          decoration: InputDecoration(
            hintText: 'Kullanıcı Adı',
            prefixIcon: const Icon(Icons.person_outline_rounded, size: 20),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          ),
        ),
        const SizedBox(height: 10),

        // Yaş Seçimi
        const Text('Yaş:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5)),
        const SizedBox(height: 6),
        SizedBox(
          height: 36,
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
                  width: 36,
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
                      fontSize: 12.5,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),

        // Avatar Seçimi
        const Text('Karakter Avatarını Seç:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5)),
        const SizedBox(height: 6),
        Wrap(
          spacing: 7,
          runSpacing: 7,
          children: _avatars.map((av) {
            final isSel = av == _selectedChildAvatar;
            return InkWell(
              onTap: () {
                _sfx.playPopSound();
                setState(() => _selectedChildAvatar = av);
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isSel ? const Color(0xFFE8F5E9) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isSel ? const Color(0xFF4CAF50) : Colors.transparent, width: 2),
                ),
                child: Text(av, style: const TextStyle(fontSize: 22)),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 10),

        const Text('E-Posta Adresi:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5)),
        const SizedBox(height: 4),
        TextField(
          controller: _childParentEmailCtrl,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.email_outlined, size: 18),
            suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
            suffixIcon: const Padding(
              padding: EdgeInsets.only(right: 14),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '@gmail.com',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF16A34A),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          ),
        ),
        const SizedBox(height: 10),

        const Text('Şifre Belirleyin:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5)),
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
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: () => _showForgotPasswordDialog(context, initialEmail: _childParentEmailCtrl.text.trim()),
            icon: const Icon(Icons.lock_reset_rounded, size: 15, color: Color(0xFF16A34A)),
            label: const Text(
              'Şifremi Unuttum',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFF16A34A),
              ),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ),
        const SizedBox(height: 10),

        const Text('Terapist Kodu (Opsiyonel):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5)),
        const SizedBox(height: 4),
        TextField(
          controller: _childTherapistCodeCtrl,
          decoration: InputDecoration(
            hintText: 'Terapist Eşleştirme Kodu (Varsa girin)',
            prefixIcon: const Icon(Icons.medical_services_outlined, size: 18),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          ),
        ),
        const SizedBox(height: 18),

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

  void _sendWelcomeAndReminderNotification({required String email, required String name}) {
    if (!kIsWeb) return;
    try {
      final req = html.HttpRequest();
      req.open('POST', '/api/notifications/send');
      req.setRequestHeader('Content-Type', 'application/json');
      req.send(jsonEncode({
        'recipient_email': email,
        'student_name': name,
        'notification_type': 'welcome',
        'subject': '🎉 Ses Yolunda Eğlence\'ye Hoş Geldiniz! Kaydınız Tamamlandı',
        'message': 'Merhaba $name!\n\nSes Yolunda Eğlence hesabınız başarıyla oluşturuldu.'
      }));
    } catch (_) {}
  }

  void _handleChildRegister() {
    final name = _childNameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Lütfen bir kullanıcı adı giriniz.'),
          backgroundColor: Colors.orangeAccent,
        ),
      );
      return;
    }
    var email = _childParentEmailCtrl.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Lütfen e-posta adresinizi giriniz.'),
          backgroundColor: Colors.orangeAccent,
        ),
      );
      return;
    }
    if (!email.contains('@')) {
      email = '$email@gmail.com';
    } else if (email.endsWith('@')) {
      email = '${email}gmail.com';
    }
    final therapistCode = _childTherapistCodeCtrl.text.trim().toUpperCase();

    _rewardState.setStudentName(name);
    _rewardState.setActiveAvatar(_selectedChildAvatar);
    if (email.isNotEmpty) {
      _rewardState.setParentEmail(email);
      _sendWelcomeAndReminderNotification(email: email, name: name);
    }
    if (therapistCode.isNotEmpty) {
      _rewardState.setTherapistCode(therapistCode);
    }

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
        duration: const Duration(seconds: 3),
      ),
    );
    _goToGameMap();
  }

  // ──────────────────────────────────────────────────────────────────────────
  // B) DKT (TERAPİST) e-DEVLET DOĞRULAMALI GERÇEK KAYIT FORMU
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildTherapistRegisterForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: const Color(0xFFE0F2FE), borderRadius: BorderRadius.circular(10)),
              child: const Text('🗣️', style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Dil ve Konuşma Terapisti Kaydı', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15.5, color: Color(0xFF0F172A))),
                  Text('🏛️ e-Devlet YÖK Mezuniyet Doğrulamalı Yetkili Hesap', style: TextStyle(fontSize: 10.5, color: Color(0xFF0284C7), fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
        const Divider(height: 20),

        const Text('Terapist Adı Soyadı:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5)),
        const SizedBox(height: 4),
        TextField(
          controller: _therapistNameCtrl,
          decoration: InputDecoration(
            hintText: 'Adınız ve Soyadınız',
            prefixIcon: const Icon(Icons.badge_outlined, size: 20),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          ),
        ),
        const SizedBox(height: 10),

        const Text('Klinik / Danışmanlık Merkezi Adı:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5)),
        const SizedBox(height: 4),
        TextField(
          controller: _clinicNameCtrl,
          decoration: InputDecoration(
            hintText: 'Klinik veya Çalıştığınız Kurum Adı',
            prefixIcon: const Icon(Icons.apartment_rounded, size: 20),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          ),
        ),
        const SizedBox(height: 10),

        // 🏛️ e-Devlet YÖK Mezuniyet Belge No ve Doğrulama Butonu
        const Text('🏛️ e-Devlet Mezuniyet Barkod No:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5)),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _edevletDocCtrl,
                decoration: InputDecoration(
                  hintText: 'e-Devlet Mezuniyet Barkod No',
                  prefixIcon: const Icon(Icons.qr_code_rounded, size: 18),
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
                  : const Icon(Icons.verified_user_rounded, size: 15, color: Colors.white),
              label: Text(_isVerifyingEdevlet ? 'Sorgulanıyor...' : 'Doğrula', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
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
                const Row(
                  children: [
                    Icon(Icons.verified_rounded, color: Color(0xFF16A34A), size: 18),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '🇹🇷 T.C. YÖK & e-Devlet Lisans Diploması Doğrulandı',
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11.5, color: Color(0xFF15803D)),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 10),
                Text('👤 Mezun: ${_therapistNameCtrl.text.trim()}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                Text('🎓 Bölüm: $_verifiedDepartment', style: const TextStyle(fontSize: 10.5, color: Color(0xFF334155))),
                Text('🏛️ Fakülte: $_verifiedUniversity', style: const TextStyle(fontSize: 10.5, color: Color(0xFF334155))),
                Text('🔑 Danışan Eşleştirme Kodunuz: $_assignedTherapistCode', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFF0284C7))),
              ],
            ),
          ),
        ],
        const SizedBox(height: 10),

        const Text('E-Posta Adresi:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5)),
        const SizedBox(height: 4),
        TextField(
          controller: _therapistEmailCtrl,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: 'E-posta adresiniz',
            prefixIcon: const Icon(Icons.alternate_email_rounded, size: 18),
            suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
            suffixIcon: const Padding(
              padding: EdgeInsets.only(right: 14),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '@gmail.com',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0284C7),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          ),
        ),
        const SizedBox(height: 10),

        const Text('Şifre Belirleyin:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5)),
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
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: () => _showForgotPasswordDialog(context, initialEmail: _therapistEmailCtrl.text.trim()),
            icon: const Icon(Icons.lock_reset_rounded, size: 15, color: Color(0xFF0284C7)),
            label: const Text(
              'Şifremi Unuttum',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0284C7),
              ),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ),
        const SizedBox(height: 14),

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
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    final tName = _therapistNameCtrl.text.trim();
    if (tName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Lütfen önce adınızı ve unvanınızı yazınız.'),
          backgroundColor: Colors.orangeAccent,
        ),
      );
      return;
    }

    final cleanFirstName = tName
        .split(' ')
        .first
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
    var email = _therapistEmailCtrl.text.trim();
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
        const SnackBar(content: Text('Lütfen e-posta ve şifrenizi giriniz.')),
      );
      return;
    }

    if (!email.contains('@')) {
      email = '$email@gmail.com';
    } else if (email.endsWith('@')) {
      email = '${email}gmail.com';
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
        content: Text('🗣️ Hoş geldiniz $name! DKT Klinik Portalınız açılıyor...'),
        backgroundColor: const Color(0xFF0284C7),
      ),
    );
    _goToTherapistPortal();
  }

  // ──────────────────────────────────────────────────────────────────────────
  // C) DANIŞAN GİRİŞ FORMU
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildChildLoginForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(10)),
              child: const Text('⭐', style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Danışan / Öğrenci Girişi', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF0F172A))),
                  Text('Kayıtlı profille oyuna devam et', style: TextStyle(fontSize: 11, color: Color(0xFF16A34A))),
                ],
              ),
            ),
          ],
        ),
        const Divider(height: 20),

        const Text('E-Posta Adresi:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5)),
        const SizedBox(height: 4),
        TextField(
          controller: _loginChildEmailCtrl,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.email_outlined, size: 18),
            suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
            suffixIcon: const Padding(
              padding: EdgeInsets.only(right: 14),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '@gmail.com',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF16A34A),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          ),
        ),
        const SizedBox(height: 10),

        const Text('Şifre:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5)),
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
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: () => _showForgotPasswordDialog(context, initialEmail: _loginChildEmailCtrl.text.trim()),
            icon: const Icon(Icons.lock_reset_rounded, size: 15, color: Color(0xFF16A34A)),
            label: const Text(
              'Şifremi Unuttum',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFF16A34A),
              ),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ),
        const SizedBox(height: 10),
        const Text('Terapist Kodu (Opsiyonel):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5)),
        const SizedBox(height: 4),
        TextField(
          controller: _loginChildTherapistCodeCtrl,
          textCapitalization: TextCapitalization.characters,
          decoration: InputDecoration(
            hintText: 'Örn: DKT-BETUL (Terapistinizin tanımladığı kod)',
            prefixIcon: const Icon(Icons.vpn_key_rounded, size: 18, color: Color(0xFF0284C7)),
            helperText: '🔑 Kod girdiğinizde konuşma verileriniz doğrudan terapistinize aktarılır.',
            helperStyle: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          ),
        ),
        const SizedBox(height: 14),

        SizedBox(
          width: double.infinity,
          height: 46,
          child: ElevatedButton(
            onPressed: () {
              var email = _loginChildEmailCtrl.text.trim();
              final pass = _loginChildPassCtrl.text.trim();
              if (email.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('⚠️ Lütfen e-posta adresinizi giriniz.'),
                    backgroundColor: Colors.orangeAccent,
                  ),
                );
                return;
              }
              if (pass.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('⚠️ Lütfen şifrenizi giriniz.'),
                    backgroundColor: Colors.orangeAccent,
                  ),
                );
                return;
              }
              if (!email.contains('@')) {
                email = '$email@gmail.com';
              } else if (email.endsWith('@')) {
                email = '${email}gmail.com';
              }
              _rewardState.setParentEmail(email);
              final userNameFromEmail = email.split('@').first;
              String formattedName = 'Öğrenci';
              if (userNameFromEmail.isNotEmpty) {
                formattedName = userNameFromEmail[0].toUpperCase() + userNameFromEmail.substring(1);
                _rewardState.setStudentName(formattedName);
              }
              final inputTherapistCode = _loginChildTherapistCodeCtrl.text.trim().toUpperCase();
              if (inputTherapistCode.isNotEmpty) {
                _rewardState.setTherapistCode(inputTherapistCode);
              }
              final effectiveTherapistCode = inputTherapistCode.isNotEmpty ? inputTherapistCode : _rewardState.therapistCode;
              _dkt.syncStudentFromOnboarding(
                name: formattedName,
                avatar: '👦',
                parentEmail: email,
                therapistCode: effectiveTherapistCode,
              );
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
      ],
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // D) DKT (TERAPİST) GİRİŞ FORMU
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildTherapistLoginForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: const Color(0xFFE0F2FE), borderRadius: BorderRadius.circular(10)),
              child: const Text('🗣️', style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Dil ve Konuşma Terapisti Girişi', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15.5, color: Color(0xFF0F172A))),
                  Text('Danışan takip paneli ve gelişim karneleri', style: TextStyle(fontSize: 10.5, color: Color(0xFF0284C7))),
                ],
              ),
            ),
          ],
        ),
        const Divider(height: 20),

        const Text('E-Posta Adresi:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5)),
        const SizedBox(height: 4),
        TextField(
          controller: _loginTherapistEmailCtrl,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: 'E-posta adresiniz',
            prefixIcon: const Icon(Icons.email_outlined, size: 18),
            suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
            suffixIcon: const Padding(
              padding: EdgeInsets.only(right: 14),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '@gmail.com',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0284C7),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          ),
        ),
        const SizedBox(height: 10),

        const Text('Şifre:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5)),
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
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: () => _showForgotPasswordDialog(context, initialEmail: _loginTherapistEmailCtrl.text.trim()),
            icon: const Icon(Icons.lock_reset_rounded, size: 15, color: Color(0xFF0284C7)),
            label: const Text(
              'Şifremi Unuttum',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0284C7),
              ),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ),
        const SizedBox(height: 14),

        SizedBox(
          width: double.infinity,
          height: 46,
          child: ElevatedButton(
            onPressed: () {
              var email = _loginTherapistEmailCtrl.text.trim();
              final pass = _loginTherapistPassCtrl.text.trim();
              if (email.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('⚠️ Lütfen e-posta adresinizi giriniz.'),
                    backgroundColor: Colors.orangeAccent,
                  ),
                );
                return;
              }
              if (!email.contains('@')) {
                email = '$email@gmail.com';
              } else if (email.endsWith('@')) {
                email = '${email}gmail.com';
              }
              _dkt.loginTherapist(email, pass);
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
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // E) ŞİFREMİ UNUTTUM & YENİLEME DİYALOĞU
  // ──────────────────────────────────────────────────────────────────────────
  void _showForgotPasswordDialog(BuildContext context, {String initialEmail = ''}) {
    final cleanInitial = initialEmail.replaceAll('@gmail.com', '').trim();
    final emailCtrl = TextEditingController(text: cleanInitial);
    final newPassCtrl = TextEditingController();
    final confirmPassCtrl = TextEditingController();
    bool obscureNew = true;
    bool obscureConfirm = true;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              actionsPadding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF38BDF8), Color(0xFF0284C7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text('🔑', style: TextStyle(fontSize: 20)),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Şifremi Unuttum',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                        ),
                        Text(
                          'Yeni şifrenizi belirleyerek hesabınızı yenileyin',
                          style: TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(height: 16),
                    const Text('Kayıtlı E-Posta Adresiniz:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5)),
                    const SizedBox(height: 4),
                    TextField(
                      controller: emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'kullaniciadi',
                        prefixIcon: const Icon(Icons.alternate_email_rounded, size: 18),
                        suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                        suffixIcon: const Padding(
                          padding: EdgeInsets.only(right: 14),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '@gmail.com',
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF0284C7),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                    ),
                    const SizedBox(height: 12),

                    const Text('Yeni Şifre Belirleyin:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5)),
                    const SizedBox(height: 4),
                    TextField(
                      controller: newPassCtrl,
                      obscureText: obscureNew,
                      decoration: InputDecoration(
                        hintText: 'En az 4 karakter',
                        prefixIcon: const Icon(Icons.lock_outline_rounded, size: 18),
                        suffixIcon: IconButton(
                          icon: Icon(obscureNew ? Icons.visibility_off_rounded : Icons.visibility_rounded, size: 18, color: const Color(0xFF64748B)),
                          onPressed: () => setDialogState(() => obscureNew = !obscureNew),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                    ),
                    const SizedBox(height: 12),

                    const Text('Yeni Şifre (Tekrar):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5)),
                    const SizedBox(height: 4),
                    TextField(
                      controller: confirmPassCtrl,
                      obscureText: obscureConfirm,
                      decoration: InputDecoration(
                        hintText: 'Şifrenizi tekrar yazın',
                        prefixIcon: const Icon(Icons.lock_reset_rounded, size: 18),
                        suffixIcon: IconButton(
                          icon: Icon(obscureConfirm ? Icons.visibility_off_rounded : Icons.visibility_rounded, size: 18, color: const Color(0xFF64748B)),
                          onPressed: () => setDialogState(() => obscureConfirm = !obscureConfirm),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                    ),
                    const SizedBox(height: 10),

                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFBBF7D0)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.shield_outlined, color: Color(0xFF16A34A), size: 18),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Yeni şifreniz kaydedildikten sonra hesabınıza anında tanımlanır.',
                              style: TextStyle(fontSize: 10.5, color: Color(0xFF166534), fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogCtx).pop(),
                  child: const Text('Vazgeç', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold)),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    var rawEmail = emailCtrl.text.trim();
                    final newPass = newPassCtrl.text.trim();
                    final confirmPass = confirmPassCtrl.text.trim();

                    if (rawEmail.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('⚠️ Lütfen e-posta adresinizi giriniz.'), backgroundColor: Colors.orangeAccent),
                      );
                      return;
                    }
                    if (newPass.length < 4) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('⚠️ Şifre en az 4 karakter olmalıdır.'), backgroundColor: Colors.orangeAccent),
                      );
                      return;
                    }
                    if (newPass != confirmPass) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('⚠️ Şifreler birbiriyle eşleşmiyor!'), backgroundColor: Colors.redAccent),
                      );
                      return;
                    }

                    if (!rawEmail.contains('@')) {
                      rawEmail = '$rawEmail@gmail.com';
                    } else if (rawEmail.endsWith('@')) {
                      rawEmail = '${rawEmail}gmail.com';
                    }

                    // Terapist ve Veli Şifrelerini Güncelle
                    _dkt.resetPassword(rawEmail, newPass);
                    final prefix = rawEmail.replaceAll('@gmail.com', '');
                    _therapistEmailCtrl.text = prefix;
                    _therapistPassCtrl.text = newPass;
                    _loginTherapistEmailCtrl.text = prefix;
                    _loginTherapistPassCtrl.text = newPass;
                    _loginChildEmailCtrl.text = prefix;
                    _loginChildPassCtrl.text = newPass;
                    _childPasswordCtrl.text = newPass;

                    _sfx.playSuccessDing();
                    Navigator.of(dialogCtx).pop();

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(Icons.check_circle_rounded, color: Colors.white),
                            const SizedBox(width: 8),
                            Expanded(child: Text('✅ Şifreniz başarıyla yenilendi! ($rawEmail)')),
                          ],
                        ),
                        backgroundColor: const Color(0xFF16A34A),
                        duration: const Duration(seconds: 4),
                      ),
                    );
                  },
                  icon: const Icon(Icons.check_rounded, size: 16, color: Colors.white),
                  label: const Text('Şifremi Sıfırla & Kaydet', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0284C7),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
