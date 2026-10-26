import 'extracted_draft.dart';

/// In-session Ask memory. Never persisted and never sent to the model whole.
class CopilotSession {
  const CopilotSession({
    this.lastUserText,
    this.lastDrafts = const [],
    this.hasConfirmedOnce = false,
  });

  final String? lastUserText;
  final List<ExtractedDraft> lastDrafts;
  final bool hasConfirmedOnce;

  CopilotSession copyWith({
    String? lastUserText,
    List<ExtractedDraft>? lastDrafts,
    bool? hasConfirmedOnce,
  }) {
    return CopilotSession(
      lastUserText: lastUserText ?? this.lastUserText,
      lastDrafts: lastDrafts ?? this.lastDrafts,
      hasConfirmedOnce: hasConfirmedOnce ?? this.hasConfirmedOnce,
    );
  }
}
