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

            // Bilgilendirme Notu
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F8E9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFC5E1A5)),
              ),
              child: const Row(
                children: [
                  Text('🌱', style: TextStyle(fontSize: 20)),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Öğrenci profilleri platforma kayıtlar yapıldıkça sisteme otomatik olarak işlenir.',
                      style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF33691E), height: 1.3),
                    ),
                  ),
                ],
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
