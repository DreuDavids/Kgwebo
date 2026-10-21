import 'minor_units.dart';
import 'money.dart';

/// Display-only money formatting. Never used as an arithmetic input.
abstract final class MoneyFormatter {
  static String format(Money amount, {bool group = true}) {
    return formatMinor(
      amount.minorUnits,
      currencyCode: amount.currencyCode,
      group: group,
    );
  }

  static String formatMinor(
    int minor, {
    required String currencyCode,
    bool group = true,
  }) {
    final number = MinorUnits.format(minor, group: group);
    return '${_symbol(currencyCode)} $number';
  }

  static String _symbol(String currencyCode) {
    return switch (currencyCode) {
      'BWP' => 'P',
      _ => currencyCode,
    };
  }
}
