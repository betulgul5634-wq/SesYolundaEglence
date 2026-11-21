import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../services/audio_speech_service.dart';

/// Canlı Video Tarzı Ağız & Dil Artikülasyon Anatomi Rehberi
/// Kullanıcı Başlatınca Çalışır ve Hareketle Eş Zamanlı Sesli & Yazılı Anlatım Yapar.
class MouthAnatomyWidget extends StatefulWidget {
  final String phoneme; // örn: "P", "B", "T", "D", "S", "K"
  final String articulationHint;

  const MouthAnatomyWidget({
    super.key,
    required this.phoneme,
    required this.articulationHint,
  });

  @override
  State<MouthAnatomyWidget> createState() => _MouthAnatomyWidgetState();
}

class _MouthAnatomyWidgetState extends State<MouthAnatomyWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _motionAnim;
  final AudioSpeechService _audioService = AudioSpeechService();

  bool _isPlaying = false; // Kullanıcı başlatınca başlar!
  bool _isSlowMotion = false; // Varsayılan normal hız (sesle 1:1 tam eşzamanlı)
  int _currentStep = 0; // 0: Dudakları Sık, 1: Titreşimi Hisset, 2: "B!" Patlat

  String _getHeaderTitle(String cleanP) {
    switch (cleanP) {
      case 'T': return '⏰ Tıkır Tıkır Saat Oyunu (T Sesi Rehberi)';
      case 'D': return '🚗 Düt Düt Araba & Davul Oyunu (D Sesi)';
      case 'K': return '😄 Kıkır Kıkır K Sesi Rehberi';
      case 'G': return '🍇 Tok ve Güçlü G Sesi Rehberi';
      case 'R': return '🏎️ Güçlü ve Canlı R Sesi Rehberi (Motor Oyunu)';
      case 'Z': return '🐝 Sevimli Arı Vızıltısı (Z Sesi Rehberi)';
      case 'S': return '🐍 İnce Rüzgar & Islık Sesi (S Sesi Rehberi)';
      case 'Ş': return '🤫 Güçlü Rüzgar & Fısıltı (Ş Sesi Rehberi)';
      case 'J': return '⚡ Titreşen Araba Motoru (J Sesi Rehberi)';
      case 'F': return '🐰 Sevimli Tavşan Dişi Oyunu (F Sesi Rehberi)';
      case 'V': return '🛵 Vızır Vızır Motor Oyunu (V Sesi Rehberi)';
      case 'H': return '🔥 Elleri Isıtma Sıcak Nefes Oyunu (H Sesi Rehberi)';
      case 'Ç': return '🚂 Çuf Çuf Tren Oyunu (Ç Sesi Rehberi)';
      case 'C': return '🐥 Cik Cik Kuş & Güçlü C Sesi Rehberi';
      case 'M': return '🍦 Nefis Dondurma Mmm Oyunu (M Sesi Rehberi)';
      case 'N': return '🔔 Neşeli Çan & Zil Oyunu (N Sesi Rehberi)';
      case 'L': return '🎵 Şarkı Söyleyen Dil (L Sesi Rehberi)';
      case 'Y': return '🛝 Eğlenceli Kaydırak Oyunu (Y Sesi Rehberi)';
      case 'B': return '🎈 Dudak Patlatma Oyunu (B Sesi Rehberi)';
      case 'P': return '🎈 Uçan Balon Patlatma Oyunu (P Sesi Rehberi)';
      default: return 'Sesli Video Rehberi: Doğru Dil & Ağız';
    }
  }

  String _getHeaderSubtitle(String cleanP) {
    switch (cleanP) {
      case 'T': return 'Gülümse, dilini damağa yapıştır ve saat gibi patlat! 💥';
      case 'D': return 'Dili damağa bas, boğazını titreterek araba gibi patlat! 🚗💨';
      case 'K': return 'Dilinin ucunu aşağıda tut, arkasını damağa bas ve boğazından patlat: K! 💥';
      case 'G': return 'Dilin arkasını damağa bas, boğazını titreterek patlat: G! 💥';
      case 'R': return 'Dil ucunu damağına yaklaştır, güçlü nefesle dilini titret: Rrr! 🏎️💨';
      case 'Z': return 'Dişlerini yaklaştır, ses tellerini titreterek arı gibi vızılda: Zzz! 🐝';
      case 'S': return 'Dişlerini birbirine yaklaştır, serin bir ıslık gibi üfle: Sss! 🐍💨';
      case 'Ş': return 'Dudaklarını yuvarla, dilinin yanlarını kaldır ve rüzgar gibi üfle: Şşş! 🤫';
      case 'J': return 'Dudaklarını öne uzat, ses tellerini titreterek araba motoru gibi vızılda: Jjj! 🏎️⚡';
      case 'F': return 'Üst tavşan dişlerini alt dudağına hafifçe değdir, fısıltıyla üfle: Fff! 🐰💨';
      case 'V': return 'Üst dişlerini alt dudağına değdir, boğazını titreterek vızıldat: Vvv! 🛵⚡';
      case 'H': return 'Ağzını arala, ellerine sıcak nefes üfler gibi fısılda: Hhh! 🔥';
      case 'Ç': return 'Dil ucunu üst damağa bas, dudaklarını hafif uzatıp aniden patlat: Ç! 🚂💥';
      case 'C': return 'Dilini damağa bas, ses tellerini titreterek kuvvetle patlat: Cik Cik! C! 🐥💥';
      case 'M': return 'Dudaklarını birbirine kapat, boğazını titreterek sesini burnundan çıkar: Mmm! 🍦';
      case 'N': return 'Dil ucunu üst diş arkasına yapıştır, sesi burnundan çınlat: Nnn! 🔔';
      case 'L': return 'Dil ucunu üst diş arkasına kaldır, havanın dil yanlarından akmasını sağla: Lll! 🎶';
      case 'Y': return 'Dil ortasını damağa yaklaştır, kaydıraktan kayar gibi tatlıca akıt: Yyy! 🛝✨';
      case 'B': return 'Dudaklarını birbirine kapat, boğazını titreterek güçlüce patlat: Bı! 🎈💥';
      case 'P': return 'Dudaklarını sıkıca kapat, havayı topla ve aniden puf diye patlat: Pı! 🎈💥';
      default: return 'Doğru artikülasyon modeli';
    }
  }

  int _getAudioDurationMs() {
    final cleanP = widget.phoneme.replaceAll('/', '').trim().toUpperCase();
    if (cleanP == 'B') return 14450; // 14.45 sn tam eşzamanlı
    if (cleanP == 'P') return 14200;
    if (cleanP == 'T') return 19500; // 19.50 sn canlı saat oyunu tam eşzamanlı
    if (cleanP == 'D') return 21400; // 21.40 sn düt düt araba ve davul oyunu tam eşzamanlı
    if (cleanP == 'K') return 28320; // 28.32 sn klinik K sesi rehberi tam eşzamanlı
    if (cleanP == 'G') return 18500; // 18.50 sn güçlü G sesi rehberi
    if (cleanP == 'R') return 19600;
    if (cleanP == 'S') return 15543;
    if (cleanP == 'Z') return 14387;
    if (cleanP == 'Ş') return 16305;
    if (cleanP == 'J') return 22980;
    if (cleanP == 'F') return 16000;
    if (cleanP == 'V') return 16000;
    if (cleanP == 'H') return 15000;
    if (cleanP == 'Ç') return 16000;
    if (cleanP == 'C') return 16000;
    if (cleanP == 'M') return 15000;
    if (cleanP == 'N') return 15000;
    if (cleanP == 'L') return 16000;
    if (cleanP == 'Y') return 15000;
    return 14450;
  }

  @override
  void initState() {
    super.initState();
    final durMs = _getAudioDurationMs();
    _animController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: durMs),
    );

    _motionAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.linear,
    )..addListener(() {
        if (!mounted) return;
        final v = _animController.value;
        final cleanP = widget.phoneme.replaceAll('/', '').trim().toUpperCase();
        int step = 0;
        if (cleanP == 'B') {
          if (v < 0.29) {
            step = 0; // 1. Adım: Dudaklarını birbirine sıkıca bastır (0.0 - 4.15 sn)
          } else if (v < 0.68) {
            step = 1; // 2. Adım: Boğazına dokun ve dudaklarını açmadan hımm diye titreşimi hisset (4.15 - 9.89 sn)
          } else {
            step = 2; // 3. Adım: Dudaklarını birden açarak sesi patlat: B! (9.89 - 14.45 sn)
          }
        } else if (cleanP == 'T') {
          if (v < 0.38) {
            step = 0; // 1. Adım: Gülümse & Dili Üst Dişe Yapıştır (0.0 - 7.4 sn)
          } else if (v < 0.65) {
            step = 1; // 2. Adım: Nefesini Sakla, Sessiz Ol (7.4 - 12.6 sn)
          } else {
            step = 2; // 3. Adım: Saatin Sesi Gibi Patlat: Tik-Tak! T! (12.6 - 19.5 sn)
          }
        } else if (cleanP == 'D') {
          if (v < 0.36) {
            step = 0; // 1. Adım: Gülümse & Dili Damağa Bas (0.0 - 7.8 sn)
          } else if (v < 0.69) {
            step = 1; // 2. Adım: Boğazında Araba Motorunu Titret (7.8 - 14.8 sn)
          } else {
            step = 2; // 3. Adım: Araba Kornası Gibi Patlat: Düt Düt! Dan! D! (14.8 - 21.4 sn)
          }
        } else if (cleanP == 'K') {
          if (v < 0.36) {
            step = 0; // 1. Adım: Dil Ucu Aşağıda (0.0 - 10.2 sn)
          } else if (v < 0.66) {
            step = 1; // 2. Adım: Dil Arkası Damağa Basılı (10.2 - 18.6 sn)
          } else {
            step = 2; // 3. Adım: Boğazdan Patlat: Kıkır Kıkır! K! (18.6 - 28.3 sn)
          }
        } else if (cleanP == 'G') {
          if (v < 0.36) {
            step = 0;
          } else if (v < 0.66) {
            step = 1;
          } else {
            step = 2;
          }
        } else if (cleanP == 'R') {
          if (v < 0.45) {
            step = 0; // 1. Adım: Dili Diş Yuvasına Yaklaştır (0.0 - 8.8 sn)
          } else if (v < 0.68) {
            step = 1; // 2. Adım: Derin Nefes Üfle (8.8 - 13.3 sn)
          } else {
            step = 2; // 3. Adım: Dil Ucunu Titret: Rrr! (13.3 - 19.6 sn)
          }
        } else if (cleanP == 'S') {
          if (v < 0.37) {
            step = 0;
          } else if (v < 0.63) {
            step = 1;
          } else {
            step = 2;
          }
        } else if (cleanP == 'Z') {
          if (v < 0.36) {
            step = 0;
          } else if (v < 0.63) {
            step = 1;
          } else {
            step = 2;
          }
        } else if (cleanP == 'Ş') {
          if (v < 0.40) {
            step = 0;
          } else if (v < 0.67) {
            step = 1;
          } else {
            step = 2;
          }
        } else if (cleanP == 'J') {
          if (v < 0.32) {
            step = 0;
          } else if (v < 0.65) {
            step = 1;
          } else {
            step = 2;
          }
        } else {
          if (v < 0.33) {
            step = 0;
          } else if (v < 0.68) {
            step = 1;
          } else {
            step = 2;
          }
        }
        if (step != _currentStep) {
          setState(() => _currentStep = step);
        }
      });

    _animController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _isPlaying = false);
      }
    });
  }

  void _startVideoWithVoice() {
    setState(() {
      _isPlaying = true;
      _animController.reset();
    });

    // Donanım düzeyinde ses ile %100 birebir kilitli canlı senkronizasyon motoru
    _audioService.speakTurkish(
      widget.phoneme,
      phoneme: widget.phoneme,
      mode: 'explain',
      onAudioStarted: () {
        if (!mounted) return;
        setState(() => _isPlaying = true);
      },
      onTimeUpdate: (currentSec, totalSec) {
        if (!mounted) return;
        if (totalSec > 0) {
          final progress = (currentSec / totalSec).clamp(0.0, 1.0);
          _animController.value = progress;
        }
      },
      onAudioCompleted: () {
        if (!mounted) return;
        setState(() {
          _isPlaying = false;
          _animController.value = 1.0;
        });
      },
    );
  }

  void _pauseVideo() {
    setState(() {
      _isPlaying = false;
      _animController.stop();
    });
    _audioService.pauseAudio();
  }

  void _resumeVideo() {
    setState(() {
      _isPlaying = true;
    });
    _audioService.resumeAudio();
  }

  void _toggleSpeed() {
    final durMs = _getAudioDurationMs();
    setState(() {
      _isSlowMotion = !_isSlowMotion;
      _animController.duration = Duration(milliseconds: _isSlowMotion ? durMs * 2 : durMs);
    });
  }

  void _seekToStep(int step) {
    final cleanP = widget.phoneme.replaceAll('/', '').trim().toUpperCase();
    setState(() {
      _currentStep = step;
      double targetSec = 0.0;
      if (cleanP == 'D') {
        if (step == 0) targetSec = 0.1;
        if (step == 1) targetSec = 7.8;
        if (step == 2) targetSec = 14.8;
      } else if (cleanP == 'K') {
        if (step == 0) targetSec = 0.1;
        if (step == 1) targetSec = 10.2;
        if (step == 2) targetSec = 18.7;
      } else if (cleanP == 'T') {
        if (step == 0) targetSec = 0.1;
        if (step == 1) targetSec = 7.4;
        if (step == 2) targetSec = 12.6;
      } else if (cleanP == 'R') {
        if (step == 0) targetSec = 0.1;
        if (step == 1) targetSec = 8.9;
        if (step == 2) targetSec = 13.4;
      } else if (cleanP == 'S') {
        if (step == 0) targetSec = 0.1;
        if (step == 1) targetSec = 6.0;
        if (step == 2) targetSec = 10.2;
      } else if (cleanP == 'Z') {
        if (step == 0) targetSec = 0.1;
        if (step == 1) targetSec = 5.5;
        if (step == 2) targetSec = 9.5;
      } else if (cleanP == 'Ş') {
        if (step == 0) targetSec = 0.1;
        if (step == 1) targetSec = 6.8;
        if (step == 2) targetSec = 11.2;
      } else if (cleanP == 'J') {
        if (step == 0) targetSec = 0.1;
        if (step == 1) targetSec = 6.2;
        if (step == 2) targetSec = 12.8;
      } else {
        if (step == 0) targetSec = 0.1;
        if (step == 1) targetSec = 4.2;
        if (step == 2) targetSec = 9.9;
      }

      final dur = _getAudioDurationMs() / 1000.0;
      _animController.value = (targetSec / dur).clamp(0.0, 1.0);
      _audioService.seekAudio(targetSec);
    });
  }

  @override
  void dispose() {
    _audioService.stopAudio();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cleanP = widget.phoneme.replaceAll('/', '').trim().toUpperCase();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 6, 16, 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFFF9800).withAlpha(120), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withAlpha(20),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Video Player Üst Çubuğu
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFF3E0),
                      shape: BoxShape.circle,
                    ),
                    child: const Text('🎬', style: TextStyle(fontSize: 18)),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getHeaderTitle(cleanP),
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 13.5,
                          color: Color(0xFFE65100),
                        ),
                      ),
                      Text(
                        _getHeaderSubtitle(cleanP),
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ],
              ),

              // Yavaş Çekim (0.5x Slow-Motion)
              InkWell(
                onTap: _toggleSpeed,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _isSlowMotion ? const Color(0xFFFFE0B2) : Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _isSlowMotion ? const Color(0xFFE65100) : Colors.grey[300]!,
                    ),
                  ),
                  child: Text(
                    _isSlowMotion ? '🐢 0.5x Ağır' : '⚡ 1.0x Normal',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: _isSlowMotion ? const Color(0xFFE65100) : Colors.black87,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Canlı Video Ekranı (Temiz, Yazısız, Kesintisiz Görsel Kesit)
          Container(
            height: 165,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFF9FBE7),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFDCEDC8), width: 1.5),
            ),
            child: AnimatedBuilder(
              animation: _motionAnim,
              builder: (context, _) {
                return CustomPaint(
                  painter: _PreciseClinicalAnatomyPainter(
                    phoneme: cleanP.toLowerCase(),
                    progress: _animController.value,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),

          // Video Kontrol Çubuğu (Oynat/Durdur Butonu + Zaman + İlerleme Çubuğu)
          AnimatedBuilder(
            animation: _animController,
            builder: (context, _) {
              final v = _animController.value;
              final totalSec = ((_getAudioDurationMs() / 1000) * (_isSlowMotion ? 2 : 1)).round();
              final currentSec = (v * totalSec).toInt();
              return Column(
                children: [
                  Row(
                    children: [
                      // Video Oynat / Duraklat Butonu
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE65100),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 2,
                        ),
                        icon: Icon(
                          _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                          size: 20,
                        ),
                        label: Text(
                          _isPlaying
                              ? 'Durdur'
                              : (v > 0 && !_animController.isCompleted ? 'Devam Et' : '▶️ Başlat'),
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
                        ),
                        onPressed: _isPlaying
                            ? _pauseVideo
                            : (v > 0 && !_animController.isCompleted ? _resumeVideo : _startVideoWithVoice),
                      ),
                      const SizedBox(width: 10),

                      // Süre ve İlerleme Çubuğu
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '00:${currentSec.toString().padLeft(2, '0')} / 00:${totalSec.toString().padLeft(2, '0')} sn',
                                  style: const TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFFE65100),
                                  ),
                                ),
                                Text(
                                  _isSlowMotion ? '🐢 0.5x Ağır Çekim' : '⚡ 1.0x Normal',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: v,
                                minHeight: 6,
                                backgroundColor: Colors.grey[200],
                                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFE65100)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // 3 Aşamalı Adım Butonları (Video Oynatırken Otomatik İlerler)
                  Row(
                    children: [
                      _buildStepPill(0, _getPillTitle(0, cleanP)),
                      const SizedBox(width: 4),
                      _buildStepPill(1, _getPillTitle(1, cleanP)),
                      const SizedBox(width: 4),
                      _buildStepPill(2, _getPillTitle(2, cleanP)),
                    ],
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 10),

          // Eş Zamanlı Altyazı ve Klinik Yönerge Kutusu (Canlı Konuşur)
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _getStepBackgroundColor(_currentStep),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _getStepBorderColor(_currentStep), width: 1.5),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _currentStep == 0 ? '👄' : (_currentStep == 1 ? '✋' : '💥'),
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getStepTitle(_currentStep),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: _getStepBorderColor(_currentStep),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _getStepNarration(_currentStep),
                        style: const TextStyle(
                          fontSize: 11,
                          height: 1.35,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF37474F),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

    String _getPillTitle(int index, String cleanP) {
    if (index == 0) {
      if (cleanP == 'T' || cleanP == 'D') return '1. Gülümse & Dili Bas 😊';
      if (cleanP == 'K') return '1. Dili Aşağı Sakla 👅';
      if (cleanP == 'R') return '1. Dili Yaklaştır 👅';
      if (cleanP == 'J' || cleanP == 'Ş') return '1. Dudakları Yuvarla 👄';
      if (cleanP == 'Z' || cleanP == 'S') return '1. Dişleri Yaklaştır 🦷';
      if (cleanP == 'B') return '1. Dudakları Sık';
      return '1. Dudakları Kapat';
    } else if (index == 1) {
      if (cleanP == 'T') return '2. Nefesini Sakla 🤫';
      if (cleanP == 'D') return '2. Boğazı Titret 🚗';
      if (cleanP == 'K') return '2. Arkasını Damağa Bas 🤫';
      if (cleanP == 'R') return '2. Motoru Çalıştır 🏎️';
      if (cleanP == 'J') return '2. Boğazı Titret ⚡';
      if (cleanP == 'Ş') return '2. Yanları Kaldır 👅';
      if (cleanP == 'Z') return '2. Boğazı Titret ✋';
      if (cleanP == 'S') return '2. Dilini Ortada Tut 👅';
      if (cleanP == 'B') return '2. Titreşimi Hisset';
      return '2. Hava Birikir';
    } else {
      if (cleanP == 'T') return '3. "Tik-Tak! T!" Patlat ⏰';
      if (cleanP == 'D') return '3. "Düt-Düt! D!" Patlat 🥁';
      if (cleanP == 'K') return '3. "K! K! K!" Patlat 💥';
      if (cleanP == 'R') return '3. Dil Ucunu Titret: Rrr! 🏎️';
      if (cleanP == 'J') return '3. Motoru Titret: Jjj! 🏎️';
      if (cleanP == 'Ş') return '3. Rüzgar Gibi Üfle: Şşş! 🤫';
      if (cleanP == 'Z') return '3. Arı Gibi Vızılda 🐝';
      if (cleanP == 'S') return '3. Islık Gibi Üfle: Sss! 🐍';
      if (cleanP == 'B') return '3. "B!" Patlat';
      return '3. Sesi Patlat!';
    }
  }

  Widget _buildStepPill(int index, String title) {
    final isSelected = _currentStep == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => _seekToStep(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 5),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFE65100) : const Color(0xFFFFF3E0),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? const Color(0xFFBF360C) : const Color(0xFFFFCC80),
              width: 1.2,
            ),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: isSelected ? Colors.white : const Color(0xFF5D4037),
            ),
          ),
        ),
      ),
    );
  }

  Color _getStepBackgroundColor(int step) {
    if (step == 0) return const Color(0xFFFFFDE7);
    if (step == 1) return const Color(0xFFFFF3E0);
    return const Color(0xFFE1F5FE);
  }

  Color _getStepBorderColor(int step) {
    if (step == 0) return const Color(0xFFFBC02D);
    if (step == 1) return const Color(0xFFFF9800);
    return const Color(0xFF0288D1);
  }

  String _getStepTitle(int step) {
    final cleanP = widget.phoneme.replaceAll('/', '').trim().toUpperCase();
    if (cleanP == 'T') {
      if (step == 0) return '1. Adım: Gülümse & Dili Üst Dişe Yapıştır 😊';
      if (step == 1) return '2. Adım: Nefesini Sakla, Sessiz Ol 🤫';
      return '3. Adım: Saatin Sesi Gibi Patlat: Tik-Tak! T! ⏰💥';
    }
    if (cleanP == 'D') {
      if (step == 0) return '1. Adım: Gülümse & Dili Damağa Bastır 😊';
      if (step == 1) return '2. Adım: Boğazında Araba Motorunu Titret 🚗💨';
      return '3. Adım: Araba Kornası ve Davul Gibi Patlat: Düt Düt! D! 🥁💥';
    }
    if (cleanP == 'K') {
      if (step == 0) return '1. Adım: Dilinin Ucunu Aşağıya Sakla 👅';
      if (step == 1) return '2. Adım: Dilinin Arkasını Damağa Yapıştır 🤫';
      return '3. Adım: Boğazından Neşeyle Patlat: K! K! K! 💥';
    }
    if (cleanP == 'G') {
      if (step == 0) return '1. Adım: Dilinin Arkasını Damağa Bastır 👅';
      if (step == 1) return '2. Adım: Boğazında Ses Tellerini Titret 🚗💨';
      return '3. Adım: Boğazından Tokça Patlat: G! G! G! 💥';
    }
    if (cleanP == 'R') {
      if (step == 0) return '1. Adım: Dil Ucunu Damağa Yaklaştır 👅';
      if (step == 1) return '2. Adım: Motoru Çalıştır & Derin Nefes Üfle 🏎️💨';
      return '3. Adım: Dil Ucunu Tatlı Tatlı Titret: Rrr! R! R! 💥';
    }
    if (cleanP == 'S') {
      if (step == 0) return '1. Adım: Dişlerini Yaklaştır 🦷';
      if (step == 1) return '2. Adım: Dilini Ortada Tut 👅';
      return '3. Adım: İnce Islık Gibi Üfle: Sss! 🐍💨';
    }
    if (cleanP == 'Z') {
      if (step == 0) return '1. Adım: Dişlerini Yaklaştır 🦷';
      if (step == 1) return '2. Adım: Dilini Ortada Tut 👅';
      return '3. Adım: Arı Gibi Vızılda: Zzz! 🐝⚡';
    }
    if (cleanP == 'Ş') {
      if (step == 0) return '1. Adım: Dudaklarını Öne Doğru Yuvarla 👄';
      if (step == 1) return '2. Adım: Dilinin Yanlarını Kaldır 👅';
      return '3. Adım: Güçlü Bir Rüzgar Gibi Üfle: Şşş! 🤫💨';
    }
    if (cleanP == 'J') {
      if (step == 0) return '1. Adım: Dudaklarını Öne Yuvarla 👄';
      if (step == 1) return '2. Adım: Dili Kaldır & Boğazı Titret 👅⚡';
      return '3. Adım: Araba Motoru Gibi Vızılda: Jjj! 🏎️💥';
    }
    if (cleanP == 'F') {
      if (step == 0) return '1. Adım: Tavşan Dişlerini Göster 🐰';
      if (step == 1) return '2. Adım: Dişleri Alt Dudağa Değdir 👄';
      return '3. Adım: Fısıltıyla Havayı Üfle: Fff! 🌬️';
    }
    if (cleanP == 'V') {
      if (step == 0) return '1. Adım: Dişleri Alt Dudağa Değdir 👄';
      if (step == 1) return '2. Adım: Boğazında Motoru Titret ⚡';
      return '3. Adım: Motor Gibi Vızıldat: Vvv! 🛵💨';
    }
    if (cleanP == 'H') {
      if (step == 0) return '1. Adım: Ağzını Rahatça Arala 👄';
      if (step == 1) return '2. Adım: Derin Bir Nefes Al 🌬️';
      return '3. Adım: Sıcak Havayı Ellere Üfle: Hhh! 🔥';
    }
    if (cleanP == 'Ç') {
      if (step == 0) return '1. Adım: Dil Ucunu Damağa Bas 👅';
      if (step == 1) return '2. Adım: Dudaklarını Hafifçe Uzat 👄';
      return '3. Adım: Tren Gibi Patlat: Çuf Çuf! Ç! 🚂💥';
    }
    if (cleanP == 'C') {
      if (step == 0) return '1. Adım: Dil Ucunu Damağa Bas 👅';
      if (step == 1) return '2. Adım: Boğazında Sesi Titret ⚡';
      return '3. Adım: Kuş Gibi Güçle Patlat: Cik Cik! C! 🐥💥';
    }
    if (cleanP == 'M') {
      if (step == 0) return '1. Adım: Dudaklarını Birbirine Kapat 👄';
      if (step == 1) return '2. Adım: Boğazında Titreşimi Başlat ⚡';
      return '3. Adım: Sesi Burnundan Çıkar: Mmm! 🍦';
    }
    if (cleanP == 'N') {
      if (step == 0) return '1. Adım: Dil Ucunu Üst Diş Arkasına Bas 👅';
      if (step == 1) return '2. Adım: Ağzını Hafif Açık Tut 👄';
      return '3. Adım: Çan Gibi Burnundan Çınlat: Nnn! 🔔';
    }
    if (cleanP == 'L') {
      if (step == 0) return '1. Adım: Dil Ucunu Üst Diş Arkasına Kaldır 👅';
      if (step == 1) return '2. Adım: Dil Yanlarını Serbest Bırak 🌬️';
      return '3. Adım: Şarkı Söyler Gibi Akıt: La La! L! 🎶';
    }
    if (cleanP == 'Y') {
      if (step == 0) return '1. Adım: Gülümser Gibi Ağzını Aç 😊';
      if (step == 1) return '2. Adım: Dil Ortasını Damağa Yaklaştır 👅';
      return '3. Adım: Kaydıraktan Kayar Gibi Akıt: Yyy! 🛝✨';
    }
    if (cleanP == 'B') {
      if (step == 0) return '1. Adım: Dudaklarını Birbirine Sıkıca Bastır';
      if (step == 1) return '2. Adım: Boğazına Dokun ve Titreşimi Hisset';
      return '3. Adım: Dudaklarını Birden Açıp Sesi Patlat: B!';
    }
    if (step == 0) return '1. Adım: Dudaklarını Kapat';
    if (step == 1) return '2. Adım: Havayı Biriktir';
    return '3. Adım: "Pı" Diye Patlat!';
  }

  String _getStepNarration(int step) {
    final cleanP = widget.phoneme.replaceAll('/', '').trim().toUpperCase();
    if (cleanP == 'T') {
      if (step == 0) {
        return 'Kocaman gülümse! Dilinin ucunu üst dişlerinin arkasındaki damağa sımsıkı yapıştır. Dudaklarını kapatma!';
      }
      if (step == 1) {
        return 'Nefesini dilinin arkasında sakla! Sakın ses çıkarma, ses tellerin sessizce beklesin.';
      }
      return 'Dilini birden aşağı bırak ve saatin sesi gibi havayı fırlat: Tik-tak! Tık! T!';
    }
    if (cleanP == 'D') {
      if (step == 0) {
        return 'Kocaman gülümse! Dilinin ucunu üst dişlerinin hemen arkasındaki damağa sımsıkı bastır. Dudaklarını sakın kapatma!';
      }
      if (step == 1) {
        return 'Elini boğazına koy! Dudaklarını açmadan araba motoru gibi ses tellerini kuvvetlice titret: Hımm!';
      }
      return 'Dilini birden aşağı bırak ve araba kornası ile davul sesi gibi havayı fırlatarak patlat: Düt düt! Dan! D!';
    }
    if (cleanP == 'K') {
      if (step == 0) {
        return 'Ağzını rahatça aç. Dilinin ucunu alt ön dişlerinin arkasında, en aşağıda tut. Dil ucunu sakın yukarı kaldırma!';
      }
      if (step == 1) {
        return 'Dilinin arkasını yukarı kaldırıp yumuşak damağına sımsıkı bas! Havayı boğazında tut ve sessizce bekle!';
      }
      return 'Dilini birden aşağı bırak ve boğazındaki havayı neşeyle dışarı patlat: Kıkır kıkır! K! K! K!';
    }
    if (cleanP == 'G') {
      if (step == 0) {
        return 'Ağzını rahatça aç. Dilinin ucunu alt ön dişlerinin arkasında en aşağıda tutarken, dilinin arkasını damağına bastır!';
      }
      if (step == 1) {
        return 'Elini boğazına koy! Dudaklarını açmadan havayı boğazında tut ve ses tellerini titreterek vızıldat: Hımm!';
      }
      return 'Dilini birden serbest bırak ve boğazından tok, güçlü bir patlama ile sesi çıkar: G! G! G!';
    }
    if (cleanP == 'R') {
      if (step == 0) {
        return 'Ağzını hafifçe arala! Dilinin ucunu üst ön dişlerinin arkasındaki damağa yaklaştır. Dil ucun serbest kalsın!';
      }
      if (step == 1) {
        return 'Derin bir nefes al ve havayı dilinin ucuna doğru kuvvetlice üfle!';
      }
      return 'Yarış arabasının motoru gibi dil ucunu neşeyle titret: Rrr! R! R!';
    }
    if (cleanP == 'S') {
      if (step == 0) {
        return 'Kocaman gülümse ve dişlerini birbirine yaklaştır. Dilinin ucunu alt ön dişlerinin arkasında rahatça tut!';
      }
      if (step == 1) {
        return 'Dilini ağzının tabanında düz tut. Dişlerini aralama, serin bir nefes topla!';
      }
      return 'Dişlerinin arasından ince ve serin bir rüzgar gibi havayı üfle: Ssssss!';
    }
    if (cleanP == 'Z') {
      if (step == 0) {
        return 'Dişlerini birbirine yaklaştır. Dilinin ucunu alt ön dişlerinin arkasında rahatça tut!';
      }
      if (step == 1) {
        return 'Elini boğazına koy ve dişlerini açmadan arı gibi ses tellerinin titreşmesini hisset!';
      }
      return 'Dişlerinin arasından sesini titreterek sevimli bir arı gibi vızılda: Zzzzzzz!';
    }
    if (cleanP == 'Ş') {
      if (step == 0) {
        return 'Dudaklarını öne doğru yuvarlak yap ve hafifçe uzat. Dişlerini birbirine yaklaştır!';
      }
      if (step == 1) {
        return 'Dilinin yanlarını kaldırıp üst azı dişlerine yasla. Dilinin ortasında serbest bir hava yolu aç!';
      }
      return 'Dişlerinin arasından sıcak ve kuvvetli bir rüzgar gibi havayı dışarı üfle: Şşşşşş!';
    }
    if (cleanP == 'J') {
      if (step == 0) {
        return 'Dudaklarını öne doğru yuvarlak yap ve hafifçe uzat. Dişlerini birbirine yaklaştır!';
      }
      if (step == 1) {
        return 'Dilinin yanlarını kaldırıp üst azı dişlerine yasla. Elini boğazına koy ve ses tellerinin titreşmesini hisset!';
      }
      return 'Dişlerinin arasından ses tellerini titreterek araba motoru gibi güçlüce vızılda: Jjjjjjj!';
    }
    if (cleanP == 'F') {
      if (step == 0) {
        return 'Üst ön dişlerini sevimli bir tavşan gibi göster. Ağzını hafifçe arala!';
      }
      if (step == 1) {
        return 'Üst dişlerini alt dudağının iç kısmına hafifçe değdir. Dudaklarını sakın tamamen kapatma!';
      }
      return 'Dişlerin ile alt dudağının arasından serin ve kesintisiz bir fısıltı rüzgarı üfle: Fffffff!';
    }
    if (cleanP == 'V') {
      if (step == 0) {
        return 'Üst ön dişlerini hafifçe alt dudağının üzerine değdir!';
      }
      if (step == 1) {
        return 'Elini boğazına koy ve ses tellerini titreterek motor gibi çalıştırmaya başla!';
      }
      return 'Dişlerin ile alt dudağın arasından vızır vızır bir motosiklet gibi sesini titret: Vvvvvvv!';
    }
    if (cleanP == 'H') {
      if (step == 0) {
        return 'Ağzını doğal ve rahat bir şekilde hafifçe arala. Dilin tabanda serbest dursun!';
      }
      if (step == 1) {
        return 'Derin bir nefes al ve kış gününde ellerini ısıtır gibi avuçlarını ağzına yaklaştır!';
      }
      return 'Boğazından sıcak bir buğu çıkarır gibi sessizce ve yumuşakça üfle: Hhhhhhh!';
    }
    if (cleanP == 'Ç') {
      if (step == 0) {
        return 'Dilinin ucunu üst ön dişlerinin arkasındaki damağa sımsıkı yapıştır. Dudaklarını hafif öne uzat!';
      }
      if (step == 1) {
        return 'Nefesini dilinin arkasında topla ve biriken havayı sessizce hapset!';
      }
      return 'Dilini birden serbest bırakıp lokomotif gibi patlat: Çuf çuf! Ç! Ç!';
    }
    if (cleanP == 'C') {
      if (step == 0) {
        return 'Dilinin ucunu üst dişlerinin arkasındaki sert damağa sımsıkı yapıştır!';
      }
      if (step == 1) {
        return 'Boğazındaki ses tellerini kuvvetlice titret ve nefesini dilinin arkasında tut!';
      }
      return 'Dilini birden aşağı bırakarak güçlü ve neşeli bir ses patlat: Cik cik! C! C!';
    }
    if (cleanP == 'M') {
      if (step == 0) {
        return 'Dudaklarını birbirine hafifçe değdirip kapat. Ağzının içini rahat bırak!';
      }
      if (step == 1) {
        return 'Elini boğazına ve burnunun kenarına koy. Ses tellerini titreterek vızıldat!';
      }
      return 'Lezzetli bir dondurma yer gibi sesini burnundan çıkararak uğuldat: Mmmmmmm!';
    }
    if (cleanP == 'N') {
      if (step == 0) {
        return 'Ağzını hafifçe açık tut. Dilinin ucunu üst ön dişlerinin arkasındaki damağa yapıştır!';
      }
      if (step == 1) {
        return 'Havanın ağzından çıkmasına izin verme, havayı doğrudan burnuna doğru yönlendir!';
      }
      return 'Neşeli bir çan gibi sesini burnundan çınlatarak çıkar: Nnnnnnn!';
    }
    if (cleanP == 'L') {
      if (step == 0) {
        return 'Ağzını rahatça arala. Dilinin ucunu üst ön dişlerinin hemen arkasına nazikçe değdir!';
      }
      if (step == 1) {
        return 'Dilinin kenarlarını gevşek bırak, böylece havanın dilin iki yanından serbestçe akmasını sağla!';
      }
      return 'Şarkı söyler gibi dilini hafifçe titreterek sesi dışarı akıt: La la la! Lllll!';
    }
    if (cleanP == 'Y') {
      if (step == 0) {
        return 'Kocaman gülümse! Ağzını iki yana doğru aç ve dilinin ucunu alt dişlerinin arkasında tut!';
      }
      if (step == 1) {
        return 'Dilinin orta kısmını yukarı, damağına doğru tatlıca yaklaştır!';
      }
      return 'Kaydıraktan aşağı kayar gibi tatlı ve pürüzsüz bir kayma sesi çıkar: Yyyyyyy!';
    }
    if (cleanP == 'B') {
      if (step == 0) {
        return 'Dudaklarını birbirine sıkıca bastırıp kapat. Dilin ağzının tabanında rahat dursun.';
      }
      if (step == 1) {
        return 'Elini boğazına dokundur, dudaklarını açmadan hımm diyerek ses tellerinin titreşmesini hisset.';
      }
      return 'Dudaklarını birden açarak biriken sesi dışarı fırlat: B!';
    }
    if (step == 0) {
      return 'Dudaklarını birbirine sıkıca bastır. Dilin ağzının tabanında rahat dursun.';
    }
    if (step == 1) {
      return 'Nefesini dudaklarının arkasında topla.';
    }
    return 'Dudaklarını açarak havayı patlat: Pı!';
  }
}

