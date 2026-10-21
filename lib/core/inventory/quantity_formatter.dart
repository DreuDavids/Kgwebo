import 'quantity.dart';

/// Display-only quantity formatting. Never used as an arithmetic input.
abstract final class QuantityFormatter {
  static String format(int milli) {
    final sign = milli < 0 ? '-' : '';
    final abs = milli.abs();
    final whole = abs ~/ Quantity.milliScale;
    var fraction = (abs % Quantity.milliScale).toString().padLeft(3, '0');
    fraction = fraction.replaceFirst(RegExp(r'0+$'), '');
    if (fraction.isEmpty) {
      return '$sign$whole';
    }
    return '$sign$whole.$fraction';
  }

  static String formatWithUnit(int milli, String unitLabel) {
    return '${format(milli)} $unitLabel';
  }
}
