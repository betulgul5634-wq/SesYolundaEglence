import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;
import 'package:flutter/foundation.dart';
import 'student_profile.dart';

class PhonemeStat {
  final String phoneme;
  int totalAttempts;
  int correctAttempts;
  int initialAttempts;
  int initialCorrect;
  int medialAttempts;
  int medialCorrect;
  int finalAttempts;
  int finalCorrect;

  PhonemeStat({
    required this.phoneme,
    this.totalAttempts = 0,
    this.correctAttempts = 0,
    this.initialAttempts = 0,
    this.initialCorrect = 0,
    this.medialAttempts = 0,
    this.medialCorrect = 0,
    this.finalAttempts = 0,
    this.finalCorrect = 0,
  });

  int get accuracyPercentage =>
      totalAttempts == 0 ? 0 : ((correctAttempts / totalAttempts) * 100).round();

  int get initialAccuracy =>
      initialAttempts == 0 ? 0 : ((initialCorrect / initialAttempts) * 100).round();

  int get medialAccuracy =>
      medialAttempts == 0 ? 0 : ((medialCorrect / medialAttempts) * 100).round();

  int get finalAccuracy =>
      finalAttempts == 0 ? 0 : ((finalCorrect / finalAttempts) * 100).round();
}

class RewardState extends ChangeNotifier {
  static final RewardState _instance = RewardState._internal();
  factory RewardState() => _instance;

  RewardState._internal() {
    _initSampleTherapyStats();
    _loadFromLocalStorage();
  }

  String _studentName = 'Can';
  String _parentEmail = 'veli@gmail.com';
  String _therapistEmail = 'dkt@klinik.com';
  String _activeProfileId = 'profile_1';
  final List<StudentProfile> _profiles = [];

  String get studentName => _studentName;
  String get parentEmail => _parentEmail;
  String get therapistEmail => _therapistEmail;
  String get activeProfileId => _activeProfileId;
  List<StudentProfile> get profiles => List.unmodifiable(_profiles);

  void setParentEmail(String email) {
    _parentEmail = email.trim();
    notifyListeners();
  }

  void setTherapistEmail(String email) {
    _therapistEmail = email.trim();
    notifyListeners();
  }

  void switchStudent(String profileId) {
    if (_profiles.isEmpty) return;
    // 1. Mevcut aktif profilin verilerini güncelle
    final currentIdx = _profiles.indexWhere((p) => p.id == _activeProfileId);
    if (currentIdx != -1) {
      _profiles[currentIdx]
        ..gems = _gems
        ..hearts = _hearts
        ..totalStars = _totalStars
        ..xp = _xp
        ..avatar = _activeAvatar
        ..name = _studentName
        ..activeCharacterId = _activeCharacterId
        ..equippedHat = _equippedHat
        ..equippedProp = _equippedProp
        ..stageStars = Map.from(_stageStars);
    }

    // 2. Yeni profile geç
    final newP = _profiles.firstWhere((p) => p.id == profileId, orElse: () => _profiles.first);
    _activeProfileId = newP.id;
    _studentName = newP.name;
    _gems = newP.gems;
    _hearts = newP.hearts;
    _totalStars = newP.totalStars;
    _xp = newP.xp;
    _activeAvatar = newP.avatar;
    _activeCharacterId = newP.activeCharacterId;
    _equippedHat = newP.equippedHat;
    _equippedProp = newP.equippedProp;
    _stageStars.clear();
    _stageStars.addAll(newP.stageStars);

    _saveToLocalStorage();
    notifyListeners();
  }

  void addStudent(String name, String avatar) {
    final newId = 'profile_${DateTime.now().millisecondsSinceEpoch}';
    final newProfile = StudentProfile(
      id: newId,
      name: name.trim().isEmpty ? 'Yeni Öğrenci' : name.trim(),
      avatar: avatar,
      gems: 150,
      hearts: 5,
      totalStars: 0,
      xp: 0,
    );
    _profiles.add(newProfile);
    switchStudent(newId);
  }

  void setStudentName(String name) {
    if (name.trim().isEmpty) return;
    _studentName = name.trim();
    final currentIdx = _profiles.indexWhere((p) => p.id == _activeProfileId);
    if (currentIdx != -1) {
      _profiles[currentIdx].name = _studentName;
    }
    _saveToLocalStorage();
    notifyListeners();
  }

