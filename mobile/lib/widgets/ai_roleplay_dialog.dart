import 'dart:async';
import 'package:flutter/material.dart';
import '../services/audio_speech_service.dart';
import '../services/sound_effects_service.dart';
import '../models/reward_state.dart';

class _RoleplayMessage {
  final bool isAi;
  final String text;
  final String speakerName;
  final String emoji;

  _RoleplayMessage({
    required this.isAi,
    required this.text,
    required this.speakerName,
    required this.emoji,
  });
}

/// 🤖 AI SESLİ SOHBET ARKADAŞI (İNTERAKTİF ROL YAPMA)
/// Çocuğun hedef sesi izole kelimelerden çıkarıp gerçek hayat diyaloglarında
/// konuşma akıcılığıyla kullanmasını sağlayan interaktif senaryo sohbeti.
class AiRoleplayDialog extends StatefulWidget {
  final String phoneme;
  final String soundTitle;

  const AiRoleplayDialog({
    super.key,
    required this.phoneme,
    required this.soundTitle,
  });

  @override
  State<AiRoleplayDialog> createState() => _AiRoleplayDialogState();
}

class _AiRoleplayDialogState extends State<AiRoleplayDialog> {
  final AudioSpeechService _audioService = AudioSpeechService();
  final SoundEffectsService _sfx = SoundEffectsService();
  final RewardState _rewardState = RewardState();
  final ScrollController _scrollController = ScrollController();

  int _currentScenarioIndex = 0;
  bool _isListening = false;
  bool _isSpeaking = false;
  String _liveTranscript = '';
  final List<_RoleplayMessage> _messages = [];

  late final List<Map<String, dynamic>> _scenarios;

  @override
  void initState() {
    super.initState();
    _initScenarios();
    _startCurrentScenario();
  }

  void _initScenarios() {
    final p = widget.phoneme.replaceAll('/', '').trim().toUpperCase();
    _scenarios = [
      {
        'title': '🍎 Sevimli Pazar Yeri',
        'partner': 'Manav Pamuk Ayı',
        'emoji': '🐻',
        'intro': 'Hoş geldin küçük ses kaşifi! Tezgahımda içinde [$p] sesi olan taptaze meyveler var. Hangisini istersin?',
        'suggestions': [
          'Portakal lütfen! 🍊',
          'Patates ve pırasa 🥔',
          'İki kilo koyar mısın? ⚖️',
        ],
        'prompts': [
          'Vay nefis bir seçim! Peki yanına kaç tane koyayım? Bir tane mi, iki tane mi?',
          'Harika konuştun! Afiyet olsun, pazarıma her zaman beklerim!',
        ],
      },
      {
        'title': '🚀 Uzay Görevi Limanı',
        'partner': 'Kaptan Astro Robot',
        'emoji': '🤖',
        'intro': 'Roketimiz kalkışa hazırlanıyor! Galaksi yolculuğunda [$p] sesli yakıt depolarını kontrol etmeliyiz.',
        'suggestions': [
          'Hadi uçalım Kaptan! 🚀',
          'Sağa dönelim! 🛸',
          'Yakıt depoları hazır! ⚡',
        ],
        'prompts': [
          'Motorlar çalıştı! Önümüzde bir meteor var, "Sağa dön" mü diyelim yoksa "Hızlan" mı?',
          'Rotayı başarıyla tamamladın! Galaksinin en akıcı konuşan kahramanı sensin!',
        ],
      },
      {
        'title': '🦁 Neşeli Hayvanat Bahçesi',
        'partner': 'Rehber Maymun Çiko',
        'emoji': '🐒',
        'intro': 'Safari turuna hoş geldin! Ormanda [$p] sesini seven hayvan dostlarımızı arıyoruz.',
        'suggestions': [
          'O bir sevimli panda! 🐼',
          'Merhaba renkli papağan! 🦜',
          'Safari turu harika! 🦁',
        ],
        'prompts': [
          'Şuradaki sevimli hayvana bak! Sence o bir panda mı yoksa papağan mı?',
          'Hayvanlar senin bu güzel sesine bayıldı! Safari başarı madalyasını kazandın!',
        ],
      },
    ];
  }

  void _startCurrentScenario() {
    _messages.clear();
    final sc = _scenarios[_currentScenarioIndex];
    final intro = sc['intro'] as String;
    final partner = sc['partner'] as String;
    final emoji = sc['emoji'] as String;

    _addAiMessage(intro, partner, emoji);
    _speakText(intro);
  }

