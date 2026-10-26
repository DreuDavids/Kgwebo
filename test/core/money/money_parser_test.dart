import 'package:flutter_test/flutter_test.dart';
import 'package:kgwebo/core/money/money_formatter.dart';
import 'package:kgwebo/core/money/money_parser.dart';

void main() {
  test('parses pula without using binary floats', () {
    expect(tryParseMinorUnits('10.50'), 1050);
    expect(tryParseMinorUnits('10.5'), 1050);
    expect(tryParseMinorUnits('2,000'), 200000);
    expect(tryParseMinorUnits('0.01'), 1);
  });

  test('rejects zero, negative, and truncated fractions', () {
    expect(tryParseMinorUnits('0'), isNull);
    expect(tryParseMinorUnits('0.00'), isNull);
    expect(tryParseMinorUnits('-1.00'), isNull);
    expect(tryParseMinorUnits('1.001'), isNull);
    expect(tryParseMinorUnits('1e2'), isNull);
    expect(tryParseMinorUnits(''), isNull);
  });

  test('allowZero accepts a zero amount without binary doubles', () {
    expect(tryParseMinorUnits('0', allowZero: true), 0);
    expect(tryParseMinorUnits('0.00', allowZero: true), 0);
    expect(tryParseMinorUnits('1e2', allowZero: true), isNull);
    expect(tryParseMinorUnits('-1.00', allowZero: true), isNull);
  });

  test('formats BWP with a pula symbol', () {
    expect(
      MoneyFormatter.formatMinor(200000, currencyCode: 'BWP'),
      'P 2,000.00',
    );
    expect(
      MoneyFormatter.formatMinor(255000, currencyCode: 'BWP', group: false),
      'P 2550.00',
    );
  });
}