  void deleteStudent(String profileId) {
    if (_profiles.length <= 1) return; // En az bir profil kalmalı
    _profiles.removeWhere((p) => p.id == profileId);
    if (_activeProfileId == profileId) {
      switchStudent(_profiles.first.id);
    } else {
      _saveToLocalStorage();
      notifyListeners();
    }
  }

  void _loadFromLocalStorage() {
    if (!kIsWeb) return;
    try {
      final storage = html.window.localStorage;
      if (storage.containsKey('sye_profiles')) {
        final raw = storage['sye_profiles'];
        if (raw != null && raw.isNotEmpty) {
          final list = jsonDecode(raw) as List;
          _profiles.clear();
          for (final item in list) {
            _profiles.add(StudentProfile.fromJson(item));
          }
        }
      }
      if (_profiles.isEmpty) {
        _profiles.add(StudentProfile(
          id: 'profile_1',
          name: 'Can',
          avatar: '👦',
          gems: _gems,
          hearts: _hearts,
          totalStars: _totalStars,
          xp: _xp,
          stageStars: Map.from(_stageStars),
        ));
      }
      if (storage.containsKey('sye_active_profile_id')) {
        _activeProfileId = storage['sye_active_profile_id'] ?? _profiles.first.id;
      }
      if (storage.containsKey('sye_student_name')) {
        _studentName = storage['sye_student_name'] ?? _studentName;
      }
      if (storage.containsKey('sye_gems')) {
        _gems = int.tryParse(storage['sye_gems'] ?? '') ?? _gems;
      }
      if (storage.containsKey('sye_hearts')) {
        _hearts = int.tryParse(storage['sye_hearts'] ?? '') ?? _hearts;
      }
      if (storage.containsKey('sye_streak_days')) {
        _streakDays = int.tryParse(storage['sye_streak_days'] ?? '') ?? _streakDays;
      }
      if (storage.containsKey('sye_last_practice_date')) {
        _lastPracticeDate = storage['sye_last_practice_date'];
      }
      if (storage.containsKey('sye_practiced_dates')) {
        final raw = storage['sye_practiced_dates'];
        if (raw != null && raw.isNotEmpty) {
          final list = jsonDecode(raw);
          if (list is List) {
            _practicedDates.addAll(list.map((e) => e.toString()));
          }
        }
      }
      _checkStreakContinuity();
      if (storage.containsKey('sye_stars')) {
        _totalStars = int.tryParse(storage['sye_stars'] ?? '') ?? _totalStars;
      }
      if (storage.containsKey('sye_xp')) {
        _xp = int.tryParse(storage['sye_xp'] ?? '') ?? _xp;
      }
      if (storage.containsKey('sye_active_avatar')) {
        _activeAvatar = storage['sye_active_avatar'] ?? _activeAvatar;
      }
      if (storage.containsKey('sye_active_char_name')) {
        _activeCharacterName = storage['sye_active_char_name'] ?? _activeCharacterName;
      }
      if (storage.containsKey('sye_active_char_id')) {
        _activeCharacterId = storage['sye_active_char_id'] ?? _activeCharacterId;
      }
      if (storage.containsKey('sye_unlocked_chars')) {
        final raw = storage['sye_unlocked_chars'];
        if (raw != null && raw.isNotEmpty) {
          final list = jsonDecode(raw);
          if (list is List) {
            _unlockedCharacters.addAll(list.map((e) => e.toString()));
          }
        }
      }
      if (storage.containsKey('sye_equipped_hat')) {
        _equippedHat = storage['sye_equipped_hat'];
      }
      if (storage.containsKey('sye_equipped_glasses')) {
        _equippedGlasses = storage['sye_equipped_glasses'];
      }
      if (storage.containsKey('sye_equipped_prop')) {
        _equippedProp = storage['sye_equipped_prop'];
      }
      if (storage.containsKey('sye_equipped_pet')) {
        _equippedPet = storage['sye_equipped_pet'];
      }
      if (storage.containsKey('sye_unlocked_acc')) {
        final raw = storage['sye_unlocked_acc'];
        if (raw != null && raw.isNotEmpty) {
          final list = jsonDecode(raw);
          if (list is List) {
            _unlockedAccessories.addAll(list.map((e) => e.toString()));
          }
        }
      }
      if (storage.containsKey('sye_unlocked_stickers')) {
        final raw = storage['sye_unlocked_stickers'];
        if (raw != null && raw.isNotEmpty) {
          final list = jsonDecode(raw);
          if (list is List) {
            _unlockedStickers.addAll(list.map((e) => e.toString().toLowerCase().trim()));
          }
        }
      }
      if (storage.containsKey('sye_unlocked_badges')) {
        final raw = storage['sye_unlocked_badges'];
        if (raw != null && raw.isNotEmpty) {
          final list = jsonDecode(raw);
          if (list is List) {
            _unlockedBadges.addAll(list.map((e) => e.toString()));
          }
        }
      }
      if (storage.containsKey('sye_stage_stars')) {
        final raw = storage['sye_stage_stars'];
        if (raw != null && raw.isNotEmpty) {
          final map = jsonDecode(raw);
          if (map is Map) {
            map.forEach((k, v) {
              _stageStars[k.toString()] = int.tryParse(v.toString()) ?? 0;
            });
          }
        }
      }
      if (storage.containsKey('sye_world_theme')) {
        _worldTheme = storage['sye_world_theme'] ?? _worldTheme;
      }
      if (storage.containsKey('sye_last_spin_date')) {
        _lastSpinDate = storage['sye_last_spin_date'];
      }
      if (storage.containsKey('sye_quest_date')) {
        _questDate = storage['sye_quest_date'];
        _questWordsCount = int.tryParse(storage['sye_quest_words'] ?? '') ?? 0;
        _questMiniGamesCount = int.tryParse(storage['sye_quest_minigames'] ?? '') ?? 0;
        _questMirrorCount = int.tryParse(storage['sye_quest_mirror'] ?? '') ?? 0;
        _questChestClaimed = storage['sye_quest_chest_claimed'] == 'true';
        if (storage.containsKey('sye_quest_claimed_ids')) {
          final raw = storage['sye_quest_claimed_ids'];
          if (raw != null && raw.isNotEmpty) {
            final list = jsonDecode(raw);
            if (list is List) {
              _claimedQuestIds.addAll(list.map((e) => e.toString()));
            }
          }
        }
      }
      _checkDailyQuestsReset();
    } catch (e) {
      debugPrint('LocalStorage okuma hatası: $e');
    }
  }

