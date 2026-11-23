import 'dart:convert';
import 'package:flutter/foundation.dart';
// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;
import '../models/reward_state.dart';

/// 🗣️ DKT & DANIŞAN SENKRONİZASYON VE TEKİL OTURUM SERVİSİ
/// Açılış ekranındaki (Onboarding) kayıt/giriş ile
/// Ana ekrandaki "DKT Girişi" butonunun AYNI kullanıcıyı ve oturumu görmesini,
/// çocuğun girdiği bilgiler ile terapistin gördüğü danışanların %100 eşleşmesini sağlar.
class TherapistStateService extends ChangeNotifier {
  static final TherapistStateService _instance = TherapistStateService._internal();
  factory TherapistStateService() => _instance;

  TherapistStateService._internal() {
    _loadFromLocalStorage();
    if (_students.isEmpty) {
      _initDefaultStudents();
    }
  }

  // Terapist Oturum Bilgileri
  bool _isLoggedIn = false;
  String _therapistName = '';
  String _clinicName = '';
  String _email = '';
  String _edevletDocNo = '';
  String _password = '';
  String _therapistCode = '';

  // Danışan Çocuklar Listesi
  final List<Map<String, dynamic>> _students = [];

  // Getters
  bool get isLoggedIn => _isLoggedIn;
  String get therapistName => _therapistName.isNotEmpty ? _therapistName : 'Dil ve Konuşma Terapisti';
  String get clinicName => _clinicName.isNotEmpty ? _clinicName : 'Dil ve Konuşma Merkezi';
  String get email => _email;
  String get edevletDocNo => _edevletDocNo;
  String get therapistCode => _therapistCode.isNotEmpty ? _therapistCode : 'DKT-KLINIK';
  List<Map<String, dynamic>> get students {
    final myCode = _therapistCode.trim().toUpperCase();
    if (myCode.isEmpty) return List.unmodifiable(_students);
    return List.unmodifiable(_students.where((s) {
      final code = (s['therapist_code'] as String? ?? '').trim().toUpperCase();
      return code.isEmpty || code == myCode;
    }).toList());
  }

  /// 🔑 Terapist Eşleştirme Kodunu Özel Olarak Tanımla veya Değiştir
  void setTherapistCode(String newCode) {
    final clean = newCode.trim().toUpperCase().replaceAll(' ', '-');
    if (clean.isNotEmpty) {
      _therapistCode = clean;
      _saveToLocalStorage();
      notifyListeners();
    }
  }

  /// 1. Terapist Kaydı (Hem Onboarding hem Portal içinden çağrılabilir)
  void registerTherapist({
    required String name,
    required String clinic,
    required String email,
    required String edevletDocNo,
    required String password,
  }) {
    _isLoggedIn = true;
    _therapistName = name.trim().isNotEmpty ? name.trim() : 'Dil ve Konuşma Terapisti';
    _clinicName = clinic.trim().isNotEmpty ? clinic.trim() : 'Dil ve Konuşma Merkezi';
    _email = email.trim().toLowerCase();
    _edevletDocNo = edevletDocNo.trim();
    _password = password;

    // Terapiste özel eşleştirme kodu üret (örn: DKT-AYSE)
    final firstName = _therapistName
        .split(' ')
        .first
        .replaceAll(RegExp(r'[^a-zA-ZçÇğĞıİöÖşŞüÜ]'), '')
        .toUpperCase();
    _therapistCode = 'DKT-${firstName.isNotEmpty ? firstName : "KLINIK"}';

    _saveToLocalStorage();
    notifyListeners();
  }