  void _addAiMessage(String text, String partner, String emoji) {
    setState(() {
      _messages.add(
        _RoleplayMessage(
          isAi: true,
          text: text,
          speakerName: partner,
          emoji: emoji,
        ),
      );
    });
    _scrollToBottom();
  }

  void _addUserMessage(String text) {
    setState(() {
      _messages.add(
        _RoleplayMessage(
          isAi: false,
          text: text,
          speakerName: _rewardState.activeCharacterName,
          emoji: _rewardState.activeAvatar,
        ),
      );
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _speakText(String text) {
    setState(() => _isSpeaking = true);
    _audioService.speakTurkish(
      text,
      phoneme: widget.phoneme,
      mode: 'roleplay',
    );
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) setState(() => _isSpeaking = false);
    });
  }

  void _toggleListening() async {
    if (_isListening) {
      _audioService.stopListening();
      setState(() => _isListening = false);
      if (_liveTranscript.trim().isNotEmpty) {
        _handleChildSpokenText(_liveTranscript.trim());
      }
    } else {
      _liveTranscript = '';
      setState(() => _isListening = true);
      _sfx.playPopSound();

      final recognized = await _audioService.listenToSpeech(
        duration: const Duration(seconds: 6),
      );

      if (mounted) {
        setState(() {
          _isListening = false;
          _liveTranscript = recognized;
        });
        if (recognized.trim().isNotEmpty) {
          _handleChildSpokenText(recognized.trim());
        }
      }
    }
  }

  void _handleChildSpokenText(String text) {
    _addUserMessage(text);
    _sfx.playSuccessDing();

    final sc = _scenarios[_currentScenarioIndex];
    final prompts = sc['prompts'] as List<String>;
    final partner = sc['partner'] as String;
    final emoji = sc['emoji'] as String;

    final userMsgCount = _messages.where((m) => !m.isAi).length;

    Timer(const Duration(milliseconds: 600), () {
      if (!mounted) return;

      if (userMsgCount <= prompts.length) {
        final nextPrompt = prompts[userMsgCount - 1];
        _addAiMessage(nextPrompt, partner, emoji);
        _speakText(nextPrompt);

        _rewardState.addReward(earnedStars: 1, earnedXp: 20, earnedGems: 10);
      } else {
        _sfx.playVictoryFanfare();
        _addAiMessage('🎉 Harikasın! Sohbeti başarıyla tamamladın! Akıcı konuşma madalyası kazandın! ⭐ +3 Yıldız', partner, emoji);
        _rewardState.addReward(earnedStars: 3, earnedXp: 50, earnedGems: 25);
      }
    });
  }

