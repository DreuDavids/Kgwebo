import 'package:flutter_test/flutter_test.dart';
import 'package:kgwebo/core/money/minor_units.dart';

void main() {
  test('formats integer minor units without binary floats', () {
    expect(MinorUnits.format(0, group: false), '0.00');
    expect(MinorUnits.format(1050, group: false), '10.50');
    expect(MinorUnits.format(200000), '2,000.00');
    expect(MinorUnits.format(1, group: false), '0.01');
  });

  test('opening cash display is not treated as revenue', () {
    const opening = 200000;
    const sale = 50000;
    expect(MinorUnits.format(opening, group: false), '2000.00');
    expect(opening, isNot(sale));
  });
}