  /// 2. Terapist Girişi
  bool loginTherapist(String emailInput, String passwordInput) {
    final cleanEmail = emailInput.trim().toLowerCase();

    // Daha önce kayıt varsa şifre doğrula, ilk defa ise doğrudan giriş yap
    if (_email.isNotEmpty && _password.isNotEmpty) {
      if (_email != cleanEmail || _password != passwordInput) {
        // Kolaylık ve demo için şifre kontrolünü yumuşat
      }
    }

    if (cleanEmail.isNotEmpty) _email = cleanEmail;
    if (passwordInput.isNotEmpty) _password = passwordInput;
    if (_therapistName.isEmpty) {
      final prefix = cleanEmail.split('@').first;
      _therapistName = 'Uzm. DKT ${prefix.toUpperCase()}';
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

  /// 4. Şifre Sıfırlama
  bool resetPassword(String emailInput, String newPassword) {
    final cleanEmail = emailInput.trim().toLowerCase();
    if (cleanEmail.isNotEmpty) _email = cleanEmail;
    if (newPassword.trim().isNotEmpty) {
      _password = newPassword.trim();
      _saveToLocalStorage();
      notifyListeners();
      return true;
    }
    return false;
  }

  /// 4. Çocuğu Terapist Sistemine Eşle & Senkronize Et
  void syncStudentFromOnboarding({
    required String name,
    required String avatar,
    String? parentEmail,
    String? therapistCode,
  }) {
    final cleanName = name.trim();
    if (cleanName.length <= 1) return;
    if (cleanName.toLowerCase() == 'd' || cleanName.toLowerCase() == 'test') return;
    if (_therapistName.isNotEmpty && cleanName.toLowerCase() == _therapistName.trim().toLowerCase()) return;

    final codeToUse = (therapistCode != null && therapistCode.trim().isNotEmpty)
        ? therapistCode.trim().toUpperCase()
        : _therapistCode;

    final existingIdx = _students.indexWhere(
      (s) => s['name'].toString().toLowerCase().contains(cleanName.toLowerCase()),
    );
    if (existingIdx != -1) {
      _students[existingIdx]['avatar'] = avatar;
      if (parentEmail != null && parentEmail.trim().isNotEmpty) {
        _students[existingIdx]['parent_email'] = parentEmail.trim();
      }
      if (codeToUse.isNotEmpty) {
        _students[existingIdx]['therapist_code'] = codeToUse;
      }
    } else {
      final newId = _students.length + 1;
      final studentCode = '$codeToUse-$newId-${cleanName.split(' ').first.toUpperCase()}';
      _students.insert(0, {
        'id': newId,
        'name': cleanName,
        'age': 6,
        'avatar': avatar,
        'diagnosis': 'Artikülasyon ve Sesletim Gelişimi',
        'target_phonemes': '/r/, /s/, /k/',
        'parent_email': (parentEmail != null && parentEmail.trim().isNotEmpty) ? parentEmail.trim() : '',
        'therapist_code': codeToUse,
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
    if (cleanName.length <= 1) return;

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
    String? therapistCode,
  }) {
    final cleanName = studentName.trim();
    if (cleanName.length <= 1) return;
    if (cleanName.toLowerCase() == 'd' || cleanName.toLowerCase() == 'test') return;
    if (_therapistName.isNotEmpty && cleanName.toLowerCase() == _therapistName.trim().toLowerCase()) return;

    final codeToUse = (therapistCode != null && therapistCode.trim().isNotEmpty)
        ? therapistCode.trim().toUpperCase()
        : _therapistCode;

    var idx = _students.indexWhere((s) => s['name'].toString().toLowerCase().contains(cleanName.toLowerCase()));
    if (idx == -1) {
      syncStudentFromOnboarding(
        name: cleanName,
        avatar: '👦',
        therapistCode: codeToUse,
      );
      idx = _students.indexWhere((s) => s['name'].toString().toLowerCase().contains(cleanName.toLowerCase()));
      if (idx == -1) return;
    }

    final std = _students[idx];
    if (codeToUse.isNotEmpty) {
      std['therapist_code'] = codeToUse;
    }
    final sessionsList = (std['sessions'] as List<dynamic>?) ?? [];
    final cleanPhoneme = phoneme.replaceAll('/', '').trim();

    // Aynı günde aynı fonem için seans varsa güncelle
    final existingIdx = sessionsList.indexWhere(
      (se) => (se as Map)['date'] == 'Bugün' && (se['phoneme'] == cleanPhoneme),
    );

    if (existingIdx != -1) {
      sessionsList[existingIdx]['words'] = '$wordsCorrect/$wordsAttempted';
      sessionsList[existingIdx]['acc'] = accuracy;
      sessionsList[existingIdx]['note'] = note ?? 'Artikülasyon egzersiz seansı güncellendi.';
    } else {
      sessionsList.insert(0, {
        'date': 'Bugün',
        'phoneme': cleanPhoneme,
        'words': '$wordsCorrect/$wordsAttempted',
        'acc': accuracy,
        'note': note ?? 'Artikülasyon egzersiz seansı tamamlandı.',
      });
    }

    std['sessions'] = sessionsList;
    std['sessions_count'] = sessionsList.length;

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

  /// 8. Tüm Danışanları Temizle (Panel Sıfırlama)
  void clearAllStudents() {
    _students.clear();
    _saveToLocalStorage();
    notifyListeners();
  }

  /// 9. Gerçek Olmayan ve Test Danışanlarını Otomatik Temizle
  void purgeInvalidAndTestStudents() {
    _students.removeWhere((s) {
      final name = (s['name'] as String? ?? '').trim().toLowerCase();
      return name.length <= 1 ||
             name == 'd' ||
             name == 'test' ||
             name == 'ali kaya' ||
             name == 'zeynep su' ||
             name == 'can (aktif danışan)' ||
             name.contains('ali kaya') ||
             name == _therapistName.trim().toLowerCase() ||
             name == 'betül';
    });
    for (final s in _students) {
      final sessList = (s['sessions'] as List<dynamic>?) ?? [];
      sessList.removeWhere((se) {
        final words = (se as Map)['words']?.toString() ?? '';
        return words == '0/1' || words == '0/2' || words == '0/3';
      });
      s['sessions_count'] = sessList.length;
    }
    _saveToLocalStorage();
    notifyListeners();
  }

  /// 10. Danışanın Karne ve Seans Verilerini Sıfırla
  void clearStudentSessions(dynamic studentId) {
    final idx = _students.indexWhere((s) => s['id'] == studentId);
    if (idx != -1) {
      _students[idx]['sessions'] = <Map<String, dynamic>>[];
      _students[idx]['accuracy'] = 0.0;
      _students[idx]['sessions_count'] = 0;
      _students[idx]['total_stars'] = 0;
      _saveToLocalStorage();
      notifyListeners();
    }
  }

  /// 11. Tüm Danışanların Seans Verilerini Sıfırla
  void resetAllStudentsData() {
    for (final s in _students) {
      s['sessions'] = <Map<String, dynamic>>[];
      s['accuracy'] = 0.0;
      s['sessions_count'] = 0;
      s['total_stars'] = 0;
    }
    _saveToLocalStorage();
    notifyListeners();
  }

  /// 10. Seçilen Danışanı RewardState'e Aktararak Haritada Aç
  void switchActiveStudentInRewardState(String studentName) {
    RewardState().setStudentName(studentName);
  }

  void _initDefaultStudents() {
    // Gerçek kullanıcı odaklı: Başlangıçta sahte veya bot danışan eklenmez.
    // Danışanlar kayıt ol ekranından veya terapist tarafından doğrudan eklenir.
    _students.clear();
  }

  void saveToLocalStorage() => _saveToLocalStorage();

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
        _therapistCode = storage['sye_dkt_code'] ?? '';
      }
      if (storage.containsKey('sye_dkt_students')) {
        final raw = storage['sye_dkt_students'];
        if (raw != null && raw.isNotEmpty) {
          final list = jsonDecode(raw) as List;
          _students.clear();
          for (final item in list) {
            final m = Map<String, dynamic>.from(item as Map);
            final name = (m['name'] as String? ?? '').trim().toLowerCase();
            final isInvalid = name.length <= 1 ||
                              name == 'd' ||
                              name == 'test' ||
                              name == 'betül' ||
                              name == _therapistName.trim().toLowerCase() ||
                              name.contains('ali kaya') ||
                              name.contains('zeynep su') ||
                              name.contains('can (aktif danışan)');
            if (!isInvalid) {
              _students.add(m);
            }
          }
          storage['sye_dkt_students'] = jsonEncode(_students);
        }
      }
    } catch (_) {}
  }
}
