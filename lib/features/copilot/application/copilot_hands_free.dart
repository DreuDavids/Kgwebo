import '../../../core/money/currency_names.dart';
import '../domain/copilot_turn.dart';

/// Spoken and typed shortcuts so Ask can stay on this page.
abstract final class CopilotHandsFree {
  static CopilotOffer offerFor(String userText) {
    final text = userText.toLowerCase();
    if (text.contains('how do i') ||
        text.contains('how to') ||
        wantsOpenForm(text)) {
      return CopilotOffer.none;
    }
    final wantsRecord =
        text.contains('record') ||
        text.contains('log a') ||
        text.contains('want to') ||
        text.contains('i need to');
    if (!wantsRecord) {
      return CopilotOffer.none;
    }
    if (text.contains('expense') ||
        text.contains('spent') ||
        text.contains('bought')) {
      return CopilotOffer.recordExpense;
    }
    if (text.contains('sale') || text.contains('sold')) {
      return CopilotOffer.recordSale;
    }
    return CopilotOffer.none;
  }

  static bool wantsOpenForm(String userText) {
    final text = userText.toLowerCase();
    return text.contains('open') ||
        text.contains('page') ||
        text.contains('modal') ||
        text.contains('form') ||
        text.contains('screen');
  }

  static bool wantsHelpHere(String userText) {
    final text = userText.toLowerCase();
    if (wantsOpenForm(text)) {
      return false;
    }
    return text.contains('help') ||
        text.contains('here') ||
        text.contains('you do') ||
        text.contains('walk me') ||
        text == 'yes' ||
        text == 'ee' ||
        text == 'ok';
  }

  static bool wantsConfirm(String userText) {
    final text = userText.toLowerCase().trim();
    return text == 'confirm' ||
        text == 'save' ||
        text == 'save it' ||
        text.contains('confirm') ||
        text.contains('save it');
  }

  static String prompt(CopilotOffer offer) {
    return switch (offer) {
      CopilotOffer.recordSale =>
        'Do you need my help recording a sale, or should I open the record sale page for you? Say help me, or say open it.',
      CopilotOffer.recordExpense =>
        'Do you need my help recording an expense, or should I open the record expense page for you? Say help me, or say open it.',
      CopilotOffer.none => '',
    };
  }

  static String helpPrompt(CopilotOffer offer, {String currencyCode = 'BWP'}) {
    final spoken = CurrencyNames.spoken(currencyCode);
    return switch (offer) {
      CopilotOffer.recordSale =>
        'Tell me the amount in $spoken, what you sold, and whether the customer has paid. I will draft it here. Nothing is saved until you confirm.',
      CopilotOffer.recordExpense =>
        'Tell me the amount in $spoken, what it was for, and whether you have already paid. I will draft it here. Nothing is saved until you confirm.',
      CopilotOffer.none => '',
    };
  }

  static String? routeForOffer(CopilotOffer offer) {
    return switch (offer) {
      CopilotOffer.recordSale => 'record-sale',
      CopilotOffer.recordExpense => 'record-expense',
      CopilotOffer.none => null,
    };
  }
}
