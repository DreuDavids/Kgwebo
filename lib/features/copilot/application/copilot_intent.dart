import '../domain/copilot_turn.dart';
import 'copilot_hands_free.dart';
import 'heuristic_extractor.dart';

enum CopilotIntentKind {
  finances,
  drafts,
  bills,
  stock,
  recent,
  recommendations,
  howto,
  navigate,
  chat,
}

/// Local intent so Ask can choose tools without a model round-trip.
CopilotIntentKind classifyCopilotIntent(
  String userText, {
  String currencyCode = 'BWP',
}) {
  final text = userText.toLowerCase();
  if (text.contains('how do i') || text.contains('how to')) {
    return CopilotIntentKind.howto;
  }
  final drafts = extractHeuristicDrafts(userText, currencyCode: currencyCode);
  if (drafts.any((draft) => draft.amountMinor != null)) {
    return CopilotIntentKind.drafts;
  }
  if (_looksBills(text)) {
    return CopilotIntentKind.bills;
  }
  if (_looksStock(text)) {
    return CopilotIntentKind.stock;
  }
  if (_looksRecent(text)) {
    return CopilotIntentKind.recent;
  }
  if (_looksRecommendations(text)) {
    return CopilotIntentKind.recommendations;
  }
  if (_looksFinancial(text)) {
    return CopilotIntentKind.finances;
  }
  if (CopilotHandsFree.wantsOpenForm(text)) {
    return CopilotIntentKind.navigate;
  }
  if (CopilotHandsFree.offerFor(userText) != CopilotOffer.none) {
    return CopilotIntentKind.drafts;
  }
  return CopilotIntentKind.chat;
}

bool shouldSendCashSnapshot(CopilotIntentKind intent) {
  return intent == CopilotIntentKind.finances ||
      intent == CopilotIntentKind.recommendations;
}

bool _looksBills(String text) {
  const keys = [
    'owe',
    'bills',
    'due',
    'kolota',
    'koloto',
    'rent due',
    'what do i owe',
  ];
  return keys.any(text.contains);
}

bool _looksStock(String text) {
  const keys = ['stock', 'inventory', 'catalogue', 'low stock', 'restock'];
  return keys.any(text.contains);
}

bool _looksRecent(String text) {
  const keys = [
    'last sale',
    'last expense',
    'open last',
    'recent sale',
    'what did i last',
  ];
  return keys.any(text.contains);
}

bool _looksRecommendations(String text) {
  if (CopilotHandsFree.wantsOpenForm(text)) {
    return false;
  }
  return text.contains('recommend') ||
      text.contains('should i') ||
      text.contains('what should') ||
      text.contains('watch');
}

bool _looksFinancial(String text) {
  if (text.contains('opening cash')) {
    return false;
  }
  const keys = [
    'how much',
    'my cash',
    'cash do i',
    'my sales',
    'my profit',
    'operating result',
    'my balance',
    'graph',
    'chart',
    'report',
    'madi',
    'ke na le',
  ];
  return keys.any(text.contains);
}
