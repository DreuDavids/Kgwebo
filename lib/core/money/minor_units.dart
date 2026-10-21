/// Integer minor-unit helpers. Binary [double] is not used for totals.
abstract final class MinorUnits {
  static const scale = 100;

  /// Formats [minor] as a decimal string. Grouping is for display only.
  static String format(int minor, {bool group = true, int decimals = 2}) {
    final sign = minor < 0 ? '-' : '';
    final abs = minor.abs();
    final factor = _pow10(decimals);
    final whole = abs ~/ factor;
    final fraction = (abs % factor).toString().padLeft(decimals, '0');
    final wholeText = group ? _groupDigits(whole) : whole.toString();
    return '$sign$wholeText.$fraction';
  }

  static int _pow10(int exponent) {
    var value = 1;
    for (var i = 0; i < exponent; i++) {
      value *= 10;
    }
    return value;
  }

  static String _groupDigits(int whole) {
    final raw = whole.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < raw.length; i++) {
      final remaining = raw.length - i;
      if (i > 0 && remaining % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(raw[i]);
    }
    return buffer.toString();
  }
}