  void _saveToLocalStorage() {
    if (!kIsWeb) return;
    try {
      final storage = html.window.localStorage;
      // Aktif profilin anlık durumunu senkronize et
      final activeIdx = _profiles.indexWhere((p) => p.id == _activeProfileId);
      if (activeIdx != -1) {
        _profiles[activeIdx]
          ..gems = _gems
          ..hearts = _hearts
          ..totalStars = _totalStars
          ..xp = _xp
          ..avatar = _activeAvatar
          ..name = _studentName
          ..activeCharacterId = _activeCharacterId
          ..equippedHat = _equippedHat
          ..equippedProp = _equippedProp
          ..stageStars = Map.from(_stageStars);
      }
      storage['sye_profiles'] = jsonEncode(_profiles.map((p) => p.toJson()).toList());
      storage['sye_active_profile_id'] = _activeProfileId;
      storage['sye_student_name'] = _studentName;
      storage['sye_gems'] = _gems.toString();
      storage['sye_hearts'] = _hearts.toString();
      storage['sye_stars'] = _totalStars.toString();
      storage['sye_xp'] = _xp.toString();
      storage['sye_active_avatar'] = _activeAvatar;
      storage['sye_active_char_name'] = _activeCharacterName;
      storage['sye_active_char_id'] = _activeCharacterId;
      storage['sye_unlocked_chars'] = jsonEncode(_unlockedCharacters.toList());
      if (_equippedHat != null) storage['sye_equipped_hat'] = _equippedHat!;
      if (_equippedGlasses != null) storage['sye_equipped_glasses'] = _equippedGlasses!;
      if (_equippedProp != null) storage['sye_equipped_prop'] = _equippedProp!;
      if (_equippedPet != null) storage['sye_equipped_pet'] = _equippedPet!;
      storage['sye_unlocked_acc'] = jsonEncode(_unlockedAccessories.toList());
      storage['sye_unlocked_stickers'] = jsonEncode(_unlockedStickers.toList());
      storage['sye_unlocked_badges'] = jsonEncode(_unlockedBadges.toList());
      storage['sye_stage_stars'] = jsonEncode(_stageStars);
      storage['sye_world_theme'] = _worldTheme;
      storage['sye_streak_days'] = _streakDays.toString();
      if (_lastPracticeDate != null) storage['sye_last_practice_date'] = _lastPracticeDate!;
      if (_lastSpinDate != null) storage['sye_last_spin_date'] = _lastSpinDate!;
      storage['sye_practiced_dates'] = jsonEncode(_practicedDates.toList());
      if (_questDate != null) storage['sye_quest_date'] = _questDate!;
      storage['sye_quest_words'] = _questWordsCount.toString();
      storage['sye_quest_minigames'] = _questMiniGamesCount.toString();
      storage['sye_quest_mirror'] = _questMirrorCount.toString();
      storage['sye_quest_chest_claimed'] = _questChestClaimed.toString();
      storage['sye_quest_claimed_ids'] = jsonEncode(_claimedQuestIds.toList());
    } catch (e) {
      debugPrint('LocalStorage yazma hatası: $e');
    }
  }

