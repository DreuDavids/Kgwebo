import 'dart:convert';

import '../../../core/finance/ledger_entry.dart';
import '../../../core/money/money_parser.dart';
import '../../transactions/domain/transaction_categories.dart';
import '../domain/extracted_draft.dart';

final _jsonFence = RegExp(
  r'```(?:json)?\s*(\{[\s\S]*?\})\s*```',
  caseSensitive: false,
);

/// Parses model text into drafts. Malformed JSON is rejected, not written.
ExtractionParseResult parseExtractionOutput(
  String raw, {
  String currencyCode = 'BWP',
}) {
  final isolated = _isolateJsonObject(raw);
  if (isolated == null) {
    return ExtractionParseResult.rejected(
      'The suggestion was not valid JSON and was discarded.',
    );
  }

  final Object? decoded;
  try {
    decoded = jsonDecode(isolated);
  } on FormatException {
    return ExtractionParseResult.rejected(
      'The suggestion was not valid JSON and was discarded.',
    );
  }

  if (decoded is! Map<String, dynamic>) {
    return ExtractionParseResult.rejected(
      'The suggestion was not a JSON object and was discarded.',
    );
  }

  final transactions = decoded['transactions'];
  if (transactions is! List) {
    return ExtractionParseResult.rejected(
      'The suggestion did not contain a transactions list and was discarded.',
    );
  }

  final drafts = <ExtractedDraft>[];
  final issues = <String>[];
  var rejectedItemCount = 0;

  for (final item in transactions) {
    if (item is! Map) {
      rejectedItemCount += 1;
      issues.add('A proposed row was not an object and was discarded.');
      continue;
    }
    final parsed = _parseItem(Map<String, dynamic>.from(item), currencyCode);
    if (parsed.draft == null) {
      rejectedItemCount += 1;
      issues.add(parsed.issue ?? 'A proposed row was discarded.');
      continue;
    }
    drafts.add(parsed.draft!);
  }

  return ExtractionParseResult(
    drafts: drafts,
    issues: issues,
    rejectedItemCount: rejectedItemCount,
  );
}

String? _isolateJsonObject(String raw) {
  final fenced = _jsonFence.firstMatch(raw);
  if (fenced != null) {
    return fenced.group(1);
  }
  final start = raw.indexOf('{');
  final end = raw.lastIndexOf('}');
  if (start < 0 || end <= start) {
    return null;
  }
  return raw.substring(start, end + 1);
}

class _ParsedItem {
  const _ParsedItem({this.draft, this.issue});

  final ExtractedDraft? draft;
  final String? issue;
}

_ParsedItem _parseItem(Map<String, dynamic> json, String currencyCode) {
  final type = _parseType(json['type']);
  if (type == null) {
    return const _ParsedItem(
      issue: 'An unsupported transaction type was discarded.',
    );
  }

  final currency = _optionalCurrency(json['currency'] ?? json['currency_code']);
  final amount = _parseAmount(json);
  if (amount.isInvalid) {
    return const _ParsedItem(issue: 'Invalid amount discarded.');
  }

  final foreign = currency != null && currency != currencyCode;
  return _ParsedItem(
    draft: ExtractedDraft(
      type: type,
      amountMinor: foreign ? null : amount.minorUnits,
      item: _optionalString(json['item']),
      quantity: _optionalPositiveInt(json['quantity']),
      categoryCode: _optionalCategory(type, json['category']),
      note: _optionalString(
        json['note'] ?? json['description'],
        maxLength: 500,
      ),
      paymentStatus: _optionalPaymentStatus(json['payment_status']),
      detectedCurrencyCode: currency ?? currencyCode,
      businessCurrencyCode: currencyCode,
    ),
  );
}

MoneyMovementType? _parseType(Object? raw) {
  if (raw is! String) {
    return null;
  }
  return switch (raw.trim().toLowerCase()) {
    'sale' => MoneyMovementType.sale,
    'expense' => MoneyMovementType.expense,
    'owner_withdrawal' || 'withdrawal' => MoneyMovementType.ownerWithdrawal,
    'owner_contribution' ||
    'contribution' => MoneyMovementType.ownerContribution,
    _ => null,
  };
}

class _AmountParse {
  const _AmountParse({this.minorUnits, this.isInvalid = false});

  final int? minorUnits;
  final bool isInvalid;
}

_AmountParse _parseAmount(Map<String, dynamic> json) {
  if (!json.containsKey('amount_pula') && !json.containsKey('amount_minor')) {
    return const _AmountParse();
  }
  if (json.containsKey('amount_pula')) {
    final raw = json['amount_pula'];
    if (raw == null) {
      return const _AmountParse();
    }
    if (raw is String) {
      final minor = tryParseMinorUnits(raw);
      if (minor == null) {
        return const _AmountParse(isInvalid: true);
      }
      return _AmountParse(minorUnits: minor);
    }
    if (raw is int) {
      final minor = tryParseMinorUnits('$raw');
      if (minor == null) {
        return const _AmountParse(isInvalid: true);
      }
      return _AmountParse(minorUnits: minor);
    }
    return const _AmountParse(isInvalid: true);
  }
  final minorRaw = json['amount_minor'];
  if (minorRaw is int) {
    final minor = tryParseMinorUnits(
      '${minorRaw ~/ 100}.${(minorRaw % 100).toString().padLeft(2, '0')}',
    );
    if (minor == null) {
      return const _AmountParse(isInvalid: true);
    }
    return _AmountParse(minorUnits: minor);
  }
  return const _AmountParse(isInvalid: true);
}

String? _optionalString(Object? raw, {int maxLength = 80}) {
  if (raw is! String) {
    return null;
  }
  final value = raw.trim();
  if (value.isEmpty || value.length > maxLength) {
    return null;
  }
  return value;
}

int? _optionalPositiveInt(Object? raw) {
  if (raw is int && raw >= 1 && raw <= 1000000) {
    return raw;
  }
  return null;
}

String? _optionalCategory(MoneyMovementType type, Object? raw) {
  if (raw is! String) {
    return null;
  }
  final code = raw.trim().toLowerCase();
  if (!TransactionCategories.isAllowed(type, code)) {
    return null;
  }
  return code;
}

PaymentStatus? _optionalPaymentStatus(Object? raw) {
  if (raw is! String) {
    return null;
  }
  return switch (raw.trim().toLowerCase()) {
    'paid' => PaymentStatus.paid,
    'unpaid' => PaymentStatus.unpaid,
    _ => null,
  };
}

String? _optionalCurrency(Object? raw) {
  if (raw is! String) {
    return null;
  }
  final value = raw.trim().toUpperCase();
  if (value.isEmpty) {
    return null;
  }
  if (value == 'P' || value == 'PULA') {
    return 'BWP';
  }
  if (value == 'R' || value == 'RAND') {
    return 'ZAR';
  }
  if (value.length == 3) {
    return value;
  }
  return null;
}
