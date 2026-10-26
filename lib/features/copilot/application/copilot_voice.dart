abstract class CopilotVoice {
  Future<void> speak(String text);
  Future<void> stop();
}

class NullCopilotVoice implements CopilotVoice {
  const NullCopilotVoice();

  @override
  Future<void> speak(String text) async {}

  @override
  Future<void> stop() async {}
}
