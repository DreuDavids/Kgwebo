import '../../../core/finance/business_calendar.dart';
import '../../../core/finance/ledger_entry.dart';
import '../../../core/money/currency_names.dart';
import '../../../core/money/money_parser.dart';
import '../domain/extracted_draft.dart';

final _wordCount = {
  'a': 1,
  'an': 1,
  'one': 1,
  'two': 2,
  'three': 3,
  'four': 4,
  'five': 5,
  'six': 6,
  'seven': 7,
  'eight': 8,
  'nine': 9,
  'ten': 10,
};

final _qtyPattern = RegExp(
  r'\b(\d+|one|two|three|four|five|six|seven|eight|nine|ten|a|an)\b',
  caseSensitive: false,
);

final _qtyBeforeNoun = RegExp(
  r'\b(\d+|one|two|three|four|five|six|seven|eight|nine|ten|a|an)\s+([a-z]{3,})\b',
  caseSensitive: false,
);

const _qtyNounSkip = {
  'for',
  'the',
  'and',
  'from',
  'with',
  'myself',
  'home',
  'pula',
  'rand',
  'each',
  'this',
};

final _prefixAmount = RegExp(
  r'\b(p|pula|zar|r|nad|usd)\s*(\d+(?:\.\d{1,2})?)\b',
  caseSensitive: false,
);

final _suffixAmount = RegExp(
  r'\b(\d+(?:\.\d{1,2})?)\s*(zar|pulas?|bwp|p|rands?|nad|usd|dollars?)\b',
  caseSensitive: false,
);

final _unitEach = RegExp(
  r'(\d+(?:\.\d{1,2})?)\s*(?:(zar|pulas?|bwp|p|rands?|nad|usd|dollars?))?\s*each\b',
  caseSensitive: false,
);

final _atPrice = RegExp(
  r'\b(?:at|@)\s*(?:(p|pula|zar|r|nad|usd)\s*)?(\d+(?:\.\d{1,2})?)',
  caseSensitive: false,
);

final _verbAmount = RegExp(
  r'\b(?:spent|paid|cost|of)\s+(?:(p|pula|zar|r|nad|usd)\s*)?(\d+(?:\.\d{1,2})?)\b',
  caseSensitive: false,
);

final _bareNumber = RegExp(r'\b(\d+(?:\.\d{1,2})?)\b');

/// Deterministic drafts from common trader phrasing. Never converts currencies.
List<ExtractedDraft> extractHeuristicDrafts(
  String raw, {
  String currencyCode = 'BWP',
  DateTime? now,
}) {
  final text = raw.trim();
  if (text.isEmpty) {
    return const [];
  }
  final chunks = _splitEvents(text);
  final drafts = <ExtractedDraft>[];
  for (final chunk in chunks) {
    final draft = _extractOne(
      chunk,
      currencyCode,
      now ?? DateTime.now().toUtc(),
    );
    if (draft != null) {
      drafts.add(draft);
    }
  }
  return drafts;
}

List<String> _splitEvents(String text) {
  final lower = text.toLowerCase();
  final hasSale = lower.contains('sold') || lower.contains('sale');
  final hasExpense =
      lower.contains('bought') ||
      lower.contains('spent') ||
      lower.contains('paid');
  if (hasSale && hasExpense) {
    final parts = text.split(RegExp(r'\band\b', caseSensitive: false));
    if (parts.length >= 2) {
      return parts
          .map((part) => part.trim())
          .where((part) => part.isNotEmpty)
          .toList();
    }
  }
  return [text];
}

