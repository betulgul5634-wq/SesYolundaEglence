import 'package:flutter/material.dart';
import '../data/sound_groups_data.dart';
import '../models/reward_state.dart';
import '../services/audio_speech_service.dart';
import '../services/sound_effects_service.dart';
import '../utils/word_pictogram_helper.dart';

class _CartoonStickerSpec {
  final String title;
  final String emoji;
  final Color bgTop;
  final Color bgBottom;

  const _CartoonStickerSpec({
    required this.title,
    required this.emoji,
    required this.bgTop,
    required this.bgBottom,
  });
}

class _AlbumSticker {
  final String title;
  final String emoji;
  final String phonemeLabel;
  final String soundLetter;
  final Color bgTop;
  final Color bgBottom;
  final bool isUnlocked;

  const _AlbumSticker({
    required this.title,
    required this.emoji,
    required this.phonemeLabel,
    required this.soundLetter,
    required this.bgTop,
    required this.bgBottom,
    required this.isUnlocked,
  });
}

/// 🖼️ ÇOCUK DOSTU ETKİLEŞİMLİ ÇİZGi FİLM ÇIKARTMA ALBÜMÜ DEFTERİ
class StickerAlbumDialog extends StatelessWidget {
  const StickerAlbumDialog({super.key});

  static const Map<String, _CartoonStickerSpec> _cartoonBySound = {
    'P': _CartoonStickerSpec(title: 'Süper Pelerin', emoji: '🦸', bgTop: Color(0xFFFFEBEE), bgBottom: Color(0xFFFFCDD2)),
    'B': _CartoonStickerSpec(title: 'Büyücü Baykuş', emoji: '🦉', bgTop: Color(0xFFF3E5F5), bgBottom: Color(0xFFE1BEE7)),
    'T': _CartoonStickerSpec(title: 'Ninja Kaplumbağa', emoji: '🐢', bgTop: Color(0xFFE8F5E9), bgBottom: Color(0xFFC8E6C9)),
    'D': _CartoonStickerSpec(title: 'Mini Dinozor', emoji: '🦕', bgTop: Color(0xFFE0F7FA), bgBottom: Color(0xFFB2EBF2)),
    'K': _CartoonStickerSpec(title: 'Kral Aslan', emoji: '🦁', bgTop: Color(0xFFFFF8E1), bgBottom: Color(0xFFFFECB3)),
    'G': _CartoonStickerSpec(title: 'Gökkuşağı Tekboynuz', emoji: '🦄', bgTop: Color(0xFFFCE4EC), bgBottom: Color(0xFFF8BBD0)),
    'F': _CartoonStickerSpec(title: 'Kurnaz Tilki', emoji: '🦊', bgTop: Color(0xFFFFF3E0), bgBottom: Color(0xFFFFE0B2)),
    'V': _CartoonStickerSpec(title: 'Peri Prenses', emoji: '🧚‍♀️', bgTop: Color(0xFFEDE7F6), bgBottom: Color(0xFFD1C4E9)),
    'S': _CartoonStickerSpec(title: 'Uzay Robotu', emoji: '🤖', bgTop: Color(0xFFE3F2FD), bgBottom: Color(0xFFBBDEFB)),
    'Z': _CartoonStickerSpec(title: 'Zıplayan Zebra', emoji: '🦓', bgTop: Color(0xFFF5F5F5), bgBottom: Color(0xFFE0E0E0)),
    'Ş': _CartoonStickerSpec(title: 'Kung Fu Panda', emoji: '🐼', bgTop: Color(0xFFE8EAF6), bgBottom: Color(0xFFC5CAE9)),
    'J': _CartoonStickerSpec(title: 'Kristal Ejderha', emoji: '🐉', bgTop: Color(0xFFE0F2F1), bgBottom: Color(0xFFB2DFDB)),
    'H': _CartoonStickerSpec(title: 'Astronot Kedi', emoji: '🐱', bgTop: Color(0xFFFFFDE7), bgBottom: Color(0xFFFFF9C4)),
    'Ç': _CartoonStickerSpec(title: 'Cesur Şövalye', emoji: '🛡️', bgTop: Color(0xFFEFEBE9), bgBottom: Color(0xFFD7CCC8)),
    'C': _CartoonStickerSpec(title: 'Zıplayan Kurbağa', emoji: '🐸', bgTop: Color(0xFFF1F8E9), bgBottom: Color(0xFFDCEDC8)),
    'M': _CartoonStickerSpec(title: 'Sevgi Ayıcığı', emoji: '🧸', bgTop: Color(0xFFFFF3E0), bgBottom: Color(0xFFFFCCBC)),
    'N': _CartoonStickerSpec(title: 'Neşeli Yunus', emoji: '🐬', bgTop: Color(0xFFE1F5FE), bgBottom: Color(0xFFB3E5FC)),
    'L': _CartoonStickerSpec(title: 'Renkli Kelebek', emoji: '🦋', bgTop: Color(0xFFF3E5F5), bgBottom: Color(0xFFE1BEE7)),
    'R': _CartoonStickerSpec(title: 'Korsan Papağan', emoji: '🦜', bgTop: Color(0xFFE8F5E9), bgBottom: Color(0xFFA5D6A7)),
    'Y': _CartoonStickerSpec(title: 'Yıldız Savaşçısı', emoji: '🌟', bgTop: Color(0xFFFFF8E1), bgBottom: Color(0xFFFFE082)),
  };

