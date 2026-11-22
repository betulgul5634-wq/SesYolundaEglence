import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import '../models/reward_state.dart';

/// 🪞 KLİNİK CANLI KONUŞMA AYNASI
/// Dil ve konuşma terapisinde en önemli araç olan aynayı çocuğun ekranına taşır.
/// Çocuk hedef sesi üretirken kendi ağız, dudak ve çene hareketlerini anlık izler.
class SpeechMirrorDialog extends StatefulWidget {
  final String phoneme;
  final String hint;

  const SpeechMirrorDialog({
    super.key,
    required this.phoneme,
    this.hint = '',
  });

  @override
  State<SpeechMirrorDialog> createState() => _SpeechMirrorDialogState();
}

class _SpeechMirrorDialogState extends State<SpeechMirrorDialog> {
  late final String _viewId;
  html.MediaStream? _cameraStream;
  html.VideoElement? _videoElement;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    RewardState().recordQuestMirror();
    _viewId = 'speech-mirror-video-${DateTime.now().millisecondsSinceEpoch}';

    if (kIsWeb) {
      ui_web.platformViewRegistry.registerViewFactory(
        _viewId,
        (int id) {
          final video = html.VideoElement()
            ..autoplay = true
            ..muted = true
            ..setAttribute('playsinline', 'true')
            ..setAttribute('webkit-playsinline', 'true')
            ..style.width = '100%'
            ..style.height = '100%'
            ..style.objectFit = 'cover'
            ..style.borderRadius = '24px'
            ..style.transform = 'scaleX(-1)' // Doğal ayna simetrisi
            ..style.backgroundColor = '#000000';

          _videoElement = video;

          html.window.navigator.mediaDevices?.getUserMedia({
            'video': {
              'facingMode': 'user',
              'width': {'ideal': 640},
              'height': {'ideal': 640},
            },
            'audio': false,
          }).then((stream) {
            _cameraStream = stream;
            video.srcObject = stream;
            video.play();
            if (mounted) {
              setState(() {
                _isLoading = false;
                _errorMessage = null;
              });
            }
          }).catchError((err) {
            debugPrint('Ayna kamera erişim hatası: $err');
            if (mounted) {
              setState(() {
                _isLoading = false;
                _errorMessage = 'Kamera izni verilmedi veya kamera bulunamadı 📷\nTarayıcı adres çubuğundaki kilit simgesinden kamera iznini açabilirsiniz.';
              });
            }
          });

          return video;
        },
      );
    }
  }

  @override
  void dispose() {
    if (_cameraStream != null) {
      try {
        _cameraStream!.getTracks().forEach((track) {
          try { track.stop(); } catch (_) {}
        });
        _cameraStream = null;
      } catch (_) {}
    }
    if (_videoElement != null) {
      try {
        _videoElement!.pause();
        _videoElement!.srcObject = null;
      } catch (_) {}
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      child: Container(
        width: 380,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          gradient: const LinearGradient(
            colors: [Color(0xFFFFF8E1), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          border: Border.all(color: const Color(0xFFFFB300), width: 2.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Üst Başlık
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFECB3),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Text('🪞', style: TextStyle(fontSize: 26)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Canlı Konuşma Aynası',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFE65100),
                        ),
                      ),
                      Text(
                        'Dudak ve dil hareketlerini izle (${widget.phoneme})',
                        style: const TextStyle(fontSize: 11.5, color: Colors.black54, fontWeight: FontWeight.w700),
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
            const SizedBox(height: 16),

            // Kamera Görüntüsü Çerçevesi (Altın Ayna Çerçevesi)
            Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: const Color(0xFFFFC107), width: 5),
                boxShadow: const [
                  BoxShadow(color: Color(0x33FFB300), blurRadius: 16, offset: Offset(0, 6)),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(23),
                child: Stack(
                  children: [
                    if (kIsWeb)
                      Positioned.fill(
                        child: HtmlElementView(viewType: _viewId),
                      )
                    else
                      Container(
                        color: Colors.black87,
                        alignment: Alignment.center,
                        child: const Text(
                          'Kamera Sadece Web Modunda Aktiftir 📷',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    if (_isLoading)
                      Positioned.fill(
                        child: Container(
                          color: Colors.black87,
                          child: const Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(color: Color(0xFFFFC107)),
                                SizedBox(height: 12),
                                Text(
                                  'Kamera açılıyor... 🪞',
                                  style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    if (_errorMessage != null)
                      Positioned.fill(
                        child: Container(
                          color: Colors.black87,
                          padding: const EdgeInsets.all(16),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('📷', style: TextStyle(fontSize: 36)),
                                const SizedBox(height: 8),
                                Text(
                                  _errorMessage!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.amberAccent, fontSize: 12, fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Terapist Ağız İpucu
            if (widget.hint.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF81C784)),
                ),
                child: Row(
                  children: [
                    const Text('🗣️', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.hint,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF2E7D32)),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 14),

            // Tamam Butonu
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF58CC02),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                ),
                icon: const Icon(Icons.check_circle_outline_rounded, size: 20),
                label: const Text(
                  'Aynayı Anladım, Pratiğe Dön 🎯',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