ExtractedDraft? _extractOne(String chunk, String currencyCode, DateTime now) {
  final lower = chunk.toLowerCase();
  final type = _typeOf(lower);
  if (type == null) {
    return null;
  }

  final each = lower.contains('each');
  final money = _firstAmount(lower);
  final qty = _quantityOf(_quantityToken(lower, money));
  final item = _guessItem(lower, type) ?? (money == null ? null : 'other');
  final category = _guessCategory(type, lower, item);
  final payment = _guessPayment(lower, type);
  final occurredOn = _guessOccurredOn(lower, now);

  if (money == null) {
    return ExtractedDraft(
      type: type,
      item: item,
      quantity: qty,
      categoryCode: category,
      paymentStatus: payment,
      occurredOn: occurredOn,
      businessCurrencyCode: currencyCode,
    );
  }

  final named = money.currency;
  final unit = money.minor;
  final foreign = named != null && named != currencyCode;

  int? amountMinor;
  if (!foreign) {
    amountMinor = each && qty != null ? unit * qty : unit;
  }

  return ExtractedDraft(
    type: type,
    amountMinor: amountMinor,
    quantity: qty,
    item: item,
    categoryCode: category,
    paymentStatus: payment,
    occurredOn: occurredOn,
    detectedCurrencyCode: named ?? currencyCode,
    businessCurrencyCode: currencyCode,
    note:
        foreign
            ? 'Named ${qty ?? 1} × ${_labelAmount(unit)} $named. Enter the amount in ${CurrencyNames.spoken(currencyCode)}.'
            : null,
  );
}

class _MoneyHit {
  const _MoneyHit({required this.minor, this.currency});

  final int minor;
  final String? currency;
}

_MoneyHit? _firstAmount(String lower) {
  final prefix = _prefixAmount.firstMatch(lower);
  if (prefix != null) {
    final minor = tryParseMinorUnits(prefix.group(2)!);
    if (minor != null) {
      return _MoneyHit(
        minor: minor,
        currency: CurrencyNames.codeOf(prefix.group(1)),
      );
    }
  }
  final suffix = _suffixAmount.firstMatch(lower);
  if (suffix != null) {
    final minor = tryParseMinorUnits(suffix.group(1)!);
    if (minor != null) {
      return _MoneyHit(
        minor: minor,
        currency: CurrencyNames.codeOf(suffix.group(2)),
      );
    }
  }
  final eachHit = _unitEach.firstMatch(lower);
  if (eachHit != null) {
    final minor = tryParseMinorUnits(eachHit.group(1)!);
    if (minor != null) {
      return _MoneyHit(
        minor: minor,
        currency: CurrencyNames.codeOf(eachHit.group(2)),
      );
    }
  }
  final atHit = _atPrice.firstMatch(lower);
  if (atHit != null) {
    final minor = tryParseMinorUnits(atHit.group(2)!);
    if (minor != null) {
      return _MoneyHit(
        minor: minor,
        currency: CurrencyNames.codeOf(atHit.group(1)),
      );
    }
  }
  final verbHit = _verbAmount.firstMatch(lower);
  if (verbHit != null) {
    final minor = tryParseMinorUnits(verbHit.group(2)!);
    if (minor != null) {
      return _MoneyHit(
        minor: minor,
        currency: CurrencyNames.codeOf(verbHit.group(1)),
      );
    }
  }
  final qtyHit = _qtyBeforeNoun.firstMatch(lower);
  final qtyNoun = qtyHit?.group(2)?.toLowerCase();
  final qtyIsItem =
      qtyHit != null && qtyNoun != null && !_qtyNounSkip.contains(qtyNoun);
  final numbers = _bareNumber.allMatches(lower).toList();
  for (final hit in numbers.reversed) {
    if (qtyIsItem && hit.start == qtyHit.start) {
      continue;
    }
    final minor = tryParseMinorUnits(hit.group(1)!);
    if (minor != null) {
      return _MoneyHit(minor: minor);
    }
  }
  return null;
}

String? _quantityToken(String lower, _MoneyHit? money) {
  var text = lower;
  if (money != null) {
    text = text
        .replaceAll(_prefixAmount, ' ')
        .replaceAll(_suffixAmount, ' ')
        .replaceAll(_unitEach, ' ')
        .replaceAll(_atPrice, ' ')
        .replaceAll(_verbAmount, ' ');
  }
  final beforeNoun = _qtyBeforeNoun.firstMatch(text);
  final noun = beforeNoun?.group(2)?.toLowerCase();
  if (beforeNoun != null && noun != null && !_qtyNounSkip.contains(noun)) {
    return beforeNoun.group(1);
  }
  return _qtyPattern.firstMatch(text)?.group(1);
}

