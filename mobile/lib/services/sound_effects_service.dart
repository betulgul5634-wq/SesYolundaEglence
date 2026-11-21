import 'package:flutter/foundation.dart';
// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:js' as js;

/// 🔊 KLİNİK VE OYUN İÇİ GERÇEK ZAMANLI SES EFEKTLERİ MOTORU (SFX)
/// Web Audio API sentezleyicisi ile sıfır dosya bağımlılığı ve 0ms gecikmeyle
/// pozitif pekiştirme sesleri (Ding, Yıldız çanı, Konfeti alkışı, Pop) üretir.
class SoundEffectsService {
  static final SoundEffectsService _instance = SoundEffectsService._internal();
  factory SoundEffectsService() => _instance;
  SoundEffectsService._internal();

  /// Başarı / Doğru Cevap Çanı (Ding! 🔔)
  void playSuccessDing() {
    if (!kIsWeb) return;
    try {
      js.context.callMethod('eval', ["""
        (function() {
          try {
            const ctx = new (window.AudioContext || window.webkitAudioContext)();
            const osc = ctx.createOscillator();
            const gain = ctx.createGain();
            osc.type = 'sine';
            osc.frequency.setValueAtTime(587.33, ctx.currentTime); // D5
            osc.frequency.exponentialRampToValueAtTime(880, ctx.currentTime + 0.15); // A5
            gain.gain.setValueAtTime(0.3, ctx.currentTime);
            gain.gain.exponentialRampToValueAtTime(0.01, ctx.currentTime + 0.4);
            osc.connect(gain);
            gain.connect(ctx.destination);
            osc.start();
            osc.stop(ctx.currentTime + 0.4);
          } catch(e) {}
        })();
      """]);
    } catch (_) {}
  }

  /// Buton / Balon Dokunma Sesi (Pop! 🎈)
  void playPopSound() => playPop();

  void playPop() {
    if (!kIsWeb) return;
    try {
      js.context.callMethod('eval', ["""
        (function() {
          try {
            const ctx = new (window.AudioContext || window.webkitAudioContext)();
            const osc = ctx.createOscillator();
            const gain = ctx.createGain();
            osc.type = 'triangle';
            osc.frequency.setValueAtTime(400, ctx.currentTime);
            osc.frequency.exponentialRampToValueAtTime(120, ctx.currentTime + 0.08);
            gain.gain.setValueAtTime(0.25, ctx.currentTime);
            gain.gain.exponentialRampToValueAtTime(0.01, ctx.currentTime + 0.08);
            osc.connect(gain);
            gain.connect(ctx.destination);
            osc.start();
            osc.stop(ctx.currentTime + 0.08);
          } catch(e) {}
        })();
      """]);
    } catch (_) {}
  }

  /// Elmas / Yıldız Toplama Çıngırağı (Coin Chime 💎)
  void playCoinChime() {
    if (!kIsWeb) return;
    try {
      js.context.callMethod('eval', ["""
        (function() {
          try {
            const ctx = new (window.AudioContext || window.webkitAudioContext)();
            [987.77, 1318.51].forEach((freq, idx) => {
              const osc = ctx.createOscillator();
              const gain = ctx.createGain();
              osc.type = 'sine';
              osc.frequency.value = freq;
              gain.gain.setValueAtTime(0.2, ctx.currentTime + idx * 0.09);
              gain.gain.exponentialRampToValueAtTime(0.01, ctx.currentTime + idx * 0.09 + 0.25);
              osc.connect(gain);
              gain.connect(ctx.destination);
              osc.start(ctx.currentTime + idx * 0.09);
              osc.stop(ctx.currentTime + idx * 0.09 + 0.25);
            });
          } catch(e) {}
        })();
      """]);
    } catch (_) {}
  }

  /// Zafer Fanfarı / Bölüm Bitirme (Fanfare 🏆)
  void playVictoryFanfare() {
    if (!kIsWeb) return;
    try {
      js.context.callMethod('eval', ["""
        (function() {
          try {
            const ctx = new (window.AudioContext || window.webkitAudioContext)();
            const notes = [523.25, 659.25, 783.99, 1046.50]; // C5, E5, G5, C6
            notes.forEach((freq, idx) => {
              const osc = ctx.createOscillator();
              const gain = ctx.createGain();
              osc.type = 'triangle';
              osc.frequency.value = freq;
              const start = ctx.currentTime + idx * 0.12;
              const dur = (idx === notes.length - 1) ? 0.6 : 0.18;
              gain.gain.setValueAtTime(0.25, start);
              gain.gain.exponentialRampToValueAtTime(0.01, start + dur);
              osc.connect(gain);
              gain.connect(ctx.destination);
              osc.start(start);
              osc.stop(start + dur);
            });
          } catch(e) {}
        })();
      """]);
    } catch (_) {}
  }

