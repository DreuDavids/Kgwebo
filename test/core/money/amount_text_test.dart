import 'package:flutter_test/flutter_test.dart';
import 'package:kgwebo/core/money/amount_text.dart';

void main() {
  test('formats integer minor units without binary doubles', () {
    expect(amountTextFromMinor(50000), '500.00');
    expect(amountTextFromMinor(1), '0.01');
    expect(amountTextFromMinor(100), '1.00');
  });
}
