import 'package:flutter/material.dart';
import '../models/reward_state.dart';
import '../services/sound_effects_service.dart';
import 'speech_mirror_dialog.dart';

class _QuestItemData {
  final String id;
  final String title;
  final String subtitle;
  final String icon;
  final int targetCount;
  final int currentCount;
  final int gemReward;
  final bool isClaimed;

  const _QuestItemData({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.targetCount,
    required this.currentCount,
    required this.gemReward,
    required this.isClaimed,
  });

  bool get isCompleted => currentCount >= targetCount;
}

/// 🎯 GÜNLÜK GÖREVLER VE GİZEMLİ HAZİNE SANDIĞI (DUOLINGO TARZI CANLI SİSTEM)
class DailyQuestsDialog extends StatefulWidget {
  const DailyQuestsDialog({super.key});

  @override
  State<DailyQuestsDialog> createState() => _DailyQuestsDialogState();
}

class _DailyQuestsDialogState extends State<DailyQuestsDialog> {
  final RewardState _rewardState = RewardState();
  final SoundEffectsService _sfx = SoundEffectsService();

  void _claimQuestReward(String questId, int gems) {
    final success = _rewardState.claimQuestReward(questId, gems);
    if (success) {
      _sfx.playSuccessDing();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🎉 Tebrikler! Görev ödülü olan +$gems 💎 hesabına eklendi!'),
          backgroundColor: const Color(0xFF2E7D32),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _claimChest() {
    final success = _rewardState.claimDailyChest(gems: 100, stars: 2, xp: 80);
    if (success) {
      _sfx.playVictoryFanfare();
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('👑🎁✨', style: TextStyle(fontSize: 52)),
              const SizedBox(height: 12),
              const Text(
                'BÜYÜK HAZİNE AÇILDI!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFFE65100)),
              ),
              const SizedBox(height: 8),
              const Text(
                'Tüm günlük görevleri tamamlayarak muazzam bir azim gösterdin!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Color(0xFF37474F)),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFFB300)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('+100 💎', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF0277BD))),
                    SizedBox(width: 14),
                    Text('+2 ⭐', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFFFF8F00))),
                    SizedBox(width: 14),
                    Text('+80 XP ⚡', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF2E7D32))),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF58CC02),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                ),
                onPressed: () => Navigator.pop(ctx),
                child: const Text('HARİKA!', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
              ),
            ),
          ],
        ),
      );
    }
  }

  void _openMirrorQuest() {
    _sfx.playPopSound();
    showDialog(
      context: context,
      builder: (ctx) => const SpeechMirrorDialog(
        phoneme: '/p/',
        hint: 'Çift dudak patlamalı sesini aynada gözlemle',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _rewardState,
      builder: (context, _) {
        final wordsDone = _rewardState.questWordsCount;
        final gamesDone = _rewardState.questMiniGamesCount;
        final mirrorDone = _rewardState.questMirrorCount;

        final quests = [
          _QuestItemData(
            id: 'q1',
            title: '5 Kelimeyi Doğru Telaffuz Et',
            subtitle: wordsDone >= 5 ? 'Tebrikler! 5 kelime tamamlandı.' : 'Pratik ekranında mikrofona konuş ($wordsDone / 5)',
            icon: '🗣️',
            targetCount: 5,
            currentCount: wordsDone,
            gemReward: 30,
            isClaimed: _rewardState.isQuestClaimed('q1'),
          ),
          _QuestItemData(
            id: 'q2',
            title: 'Bir Mini Oyun Tamamla',
            subtitle: gamesDone >= 1 ? 'Mini oyun başarıyla tamamlandı!' : 'Ses Canavarı veya Balon Avcısı oyna ($gamesDone / 1)',
            icon: '🎮',
            targetCount: 1,
            currentCount: gamesDone,
            gemReward: 40,
            isClaimed: _rewardState.isQuestClaimed('q2'),
          ),
          _QuestItemData(
            id: 'q3',
            title: 'Canlı Aynada Dudaklarını İncele',
            subtitle: mirrorDone >= 1 ? 'Konuşma aynası incelendi!' : 'Konuşma aynasını aç ve izle ($mirrorDone / 1)',
            icon: '🪞',
            targetCount: 1,
            currentCount: mirrorDone,
            gemReward: 20,
            isClaimed: _rewardState.isQuestClaimed('q3'),
          ),
        ];

        final completedCount = quests.where((q) => q.isCompleted).length;
        final allCompleted = completedCount == quests.length;
        final isChestClaimed = _rewardState.questChestClaimed;

        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
          child: Container(
            width: 440,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              color: Colors.white,
              border: Border.all(color: const Color(0xFFFF9800), width: 2.5),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ÜST BAŞLIK & İLERLEME
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3E0),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Text('🎯', style: TextStyle(fontSize: 26)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'GÜNLÜK GÖREVLER',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFFE65100),
                              ),
                            ),
                            Text(
                              'Bugün $completedCount / ${quests.length} Görev Tamamlandı 🔥',
                              style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w700),
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

                  // GÖREVLER LİSTESİ
                  ...quests.map((q) {
                    final pct = (q.currentCount / q.targetCount).clamp(0.0, 1.0);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: q.isCompleted ? const Color(0xFFF1F8E9) : const Color(0xFFFAFAFA),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: q.isCompleted ? const Color(0xFF81C784) : Colors.grey[300]!,
                          width: q.isCompleted ? 1.8 : 1.2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(q.icon, style: const TextStyle(fontSize: 28)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        q.title,
                                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                                      ),
                                    ),
                                    Text(
                                      '${q.currentCount.clamp(0, q.targetCount)}/${q.targetCount}',
                                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: q.isCompleted ? const Color(0xFF2E7D32) : const Color(0xFFE65100)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  q.subtitle,
                                  style: TextStyle(fontSize: 10.5, color: Colors.grey[600], fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 6),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: LinearProgressIndicator(
                                    value: pct,
                                    backgroundColor: Colors.grey[200],
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      q.isCompleted ? const Color(0xFF58CC02) : const Color(0xFFFF9800),
                                    ),
                                    minHeight: 6,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),

                          // Ödül / Al / Buton Alanı
                          if (q.isCompleted) ...[
                            if (q.isClaimed)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF58CC02),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.check_rounded, color: Colors.white, size: 16),
                                    SizedBox(width: 2),
                                    Text('ALINDI', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900)),
                                  ],
                                ),
                              )
                            else
                              ElevatedButton(
                                onPressed: () => _claimQuestReward(q.id, q.gemReward),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFF9800),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  elevation: 2,
                                ),
                                child: Text(
                                  '+${q.gemReward} 💎 AL',
                                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11),
                                ),
                              ),
                          ] else ...[
                            // Henüz bitmemiş görevler için hızlı eylem
                            if (q.id == 'q3')
                              OutlinedButton(
                                onPressed: _openMirrorQuest,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF1976D2),
                                  side: const BorderSide(color: Color(0xFF64B5F6)),
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                child: const Text('Aynayı Aç 🪞', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800)),
                              )
                            else
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE1F5FE),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '+${q.gemReward} 💎',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF0277BD),
                                  ),
                                ),
                              ),
                          ],
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 12),

                  // BÜYÜK GÜNLÜK HAZİNE SANDIĞI
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isChestClaimed
                            ? [const Color(0xFFECEFF1), const Color(0xFFCFD8DC)]
                            : (allCompleted
                                ? [const Color(0xFFFFF3E0), const Color(0xFFFFD54F)]
                                : [const Color(0xFFFFF8E1), const Color(0xFFFFECB3)]),
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: allCompleted && !isChestClaimed ? const Color(0xFFFF8F00) : const Color(0xFFFFB300),
                        width: allCompleted && !isChestClaimed ? 2.5 : 1.5,
                      ),
                      boxShadow: allCompleted && !isChestClaimed
                          ? [
                              const BoxShadow(
                                color: Color(0x44FFB300),
                                blurRadius: 10,
                                offset: Offset(0, 3),
                              )
                            ]
                          : [],
                    ),
                    child: Row(
                      children: [
                        Text(isChestClaimed ? '✨🎁✨' : '🎁', style: const TextStyle(fontSize: 36)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'GÜNÜN BÜYÜK HAZİNESİ',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFFE65100)),
                              ),
                              Text(
                                isChestClaimed
                                    ? 'Bugünkü hazine alındı! Yarın yeni ödüller gelecek ✨'
                                    : (allCompleted
                                        ? 'Tebrikler! 3 görevi de bitirdin, hazinen hazır!'
                                        : '3 görevi de bitir, dev hazineyi aç! (+100 💎, +2 ⭐, +80 XP)'),
                                style: TextStyle(
                                  fontSize: 10.5,
                                  color: isChestClaimed ? Colors.grey[700] : Colors.black87,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: (allCompleted && !isChestClaimed)
                                ? const Color(0xFFFF9800)
                                : Colors.grey[400],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            elevation: (allCompleted && !isChestClaimed) ? 4 : 0,
                          ),
                          onPressed: (allCompleted && !isChestClaimed) ? _claimChest : null,
                          child: Text(
                            isChestClaimed ? 'AÇILDI ✨' : 'AÇ 👑',
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