  @override
  Widget build(BuildContext context) {
    final rewardState = RewardState();
    final audio = AudioSpeechService();
    final sfx = SoundEffectsService();

    return ListenableBuilder(
      listenable: rewardState,
      builder: (context, _) {
        final List<_AlbumSticker> allStickers = [];
        final Set<String> seenTitles = {};

        for (final stage in kBookStages) {
          final letter = stage.soundLetter.trim().toUpperCase();
          final spec = _cartoonBySound[letter];
          final title = spec?.title ?? stage.soundLetter;
          final emoji = spec?.emoji ?? stage.emoji;
          final unlocked = rewardState.getStageStars(stage.id) > 0 ||
              rewardState.isStickerUnlocked(title) ||
              (stage.content.wordsBeginning.isNotEmpty &&
                  rewardState.isStickerUnlocked(stage.content.wordsBeginning.first));
          seenTitles.add(title.toLowerCase());
          allStickers.add(
            _AlbumSticker(
              title: title,
              emoji: emoji,
              phonemeLabel: stage.phoneme,
              soundLetter: stage.soundLetter,
              bgTop: spec?.bgTop ?? const Color(0xFFFFFDE7),
              bgBottom: spec?.bgBottom ?? const Color(0xFFFFF59D),
              isUnlocked: unlocked,
            ),
          );
        }

        for (final extra in rewardState.unlockedStickers) {
          final clean = extra.trim();
          if (clean.isEmpty || seenTitles.contains(clean.toLowerCase())) continue;
          seenTitles.add(clean.toLowerCase());
          allStickers.add(
            _AlbumSticker(
              title: clean[0].toUpperCase() + clean.substring(1),
              emoji: WordPictogramHelper.getPictogram(clean),
              phonemeLabel: 'Kazanıldı',
              soundLetter: '',
              bgTop: const Color(0xFFFFFDE7),
              bgBottom: const Color(0xFFFFECB3),
              isUnlocked: true,
            ),
          );
        }

        final unlockedCount = allStickers.where((s) => s.isUnlocked).length;

        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 540, maxHeight: 640),
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFFDE7), Color(0xFFFFFFFF)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Text('🖼️', style: TextStyle(fontSize: 24)),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Çizgi Kahraman Çıkartmalarım',
                              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: Color(0xFF5D4037)),
                            ),
                            Text(
                              '$unlockedCount / ${allStickers.length} kahraman açık • Sesleri tamamla, kahramanları topla!',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF8D6E63)),
                            ),
                          ],
                        ),
                      ],
                    ),
                    IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded)),
                  ],
                ),
                const Divider(height: 18),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.84,
                    ),
                    itemCount: allStickers.length,
                    itemBuilder: (ctx, i) {
                      final st = allStickers[i];
                      return InkWell(
                        onTap: () {
                          sfx.playPopSound();
                          if (st.isUnlocked) {
                            audio.speakTurkish(st.title, phoneme: st.soundLetter);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('🎯 "${st.title}" çıkartması için ${st.phonemeLabel} sesini tamamla!'),
                                duration: const Duration(seconds: 2),
                                backgroundColor: const Color(0xFF7B1FA2),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: st.isUnlocked
                                ? LinearGradient(
                                    colors: [st.bgTop, st.bgBottom],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )
                                : null,
                            color: st.isUnlocked ? null : const Color(0xFFF5F5F4),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: st.isUnlocked ? const Color(0xFFFFB300) : const Color(0xFFD6D3D1),
                              width: st.isUnlocked ? 2.2 : 1.2,
                            ),
                            boxShadow: st.isUnlocked
                                ? const [BoxShadow(color: Color(0x22FFB300), blurRadius: 8, offset: Offset(0, 3))]
                                : null,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Opacity(
                                opacity: st.isUnlocked ? 1.0 : 0.45,
                                child: Text(st.emoji, style: const TextStyle(fontSize: 36)),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                st.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 11,
                                  color: st.isUnlocked ? const Color(0xFF3E2723) : const Color(0xFF78716C),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: st.isUnlocked ? const Color(0xFFDCFCE7) : const Color(0xFFE7E5E4),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  st.isUnlocked ? '✅ ${st.phonemeLabel}' : '🔒 ${st.phonemeLabel} Sesi',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                    color: st.isUnlocked ? const Color(0xFF15803D) : const Color(0xFF57534E),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
