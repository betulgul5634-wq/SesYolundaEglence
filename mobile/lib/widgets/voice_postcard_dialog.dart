import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/reward_state.dart';
import '../services/audio_speech_service.dart';
import '../services/sound_effects_service.dart';

/// 💌 SES KARTPOSTALI & AİLEYE GÖNDER
/// Çocuğun terapide kazandığı başarıyı kendi sesiyle ailesine bir hediye kartı olarak göndermesini sağlar.
class VoicePostcardDialog extends StatefulWidget {
  final String phoneme;

  const VoicePostcardDialog({
    super.key,
    required this.phoneme,
  });

  @override
  State<VoicePostcardDialog> createState() => _VoicePostcardDialogState();
}

class _VoicePostcardDialogState extends State<VoicePostcardDialog> {
  final RewardState _rewardState = RewardState();
  final AudioSpeechService _audioService = AudioSpeechService();
  final SoundEffectsService _sfx = SoundEffectsService();

  int _selectedFrameIndex = 0; // 0: Sevgi, 1: Şampiyon, 2: Uzay
  bool _isRecording = false;
  bool _hasRecorded = false;
  String _recordedMessage = '';

  final List<(String, String, Color, Color)> _frames = [
    ('💌 Sevgi Kalbi', '❤️', const Color(0xFFFCE4EC), const Color(0xFFE91E63)),
    ('🏆 Şampiyon Yıldız', '⭐', const Color(0xFFFFF8E1), const Color(0xFFFF8F00)),
    ('🚀 Uzay Macerası', '🪐', const Color(0xFFEDE7F6), const Color(0xFF673AB7)),
  ];

  void _toggleRecording() async {
    if (_isRecording) {
      _audioService.stopListening();
      setState(() {
        _isRecording = false;
        _hasRecorded = true;
      });
      _sfx.playSuccessDing();
    } else {
      final perm = await _audioService.requestMicrophonePermission();
      if (!perm) return;

      setState(() {
        _isRecording = true;
        _recordedMessage = 'Kaydediliyor... Sevdiklerine seslen! 🎤';
      });

      _audioService.listenToSpeech(
        duration: const Duration(seconds: 8),
        onInterimText: (text) {
          if (mounted) setState(() => _recordedMessage = text);
        },
      ).then((spoken) {
        if (mounted) {
          setState(() {
            _isRecording = false;
            _hasRecorded = true;
            if (spoken.isNotEmpty) _recordedMessage = spoken;
          });
        }
      });
    }
  }

  void _sharePostcard() {
    final frame = _frames[_selectedFrameIndex];
    final text = '💌 *SES YOLUNDA EĞLENCE — SES KARTPOSTALI* ${frame.$2}\n\n'
        '👤 Gönderen: ${_rewardState.activeCharacterName} (${_rewardState.activeAvatar})\n'
        '🎯 Başarılan Ses: ${widget.phoneme} Sesi\n'
        '💬 Sesli Notum: "${_recordedMessage.isEmpty ? "Bugün konuşma terapisinde yeni bir ses öğrendim!" : _recordedMessage}"\n\n'
        '⭐ Toplam Kazanılan Yıldızlar: ${_rewardState.totalStars} ⭐\n'
        '❤️ Sevgilerimle!';

    Clipboard.setData(ClipboardData(text: text));
    _sfx.playVictoryFanfare();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Ses Kartpostalı panoya kopyalandı! WhatsApp ile ailene gönderebilirsin! 📱'),
        backgroundColor: Color(0xFF2E7D32),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final frame = _frames[_selectedFrameIndex];

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      child: Container(
        width: 440,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          color: Colors.white,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Üst Başlık
              Row(
                children: [
                  const Text('💌', style: TextStyle(fontSize: 26)),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ailene Ses Kartpostalı Gönder',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFFC2185B)),
                        ),
                        Text(
                          'Kendi sesin ve avatarınla sevdiklerine sürpriz yap!',
                          style: TextStyle(fontSize: 11, color: Colors.black54, fontWeight: FontWeight.w700),
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

              // ÇERÇEVE SEÇİCİ
              Row(
                children: List.generate(_frames.length, (i) {
                  final f = _frames[i];
                  final isSel = _selectedFrameIndex == i;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedFrameIndex = i),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: isSel ? f.$4 : f.$3,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: f.$4, width: 1.5),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          f.$1,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: isSel ? Colors.white : f.$4,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),

              // KARTPOSTAL ÖNİZLEMESİ
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: frame.$3,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: frame.$4, width: 3),
                  boxShadow: [
                    BoxShadow(color: frame.$4.withValues(alpha: 0.25), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(frame.$2, style: const TextStyle(fontSize: 28)),
                        Text('${widget.phoneme} Sesi Başarısı',
                            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: frame.$4)),
                        Text(frame.$2, style: const TextStyle(fontSize: 28)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: Colors.white,
                      child: Text(_rewardState.activeAvatar, style: const TextStyle(fontSize: 42)),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _rewardState.activeCharacterName,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF263238)),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: frame.$4.withValues(alpha: 0.5)),
                      ),
                      child: Text(
                        _recordedMessage.isEmpty
                            ? '🎙️ "Aşağıdaki butona basarak sevdiklerine sesli mesajını kaydet!"'
                            : '"$_recordedMessage"',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: _recordedMessage.isEmpty ? Colors.grey[600] : const Color(0xFF1B5E20),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // SES KAYDETME BUTONU
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isRecording ? const Color(0xFFE53935) : const Color(0xFF1976D2),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      icon: Icon(_isRecording ? Icons.stop_rounded : Icons.mic_rounded),
                      label: Text(
                        _isRecording ? 'KAYDI BİTİR ⏹️' : (_hasRecorded ? 'YENİDEN KAYDET 🎤' : 'SESİNİ KAYDET 🎤'),
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12.5),
                      ),
                      onPressed: _toggleRecording,
                    ),
                  ),
                  if (_hasRecorded) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.play_circle_fill_rounded, color: Color(0xFF7B1FA2), size: 36),
                      tooltip: 'Sesini Dinle 🎧',
                      onPressed: () => _audioService.playLastRecordedAudio(),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 10),

              // AİLEYE GÖNDER BUTONU
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF25D366), // WhatsApp Yeşili
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    elevation: 3,
                  ),
                  icon: const Icon(Icons.send_rounded, size: 20),
                  label: const Text(
                    'Ailene Kartpostal Gönder (WhatsApp) 📱',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13.5),
                  ),
                  onPressed: _sharePostcard,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
