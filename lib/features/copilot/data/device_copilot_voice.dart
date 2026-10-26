import 'package:flutter_tts/flutter_tts.dart';

import '../application/copilot_voice.dart';

class DeviceCopilotVoice implements CopilotVoice {
  FlutterTts? _tts;

  @override
  Future<void> speak(String text) async {
    final clipped = text.trim();
    if (clipped.isEmpty) {
      return;
    }
    try {
      _tts ??= FlutterTts();
      await _tts!.stop();
      await _tts!.setSpeechRate(0.48);
      await _tts!.speak(clipped);
    } catch (_) {}
  }

  @override
  Future<void> stop() async {
    try {
      await _tts?.stop();
    } catch (_) {}
  }
}
