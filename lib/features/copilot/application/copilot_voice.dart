abstract class CopilotVoice {
  Future<void> speak(String text, {String? languageCode});
  Future<void> stop();
  Future<String?> listenOnce();
}

class NullCopilotVoice implements CopilotVoice {
  const NullCopilotVoice();

  @override
  Future<void> speak(String text, {String? languageCode}) async {}

  @override
  Future<void> stop() async {}

  @override
  Future<String?> listenOnce() async => null;
}
