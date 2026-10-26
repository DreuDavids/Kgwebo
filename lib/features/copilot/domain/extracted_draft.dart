import '../../../core/finance/ledger_entry.dart';

/// A proposed sale or expense. Unknown fields stay null and are never invented.
class ExtractedDraft {
  const ExtractedDraft({
    required this.type,
    this.amountMinor,
    this.item,
    this.quantity,
    this.categoryCode,
    this.note,
    this.paymentStatus,
    this.occurredOn,
    this.detectedCurrencyCode,
    this.businessCurrencyCode = 'BWP',
  });

  final MoneyMovementType type;
  final int? amountMinor;
  final String? item;
  final int? quantity;
  final String? categoryCode;
  final String? note;
  final PaymentStatus? paymentStatus;

  /// AI output never supplies a date. The review UI may default to today.
  final DateTime? occurredOn;

  /// ISO code if the user named a currency, or the book currency for unnamed amounts.
  final String? detectedCurrencyCode;

  /// Currency from the signed-in business profile. Unnamed amounts use this.
  final String businessCurrencyCode;

  bool get hasForeignCurrency {
    final code = detectedCurrencyCode;
    return code != null &&
        code.toUpperCase() != businessCurrencyCode.toUpperCase();
  }

  List<String> get missingRequired {
    return [
      if (amountMinor == null || hasForeignCurrency) 'amount',
      if (categoryCode == null) 'category',
      if (paymentStatus == null) 'payment status',
    ];
  }

  bool get isComplete => missingRequired.isEmpty && !hasForeignCurrency;

  ExtractedDraft copyWith({
    MoneyMovementType? type,
    int? amountMinor,
    String? item,
    int? quantity,
    String? categoryCode,
    String? note,
    PaymentStatus? paymentStatus,
    DateTime? occurredOn,
    String? detectedCurrencyCode,
    String? businessCurrencyCode,
    bool clearAmount = false,
    bool clearItem = false,
    bool clearQuantity = false,
    bool clearCategory = false,
    bool clearNote = false,
    bool clearPaymentStatus = false,
    bool clearOccurredOn = false,
    bool clearCurrency = false,
  }) {
    return ExtractedDraft(
      type: type ?? this.type,
      amountMinor: clearAmount ? null : (amountMinor ?? this.amountMinor),
      item: clearItem ? null : (item ?? this.item),
      quantity: clearQuantity ? null : (quantity ?? this.quantity),
      categoryCode: clearCategory ? null : (categoryCode ?? this.categoryCode),
      note: clearNote ? null : (note ?? this.note),
      paymentStatus:
          clearPaymentStatus ? null : (paymentStatus ?? this.paymentStatus),
      occurredOn: clearOccurredOn ? null : (occurredOn ?? this.occurredOn),
      detectedCurrencyCode:
          clearCurrency
              ? null
              : (detectedCurrencyCode ?? this.detectedCurrencyCode),
      businessCurrencyCode: businessCurrencyCode ?? this.businessCurrencyCode,
    );
  }
}

class ExtractionParseResult {
  const ExtractionParseResult({
    required this.drafts,
    required this.issues,
    this.isRejected = false,
    this.rejectedItemCount = 0,
  });

  factory ExtractionParseResult.rejected(String issue) {
    return ExtractionParseResult(
      drafts: const [],
      issues: [issue],
      isRejected: true,
    );
  }

  final List<ExtractedDraft> drafts;
  final List<String> issues;
  final bool isRejected;
  final int rejectedItemCount;
}
