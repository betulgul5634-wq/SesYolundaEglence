import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../services/audio_speech_service.dart';
import '../services/sound_effects_service.dart';
import '../models/reward_state.dart';

/// 🥁 FONEM BEATBOX & RİTİM BANDO STÜDYOSU (DJ SOUND PADS)
/// Konuşma ritmi, hece geçişleri ve fonetik artikülasyonu müzikle
/// harmanlayan interaktif DJ ses padleri!
class PhonemeBeatboxStudioDialog extends StatefulWidget {
  final String phoneme;
  final String soundTitle;

  const PhonemeBeatboxStudioDialog({
    super.key,
    required this.phoneme,
    required this.soundTitle,
  });

  @override
  State<PhonemeBeatboxStudioDialog> createState() => _PhonemeBeatboxStudioDialogState();
}

class _PhonemeBeatboxStudioDialogState extends State<PhonemeBeatboxStudioDialog> {
  final AudioSpeechService _audioService = AudioSpeechService();
  final SoundEffectsService _sfx = SoundEffectsService();
  final RewardState _rewardState = RewardState();

  bool _isPlayingLoop = false;
  Timer? _loopTimer;
  int _activeBeatStep = 0;
  int _totalHits = 0;
  int _comboCount = 0;
  int? _highlightedTargetIndex;

  late final List<String> _syllables;

  final List<Color> _padColors = const [
    Color(0xFFFF1744),
    Color(0xFFFF9100),
    Color(0xFFFFD600),
    Color(0xFF00E676),
    Color(0xFF00E5FF),
    Color(0xFF651FFF),
    Color(0xFFF50057),
    Color(0xFF76FF03),
  ];

  @override
  void initState() {
    super.initState();
    final p = widget.phoneme.replaceAll('/', '').trim().toUpperCase();
    final vowels = ['A', 'E', 'I', 'İ', 'O', 'Ö', 'U', 'Ü'];
    _syllables = vowels.map((v) => '$p$v').toList();
    _pickNextChallenge();
  }

  void _pickNextChallenge() {
    setState(() {
      _highlightedTargetIndex = math.Random().nextInt(_syllables.length);
    });
  }

  void _hitPad(int index) {
    final syl = _syllables[index];
    _sfx.playPopSound();
    _audioService.speakTurkish(syl, phoneme: widget.phoneme, mode: 'phoneme');

    final bool isTargetHit = (_highlightedTargetIndex != null && index == _highlightedTargetIndex);

    setState(() {
      _totalHits++;
      if (isTargetHit) {
        _comboCount++;
        _sfx.playSuccessDing();
        _pickNextChallenge();
      } else {
        _comboCount = 0;
      }

      if (_totalHits % 10 == 0) {
        _rewardState.addReward(earnedStars: 1, earnedXp: 20, earnedGems: 10);
      }
    });
  }

