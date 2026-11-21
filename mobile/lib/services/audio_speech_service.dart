import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;
// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:js' as js;

class LetterAnalysisItem {
  final String targetChar;
  final String spokenChar;
  final bool isMatch;

  LetterAnalysisItem({
    required this.targetChar,
    required this.spokenChar,
    required this.isMatch,
  });
}

class StoryWordItem {
  final String word;
  final String spokenAs;
  final bool isCorrect;
  final bool hasTargetPhoneme;

  StoryWordItem({
    required this.word,
    required this.spokenAs,
    required this.isCorrect,
    required this.hasTargetPhoneme,
  });
}

class StoryEvaluationData {
  final int accuracyScore;
  final int totalWords;
  final int correctWordsCount;
  final List<String> targetPhonemeErrorWords;
  final List<String> mispronouncedWords;
  final List<StoryWordItem> wordEvaluations;
  final String feedbackMessage;
  final String therapistCorrectionPrompt;
  final int starsEarned;
  final String recognizedText;

  StoryEvaluationData({
    required this.accuracyScore,
    required this.totalWords,
    required this.correctWordsCount,
    required this.targetPhonemeErrorWords,
    required this.mispronouncedWords,
    required this.wordEvaluations,
    required this.feedbackMessage,
    required this.therapistCorrectionPrompt,
    required this.starsEarned,
    required this.recognizedText,
  });
}

class SpeechEvaluationResult {
  final String recognizedText;
  final String targetText;
  final int score;
  final int errorPercentage;
  final bool isMatched;
  final String feedback;
  final String errorType;
  final String errorDetail;
  final String articulatoryCorrection;
  final List<LetterAnalysisItem> letterAnalysis;
  final String? error;

  SpeechEvaluationResult({
    required this.recognizedText,
    required this.targetText,
    required this.score,
    this.errorPercentage = 0,
    required this.isMatched,
    required this.feedback,
    this.errorType = '',
    this.errorDetail = '',
    this.articulatoryCorrection = '',
    this.letterAnalysis = const [],
    this.error,
  });
}

class AudioSpeechService {
  static final AudioSpeechService _instance = AudioSpeechService._internal();
  factory AudioSpeechService() => _instance;
  AudioSpeechService._internal() {
    if (kIsWeb) {
      html.window.addEventListener('mic_volume', (event) {
        try {
          final vol = (js.context['peakSpeechVolume'] as num?)?.toInt() ?? 0;
          if (!_volumeController.isClosed) {
            _volumeController.add(vol);
          }
        } catch (_) {}
      });
    }
  }

  static String get backendUrl {
    if (kIsWeb) {
      final loc = html.window.location;
      if (loc.protocol == 'https:' || loc.port == '8080') {
        return loc.origin;
      }
      final host = loc.hostname;
      if (host != null && host.isNotEmpty) {
        return 'http://$host:8000';
      }
      return 'http://127.0.0.1:8000';
    }
    return 'http://10.0.2.2:8000';
  }
  html.AudioElement? _currentAudio;
  final Map<String, html.AudioElement> _preloadedAudios = {};
  final Map<String, String> _blobUrlCache = {};
  final StreamController<int> _volumeController = StreamController<int>.broadcast();
  Stream<int> get onMicVolume => _volumeController.stream;