  int _gems = 300;             // Mücevherler/Elmaslar
  int _hearts = 5;             // Canlar (Maks: 5)
  int _streakDays = 1;         // Günlük seri (gün)
  String? _lastPracticeDate;
  String? _lastSpinDate;
  final Set<String> _practicedDates = {};
  int _totalStars = 14;        // Toplam toplanan yıldız
  int _xp = 420;               // Deneyim puanı

  // 🎡 Şans Çarkıfeleği Günlük Durumu
  bool get isDailyFreeSpinAvailable {
    final today = _formatDate(DateTime.now());
    return _lastSpinDate != today;
  }

  void recordDailyFreeSpin() {
    _lastSpinDate = _formatDate(DateTime.now());
    _saveToLocalStorage();
    notifyListeners();
  }

  bool spendGemsForSpin(int gemCost) {
    if (_gems >= gemCost) {
      _gems -= gemCost;
      _saveToLocalStorage();
      notifyListeners();
      return true;
    }
    return false;
  }

  void unlockAndEquipFree({
    required String itemId,
    required String category,
    required String emoji,
  }) {
    _unlockedAccessories.add(itemId);
    equipAccessory(category, emoji);
    _saveToLocalStorage();
    notifyListeners();
  }

  // 🎯 Günlük Görevler (Duolingo Tarzı Canlı Takip)
  String? _questDate;
  int _questWordsCount = 0; // Hedef: 5
  int _questMiniGamesCount = 0; // Hedef: 1
  int _questMirrorCount = 0; // Hedef: 1
  final Set<String> _claimedQuestIds = {};
  bool _questChestClaimed = false;

  int get questWordsCount => _questWordsCount;
  int get questMiniGamesCount => _questMiniGamesCount;
  int get questMirrorCount => _questMirrorCount;
  bool isQuestClaimed(String qId) => _claimedQuestIds.contains(qId);
  bool get questChestClaimed => _questChestClaimed;

  String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  void _checkDailyQuestsReset() {
    final today = _formatDate(DateTime.now());
    if (_questDate != today) {
      _questDate = today;
      _questWordsCount = 0;
      _questMiniGamesCount = 0;
      _questMirrorCount = 0;
      _claimedQuestIds.clear();
      _questChestClaimed = false;
      _saveToLocalStorage();
    }
  }

  void recordQuestWord() {
    _checkDailyQuestsReset();
    _questWordsCount++;
    _saveToLocalStorage();
    notifyListeners();
  }

  void recordQuestMiniGame() {
    _checkDailyQuestsReset();
    _questMiniGamesCount++;
    _saveToLocalStorage();
    notifyListeners();
  }

  void recordQuestMirror() {
    _checkDailyQuestsReset();
    _questMirrorCount++;
    _saveToLocalStorage();
    notifyListeners();
  }

  bool claimQuestReward(String questId, int gemReward) {
    _checkDailyQuestsReset();
    if (_claimedQuestIds.contains(questId)) return false;
    _claimedQuestIds.add(questId);
    _gems += gemReward;
    _saveToLocalStorage();
    notifyListeners();
    return true;
  }

  bool claimDailyChest({int gems = 100, int stars = 2, int xp = 80}) {
    _checkDailyQuestsReset();
    if (_questChestClaimed) return false;
    if (_questWordsCount < 5 || _questMiniGamesCount < 1 || _questMirrorCount < 1) {
      return false;
    }
    _questChestClaimed = true;
    _gems += gems;
    _totalStars += stars;
    _xp += xp;
    _saveToLocalStorage();
    notifyListeners();
    return true;
  }