  void _toggleLoop() {
    setState(() {
      _isPlayingLoop = !_isPlayingLoop;
      if (_isPlayingLoop) {
        _activeBeatStep = 0;
        _loopTimer?.cancel();
        _loopTimer = Timer.periodic(const Duration(milliseconds: 500), (t) {
          if (!mounted) return;
          setState(() {
            _activeBeatStep = (_activeBeatStep + 1) % 4;
            if (_activeBeatStep == 0) {
              _sfx.playPopSound();
            }
          });
        });
      } else {
        _loopTimer?.cancel();
      }
    });
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Text('🎧', style: TextStyle(fontSize: 28)),
            SizedBox(width: 8),
            Text('DJ Stüdyosu Nasıl Oynanır?', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              '🎯 Oyunun Amacı:',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Color(0xFFE91E63)),
            ),
            SizedBox(height: 4),
            Text(
              'Konuşma akıcılığını geliştirmek için heceleri ritim eşliğinde söylemek.',
              style: TextStyle(fontSize: 12, color: Colors.black87),
            ),
            SizedBox(height: 12),
            Text(
              '🎵 Nasıl Oynanır?',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Color(0xFF00C853)),
            ),
            SizedBox(height: 4),
            Text(
              '1. "RİTİM BAŞLAT" butonuna basarak eğlenceli DJ arka plan ritmini aç.\n'
              '2. Yanan ışıklı hece pedine dokun ve sesi tekrar et.\n'
              '3. Ritmi yakaladıkça kombo çarpanı artar ve ekstra yıldız kazanırsın!',
              style: TextStyle(fontSize: 12, color: Colors.black87, height: 1.4),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF58CC02),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('ANLADIM, BAŞLAYALIM! 🚀', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _loopTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 720),
        decoration: BoxDecoration(
          color: const Color(0xFF121212), // DJ Gece Kulübü Teması
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: const Color(0xFFFF4081), width: 2.5),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF4081).withValues(alpha: 0.35),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            // ÜST BAŞLIK & DJ KONSOLU
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: const BoxDecoration(
                color: Color(0xFF1E1E1E),
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Row(
                children: [
                  const Text('🎧', style: TextStyle(fontSize: 28)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Beatbox & DJ Hece Stüdyosu',
                          style: TextStyle(
                            color: Color(0xFFFF4081),
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          'Hedef [${widget.soundTitle}] Ritim & Akıcılık Padleri',
                          style: const TextStyle(color: Colors.white70, fontSize: 11.5, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.help_outline_rounded, color: Colors.amberAccent),
                    tooltip: 'Nasıl Oynanır?',
                    onPressed: _showHelpDialog,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white70),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // OYUNUN AMACINI ANLATAN BANNER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: const Color(0xFF261E2E),
              child: Row(
                children: [
                  const Text('💡', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _highlightedTargetIndex != null
                          ? 'IŞIĞI YAKALA: Parlayan "${_syllables[_highlightedTargetIndex!]}" pedine dokun ve seslendir!'
                          : 'Ritim açıkken pedlere bas, heceleri müzikle birleştir!',
                      style: const TextStyle(
                        color: Color(0xFFFF80AB),
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  if (_comboCount > 1)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'x$_comboCount 🔥',
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Colors.black),
                      ),
                    ),
                ],
              ),
            ),

            // RİTİM SEÇİCİ VE VURUŞ İNDİKATÖRÜ
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  // Beat Döngü Butonu
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isPlayingLoop ? const Color(0xFF00E676) : const Color(0xFF2C2C2C),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    icon: Icon(_isPlayingLoop ? Icons.stop_rounded : Icons.play_arrow_rounded, size: 20),
                    label: Text(
                      _isPlayingLoop ? 'RİTİM AÇIK' : 'RİTİM BAŞLAT',
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11),
                    ),
                    onPressed: _toggleLoop,
                  ),
                  const SizedBox(width: 12),
                  // Ritim Adım Işıkları (4 Beat Led)
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(4, (i) {
                        final isActive = _isPlayingLoop && _activeBeatStep == i;
                        return Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isActive ? const Color(0xFFFF4081) : Colors.white12,
                            boxShadow: isActive
                                ? [BoxShadow(color: const Color(0xFFFF4081).withValues(alpha: 0.8), blurRadius: 10, spreadRadius: 2)]
                                : null,
                          ),
                        );
                      }),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text('Vuruş: $_totalHits', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12)),
                  ),
                ],
              ),
            ),

            // 8 ADET RENKLİ DJ HECE PEDİ (2x4 Grid)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: _syllables.length,
                  itemBuilder: (ctx, i) {
                    final syl = _syllables[i];
                    final color = _padColors[i % _padColors.length];
                    final isHighlighted = (i == _highlightedTargetIndex);

                    return GestureDetector(
                      onTap: () => _hitPad(i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isHighlighted ? Colors.white : Colors.white24,
                            width: isHighlighted ? 3.5 : 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isHighlighted
                                  ? Colors.white.withAlpha(200)
                                  : color.withValues(alpha: 0.4),
                              blurRadius: isHighlighted ? 18 : 8,
                              spreadRadius: isHighlighted ? 2 : 0,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              syl,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                shadows: [Shadow(color: Colors.black38, blurRadius: 4, offset: Offset(0, 2))],
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isHighlighted ? 'HEDEF ⭐' : 'PAD',
                              style: TextStyle(
                                fontSize: 8.5,
                                fontWeight: FontWeight.w800,
                                color: isHighlighted ? Colors.yellowAccent : Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // ALT AKSİYON BARI
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2C2C2C),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                  label: const Text('HARİKA, ÇIKIŞ YAP 🎯', style: TextStyle(fontWeight: FontWeight.w900)),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