  void _showHelpInfo() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Text('🤖', style: TextStyle(fontSize: 28)),
            SizedBox(width: 8),
            Text('Yapay Zeka Tiyatrosu Nedir?', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              '🎯 Neden Buradayız?',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Color(0xFF673AB7)),
            ),
            SizedBox(height: 4),
            Text(
              'Tek tek kelime söylemek yerine gerçek hayatta arkadaşınla konuşur gibi pratik yapmak için buradasın.',
              style: TextStyle(fontSize: 12, color: Colors.black87),
            ),
            SizedBox(height: 12),
            Text(
              '🗣️ Nasıl Cevap Veririm?',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Color(0xFF2E7D32)),
            ),
            SizedBox(height: 4),
            Text(
              '1. Karakterin söylediği cümleyi dinle.\n'
              '2. Mikrofona basıp kendi cümleni söyle veya alttaki hazır cevap balonlarına dokun.\n'
              '3. Terapist yapay zeka seni dinler ve sohbete devam eder!',
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
            child: const Text('HARİKA, ANLADIM! 🚀', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sc = _scenarios[_currentScenarioIndex];
    final suggestions = sc['suggestions'] as List<String>? ?? [];

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 720),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: const Color(0xFF673AB7), width: 3),
          boxShadow: const [
            BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, 8)),
          ],
        ),
        child: Column(
          children: [
            // ÜST BAŞLIK & SENARYO SEÇİCİ
            Container(
              padding: const EdgeInsets.fromLTRB(18, 14, 14, 10),
              decoration: const BoxDecoration(
                color: Color(0xFF673AB7),
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Row(
                children: [
                  Text(sc['emoji'] as String, style: const TextStyle(fontSize: 28)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sc['title'] as String,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          'Partner: ${sc['partner']} (${widget.soundTitle})',
                          style: const TextStyle(color: Colors.white70, fontSize: 11.5, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.help_outline_rounded, color: Colors.amberAccent),
                    tooltip: 'Buranın Mantığı Nedir?',
                    onPressed: _showHelpInfo,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // AMACI VE MANTIĞI AÇIKLAYAN BİLGİ BANDI
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              color: _isSpeaking ? const Color(0xFFE8F5E9) : const Color(0xFFEDE7F6),
              child: Row(
                children: [
                  Text(_isSpeaking ? '🔊' : '💡', style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _isSpeaking
                          ? '${sc['partner']} seninle konuşuyor... Dikkatlice dinle!'
                          : 'Karakter sana soru sorduğunda mikrofona konuş veya aşağıdaki hazır cevaplara dokun!',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                        color: _isSpeaking ? const Color(0xFF1B5E20) : const Color(0xFF512DA8),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // SENARYO DEĞİŞTİRME SEKMELERİ
            Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              color: const Color(0xFFF3E5F5),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _scenarios.length,
                itemBuilder: (ctx, i) {
                  final isSel = i == _currentScenarioIndex;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(
                        _scenarios[i]['title'] as String,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: isSel ? Colors.white : const Color(0xFF512DA8),
                        ),
                      ),
                      selected: isSel,
                      selectedColor: const Color(0xFF673AB7),
                      backgroundColor: Colors.white,
                      showCheckmark: false,
                      onSelected: (_) {
                        setState(() => _currentScenarioIndex = i);
                        _startCurrentScenario();
                      },
                    ),
                  );
                },
              ),
            ),

            // MESAJ SOHBET LİSTESİ
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (ctx, idx) {
                  final m = _messages[idx];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      mainAxisAlignment: m.isAi ? MainAxisAlignment.start : MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (m.isAi) ...[
                          Text(m.emoji, style: const TextStyle(fontSize: 24)),
                          const SizedBox(width: 8),
                        ],
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: m.isAi ? const Color(0xFFF3E5F5) : const Color(0xFF58CC02),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: m.isAi ? const Color(0xFFD1C4E9) : const Color(0xFF43A047),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      m.speakerName,
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w900,
                                        color: m.isAi ? const Color(0xFF512DA8) : Colors.white70,
                                      ),
                                    ),
                                    if (m.isAi) ...[
                                      const SizedBox(width: 6),
                                      InkWell(
                                        onTap: () => _speakText(m.text),
                                        child: const Icon(Icons.volume_up_rounded, size: 16, color: Color(0xFF673AB7)),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  m.text,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: m.isAi ? Colors.black87 : Colors.white,
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (!m.isAi) ...[
                          const SizedBox(width: 8),
                          Text(m.emoji, style: const TextStyle(fontSize: 24)),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),

            // HAZIR CEVAP ÖNERİLERİ (ÇOCUĞUN KONUŞMASINI KOLAYLAŞTIRAN ÇİPLER)
            if (suggestions.isNotEmpty && !_isListening)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                color: const Color(0xFFFAFAFA),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: suggestions.map((sug) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ActionChip(
                          backgroundColor: const Color(0xFFEDE7F6),
                          label: Text(sug, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF512DA8))),
                          onPressed: () => _handleChildSpokenText(sug),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

            // CANLI DİNLENİYOR PANELİ
            if (_isListening)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                color: const Color(0xFFFFEBEE),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.mic_rounded, color: Colors.red, size: 20),
                    SizedBox(width: 8),
                    Text('Seni Dinliyorum... Şimdi cevap ver! 🔴', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w900, fontSize: 12)),
                  ],
                ),
              ),

            // ALT MİKROFON BUTONU
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
                border: Border(top: BorderSide(color: Colors.grey[200]!)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isListening ? Colors.red : const Color(0xFF673AB7),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 3,
                      ),
                      icon: Icon(_isListening ? Icons.stop_rounded : Icons.mic_rounded, size: 22),
                      label: Text(
                        _isListening ? 'BİTTİ, GÖNDER 🛑' : 'MİKROFONLA CEVAP VER 🎤',
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                      ),
                      onPressed: _toggleListening,
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
}
