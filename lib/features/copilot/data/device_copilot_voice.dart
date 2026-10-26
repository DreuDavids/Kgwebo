import 'dart:async';

import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../application/copilot_voice.dart';

class DeviceCopilotVoice implements CopilotVoice {
  FlutterTts? _tts;
  SpeechToText? _speech;

  @override
  Future<void> speak(String text, {String? languageCode}) async {
    final clipped = text.trim();
    if (clipped.isEmpty) {
      return;
    }
    try {
      _tts ??= FlutterTts();
      await _tts!.stop();
      await _tts!.setSpeechRate(0.48);
      await _tts!.setLanguage(_ttsLocale(languageCode));
      await _tts!.speak(clipped);
    } catch (_) {}
  }

  @override
  Future<void> stop() async {
    try {
      await _tts?.stop();
    } catch (_) {}
    try {
      await _speech?.stop();
    } catch (_) {}
  }

  @override
  Future<String?> listenOnce() async {
    try {
      _speech ??= SpeechToText();
      final ready = await _speech!.initialize();
      if (!ready) {
        return null;
      }
      final done = Completer<String?>();
      await _speech!.listen(
        listenOptions: SpeechListenOptions(
          listenFor: const Duration(seconds: 8),
          pauseFor: const Duration(seconds: 2),
        ),
        onResult: (result) {
          if (result.finalResult && !done.isCompleted) {
            done.complete(result.recognizedWords);
          }
        },
      );
      final heard = await done.future.timeout(
        const Duration(seconds: 8),
        onTimeout: () async {
          await _speech?.stop();
          return null;
        },
      );
      await _speech!.stop();
      final text = heard?.trim();
      if (text == null || text.isEmpty) {
        return null;
      }
      return text;
    } catch (_) {
      return null;
    }
  }

  String _ttsLocale(String? languageCode) {
    return switch (languageCode?.toLowerCase()) {
      'tn' || 'af' || 'en' => 'en-ZA',
      _ => 'en-ZA',
    };
  }
}