  final Set<String> _unlockedBadges = {'ilk_adim', 'kelime_avcisi', 'ses_kesfi', 'yildiz_koleksiyoncusu'};
  String _activeAvatar = '👦';
  String _activeCharacterName = 'SÜPER KAHRAMAN CAN';
  String _activeCharacterId = 'char_skater_can';
  final Set<String> _unlockedCharacters = {'char_skater_can', 'char_ninja', 'char_dino'};

  // 🛍️ Gardırop & Aksesuarlar
  String? _equippedHat = '👑';
  String? _equippedGlasses;
  String? _equippedProp = '🛹';
  String? _equippedPet = '🐶';
  final Set<String> _unlockedAccessories = {'hat_crown', 'prop_skateboard', 'hat_cap'};

  // 📖 Çıkartma Albümü
  final Set<String> _unlockedStickers = {
    'pasta', 'panda', 'kedi', 'balon', 'roket', 'aslan', 'elma', 'araba', 'peynir', 'robot'
  };

  // 🎡 Şans Çarkıfeleği Günlük Durumu
  bool _spinWheelAvailable = true;

  // 🌌 Dinamik Dünya Teması: 'day', 'night', 'candy', 'ocean'
  String _worldTheme = 'day';
  String get worldTheme => _worldTheme;
  void setWorldTheme(String theme) {
    _worldTheme = theme;
    _saveToLocalStorage();
    notifyListeners();
  }

  // Seviye Yıldız İlerlemesi: id -> 1, 2, 3 yıldız
  final Map<String, int> _stageStars = {
    'sound_p': 3,
    'sound_b': 3,
    'sound_m': 3,
    'sound_n': 2,
    'sound_r': 1,
  };

  // Klinik Terapist / Ebeveyn İstatistikleri
  final Map<String, PhonemeStat> _phonemeStats = {};

  int get gems => _gems;
  int get hearts => _hearts;
  int get streakDays => _streakDays;
  String? get lastPracticeDate => _lastPracticeDate;
  Set<String> get practicedDates => Set.unmodifiable(_practicedDates);
  int get totalStars => _totalStars;
  int get xp => _xp;
  Set<String> get unlockedBadges {
    final set = Set<String>.from(_unlockedBadges);
    if (totalPracticedSuccesses >= 1) set.add('ses_roket');
    if (totalPracticedSuccesses >= 50) set.add('keskin_nisanci');
    if (_totalStars >= 25) set.add('yildiz_sampiyonu');
    if (_streakDays >= 5) set.add('atesli_seri');
    if (_gems >= 300) set.add('elmas_zengini');
    if (_unlockedStickers.length >= 8) set.add('cikartma_koleksiyoneri');
    if (_xp >= 400) set.add('lig_sampiyonu');
    if (_questMirrorCount >= 1 || _unlockedAccessories.isNotEmpty) set.add('ayna_kasifi');
    if (_unlockedAccessories.length >= 4) set.add('gardirob_tasarimcisi');
    if (totalPracticedAttempts >= 50 && overallAccuracy >= 80) set.add('buyuk_usta');
    set.add('ilk_adim');
    if (totalPracticedSuccesses >= 20) set.add('kelime_avcisi');
    if (_totalStars >= 10) set.add('yildiz_koleksiyoncusu');
    return set;
  }

  bool isBadgeUnlocked(String badgeId) => unlockedBadges.contains(badgeId);

  void unlockBadge(String badgeId) {
    if (!_unlockedBadges.contains(badgeId)) {
      _unlockedBadges.add(badgeId);
      _saveToLocalStorage();
      notifyListeners();
    }
  }
  String get activeAvatar => _activeAvatar;
  String get activeCharacterName => _activeCharacterName;
  String get activeCharacterId => _activeCharacterId;
  Set<String> get unlockedCharacters => _unlockedCharacters;
  Map<String, PhonemeStat> get phonemeStats => _phonemeStats;

