import '../../../core/finance/ledger_entry.dart';
import '../../../core/money/money_parser.dart';
import '../domain/extracted_draft.dart';
import 'heuristic_extractor.dart';

final _amountCorrection = RegExp(
  r'\b(?:it was|change (?:it )?to|make it|no[, ]+)\s*(?:p|pula|zar|r)?\s*(\d+(?:\.\d{1,2})?)\b',
  caseSensitive: false,
);

final _bareAmountOnly = RegExp(
  r'^\s*(?:p|pula|zar|r)?\s*(\d+(?:\.\d{1,2})?)\s*(?:pula|zar|p)?\s*$',
  caseSensitive: false,
);

/// Applies a short correction to the last Ask draft instead of starting over.
abstract final class CopilotFollowUp {
  static List<ExtractedDraft>? apply({
    required String userText,
    required List<ExtractedDraft> lastDrafts,
    String currencyCode = 'BWP',
  }) {
    if (lastDrafts.isEmpty) {
      return null;
    }
    final fresh = extractHeuristicDrafts(userText, currencyCode: currencyCode);
    if (fresh.any((draft) => draft.amountMinor != null) &&
        !_isPureCorrection(userText)) {
      return null;
    }

    var changed = false;
    final next = [
      for (final draft in lastDrafts)
        _applyOne(userText, draft, currencyCode, () => changed = true),
    ];
    return changed ? next : null;
  }

  static bool _isPureCorrection(String raw) {
    final text = raw.trim().toLowerCase();
    if (_amountCorrection.hasMatch(text) || _bareAmountOnly.hasMatch(text)) {
      return true;
    }
    return RegExp(
      r'^(?:make it )?(?:unpaid|paid|on credit|not paid|ka mokgele)\.?$',
    ).hasMatch(text);
  }

  static ExtractedDraft _applyOne(
    String userText,
    ExtractedDraft draft,
    String currencyCode,
    void Function() markChanged,
  ) {
    var next = draft;
    final lower = userText.toLowerCase();
    if (RegExp(
      r'\b(unpaid|not (yet )?paid|on credit|ka mokgele|still owe)\b',
    ).hasMatch(lower)) {
      next = next.copyWith(paymentStatus: PaymentStatus.unpaid);
      markChanged();
    } else if (RegExp(r'\b(already paid|mark(?:ed)? paid)\b').hasMatch(lower) ||
        lower.trim() == 'paid') {
      next = next.copyWith(paymentStatus: PaymentStatus.paid);
      markChanged();
    }

    final corrected =
        _amountCorrection.firstMatch(lower) ??
        _bareAmountOnly.firstMatch(lower);
    if (corrected != null) {
      final minor = tryParseMinorUnits(corrected.group(1)!);
      if (minor != null) {
        next = next.copyWith(
          amountMinor: minor,
          detectedCurrencyCode: currencyCode,
          clearCurrency: false,
        );
        markChanged();
      }
    }
    return next;
  }
}