  /// Tarayıcıda Mikrofon İzni İsteme (Doğrudan native dart:html getUserMedia)
  Future<bool> requestMicrophonePermission() async {
    if (!kIsWeb) return true;
    // Zaten önceden izin alındıysa tekrar test akışı açmaya gerek yok
    if (kIsWeb) {
      try {
        final alreadyGranted = js.context['hasMicPermission'];
        if (alreadyGranted == true) return true;
      } catch (_) {}
    }
    try {
      final stream = await html.window.navigator.mediaDevices?.getUserMedia({'audio': true});
      if (stream != null) {
        stream.getTracks().forEach((track) {
          try {
            track.stop();
          } catch (_) {}
        });
        js.context['hasMicPermission'] = true;
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Mikrofon izni alınamadı: $e');
      return false;
    }
  }

  /// Oyunda ve Pratik Ekranlarında 0 Gecikme (0ms Latency) için Sesleri Blob Olarak RAM'e Önceden Yükler
  Future<void> preloadWords(List<String> words, {String? phoneme}) async {
    if (!kIsWeb) return;
    for (final w in words) {
      final cleanW = w.trim();
      if (cleanW.isEmpty) continue;
      final cacheKey = cleanW.toLowerCase();
      if (_blobUrlCache.containsKey(cacheKey)) continue;

      try {
        final encodedText = Uri.encodeComponent(cleanW);
        final encodedPhoneme = Uri.encodeComponent(phoneme ?? '');
        final audioUrl = '$backendUrl/api/tts?text=$encodedText&phoneme=$encodedPhoneme&mode=game&v=53';
        
        final req = await html.HttpRequest.request(audioUrl, responseType: 'blob');
        if (req.response is html.Blob) {
          final blobUrl = html.Url.createObjectUrlFromBlob(req.response as html.Blob);
          _blobUrlCache[cacheKey] = blobUrl;
          final audio = html.AudioElement(blobUrl);
          _preloadedAudios[cacheKey] = audio;
        }
      } catch (e) {
        debugPrint('Preload Blob hatası ($cleanW): $e');
      }
    }
  }

  /// 1. DOĞAL TÜRKÇE KADIN SESİ (FastAPI Edge-TTS MP3 Çalma)
  /// Heceleri çocukların net algılaması için uzatarak ve canlı tempoda seslendirir!
  Future<void> speakTurkish(
    String text, {
    String? phoneme,
    bool withInstruction = false,
    String? mode,
    void Function()? onAudioStarted,
    void Function(double currentSec, double totalSec)? onTimeUpdate,
    void Function()? onAudioCompleted,
  }) async {
    final completer = Completer<void>();
    if (kIsWeb) {
      try {
        _currentAudio?.pause();
        _currentAudio = null;

        final effectiveMode = mode ?? (withInstruction ? 'explain' : (text.trim().length <= 3 && !text.contains(' ') ? 'syllable' : 'natural'));
        final cleanKey = '${text.trim().toLowerCase()}_${effectiveMode}_${phoneme ?? ''}_$withInstruction';
        html.AudioElement audio;

        // Önbellekte Blob olarak varsa SIFIR GECİKME (0ms) ile anında çal!
        if (_blobUrlCache.containsKey(cleanKey)) {
          audio = html.AudioElement(_blobUrlCache[cleanKey]!);
        } else if (_preloadedAudios.containsKey(cleanKey)) {
          audio = _preloadedAudios[cleanKey]!;
          audio.currentTime = 0;
        } else {
          final encodedText = Uri.encodeComponent(text);
          final encodedPhoneme = Uri.encodeComponent(phoneme ?? '');
          final audioUrl = '$backendUrl/api/tts?text=$encodedText&phoneme=$encodedPhoneme&mode=$effectiveMode&v=54';
          audio = html.AudioElement(audioUrl);
          _preloadedAudios[cleanKey] = audio;
        }

        _currentAudio = audio;

        audio.onPlay.listen((_) {
          onAudioStarted?.call();
        });

        audio.onTimeUpdate.listen((_) {
          final cur = audio.currentTime.toDouble();
          final dur = audio.duration.toDouble();
          if (dur > 0 && !dur.isNaN) {
            onTimeUpdate?.call(cur, dur);
          }
        });

        audio.onEnded.listen((_) {
          onAudioCompleted?.call();
          if (!completer.isCompleted) completer.complete();
        });
        final requestedAudio = audio;
        audio.onError.listen((e) {
          if (_currentAudio != requestedAudio) return;
          debugPrint('Backend TTS ses çalma hatası: $e');
          _fallbackBrowserTts(text, completer);
        });

        audio.play();

        final safetySeconds = (mode == 'explain' || withInstruction) ? 35 : 10;
        Timer(Duration(seconds: safetySeconds), () {
          if (!completer.isCompleted) completer.complete();
        });
        return completer.future;
      } catch (e) {
        debugPrint('TTS Hatası: $e');
        _fallbackBrowserTts(text, completer);
        return completer.future;
      }
    } else {
      return completer.future;
    }
  }

  void seekAudio(double seconds) {
    try {
      if (_currentAudio != null) {
        _currentAudio!.currentTime = seconds;
      }
    } catch (_) {}
  }

  void pauseAudio() {
    try {
      _currentAudio?.pause();
    } catch (_) {}
  }

  void resumeAudio() {
    try {
      _currentAudio?.play();
    } catch (_) {}
  }

  /// Kullanıcının az önce mikrofondan söylediği kendi ham ses kaydını (WAV) dinletir
  bool playLastRecordedAudio({void Function()? onEnded}) {
    if (kIsWeb) {
      try {
        if (onEnded != null) {
          StreamSubscription? sub;
          sub = html.window.on['playback_ended'].listen((_) {
            sub?.cancel();
            onEnded();
          });
        }
        final res = js.context.callMethod('playLastRecordedAudio');
        return res == true;
      } catch (e) {
        debugPrint('playLastRecordedAudio hatası: $e');
      }
    }
    return false;
  }

  bool hasLastRecordedAudio() {
    if (kIsWeb) {
      try {
        final blob = js.context['lastRecordedWavBlob'] ?? js.context['_persistentLastWavBlob'];
        return blob != null;
      } catch (_) {}
    }
    return false;
  }

  void stopAudio() {
    try {
      _currentAudio?.pause();
      _currentAudio?.currentTime = 0;
      _currentAudio = null;
    } catch (_) {}
  }

  void _fallbackBrowserTts(String text, Completer<void> completer) {
    if (kIsWeb) {
      try {
        final safeText = text.replaceAll("'", "\\'");
        html.document.body?.append(
          html.ScriptElement()..innerHtml = """
            if ('speechSynthesis' in window) {
              window.speechSynthesis.cancel();
              const voices = window.speechSynthesis.getVoices();
              const femaleVoice = voices.find(v => 
                v.lang.startsWith('tr') && 
                (v.name.includes('Emel') || v.name.includes('Filiz') || v.name.includes('Seda') || v.name.includes('Google') || v.name.toLowerCase().includes('female') || v.name.toLowerCase().includes('kadin'))
              );
              // KESİNLİKLE erkek sesi (Tolga vb.) çalınmasın! Sadece gerçek kadın terapist sesi varsa çal!
              if (femaleVoice) {
                const u = new SpeechSynthesisUtterance('$safeText');
                u.lang = 'tr-TR';
                u.rate = 0.85;
                u.voice = femaleVoice;
                window.speechSynthesis.speak(u);
              }
            }
          """
        );
      } catch (_) {}
    }
    if (!completer.isCompleted) completer.complete();
  }

  /// Aktif sesli okumayı (TTS / SpeechSynthesis / MP3) anında durdurur
  void stopSpeaking() {
    if (kIsWeb) {
      try {
        _currentAudio?.pause();
        _currentAudio = null;
        js.context.callMethod('eval', ['window.speechSynthesis && window.speechSynthesis.cancel()']);
      } catch (_) {}
    }
  }

  /// 2. SES KAYDI VE WEB SPEECH RECOGNITION DİNLEME (Duolingo Tarzı Kesintisiz Dinleme)
  Future<String> listenToSpeech({
    Duration duration = const Duration(seconds: 10),
    bool continuous = false,
    String? targetText,
    String? phoneme,
    ValueChanged<String>? onInterimText,
  }) async {
    final completer = Completer<String>();
    if (kIsWeb) {
      try {
        js.context.callMethod('startSpeechRecognition', [
          'tr-TR',
          continuous,
          targetText ?? '',
          phoneme ?? '',
        ]);

        StreamSubscription? interimSub;
        StreamSubscription? endedSub;
        Timer? timeoutTimer;

        void cleanup() {
          interimSub?.cancel();
          endedSub?.cancel();
          timeoutTimer?.cancel();
        }

        void finish(String text) {
          if (!completer.isCompleted) {
            cleanup();
            completer.complete(text);
          }
        }

        interimSub = html.window.on['stt_interim'].listen((_) {
          final text = (js.context['currentSpokenTranscript'] as String? ?? '').trim();
          if (text.isNotEmpty && onInterimText != null) {
            onInterimText(text);
          }
        });

        endedSub = html.window.on['stt_ended'].listen((_) {
          final text = (js.context['currentSpokenTranscript'] as String? ?? '').trim();
          finish(text);
        });

        timeoutTimer = Timer(duration, () {
          stopListening();
          final text = (js.context['currentSpokenTranscript'] as String? ?? '').trim();
          finish(text);
        });

        return await completer.future;
      } catch (e) {
        debugPrint('listenToSpeech hatası: $e');
        return '';
      }
    }
    return '';
  }

  /// Mikrofonu açıp konuşmayı dinler, mikrofon seviyesini yayınlar ve backend ile değerlendirir
  Future<SpeechEvaluationResult> listenAndEvaluate({
    required String targetText,
    required String phoneme,
    Duration duration = const Duration(seconds: 10),
    ValueChanged<String>? onInterimText,
    ValueChanged<String>? onLiveSpeech,
  }) async {
    final spoken = await listenToSpeech(
      duration: duration,
      continuous: false,
      targetText: targetText,
      phoneme: phoneme,
      onInterimText: (text) {
        onInterimText?.call(text);
        onLiveSpeech?.call(text);
      },
    );

    stopListening();

    if (onLiveSpeech != null && spoken.isNotEmpty) {
      onLiveSpeech(spoken);
    }

    return evaluateAudio(
      targetText: targetText,
      phoneme: phoneme,
      spokenText: spoken,
    );
  }

  /// 3. BACKEND AKILLI SES DEĞERLENDİRME (WAV Destekli Native Köprü)
  Future<SpeechEvaluationResult> evaluateAudio({
    required String targetText,
    required String phoneme,
    required String spokenText,
    Uint8List? audioBytes,
  }) async {
    if (kIsWeb) {
      final completer = Completer<SpeechEvaluationResult>();
      StreamSubscription? doneSub;
      StreamSubscription? errSub;

      void cleanup() {
        doneSub?.cancel();
        errSub?.cancel();
      }

      doneSub = html.window.on['speech_eval_done'].listen((_) {
        try {
          cleanup();
          final rawJson = js.context['__lastEvalJson'] as String? ?? '';
          if (rawJson.isNotEmpty) {
            final data = json.decode(rawJson);
            final rawLetters = (data['letter_analysis'] as List? ?? []);
            final letters = rawLetters.map((l) => LetterAnalysisItem(
              targetChar: l['target_char'] ?? '',
              spokenChar: l['spoken_char'] ?? '',
              isMatch: l['is_match'] ?? false,
            )).toList();

            if (!completer.isCompleted) {
              completer.complete(SpeechEvaluationResult(
                recognizedText: data['recognized_text'] ?? spokenText,
                targetText: targetText,
                score: (data['accuracy_score'] as num? ?? 0).toInt(),
                errorPercentage: (data['error_percentage'] as num? ?? 0).toInt(),
                isMatched: data['is_correct'] ?? false,
                feedback: data['feedback_message'] ?? 'Değerlendirme tamamlandı.',
                errorType: data['error_type'] ?? '',
                errorDetail: data['error_detail'] ?? '',
                articulatoryCorrection: data['articulatory_correction'] ?? '',
                letterAnalysis: letters,
              ));
            }
            return;
          }
        } catch (err) {
          debugPrint('JSON parse hatası: $err');
        }
        if (!completer.isCompleted) {
          completer.complete(_localEvaluate(spokenText, targetText, phoneme));
        }
      });

      errSub = html.window.on['speech_eval_error'].listen((_) {
        cleanup();
        debugPrint('callEvaluateAudioApi JS hata bildirdi.');
        if (!completer.isCompleted) {
          completer.complete(_localEvaluate(spokenText, targetText, phoneme));
        }
      });

      try {
        js.context.callMethod('callEvaluateAudioApi', [
          backendUrl,
          targetText,
          phoneme,
          spokenText,
        ]);

        return await completer.future.timeout(const Duration(seconds: 8), onTimeout: () {
          cleanup();
          return _localEvaluate(spokenText, targetText, phoneme);
        });
      } catch (e) {
        cleanup();
        debugPrint('evaluateAudio hatası: $e');
        return _localEvaluate(spokenText, targetText, phoneme);
      }
    }

    return _localEvaluate(spokenText, targetText, phoneme);
  }

  SpeechEvaluationResult _localEvaluate(String recognized, String target, String phoneme) {
    final cleanRecognized = recognized.toLowerCase().replaceAll(RegExp(r'[^\w\sğüşıöç]'), '').trim();
    final cleanTarget = target.toLowerCase().replaceAll(RegExp(r'[^\w\sğüşıöç]'), '').trim();
    final hasWav = hasLastRecordedAudio();

    if (cleanRecognized.isEmpty) {
      if (hasWav) {
        return SpeechEvaluationResult(
          recognizedText: '(Belirsiz ses)',
          targetText: target,
          score: 35,
          isMatched: false,
          feedback: 'Sesini duydum fakat "$target" sesini tam seçemedim. Lütfen ağzını biraz daha açarak net bir şekilde tekrar söyle! 🎙️',
        );
      }
      return SpeechEvaluationResult(
        recognizedText: '(Hiç ses algılanmadı)',
        targetText: target,
        score: 0,
        isMatched: false,
        feedback: 'Mikrofondan hiç ses gelmedi! Lütfen kelimeyi yüksek sesle söyle.',
      );
    }

    final bool isExactMatch = cleanRecognized == cleanTarget;
    final bool isTargetInSpoken = cleanRecognized.contains(cleanTarget);
    final bool isSpokenInTarget = cleanTarget.contains(cleanRecognized) && cleanRecognized.length >= (cleanTarget.length * 0.85);

    if (isExactMatch || isTargetInSpoken || isSpokenInTarget) {
      return SpeechEvaluationResult(
        recognizedText: recognized,
        targetText: target,
        score: 96,
        isMatched: true,
        feedback: 'Mükemmel! "$target" kelimesini ve "$phoneme" sesini harika söyledin! 🌟',
      );
    }

    return SpeechEvaluationResult(
      recognizedText: recognized,
      targetText: target,
      score: 25,
      isMatched: false,
      feedback: 'Sen "$recognized" dedin. Hedef olan "$phoneme" sesini tam duyamadım. Dudaklarına dikkat ederek tekrar dene! 💪',
    );
  }

  /// 4. HİKAYE YAPAY ZEKA DEĞERLENDİRME VE KLİNİK GERİ BİLDİRİM
  Future<StoryEvaluationData> evaluateStory({
    required String storyText,
    required String targetPhoneme,
    required String spokenText,
    Uint8List? audioBytes,
  }) async {
    if (kIsWeb) {
      try {
        final uri = Uri.parse('$backendUrl/api/evaluate-story');
        final formData = html.FormData();
        formData.append('story_text', storyText);
        formData.append('target_phoneme', targetPhoneme);
        formData.append('spoken_text', spokenText);

        if (audioBytes != null && audioBytes.isNotEmpty) {
          final blob = html.Blob([audioBytes], 'audio/wav');
          formData.appendBlob('audio_file', blob, 'story_recording.wav');
        } else {
          try {
            js.context.callMethod('appendRecordedWavToFormData', [formData]);
          } catch (_) {}
        }

        final request = await html.HttpRequest.request(
          uri.toString(),
          method: 'POST',
          sendData: formData,
        );

        if (request.status == 200) {
          final data = json.decode(request.responseText ?? '{}');
          final rawWords = (data['word_evaluations'] as List? ?? []);
          final wordList = rawWords.map((w) => StoryWordItem(
            word: w['word'] ?? '',
            spokenAs: w['spoken_as'] ?? '',
            isCorrect: w['is_correct'] ?? false,
            hasTargetPhoneme: w['has_target_phoneme'] ?? false,
          )).toList();

          return StoryEvaluationData(
            accuracyScore: (data['accuracy_score'] as num? ?? 0).toInt(),
            totalWords: (data['total_words'] as num? ?? 0).toInt(),
            correctWordsCount: (data['correct_words_count'] as num? ?? 0).toInt(),
            targetPhonemeErrorWords: List<String>.from(data['target_phoneme_error_words'] ?? []),
            mispronouncedWords: List<String>.from(data['mispronounced_words'] ?? []),
            wordEvaluations: wordList,
            feedbackMessage: data['feedback_message'] ?? 'Hikaye değerlendirmesi tamamlandı.',
            therapistCorrectionPrompt: data['therapist_correction_prompt'] ?? '',
            starsEarned: (data['stars_earned'] as num? ?? 0).toInt(),
            recognizedText: data['recognized_text'] ?? spokenText,
          );
        }
      } catch (e) {
        debugPrint('Story evaluation backend error: $e');
      }
    }

    final rawStoryWords = storyText.replaceAll(RegExp(r'[^\w\sğüşıöç]'), ' ').split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    final spokenWords = spokenText.toLowerCase().replaceAll(RegExp(r'[^\w\sğüşıöç]'), ' ').split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    final pClean = targetPhoneme.replaceAll(RegExp(r'[/ -]'), '').toLowerCase();

    final List<StoryWordItem> words = [];
    final List<String> pErrors = [];
    int correct = 0;

    for (final w in rawStoryWords) {
      final hasP = w.toLowerCase().contains(pClean);
      final isFound = spokenWords.contains(w.toLowerCase());
      if (isFound) correct++;
      if (!isFound && hasP && !pErrors.contains(w)) pErrors.add(w);
      words.add(StoryWordItem(
        word: w,
        spokenAs: isFound ? w : '',
        isCorrect: isFound,
        hasTargetPhoneme: hasP,
      ));
    }

    final score = rawStoryWords.isEmpty ? 0 : ((correct / rawStoryWords.length) * 100).toInt();
    return StoryEvaluationData(
      accuracyScore: score,
      totalWords: rawStoryWords.length,
      correctWordsCount: correct,
      targetPhonemeErrorWords: pErrors.take(5).toList(),
      mispronouncedWords: [],
      wordEvaluations: words,
      feedbackMessage: score >= 70
          ? 'Tebrikler! Hikayedeki kelimeleri ve /$pClean/ seslerini başarıyla seslendirdin!'
          : 'Güzel bir çalışma! /$pClean/ sesini içeren kelimeleri birlikte tekrarlayalım.',
      therapistCorrectionPrompt: 'Şimdi /$pClean/ sesini vurgulayarak bu kelimeleri tekrar söyle!',
      starsEarned: score >= 75 ? 3 : (score >= 40 ? 2 : 1),
      recognizedText: spokenText,
    );
  }

  void stopListening() {
    if (kIsWeb) {
      try {
        js.context.callMethod('stopSpeechRecognition', []);
      } catch (_) {}
    }
  }

  /// Klinik Seansını Backend SQLite/PostgreSQL Veritabanına Kaydet (Terapist Paneli Senkronizasyonu)
  Future<bool> recordTherapySession({
    required String studentName,
    required String phoneme,
    required int durationMinutes,
    required int wordsAttempted,
    required int wordsCorrect,
    required double accuracyScore,
    String? therapistNote,
  }) async {
    if (!kIsWeb) return false;
    try {
      final req = html.HttpRequest();
      req.open('POST', '$backendUrl/api/sessions/record');
      req.setRequestHeader('Content-Type', 'application/json');
      req.send(jsonEncode({
        'student_name': studentName,
        'phoneme': phoneme,
        'duration_minutes': durationMinutes,
        'words_attempted': wordsAttempted,
        'words_correct': wordsCorrect,
        'accuracy_score': accuracyScore,
        'therapist_note': therapistNote ?? 'Flutter Web klinik seansı tamamlandı.',
      }));
      await req.onLoad.first;
      return req.status == 200;
    } catch (e) {
      debugPrint('recordTherapySession error: $e');
      return false;
    }
  }
}