/// Klinik Doğrulukta Tam Sagittal Ağız Kesiti (Artikülasyon Anatomisi)
class _PreciseClinicalAnatomyPainter extends CustomPainter {
  final String phoneme;
  final double progress;

  _PreciseClinicalAnatomyPainter({required this.phoneme, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final cleanP = phoneme.replaceAll('/', '').trim().toUpperCase();
    final center = Offset(size.width / 2 + 10, size.height / 2 + 8);
    final pulse = math.sin(progress * 28.0 * math.pi);
    final breath = math.sin(progress * 6.0 * math.pi);

    // B, T, D ve K sesi için özel klinik eşikler
    // ignore: unused_local_variable
    bool isStep1 = false;
    bool isStep2 = false;
    bool isPlosion = false;
    double stepProgress = 0.0;
    double openFactor = 0.0;

    if (cleanP == 'B') {
            isStep2 = progress >= 0.29 && progress < 0.68;
      isPlosion = progress >= 0.68;
      if (isStep2) stepProgress = (progress - 0.29) / 0.39;
      if (isPlosion) openFactor = ((progress - 0.68) / 0.32).clamp(0.0, 1.0);
    } else if (cleanP == 'T') {
      isStep1 = progress < 0.38;
      isStep2 = progress >= 0.38 && progress < 0.65;
      isPlosion = progress >= 0.65;
      if (isStep2) stepProgress = (progress - 0.38) / 0.27;
      if (isPlosion) openFactor = ((progress - 0.65) / 0.35).clamp(0.0, 1.0);
    } else if (cleanP == 'D') {
      isStep1 = progress < 0.36;
      isStep2 = progress >= 0.36 && progress < 0.69;
      isPlosion = progress >= 0.69;
      if (isStep2) stepProgress = (progress - 0.36) / 0.33;
      if (isPlosion) openFactor = ((progress - 0.69) / 0.31).clamp(0.0, 1.0);
    } else if (cleanP == 'K') {
      isStep1 = progress < 0.37;
      isStep2 = progress >= 0.37 && progress < 0.62;
      isPlosion = progress >= 0.62;
      if (isStep2) stepProgress = (progress - 0.37) / 0.25;
      if (isPlosion) openFactor = ((progress - 0.62) / 0.38).clamp(0.0, 1.0);
    } else if (cleanP == 'R') {
      isStep1 = progress < 0.45;
      isStep2 = progress >= 0.45 && progress < 0.68;
      isPlosion = progress >= 0.68;
      if (isStep2) stepProgress = (progress - 0.45) / 0.23;
      if (isPlosion) openFactor = ((progress - 0.68) / 0.32).clamp(0.0, 1.0);
    } else {
      isStep1 = progress < 0.33;
      isStep2 = progress >= 0.33 && progress < 0.68;
      isPlosion = progress >= 0.68;
      if (isStep2) stepProgress = (progress - 0.33) / 0.35;
      if (isPlosion) openFactor = ((progress - 0.68) / 0.32).clamp(0.0, 1.0);
    }

    double targetJawDrop = 25.0;
    if (cleanP == 'T' || cleanP == 'D') {
      targetJawDrop = 14.0;
    } else if (cleanP == 'K') {
      targetJawDrop = 16.0;
    } else if (cleanP == 'S' || cleanP == 'Z' || cleanP == 'Ş' || cleanP == 'J') {
      targetJawDrop = 4.0; // Diş seslerinde dişler bitişik
    } else if (cleanP == 'F' || cleanP == 'V') {
      targetJawDrop = 8.0; // Labiodental
    } else if (cleanP == 'Ç' || cleanP == 'C') {
      targetJawDrop = 7.0; // Durak-sürtünmeli (Affricate)
    } else if (cleanP == 'M') {
      targetJawDrop = 2.0; // Dudaklar kapalı/yakın
    } else if (cleanP == 'N' || cleanP == 'L') {
      targetJawDrop = 10.0; // Alveoler
    } else if (cleanP == 'H' || cleanP == 'Y') {
      targetJawDrop = 15.0; // Geniş açık / tatlı kayma
    } else if (cleanP == 'R') {
      targetJawDrop = 9.0;
    }
    final double jawDrop = (cleanP == 'T' || cleanP == 'D' || cleanP == 'K')
        ? (10.0 + openFactor * 6.0)
        : (openFactor * targetJawDrop);

    final double puffX = (isStep2 && (cleanP == 'B' || cleanP == 'P' || cleanP == 'M'))
        ? (2.2 + pulse.abs() * 2.2)
        : 0.0;

    // ── 1. AĞIZ VE BURUN BOŞLUĞU İÇ ZEMİNİ (Ağız Mukozası & Farenks) ────────────
    final cavityPaint = Paint()
      ..color = const Color(0xFFFFF0F2)
      ..style = PaintingStyle.fill;

    // Ağız içi ana boşluğu
    final mouthCavity = Path()
      ..moveTo(center.dx - 26, center.dy - 10)
      ..quadraticBezierTo(center.dx + 6, center.dy - 30, center.dx + 52, center.dy - 14) // Damak kemeri altı
      ..lineTo(center.dx + 62, center.dy + 48) // Boğaz arka duvarı
      ..lineTo(center.dx + 35, center.dy + 48) // Boyun önü
      ..quadraticBezierTo(center.dx + 15, center.dy + 35, center.dx - 24, center.dy + 14 + jawDrop)
      ..close();
    canvas.drawPath(mouthCavity, cavityPaint);

    // Burun Boşluğu (Nasal Cavity - Damağın üstündeki açık hava kanalı)
    final nasalPaint = Paint()
      ..color = const Color(0xFFE8F5E9)
      ..style = PaintingStyle.fill;
    final nasalPath = Path()
      ..moveTo(center.dx - 48, center.dy - 34)
      ..quadraticBezierTo(center.dx - 10, center.dy - 50, center.dx + 48, center.dy - 32)
      ..lineTo(center.dx + 50, center.dy - 20)
      ..quadraticBezierTo(center.dx + 8, center.dy - 32, center.dx - 30, center.dy - 20)
      ..close();
    canvas.drawPath(nasalPath, nasalPaint);

    final nasalBorder = Paint()
      ..color = const Color(0xFF81C784)
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;
    canvas.drawPath(nasalPath, nasalBorder);

    // ── 2. BAŞ VE YÜZ PROFİLİ (Alın, Burun ve Çene Kemik Hattı) ─────────────────
    final skinPaint = Paint()
      ..color = const Color(0xFF37474F)
      ..strokeWidth = 3.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final noseProfile = Path()
      ..moveTo(center.dx - 62, center.dy - 60)
      ..quadraticBezierTo(center.dx - 52, center.dy - 34, center.dx - 30, center.dy - 20); // Burun altı
    canvas.drawPath(noseProfile, skinPaint);

    final double chinY = center.dy + 18 + jawDrop;
    final chinProfile = Path()
      ..moveTo(center.dx - 34 - puffX, chinY)
      ..quadraticBezierTo(center.dx - 28, chinY + 16, center.dx - 46, chinY + 38) // Çene ucu
      ..lineTo(center.dx + 48, chinY + 38); // Boyun altı
    canvas.drawPath(chinProfile, skinPaint);

    // Yutak arka duvarı (Pharynx)
    final pharynxWall = Path()
      ..moveTo(center.dx + 52, center.dy - 45)
      ..quadraticBezierTo(center.dx + 65, center.dy + 5, center.dx + 62, center.dy + 48);
    canvas.drawPath(pharynxWall, skinPaint);

    // ── 3. TAM DAMAK YAPISI (SERT DAMAK RUGAE + YUMUŞAK DAMAK + KÜÇÜK DİL) ───────
    // A) Sert Damak Kemiği (Hard Palate - Maxilla kemik çatısı)
    final bonePaint = Paint()
      ..color = const Color(0xFF78909C)
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final hardPalatePath = Path()
      ..moveTo(center.dx - 24, center.dy - 10)
      ..quadraticBezierTo(center.dx + 6, center.dy - 30, center.dx + 34, center.dy - 22);
    canvas.drawPath(hardPalatePath, bonePaint);

    // B) Palatin Rugae (Sert damak önündeki anatomik doku tırtıkları - Alveolar bölge)
    final rugaePaint = Paint()
      ..color = const Color(0xFFE57373)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    for (int r = 0; r < 3; r++) {
      final double rx = (center.dx - 18) + (r * 6.5);
      final double ry = (center.dy - 13) - (r * 2.8);
      canvas.drawLine(Offset(rx, ry), Offset(rx + 2.5, ry + 3.0), rugaePaint);
    }

    // C) Yumuşak Damak (Soft Palate / Velum) ve Küçük Dil (Uvula)
    final velumFill = Paint()
      ..color = const Color(0xFFEF9A9A)
      ..style = PaintingStyle.fill;
    final velumStroke = Paint()
      ..color = const Color(0xFFC62828)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final uvulaPath = Path()
      ..moveTo(center.dx + 34, center.dy - 22)
      ..quadraticBezierTo(center.dx + 48, center.dy - 18, center.dx + 52, center.dy - 12) // Yumuşak damak kıvrımı
      ..quadraticBezierTo(center.dx + 54, center.dy - 6, center.dx + 51, center.dy - 4)  // Küçük dil ucu (uvula)
      ..quadraticBezierTo(center.dx + 47, center.dy - 6, center.dx + 45, center.dy - 15)
      ..close();
    canvas.drawPath(uvulaPath, velumFill);
    canvas.drawPath(uvulaPath, velumStroke);

    // ── 4. SES TELLERİ, EPİGLOTTİS VE BOĞAZ (LARYNX) ─────────────────────────────
    final isVoiced = ['B', 'D', 'G', 'V', 'Z', 'J', 'C', 'M', 'N', 'L', 'R', 'Y'].contains(cleanP);
    final throatPos = Offset(center.dx + 52, center.dy + 32);

    // Soluk borusu kıkırdak halkaları
    final tracheaPaint = Paint()
      ..color = const Color(0xFFB0BEC5)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(center.dx + 44, center.dy + 15), Offset(center.dx + 44, center.dy + 46), tracheaPaint);
    canvas.drawLine(Offset(center.dx + 58, center.dy + 10), Offset(center.dx + 58, center.dy + 46), tracheaPaint);

    // Epiglottis (Gırtlak Kapağı)
    final epiglottisPath = Path()
      ..moveTo(center.dx + 38, center.dy + 16)
      ..quadraticBezierTo(center.dx + 46, center.dy + 12, center.dx + 44, center.dy + 24);
    canvas.drawPath(epiglottisPath, Paint()..color = const Color(0xFFEF9A9A)..strokeWidth = 3.5..style = PaintingStyle.stroke..strokeCap = StrokeCap.round);

    // Ses Telleri Titreşimi (Ötümlü seslerde boğazda titreşen altın/turuncu dalgalar)
    if (isVoiced) {
      final double voicePulse = math.sin(progress * 42.0 * math.pi);
      final cordGlow = Paint()
        ..color = (isStep2 && cleanP == 'B')
            ? const Color(0xFFFF6D00).withAlpha((190 + voicePulse.abs() * 65).toInt().clamp(0, 255))
            : const Color(0xFFFF9800).withAlpha((140 + voicePulse.abs() * 95).toInt().clamp(0, 255))
        ..style = PaintingStyle.stroke
        ..strokeWidth = (isStep2 && cleanP == 'B') ? 3.2 : 2.2
        ..strokeCap = StrokeCap.round;

      for (int i = 0; i < 3; i++) {
        final double r = 5.0 + (i * 5.0) + (isStep2 ? voicePulse.abs() * 2.8 : 0.0);
        canvas.drawArc(
          Rect.fromCircle(center: throatPos, radius: r),
          -math.pi / 2,
          math.pi,
          false,
          cordGlow,
        );
      }

      // Adım 2: Çocuğa dokunsal rehber rozeti
      if (isStep2 && (cleanP == 'B' || cleanP == 'D')) {
        final badgePaint = Paint()..color = const Color(0xFFFF6D00)..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(throatPos.dx + 6, throatPos.dy - 8), 4.5, badgePaint);

        final textPainter = TextPainter(
          text: TextSpan(
            text: cleanP == 'D' ? '🚗 Motor Titreşimi (hımm...)' : '✋ Titreşim (hımm...)',
            style: const TextStyle(
              color: Color(0xFFD84315),
              fontSize: 9.5,
              fontWeight: FontWeight.w900,
              backgroundColor: Color(0xFFFFF3E0),
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        textPainter.paint(canvas, Offset(throatPos.dx - 22, throatPos.dy + 12));
      }
    }

    // ── 5. BELİRGİN DİŞLER (ÜST VE ALT BEYAZ KESİCİ DİŞLER & DİŞ ETİ) ─────────────
    final toothFill = Paint()..color = Colors.white;
    final toothBorder = Paint()
      ..color = const Color(0xFF607D8B)
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;
    final gumPaint = Paint()..color = const Color(0xFFFF8A80);

    // A) Üst Diş Eti & Kesici Diş
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(center.dx - 27, center.dy - 13, 12, 5),
        const Radius.circular(2.5),
      ),
      gumPaint,
    );
    final upperToothRect = Rect.fromLTWH(center.dx - 26, center.dy - 9, 9.0, 12.5);
    canvas.drawRRect(RRect.fromRectAndRadius(upperToothRect, const Radius.circular(2.5)), toothFill);
    canvas.drawRRect(RRect.fromRectAndRadius(upperToothRect, const Radius.circular(2.5)), toothBorder);
    // Mine ayrım çizgisi
    canvas.drawLine(
      Offset(center.dx - 21.5, center.dy - 8),
      Offset(center.dx - 21.5, center.dy + 3),
      Paint()..color = const Color(0xFFCFD8DC)..strokeWidth = 1.0,
    );

    // B) Alt Diş Eti & Kesici Diş (Çene ile Birlikte Açılır!)
    final double lowerToothY = center.dy + 3 + (jawDrop * 0.85);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(center.dx - 25, lowerToothY + 10, 11, 5),
        const Radius.circular(2.5),
      ),
      gumPaint,
    );
    final lowerToothRect = Rect.fromLTWH(center.dx - 24.5, lowerToothY, 8.5, 11.0);
    canvas.drawRRect(RRect.fromRectAndRadius(lowerToothRect, const Radius.circular(2.5)), toothFill);
    canvas.drawRRect(RRect.fromRectAndRadius(lowerToothRect, const Radius.circular(2.5)), toothBorder);
    // Alt mine çizgisi
    canvas.drawLine(
      Offset(center.dx - 20, lowerToothY + 1),
      Offset(center.dx - 20, lowerToothY + 9),
      Paint()..color = const Color(0xFFCFD8DC)..strokeWidth = 1.0,
    );

    // ── 6. DİNAMİK VE DOĞAL DİL KASI (BÜTÜN DİL ANATOMİSİ) ──────────────────────
    final tongueFill = Paint()..color = const Color(0xFFFF8A80);
    final tongueStroke = Paint()
      ..color = const Color(0xFFC62828)
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke;

    final tonguePath = Path();
    tonguePath.moveTo(center.dx + 40, center.dy + 26);

    if (cleanP == 'T' || cleanP == 'D') {
      if (!isPlosion) {
        // 1. ve 2. Adım: Dil ucu sert damağın önündeki rugae/alveoler kabartıya TAM YAPIŞIKTIR (hava sızdırmaz)
        tonguePath.quadraticBezierTo(
          center.dx + 16,
          center.dy + 8,
          center.dx - 18,
          center.dy - 10,
        );
        tonguePath.quadraticBezierTo(center.dx + 2, center.dy + 28, center.dx + 40, center.dy + 26);
      } else {
        // 3. Adım: Patlama anında dil ucu aniden damağından aşağıya düşer!
        final double drop = openFactor * 22.0;
        tonguePath.quadraticBezierTo(
          center.dx + 16,
          center.dy + 10 + (drop * 0.3),
          center.dx - 16,
          center.dy - 10 + drop,
        );
        tonguePath.quadraticBezierTo(center.dx + 2, center.dy + 28, center.dx + 40, center.dy + 26);
      }
    } else if (cleanP == 'N' || cleanP == 'L') {
      // Dil ucu sert damağın önündeki rugae/alveolar bölgeye yapışır
      tonguePath.quadraticBezierTo(
        center.dx + 16,
        center.dy + 12,
        center.dx - 18,
        center.dy - 8,
      );
      tonguePath.quadraticBezierTo(center.dx + 2, center.dy + 28, center.dx + 40, center.dy + 26);
    } else if (cleanP == 'K' || cleanP == 'G') {
      if (!isPlosion) {
        // Dil arkası yumuşak damağa sımsıkı yapışır (Velar kapanma)
        tonguePath.quadraticBezierTo(
          center.dx + 28,
          center.dy - 17,
          center.dx - 16,
          lowerToothY - 1,
        );
        tonguePath.quadraticBezierTo(center.dx + 8, center.dy + 28, center.dx + 40, center.dy + 26);
      } else {
        // 3. Adım: Dil arkası aniden aşağı düşer, hava yolu patlayarak açılır!
        final double drop = openFactor * 22.0;
        tonguePath.quadraticBezierTo(
          center.dx + 26,
          center.dy - 17 + drop,
          center.dx - 16,
          lowerToothY - 1,
        );
        tonguePath.quadraticBezierTo(center.dx + 8, center.dy + 28, center.dx + 40, center.dy + 26);
      }
    } else if (cleanP == 'S' || cleanP == 'Z' || cleanP == 'Ş' || cleanP == 'J') {
      // Dil ucu alt kesici dişin arkasında durur
      tonguePath.quadraticBezierTo(
        center.dx + 12,
        center.dy + 3,
        center.dx - 16,
        lowerToothY - 1,
      );
      tonguePath.quadraticBezierTo(center.dx + 8, center.dy + 28, center.dx + 40, center.dy + 26);
    } else if (cleanP == 'R') {
      // R sesi: Dil ucu üst diş yuvasına kalkık, kenarlar yan dişlere yapışık, dil ucu flutter yapar
      final double rFlutter = (isStep2 || isPlosion)
          ? (math.sin(progress * 48.0 * math.pi) * 3.5)
          : 0.0;
      tonguePath.quadraticBezierTo(
        center.dx + 16,
        center.dy + 8,
        center.dx - 18,
        center.dy - 7 + rFlutter,
      );
      tonguePath.quadraticBezierTo(center.dx + 2, center.dy + 26, center.dx + 40, center.dy + 26);
    } else {
      // /b/, /p/, /m/: Dil tamamen nötrdür, ağız tabanında serbest ve düz yatar
      final tongueYOffset = breath * 1.5;
      tonguePath.quadraticBezierTo(
        center.dx + 16,
        center.dy + 14 + tongueYOffset,
        center.dx - 12,
        center.dy + 17 + tongueYOffset,
      );
      tonguePath.quadraticBezierTo(center.dx + 10, center.dy + 32, center.dx + 40, center.dy + 26);
    }

    canvas.drawPath(tonguePath, tongueFill);
    canvas.drawPath(tonguePath, tongueStroke);

    // ── 7. DOLGUN VE BELİRGİN DUDAKLAR (ETLİ PEMBE-KIRMIZI ANATOMİK DUDAKLAR) ───
    final lipFill = Paint()..color = const Color(0xFFE57373);
    final lipStroke = Paint()
      ..color = const Color(0xFFB71C1C)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // A) ÜST DUDAK
    final upperLipPath = Path()
      ..moveTo(center.dx - 30, center.dy - 20)
      ..quadraticBezierTo(center.dx - 48, center.dy - 9, center.dx - 38, center.dy - 1)
      ..quadraticBezierTo(center.dx - 29, center.dy - 1, center.dx - 27, center.dy - 6)
      ..close();
    canvas.drawPath(upperLipPath, lipFill);
    canvas.drawPath(upperLipPath, lipStroke);

    // B) ALT DUDAK (Çene ile Birlikte Açılır / Kapanır)
    final double lowerLipContactY = (cleanP == 'T' || cleanP == 'D' || cleanP == 'K')
        ? (center.dy - 1 + jawDrop)
        : (isPlosion ? (center.dy - 1 + jawDrop) : (center.dy - 1));
    final double lowerLipBulgeX = center.dx - 38 - puffX;

    final lowerLipPath = Path()
      ..moveTo(center.dx - 28, lowerLipContactY)
      ..quadraticBezierTo(lowerLipBulgeX, lowerLipContactY + 7, center.dx - 33, lowerLipContactY + 17)
      ..quadraticBezierTo(center.dx - 25, lowerLipContactY + 14, center.dx - 24, lowerToothY + 3)
      ..close();
    canvas.drawPath(lowerLipPath, lipFill);
    canvas.drawPath(lowerLipPath, lipStroke);

    // ── 8. DUDAK / ALVEOL TEMASI, BASINÇ VE SES PATLAMASI ──────────────────────
    if (cleanP == 'K') {
      if (!isPlosion) {
        // 1. ve 2. Adım: Dil arkası ve yumuşak damak temas noktası
        final velarSeal = Paint()
          ..color = const Color(0xFFFF5722).withAlpha((170 + pulse.abs() * 85).toInt().clamp(0, 255))
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(center.dx + 28, center.dy - 17), 6.0, velarSeal);

        final sealBorder = Paint()
          ..color = const Color(0xFFE64A19)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0;
        canvas.drawCircle(Offset(center.dx + 28, center.dy - 17), 7.0, sealBorder);

        // Rozet: Dil Arkası Damağa Basılı
        final textPainter = TextPainter(
          text: const TextSpan(
            text: '👅 Dil Arkası Damağa Basılı',
            style: TextStyle(
              color: Color(0xFFBF360C),
              fontSize: 9.0,
              fontWeight: FontWeight.w900,
              backgroundColor: Color(0xFFFFF3E0),
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        textPainter.paint(canvas, Offset(center.dx + 6, center.dy - 32));

        // 2. Adım: Boğazda hava basıncı birikmesi (Hava tıkacı)
        if (isStep2) {
          final pressurePaint = Paint()
            ..color = const Color(0xFFFF9800).withAlpha((170 + pulse.abs() * 85).toInt().clamp(0, 255))
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.2;

          final double r1 = 8.0 + pulse.abs() * 4.0 + stepProgress * 6.0;
          final double r2 = 14.0 + pulse.abs() * 6.0 + stepProgress * 8.0;
          canvas.drawCircle(Offset(center.dx + 42, center.dy + 6), r1, pressurePaint);
          canvas.drawCircle(Offset(center.dx + 42, center.dy + 6), r2, pressurePaint..strokeWidth = 1.4);

          final badgePainter = TextPainter(
            text: const TextSpan(
              text: '💨 Boğazda Hava Tıkacı (Sessiz)',
              style: TextStyle(
                color: Color(0xFFE65100),
                fontSize: 8.5,
                fontWeight: FontWeight.w900,
                backgroundColor: Color(0xFFFFF8E1),
              ),
            ),
            textDirection: TextDirection.ltr,
          )..layout();
          badgePainter.paint(canvas, Offset(center.dx + 12, center.dy + 22));
        }
      } else {
        // 3. Adım: Dil arkası açılır, ağızdan çıtır mısır patlaması ve K fırlar!
        final blastProgress = openFactor;
        final blastColor = const Color(0xFFFF9100)
            .withAlpha(((1.0 - blastProgress) * 255).toInt().clamp(0, 255));
        final blastPaint = Paint()
          ..color = blastColor
          ..strokeWidth = 3.2
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke;

        for (int w = 0; w < 3; w++) {
          final double waveOffset = blastProgress * 48.0 + (w * 16.0);
          final double bx = center.dx + 15 - waveOffset;
          final double by = center.dy - 2;
          final double h = 10.0 + (w * 6.0) + (blastProgress * 10.0);

          final wavePath = Path()
            ..moveTo(bx, by - h)
            ..quadraticBezierTo(bx - (8 + w * 4), by, bx, by + h);
          canvas.drawPath(wavePath, blastPaint..strokeWidth = 3.0 - (w * 0.6));
        }

        // Çıtır mısır patlama kıvılcımları (Altın sarısı / turuncu)
        final sparkPaint = Paint()
          ..color = const Color(0xFFFFD600).withAlpha(((1.0 - blastProgress) * 255).toInt().clamp(0, 255));
        for (int i = 0; i < 8; i++) {
          final double angle = -0.8 + (i * 0.22);
          final double dist = 14.0 + blastProgress * 55.0 + (i * 3);
          final double dx = center.dx + 18 - (dist * math.cos(angle));
          final double dy = center.dy - 2 + (dist * math.sin(angle));
          canvas.drawCircle(Offset(dx, dy), 3.0, sparkPaint);
        }

        final popText = TextPainter(
          text: const TextSpan(
            text: '💥 "Kıkır Kıkır! K!" Patlaması!',
            style: TextStyle(
              color: Color(0xFFD84315),
              fontSize: 10.5,
              fontWeight: FontWeight.w900,
              backgroundColor: Color(0xFFFFF3E0),
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        popText.paint(canvas, Offset(center.dx - 32, center.dy - 28));
      }
    } else if (cleanP == 'T' || cleanP == 'D') {
      if (!isPlosion) {
        // 1. ve 2. Adım: Alveoler Temas Noktası (Dil ucu sert damağa basılı, dudaklar aralık)
        final alveolarSeal = Paint()
          ..color = const Color(0xFFFF1744).withAlpha((160 + pulse.abs() * 95).toInt().clamp(0, 255))
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(center.dx - 18, center.dy - 10), 5.5, alveolarSeal);

        final sealBorder = Paint()
          ..color = const Color(0xFFD50000)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0;
        canvas.drawCircle(Offset(center.dx - 18, center.dy - 10), 6.5, sealBorder);

        // 2. Adım: Dil arkasında hava basıncı birikmesi
        if (isStep2) {
          final pressurePaint = Paint()
            ..color = (cleanP == 'D' ? const Color(0xFFFF6D00) : const Color(0xFFFF9800))
                .withAlpha((160 + pulse.abs() * 95).toInt().clamp(0, 255))
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.4;

          final double r1 = 8.0 + pulse.abs() * 4.0 + stepProgress * 6.0;
          final double r2 = 15.0 + pulse.abs() * 6.0 + stepProgress * 8.0;
          canvas.drawCircle(Offset(center.dx - 2, center.dy + 2), r1, pressurePaint);
          canvas.drawCircle(Offset(center.dx - 2, center.dy + 2), r2, pressurePaint..strokeWidth = 1.4);

          final arrowPaint = Paint()
            ..color = const Color(0xFFE65100)
            ..strokeWidth = 2.2
            ..style = PaintingStyle.stroke;
          canvas.drawLine(Offset(center.dx + 12, center.dy + 4), Offset(center.dx - 8, center.dy - 5), arrowPaint);
          canvas.drawLine(Offset(center.dx - 3, center.dy - 8), Offset(center.dx - 8, center.dy - 5), arrowPaint);
          canvas.drawLine(Offset(center.dx - 2, center.dy), Offset(center.dx - 8, center.dy - 5), arrowPaint);
        }
      } else {
        // 3. Adım: Dil aniden düşer, dişlerin arasından keskin hava patlaması fırlar!
        final blastProgress = openFactor;
        final blastColor = (cleanP == 'D' ? const Color(0xFFFF6D00) : const Color(0xFF00ACC1))
            .withAlpha(((1.0 - blastProgress) * 255).toInt().clamp(0, 255));
        final blastPaint = Paint()
          ..color = blastColor
          ..strokeWidth = 3.2
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke;

        for (int w = 0; w < 3; w++) {
          final double waveOffset = blastProgress * 42.0 + (w * 16.0);
          final double bx = center.dx - 36 - waveOffset;
          final double by = center.dy + 4;
          final double h = 12.0 + (w * 7.0) + (blastProgress * 12.0);

          final wavePath = Path()
            ..moveTo(bx, by - h)
            ..quadraticBezierTo(bx - (9 + w * 4), by, bx, by + h);
          canvas.drawPath(wavePath, blastPaint..strokeWidth = 3.2 - (w * 0.6));
        }

        final burstDotPaint = Paint()
          ..color = (cleanP == 'D' ? const Color(0xFFFFD600) : const Color(0xFF00E5FF))
              .withAlpha(((1.0 - blastProgress) * 255).toInt().clamp(0, 255));
        for (int i = 0; i < 7; i++) {
          final double angle = -0.7 + (i * 0.22);
          final double dist = 16.0 + blastProgress * 52.0 + (i * 3);
          final double dx = center.dx - 34 - (dist * math.cos(angle));
          final double dy = center.dy + 4 + (dist * math.sin(angle));
          canvas.drawCircle(Offset(dx, dy), 2.8, burstDotPaint);
        }
      }
    } else if (!isPlosion) {
      // 1. ve 2. Adım: Dudaklar birbirine sıkıca basılı (Bilabial kapanma çizgisi)
      final contactLine = Paint()
        ..color = const Color(0xFFD50000)
        ..strokeWidth = 3.2
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        Offset(center.dx - 39 - puffX, center.dy - 1),
        Offset(center.dx - 27, center.dy - 1),
        contactLine,
      );

      final glowPaint = Paint()
        ..color = const Color(0xFFFF1744).withAlpha((130 + pulse.abs() * 110).toInt().clamp(0, 255))
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(center.dx - 34 - puffX, center.dy - 1), 5.0, glowPaint);

      // 2. Adım: Dudak arkasında basınç birikmesi
      if (isStep2) {
        final pressurePaint = Paint()
          ..color = const Color(0xFFFF9800).withAlpha((150 + pulse.abs() * 105).toInt().clamp(0, 255))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.4;

        final double r1 = 8.0 + pulse.abs() * 4.0 + stepProgress * 6.0;
        final double r2 = 14.0 + pulse.abs() * 6.0 + stepProgress * 8.0;
        canvas.drawCircle(Offset(center.dx - 25, center.dy + 1), r1, pressurePaint);
        canvas.drawCircle(Offset(center.dx - 25, center.dy + 1), r2, pressurePaint..strokeWidth = 1.4);

        final arrowPaint = Paint()
          ..color = const Color(0xFFE65100)
          ..strokeWidth = 2.2
          ..style = PaintingStyle.stroke;
        canvas.drawLine(Offset(center.dx - 13, center.dy + 1), Offset(center.dx - 27, center.dy + 1), arrowPaint);
        canvas.drawLine(Offset(center.dx - 23, center.dy - 3), Offset(center.dx - 27, center.dy + 1), arrowPaint);
        canvas.drawLine(Offset(center.dx - 23, center.dy + 5), Offset(center.dx - 27, center.dy + 1), arrowPaint);
      }
    } else {
      // 3. Adım: DUDAKLAR ANİDEN AÇILIR VE BÜYÜK PATLAMA GERÇEKLEŞİR!
      final blastProgress = openFactor;
      final blastColor = const Color(0xFF0288D1).withAlpha(((1.0 - blastProgress) * 255).toInt().clamp(0, 255));
      final blastPaint = Paint()
        ..color = blastColor
        ..strokeWidth = 3.2
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      for (int w = 0; w < 3; w++) {
        final double waveOffset = blastProgress * 40.0 + (w * 15.0);
        final double bx = center.dx - 40 - waveOffset;
        final double by = center.dy + 5;
        final double h = 14.0 + (w * 7.0) + (blastProgress * 12.0);

        final wavePath = Path()
          ..moveTo(bx, by - h)
          ..quadraticBezierTo(bx - (9 + w * 4), by, bx, by + h);
        canvas.drawPath(wavePath, blastPaint..strokeWidth = 3.2 - (w * 0.6));
      }

      final burstDotPaint = Paint()
        ..color = const Color(0xFF00B0FF).withAlpha(((1.0 - blastProgress) * 255).toInt().clamp(0, 255));
      for (int i = 0; i < 7; i++) {
        final double angle = -0.7 + (i * 0.22);
        final double dist = 16.0 + blastProgress * 52.0 + (i * 3);
        final double dx = center.dx - 38 - (dist * math.cos(angle));
        final double dy = center.dy + 5 + (dist * math.sin(angle));
        canvas.drawCircle(Offset(dx, dy), 2.8, burstDotPaint);
      }
    }

    // ── 9. ANATOMİK REHBER ETİKETLERİ (Sert Damak, Küçük Dil vb.) ────────────────
    _drawAnatomyLabel(canvas, Offset(center.dx - 4, center.dy - 34), 'Sert Damak');
    if (cleanP == 'T') {
      _drawAnatomyLabel(canvas, Offset(center.dx - 38, center.dy - 18), 'Alveol (Diş Eti)');
      _drawAnatomyLabel(canvas, Offset(center.dx - 28, center.dy + 6), 'Dil Ucu');
    }
    _drawAnatomyLabel(canvas, Offset(center.dx + 40, center.dy - 12), 'Küçük Dil');
    _drawAnatomyLabel(canvas, Offset(center.dx + 8, center.dy + 38), 'Dil');
  }

  void _drawAnatomyLabel(Canvas canvas, Offset pos, String text) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Color(0xFF546E7A),
          fontSize: 8.5,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(canvas, pos);
  }

  @override
  bool shouldRepaint(covariant _PreciseClinicalAnatomyPainter oldDelegate) => true;
}