MoneyMovementType? _typeOf(String lower) {
  if (RegExp(r'\b(took|drawn|drawing|withdraw|ke tsere)\b').hasMatch(lower)) {
    return MoneyMovementType.ownerWithdrawal;
  }
  if (lower.contains('sold') ||
      lower.contains('sale') ||
      lower.contains('received') ||
      lower.contains('rekisitse')) {
    return MoneyMovementType.sale;
  }
  if (lower.contains('bought') ||
      lower.contains('spent') ||
      lower.contains('paid') ||
      lower.contains('expense') ||
      lower.contains('rekile') ||
      lower.contains('airtime')) {
    return MoneyMovementType.expense;
  }
  return null;
}

int? _quantityOf(String? raw) {
  if (raw == null) {
    return null;
  }
  final word = _wordCount[raw.toLowerCase()];
  if (word != null) {
    return word;
  }
  return int.tryParse(raw);
}

PaymentStatus? _guessPayment(String lower, MoneyMovementType type) {
  if (RegExp(
    r'\b(unpaid|not (yet )?paid|on credit|ka mokgele|will pay|still owe)\b',
  ).hasMatch(lower)) {
    return PaymentStatus.unpaid;
  }
  if (RegExp(
    r'\b(bought|spent|paid|already paid|rekile|rekisitse)\b',
  ).hasMatch(lower)) {
    return PaymentStatus.paid;
  }
  if (type == MoneyMovementType.sale &&
      RegExp(r'\b(sold|received|got paid)\b').hasMatch(lower)) {
    return PaymentStatus.paid;
  }
  if (type == MoneyMovementType.ownerWithdrawal) {
    return PaymentStatus.paid;
  }
  return null;
}

String? _guessItem(String lower, MoneyMovementType type) {
  if (type == MoneyMovementType.expense && lower.contains('transport')) {
    return 'transport';
  }
  if (lower.contains('airtime')) {
    return 'airtime';
  }
  if (lower.contains('domain')) {
    return 'domains';
  }
  if (lower.contains('shirt') || lower.contains('dihempe')) {
    return 'shirts';
  }
  if (lower.contains('fat cake')) {
    return 'fat cakes';
  }
  final bought = RegExp(
    r'\b(?:bought|spent|paid|sold|rekile|rekisitse)\s+(?:\d+|one|two|three|four|five|six|seven|eight|nine|ten|a|an)\s+([a-z]{3,})',
    caseSensitive: false,
  ).firstMatch(lower);
  final noun = bought?.group(1);
  if (noun != null &&
      !{'pula', 'pulas', 'rand', 'rands', 'each', 'for', 'ka'}.contains(noun)) {
    return noun;
  }
  return null;
}

String? _guessCategory(MoneyMovementType type, String lower, String? item) {
  if (type == MoneyMovementType.ownerWithdrawal) {
    return 'owner_withdrawal';
  }
  if (type == MoneyMovementType.expense) {
    if (lower.contains('transport') || item == 'transport') {
      return 'transport';
    }
    if (lower.contains('airtime') || lower.contains('utilit')) {
      return 'utilities';
    }
    if (lower.contains('domain') || lower.contains('fee')) {
      return 'fees';
    }
    if (lower.contains('rent')) {
      return 'rent';
    }
    return 'other_expense';
  }
  if (type == MoneyMovementType.sale) {
    if (lower.contains('shirt') ||
        lower.contains('good') ||
        lower.contains('fat cake')) {
      return 'goods';
    }
    return 'other_sale';
  }
  return null;
}

DateTime? _guessOccurredOn(String lower, DateTime now) {
  final wall = BusinessCalendar.gaboroneWallTime(now);
  if (lower.contains('yesterday') || lower.contains('maabane')) {
    return BusinessCalendar.utcFromGaborone(
      year: wall.year,
      month: wall.month,
      day: wall.day - 1,
    );
  }
  if (lower.contains('today') || lower.contains('kajeno')) {
    return BusinessCalendar.utcFromGaborone(
      year: wall.year,
      month: wall.month,
      day: wall.day,
    );
  }
  return null;
}

String _labelAmount(int minor) {
  final whole = minor ~/ 100;
  final fraction = (minor % 100).toString().padLeft(2, '0');
  return '$whole.$fraction';
}