  void _checkStreakContinuity() {
    if (_lastPracticeDate == null || _lastPracticeDate!.isEmpty) return;
    try {
      final now = DateTime.now();
      final lastDate = DateTime.tryParse(_lastPracticeDate!);
      if (lastDate != null) {
        final diffDays = DateTime(now.year, now.month, now.day)
            .difference(DateTime(lastDate.year, lastDate.month, lastDate.day))
            .inDays;
        if (diffDays > 1) {
          _streakDays = 0;
          _saveToLocalStorage();
        }
      }
    } catch (_) {}
  }

  void recordPracticeToday() {
    final now = DateTime.now();
    final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    _practicedDates.add(todayStr);

    if (_lastPracticeDate == null || _lastPracticeDate!.isEmpty) {
      _streakDays = 1;
      _lastPracticeDate = todayStr;
    } else if (_lastPracticeDate == todayStr) {
      if (_streakDays == 0) _streakDays = 1;
    } else {
      final lastDate = DateTime.tryParse(_lastPracticeDate!);
      if (lastDate != null) {
        final diffDays = DateTime(now.year, now.month, now.day)
            .difference(DateTime(lastDate.year, lastDate.month, lastDate.day))
            .inDays;
        if (diffDays == 1) {
          _streakDays++;
        } else {
          _streakDays = 1;
        }
      } else {
        _streakDays = 1;
      }
      _lastPracticeDate = todayStr;
    }
    _saveToLocalStorage();
    notifyListeners();
  }

  List<bool> getWeeklyCompletedDays() {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    return List.generate(7, (i) {
      final day = monday.add(Duration(days: i));
      final dayStr = '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
      return _practicedDates.contains(dayStr);
    });
  }

  void gainHeart([int amount = 1]) {
    _hearts = (_hearts + amount).clamp(0, 5);
    _saveToLocalStorage();
    notifyListeners();
  }

  bool refillHeartsWithGems({int gemCost = 50}) {
    if (_gems >= gemCost && _hearts < 5) {
      _gems -= gemCost;
      _hearts = 5;
      _saveToLocalStorage();
      notifyListeners();
      return true;
    }
    return false;
  }

  String? get equippedHat => _equippedHat;
  String? get equippedGlasses => _equippedGlasses;
  String? get equippedProp => _equippedProp;
  String? get equippedPet => _equippedPet;
  Set<String> get unlockedAccessories => _unlockedAccessories;
  Set<String> get unlockedStickers => _unlockedStickers;
  bool get spinWheelAvailable => _spinWheelAvailable;

  int getStageStars(String stageId) => _stageStars[stageId] ?? 0;

  void setStageStars(String stageId, int stars) {
    if ((_stageStars[stageId] ?? 0) < stars) {
      _stageStars[stageId] = stars;
      _saveToLocalStorage();
      notifyListeners();
    }
  }

  void equipCharacter(String charId, String name, String emoji) {
    _activeAvatar = emoji;
    _activeCharacterName = name;
    _activeCharacterId = charId;
    _unlockedCharacters.add(charId);
    _saveToLocalStorage();
    notifyListeners();
  }

  void unlockCharacter(String charId) {
    _unlockedCharacters.add(charId);
    _saveToLocalStorage();
    notifyListeners();
  }

  bool isCharacterUnlocked(String charId) => _unlockedCharacters.contains(charId);

  // Aksesuar Satın Alma ve Kuşanma
  bool buyAndEquipAccessory({
    required String itemId,
    required String category, // 'hat', 'glasses', 'prop'
    required String emoji,
    required int gemCost,
  }) {
    if (_gems >= gemCost && !_unlockedAccessories.contains(itemId)) {
      _gems -= gemCost;
      _unlockedAccessories.add(itemId);
      equipAccessory(category, emoji);
      _saveToLocalStorage();
      notifyListeners();
      return true;
    }
    return false;
  }

  void equipAccessory(String category, String? emoji) {
    if (category == 'hat') _equippedHat = emoji;
    if (category == 'glasses') _equippedGlasses = emoji;
    if (category == 'prop') _equippedProp = emoji;
    if (category == 'pet') _equippedPet = emoji;
    _saveToLocalStorage();
    notifyListeners();
  }

  bool isAccessoryUnlocked(String itemId) => _unlockedAccessories.contains(itemId);

  void unlockSticker(String stickerId) {
    _unlockedStickers.add(stickerId.toLowerCase().trim());
    _saveToLocalStorage();
    notifyListeners();
  }

