import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter/foundation.dart';

class VoiceService {
  final SpeechToText _speech = SpeechToText();
  bool _isInitialized = false;

  bool get isListening => _speech.isListening;

  Future<bool> initialize() async {
    if (_isInitialized) return true;
    _isInitialized = await _speech.initialize(
      onError: (error) => debugPrint('Speech error: $error'),
      onStatus: (status) => debugPrint('Speech status: $status'),
    );
    return _isInitialized;
  }

  Future<void> startListening({
    required Function(String text) onResult,
    String localeId = 'en_US',
  }) async {
    final available = await initialize();
    if (!available) return;

    await _speech.listen(
      onResult: (result) {
        if (result.finalResult) {
          onResult(result.recognizedWords);
        }
      },
      localeId: localeId,
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      cancelOnError: true,
    );
  }

  Future<void> stopListening() async {
    await _speech.stop();
  }

  Future<List<String>> getAvailableLocales() async {
    await initialize();
    final locales = await _speech.locales();
    return locales.map((l) => l.localeId).toList();
  }
}

final voiceService = VoiceService();
