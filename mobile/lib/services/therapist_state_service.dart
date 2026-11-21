import 'dart:convert';
import 'package:flutter/foundation.dart';
// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

/// 🗣️ DKT & DANIŞAN SENKRONİZASYON VE TEKİL OTURUM SERVİSİ
/// Açılış ekranındaki (Onboarding) kayıt/giriş ile
/// Ana ekrandaki "DKT Girişi" butonunun AYNI kullanıcıyı görmesini,
/// çocuğun girdiği bilgiler ile terapistin gördüğü danışanların %100 eşleşmesini sağlar.
class TherapistStateService extends ChangeNotifier {
  static final TherapistStateService _instance = TherapistStateService._internal();
  factory TherapistStateService() => _instance;

  TherapistStateService._internal() {
    _loadFromLocalStorage();
  }

  // Terapist Oturum Bilgileri
  bool _isLoggedIn = false;
  String _therapistName = '';
  String _clinicName = '';
  String _email = '';
  String _edevletDocNo = '';
  String _password = '';
  String _therapistCode = 'DKT-101';

  // Danışan Çocuklar Listesi (Kullanıcı ekledikçe veya çocuk kaydoldukça buraya akar)
  final List<Map<String, dynamic>> _students = [];

  // Getters
  bool get isLoggedIn => _isLoggedIn;
  String get therapistName => _therapistName.isNotEmpty ? _therapistName : 'Dil ve Konuşma Terapisti';
  String get clinicName => _clinicName.isNotEmpty ? _clinicName : 'Dil ve Konuşma Danışmanlık Merkezi';
  String get email => _email;
  String get edevletDocNo => _edevletDocNo;
  String get therapistCode => _therapistCode;
  List<Map<String, dynamic>> get students => List.unmodifiable(_students);

  /// 1. Terapist Kaydı (Hem Onboarding hem Portal içinden çağrılabilir)
  void registerTherapist({
    required String name,
    required String clinic,
    required String email,
    required String edevletDocNo,
    required String password,
  }) {
    _isLoggedIn = true;
    _therapistName = name.trim();
    _clinicName = clinic.trim().isNotEmpty ? clinic.trim() : 'Dil ve Konuşma Danışmanlık Merkezi';
    _email = email.trim().toLowerCase();
    _edevletDocNo = edevletDocNo.trim();
    _password = password;

    // Terapiste özel eşleştirme kodu üret (örn: DKT-MERVE veya DKT-101)
    final firstName = _therapistName.split(' ').first.replaceAll(RegExp(r'[^a-zA-ZçÇğĞıİöÖşŞüÜ]'), '').toUpperCase();
    _therapistCode = 'DKT-${firstName.isNotEmpty ? firstName : "101"}';

    _saveToLocalStorage();
    notifyListeners();
  }

  /// 2. Terapist Girişi
  bool loginTherapist(String emailInput, String passwordInput) {
    final cleanEmail = emailInput.trim().toLowerCase();
    
    // Daha önce kayıt varsa şifre doğrula, ilk defa ise doğrudan giriş yap
    if (_email.isNotEmpty && _password.isNotEmpty) {
      if (_email != cleanEmail || _password != passwordInput) {
        return false;
      }
    } else {
      _email = cleanEmail;
      _password = passwordInput;
      if (_therapistName.isEmpty) {
        final prefix = cleanEmail.split('@').first;
        _therapistName = 'Uzm. DKT ${prefix.toUpperCase()}';
      }
    }

    _isLoggedIn = true;
    _saveToLocalStorage();
    notifyListeners();
    return true;
  }

  /// 3. Çıkış Yap
  void logout() {
    _isLoggedIn = false;
    _saveToLocalStorage();
    notifyListeners();
  }

  /// 4. Çocuğu Terapist Sistemine Eşle & Senkronize Et
  /// Çocuk ilk açılış ekranında kaydolduğunda otomatik olarak buraya eklenir!
  void syncStudentFromOnboarding({
    required String name,
    required String avatar,
    String? parentEmail,
    String? therapistCode,
  }) {
    final cleanName = name.trim();
    if (cleanName.isEmpty) return;

    // Aynı isimde öğrenci varsa bilgilerini güncelle
    final existingIdx = _students.indexWhere((s) => s['name'] == cleanName);
    if (existingIdx != -1) {
      _students[existingIdx]['avatar'] = avatar;
      if (parentEmail != null && parentEmail.trim().isNotEmpty) {
        _students[existingIdx]['parent_email'] = parentEmail.trim();
      }
      if (therapistCode != null && therapistCode.trim().isNotEmpty) {
        _students[existingIdx]['therapist_code'] = therapistCode.trim();
      }
    } else {
      final newId = _students.length + 1;
      final studentCode = 'DKT-$newId-${cleanName.split(' ').first.toUpperCase()}';
      _students.insert(0, {
        'id': newId,
        'name': cleanName,
        'age': 6,
        'avatar': avatar,
        'diagnosis': 'Artikülasyon ve Sesletim Gelişimi',
        'target_phonemes': '/r/, /s/, /k/',
        'parent_email': (parentEmail != null && parentEmail.trim().isNotEmpty) ? parentEmail.trim() : '',
        'therapist_code': (therapistCode != null && therapistCode.trim().isNotEmpty) ? therapistCode.trim() : _therapistCode,
        'student_code': studentCode,
        'total_stars': 0,
        'accuracy': 0.0,
        'sessions_count': 0,
        'sessions': <Map<String, dynamic>>[],
      });
    }

    _saveToLocalStorage();
    notifyListeners();
  }