  bool isStickerUnlocked(String stickerId) =>
      _unlockedStickers.contains(stickerId.toLowerCase().trim());

  void claimSpinWheel() {
    _spinWheelAvailable = false;
    _saveToLocalStorage();
    notifyListeners();
  }

  void addReward({required int earnedStars, required int earnedXp, required int earnedGems}) {
    _totalStars += earnedStars;
    _xp += earnedXp;
    _gems += earnedGems;
    if (_totalStars >= 10 && !_unlockedBadges.contains('yildiz_koleksiyoncusu')) {
      _unlockedBadges.add('yildiz_koleksiyoncusu');
    }
    _saveToLocalStorage();
    notifyListeners();
  }

  void loseHeart() {
    if (_hearts > 0) {
      _hearts--;
      _saveToLocalStorage();
      notifyListeners();
    }
  }

  void refillHearts() {
    if (_gems >= 50 && _hearts < 5) {
      _gems -= 50;
      _hearts = 5;
      _saveToLocalStorage();
      notifyListeners();
    }
  }

  /// Artikülasyon denemesini pozisyonuna ve sesine göre anlık kaydeder
  void recordAttempt({
    required String phoneme,
    required String position, // 'Başta', 'Ortada', 'Sonda', 'Cümle', 'Hikaye'
    required bool isCorrect,
  }) {
    final cleanP = phoneme.replaceAll('/', '').trim().toUpperCase();
    if (!_phonemeStats.containsKey(cleanP)) {
      _phonemeStats[cleanP] = PhonemeStat(phoneme: cleanP);
    }

    final stat = _phonemeStats[cleanP]!;
    stat.totalAttempts++;
    if (isCorrect) stat.correctAttempts++;

    final posLower = position.toLowerCase();
    if (posLower.contains('baş')) {
      stat.initialAttempts++;
      if (isCorrect) stat.initialCorrect++;
    } else if (posLower.contains('orta')) {
      stat.medialAttempts++;
      if (isCorrect) stat.medialCorrect++;
    } else if (posLower.contains('son')) {
      stat.finalAttempts++;
      if (isCorrect) stat.finalCorrect++;
    }

    notifyListeners();
  }

  int get totalPracticedAttempts {
    int sum = 0;
    for (final s in _phonemeStats.values) {
      sum += s.totalAttempts;
    }
    return sum;
  }

  int get totalPracticedSuccesses {
    int sum = 0;
    for (final s in _phonemeStats.values) {
      sum += s.correctAttempts;
    }
    return sum;
  }

  int get overallAccuracy {
    if (totalPracticedAttempts == 0) return 0;
    return ((totalPracticedSuccesses / totalPracticedAttempts) * 100).round();
  }

  void _initSampleTherapyStats() {
    _phonemeStats['P'] = PhonemeStat(
      phoneme: 'P',
      totalAttempts: 18,
      correctAttempts: 16,
      initialAttempts: 8,
      initialCorrect: 8,
      medialAttempts: 6,
      medialCorrect: 5,
      finalAttempts: 4,
      finalCorrect: 3,
    );
    _phonemeStats['B'] = PhonemeStat(
      phoneme: 'B',
      totalAttempts: 15,
      correctAttempts: 14,
      initialAttempts: 8,
      initialCorrect: 8,
      medialAttempts: 7,
      medialCorrect: 6,
      finalAttempts: 0,
      finalCorrect: 0,
    );
    _phonemeStats['M'] = PhonemeStat(
      phoneme: 'M',
      totalAttempts: 12,
      correctAttempts: 11,
      initialAttempts: 5,
      initialCorrect: 5,
      medialAttempts: 4,
      medialCorrect: 4,
      finalAttempts: 3,
      finalCorrect: 2,
    );
    _phonemeStats['N'] = PhonemeStat(
      phoneme: 'N',
      totalAttempts: 14,
      correctAttempts: 11,
      initialAttempts: 6,
      initialCorrect: 5,
      medialAttempts: 5,
      medialCorrect: 4,
      finalAttempts: 3,
      finalCorrect: 2,
    );
    _phonemeStats['R'] = PhonemeStat(
      phoneme: 'R',
      totalAttempts: 20,
      correctAttempts: 13,
      initialAttempts: 8,
      initialCorrect: 6,
      medialAttempts: 7,
      medialCorrect: 4,
      finalAttempts: 5,
      finalCorrect: 3,
    );
  }
}