  /// 🥁 RİTİMLİ TEKERLEME & ŞARKI İÇİN CANLI MÜZİK VE VURUŞ ALTYAPISI (BPM tabanlı)
  void startRhythmBeat({double bpm = 112}) {
    if (!kIsWeb) return;
    try {
      js.context.callMethod('eval', ["""
        (function() {
          if (window._rhythmLoopActive) {
            try { window._rhythmLoopStop(); } catch(e) {}
          }
          try {
            const AudioContext = window.AudioContext || window.webkitAudioContext;
            const ctx = new AudioContext();
            if (ctx.state === 'suspended') {
              ctx.resume();
            }
            window._rhythmCtx = ctx;
            window._rhythmLoopActive = true;
            
            const bpmVal = $bpm;
            const beatTime = 60.0 / bpmVal;
            const startTime = ctx.currentTime + 0.05;
            
            const masterGain = ctx.createGain();
            masterGain.gain.setValueAtTime(0.24, ctx.currentTime);
            masterGain.connect(ctx.destination);
            
            function playKick(time) {
              const osc = ctx.createOscillator();
              const gain = ctx.createGain();
              osc.type = 'sine';
              osc.frequency.setValueAtTime(130, time);
              osc.frequency.exponentialRampToValueAtTime(42, time + 0.12);
              gain.gain.setValueAtTime(0.75, time);
              gain.gain.exponentialRampToValueAtTime(0.001, time + 0.18);
              osc.connect(gain);
              gain.connect(masterGain);
              osc.start(time);
              osc.stop(time + 0.2);
            }
            
            function playClap(time) {
              const bufferSize = Math.floor(ctx.sampleRate * 0.07);
              const buffer = ctx.createBuffer(1, bufferSize, ctx.sampleRate);
              const output = buffer.getChannelData(0);
              for (let i = 0; i < bufferSize; i++) {
                output[i] = Math.random() * 2 - 1;
              }
              const whiteNoise = ctx.createBufferSource();
              whiteNoise.buffer = buffer;
              
              const filter = ctx.createBiquadFilter();
              filter.type = 'bandpass';
              filter.frequency.value = 1200;
              filter.Q.value = 1.8;
              
              const gain = ctx.createGain();
              gain.gain.setValueAtTime(0.5, time);
              gain.gain.exponentialRampToValueAtTime(0.01, time + 0.1);
              
              whiteNoise.connect(filter);
              filter.connect(gain);
              gain.connect(masterGain);
              
              const osc = ctx.createOscillator();
              const oscGain = ctx.createGain();
              osc.type = 'triangle';
              osc.frequency.setValueAtTime(260, time);
              osc.frequency.exponentialRampToValueAtTime(130, time + 0.05);
              oscGain.gain.setValueAtTime(0.3, time);
              oscGain.gain.exponentialRampToValueAtTime(0.01, time + 0.05);
              osc.connect(oscGain);
              oscGain.connect(masterGain);
              
              whiteNoise.start(time);
              whiteNoise.stop(time + 0.1);
              osc.start(time);
              osc.stop(time + 0.05);
            }
            
            function playWoodblock(time, high) {
              const osc = ctx.createOscillator();
              const gain = ctx.createGain();
              osc.type = 'sine';
              osc.frequency.value = high ? 950 : 700;
              gain.gain.setValueAtTime(0.18, time);
              gain.gain.exponentialRampToValueAtTime(0.001, time + 0.04);
              osc.connect(gain);
              gain.connect(masterGain);
              osc.start(time);
              osc.stop(time + 0.045);
            }
            
            function playMarimba(time, freq) {
              const osc = ctx.createOscillator();
              const gain = ctx.createGain();
              osc.type = 'triangle';
              osc.frequency.value = freq;
              gain.gain.setValueAtTime(0.2, time);
              gain.gain.exponentialRampToValueAtTime(0.001, time + 0.22);
              osc.connect(gain);
              gain.connect(masterGain);
              osc.start(time);
              osc.stop(time + 0.25);
            }
            
            const melody = [261.63, 329.63, 392.00, 440.00, 523.25, 440.00, 392.00, 329.63];
            let currentStep = 0;
            let nextNoteTime = startTime;
            const scheduleAheadTime = 0.2;
            const lookahead = 25.0;
            
            function nextNote() {
              nextNoteTime += (beatTime / 2);
              currentStep = (currentStep + 1) % 16;
            }
            
            function scheduleStep(step, time) {
              const beatInMeasure = step % 8;
              if (beatInMeasure === 0 || beatInMeasure === 4) {
                playKick(time);
              }
              if (beatInMeasure === 2 || beatInMeasure === 6) {
                playClap(time);
              }
              if (beatInMeasure % 2 === 1) {
                playWoodblock(time, beatInMeasure === 7);
              }
              if (beatInMeasure === 0) playMarimba(time, melody[Math.floor(step / 2) % melody.length]);
              if (beatInMeasure === 4) playMarimba(time, melody[(Math.floor(step / 2) + 2) % melody.length]);
            }
            
            let timerId = null;
            function scheduler() {
              if (!window._rhythmLoopActive) return;
              while (nextNoteTime < ctx.currentTime + scheduleAheadTime) {
                scheduleStep(currentStep, nextNoteTime);
                nextNote();
              }
              timerId = setTimeout(scheduler, lookahead);
            }
            scheduler();
            
            window._rhythmLoopStop = function() {
              window._rhythmLoopActive = false;
              if (timerId) clearTimeout(timerId);
              try {
                masterGain.gain.setValueAtTime(masterGain.gain.value, ctx.currentTime);
                masterGain.gain.exponentialRampToValueAtTime(0.0001, ctx.currentTime + 0.25);
                setTimeout(() => {
                  try { ctx.close(); } catch(e) {}
                }, 300);
              } catch(e) {}
            };
          } catch(e) {
            console.error("Rhythm beat error:", e);
          }
        })();
      """]);
    } catch (_) {}
  }

  /// ⏹️ RİTİM VURUŞUNU DURDUR
  void stopRhythmBeat() {
    if (!kIsWeb) return;
    try {
      js.context.callMethod('eval', ["""
        (function() {
          if (window._rhythmLoopStop) {
            try { window._rhythmLoopStop(); } catch(e) {}
          }
        })();
      """]);
    } catch (_) {}
  }
}