  /// 5. Terapistin Kendisinin Panelden Danışan Eklemesi
  void addStudent({
    required String name,
    int age = 6,
    String avatar = '👦',
    String diagnosis = 'Artikülasyon Güçlüğü',
    String targetPhonemes = '/r/, /s/',
    String parentEmail = '',
  }) {
    final cleanName = name.trim();
    if (cleanName.isEmpty) return;

    final newId = _students.length + 1;
    final studentCode = 'DKT-$newId-${cleanName.split(' ').first.toUpperCase()}';

    _students.insert(0, {
      'id': newId,
      'name': cleanName,
      'age': age,
      'avatar': avatar,
      'diagnosis': diagnosis.trim().isNotEmpty ? diagnosis.trim() : 'Artikülasyon Güçlüğü',
      'target_phonemes': targetPhonemes.trim().isNotEmpty ? targetPhonemes.trim() : '/r/, /s/',
      'parent_email': parentEmail.trim(),
      'therapist_code': _therapistCode,
      'student_code': studentCode,
      'total_stars': 0,
      'accuracy': 0.0,
      'sessions_count': 0,
      'sessions': <Map<String, dynamic>>[],
    });

    _saveToLocalStorage();
    notifyListeners();
  }

  /// 6. Seans Kaydı (Çocuk oyunda pratik yaptıkça terapist ekranına anında akar)
  void recordSession({
    required String studentName,
    required String phoneme,
    required double accuracy,
    int wordsCorrect = 14,
    int wordsAttempted = 16,
    String? note,
  }) {
    final cleanName = studentName.trim();
    var idx = _students.indexWhere((s) => s['name'] == cleanName);
    if (idx == -1) {
      // Öğrenci yoksa hemen ekle
      syncStudentFromOnboarding(name: cleanName, avatar: '👦');
      idx = _students.indexWhere((s) => s['name'] == cleanName);
      if (idx == -1) return;
    }

    final std = _students[idx];
    final sessionsList = (std['sessions'] as List<dynamic>?) ?? [];
    
    sessionsList.insert(0, {
      'date': 'Bugün',
      'phoneme': phoneme.replaceAll('/', '').trim(),
      'words': '$wordsCorrect/$wordsAttempted',
      'acc': accuracy,
      'note': note ?? 'Artikülasyon egzersiz seansı tamamlandı.',
    });

    std['sessions'] = sessionsList;
    std['sessions_count'] = sessionsList.length;

    // Ortalama doğruluk güncelle
    double sumAcc = 0;
    for (final se in sessionsList) {
      sumAcc += ((se as Map)['acc'] as num?)?.toDouble() ?? 0.0;
    }
    std['accuracy'] = double.parse((sumAcc / sessionsList.length).toStringAsFixed(1));
    std['total_stars'] = (std['total_stars'] as int? ?? 0) + (accuracy >= 80 ? 3 : 2);

    _saveToLocalStorage();
    notifyListeners();
  }

  /// 7. Danışan Silme
  void deleteStudent(dynamic id) {
    _students.removeWhere((s) => s['id'] == id);
    _saveToLocalStorage();
    notifyListeners();
  }

  /// Yerel Depolama (Flutter Web LocalStorage)
  void _saveToLocalStorage() {
    if (!kIsWeb) return;
    try {
      final storage = html.window.localStorage;
      storage['sye_dkt_logged_in'] = _isLoggedIn ? 'true' : 'false';
      storage['sye_dkt_name'] = _therapistName;
      storage['sye_dkt_clinic'] = _clinicName;
      storage['sye_dkt_email'] = _email;
      storage['sye_dkt_edevlet'] = _edevletDocNo;
      storage['sye_dkt_pass'] = _password;
      storage['sye_dkt_code'] = _therapistCode;
      storage['sye_dkt_students'] = jsonEncode(_students);
    } catch (_) {}
  }

  void _loadFromLocalStorage() {
    if (!kIsWeb) return;
    try {
      final storage = html.window.localStorage;
      if (storage.containsKey('sye_dkt_logged_in')) {
        _isLoggedIn = storage['sye_dkt_logged_in'] == 'true';
      }
      if (storage.containsKey('sye_dkt_name')) {
        _therapistName = storage['sye_dkt_name'] ?? '';
      }
      if (storage.containsKey('sye_dkt_clinic')) {
        _clinicName = storage['sye_dkt_clinic'] ?? '';
      }
      if (storage.containsKey('sye_dkt_email')) {
        _email = storage['sye_dkt_email'] ?? '';
      }
      if (storage.containsKey('sye_dkt_edevlet')) {
        _edevletDocNo = storage['sye_dkt_edevlet'] ?? '';
      }
      if (storage.containsKey('sye_dkt_pass')) {
        _password = storage['sye_dkt_pass'] ?? '';
      }
      if (storage.containsKey('sye_dkt_code')) {
        _therapistCode = storage['sye_dkt_code'] ?? 'DKT-101';
      }
      if (storage.containsKey('sye_dkt_students')) {
        final raw = storage['sye_dkt_students'];
        if (raw != null && raw.isNotEmpty) {
          final list = jsonDecode(raw) as List;
          _students.clear();
          for (final item in list) {
            _students.add(Map<String, dynamic>.from(item as Map));
          }
        }
      }
    } catch (_) {}
  }
}
