import 'package:flutter/material.dart';
import '../models/reward_state.dart';
import '../models/student_profile.dart';
import '../services/sound_effects_service.dart';

/// 👥 ÖĞRENCİ VE ÇOCUK PROFİLLERİ YÖNETİM MERKEZİ (KLİNİK & AİLE SİSTEMİ)
/// Terapistlerin ve velilerin farklı çocukların artikülasyon ilerlemelerini,
/// yıldızlarını ve terapi puanlarını birbirine karışmadan ayrı ayrı takip etmesini sağlar.
class StudentProfilesDialog extends StatefulWidget {
  const StudentProfilesDialog({super.key});

  @override
  State<StudentProfilesDialog> createState() => _StudentProfilesDialogState();
}

class _StudentProfilesDialogState extends State<StudentProfilesDialog> {
  final RewardState _rewardState = RewardState();
  final SoundEffectsService _sfx = SoundEffectsService();

  static const List<String> kAvailableAvatars = [
    '⭐', '🚀', '🎨', '🦁', '🐼', '🐱', '🦄', '⚽', '🧒', '👧', '👦'
  ];

  void _showAddStudentDialog() {
    _sfx.playPopSound();
    final nameController = TextEditingController();
    String selectedAvatar = '⭐';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          title: const Row(
            children: [
              Text('➕', style: TextStyle(fontSize: 26)),
              SizedBox(width: 10),
              Text(
                'Yeni Öğrenci Ekle',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Öğrencinin Adı:',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF37474F)),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: nameController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Örn: Zeynep, Ali, Mehmet...',
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Profil Simgesi Seç:',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF37474F)),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: kAvailableAvatars.map((av) {
                  final isSelected = av == selectedAvatar;
                  return InkWell(
                    onTap: () {
                      setModalState(() => selectedAvatar = av);
                      _sfx.playPopSound();
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFE8F5E9) : const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF4CAF50) : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Text(av, style: const TextStyle(fontSize: 28)),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('İPTAL', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF58CC02),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isNotEmpty) {
                  _rewardState.addStudent(name, selectedAvatar);
                  _sfx.playSuccessDing();
                  Navigator.pop(ctx);
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('🎉 $name öğrencisi başarıyla eklendi!'),
                      backgroundColor: const Color(0xFF2E7D32),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: const Text('KAYDET 🚀', style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ],
        ),
      ),
    ).then((_) => nameController.dispose());
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      child: Container(
        width: 440,
        constraints: const BoxConstraints(maxHeight: 560),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          gradient: const LinearGradient(
            colors: [Color(0xFFE8F5E9), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          border: Border.all(color: const Color(0xFF4CAF50), width: 2.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Başlık
            Row(
              children: [
                const Text('👥', style: TextStyle(fontSize: 30)),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Öğrenci Profilleri',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF1B5E20)),
                      ),
                      Text(
                        'Farklı çocuklar için ayrı terapi takibi',
                        style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Colors.blueGrey),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.grey),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Profil Listesi
            Flexible(
              child: ListenableBuilder(
                listenable: _rewardState,
                builder: (context, _) {
                  final profiles = _rewardState.profiles;
                  final activeId = _rewardState.activeProfileId;

                  return ListView.separated(
                    shrinkWrap: true,
                    itemCount: profiles.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
                    itemBuilder: (ctx, i) {
                      final p = profiles[i];
                      final isActive = p.id == activeId;

                      return _buildProfileCard(p, isActive, profiles.length > 1);
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Yeni Öğrenci Ekle Butonu
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF58CC02),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  elevation: 3,
                ),
                icon: const Icon(Icons.person_add_rounded, size: 22),
                label: const Text(
                  'YENİ ÖĞRENCİ EKLE ➕',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13.5),
                ),
                onPressed: _showAddStudentDialog,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(StudentProfile p, bool isActive, bool canDelete) {
    return Container(
      decoration: BoxDecoration(
        color: isActive ? Colors.white : const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive ? const Color(0xFF4CAF50) : const Color(0xFFE0E0E0),
          width: isActive ? 2.5 : 1.2,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: const Color(0xFF4CAF50).withAlpha(40),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (!isActive) {
              _sfx.playSuccessDing();
              _rewardState.switchStudent(p.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('✨ ${p.name} profiline geçildi!'),
                  backgroundColor: const Color(0xFF2E7D32),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isActive ? const Color(0xFFE8F5E9) : const Color(0xFFEEEEEE),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isActive ? const Color(0xFF4CAF50) : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(p.avatar, style: const TextStyle(fontSize: 28)),
                  ),
                ),
                const SizedBox(width: 12),

                // Bilgiler
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            p.name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF263238),
                            ),
                          ),
                          const SizedBox(width: 6),
                          if (isActive)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F5E9),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFF4CAF50), width: 1),
                              ),
                              child: const Text(
                                'AKTİF ✨',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF2E7D32),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text('⭐ ${p.totalStars} Yıldız', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFFF57F17))),
                          const SizedBox(width: 10),
                          Text('💎 ${p.gems} Elmas', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF0288D1))),
                        ],
                      ),
                    ],
                  ),
                ),

                // Seç Butonu veya Silme
                if (!isActive) ...[
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E88E5),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 1,
                    ),
                    onPressed: () {
                      _sfx.playSuccessDing();
                      _rewardState.switchStudent(p.id);
                      Navigator.pop(context);
                    },
                    child: const Text('SEÇ 🎯', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11)),
                  ),
                  if (canDelete) ...[
                    const SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: Colors.grey, size: 20),
                      onPressed: () {
                        _sfx.playPopSound();
                        _rewardState.deleteStudent(p.id);
                        setState(() {});
                      },
                    ),
                  ],
                ] else ...[
                  const Icon(Icons.check_circle_rounded, color: Color(0xFF4CAF50), size: 26),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
