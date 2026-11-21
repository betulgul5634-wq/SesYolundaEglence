class StudentProfile {
  final String id;
  String name;
  String avatar;
  int gems;
  int hearts;
  int totalStars;
  int xp;
  String activeCharacterId;
  String? equippedHat;
  String? equippedProp;
  Map<String, int> stageStars;
  DateTime createdAt;

  StudentProfile({
    required this.id,
    required this.name,
    this.avatar = '👦',
    this.gems = 150,
    this.hearts = 5,
    this.totalStars = 0,
    this.xp = 0,
    this.activeCharacterId = 'char_skater_can',
    this.equippedHat,
    this.equippedProp,
    Map<String, int>? stageStars,
    DateTime? createdAt,
  })  : stageStars = stageStars ?? {},
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'avatar': avatar,
        'gems': gems,
        'hearts': hearts,
        'totalStars': totalStars,
        'xp': xp,
        'activeCharacterId': activeCharacterId,
        'equippedHat': equippedHat,
        'equippedProp': equippedProp,
        'stageStars': stageStars,
        'createdAt': createdAt.toIso8601String(),
      };

  factory StudentProfile.fromJson(Map<String, dynamic> json) => StudentProfile(
        id: json['id'] ?? 'default',
        name: json['name'] ?? 'Öğrenci',
        avatar: json['avatar'] ?? '👦',
        gems: json['gems'] ?? 150,
        hearts: json['hearts'] ?? 5,
        totalStars: json['totalStars'] ?? 0,
        xp: json['xp'] ?? 0,
        activeCharacterId: json['activeCharacterId'] ?? 'char_skater_can',
        equippedHat: json['equippedHat'],
        equippedProp: json['equippedProp'],
        stageStars: (json['stageStars'] as Map<String, dynamic>?)?.map(
              (k, v) => MapEntry(k, int.tryParse(v.toString()) ?? 0),
            ) ??
            {},
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'])
            : null,
      );
}
