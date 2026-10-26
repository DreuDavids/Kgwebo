import 'money_limits.dart';

/// Parses a user-entered decimal amount into integer minor units.
///
/// Two fraction digits are required by the current onboarding currencies.
/// Extra fraction digits are rejected rather than truncated. Scientific
/// notation and binary [double] conversion are not used.
int? tryParseMinorUnits(
  String raw, {
  int decimals = 2,
  bool allowZero = false,
}) {
  if (decimals < 0 || decimals > 8) {
    return null;
  }
  var text = raw.trim().replaceAll(',', '').replaceAll(' ', '');
  if (text.isEmpty) {
    return null;
  }
  if (text.startsWith('+')) {
    text = text.substring(1);
  }
  if (text.isEmpty || text.startsWith('-')) {
    return null;
  }
  if (text.contains('e') || text.contains('E')) {
    return null;
  }
  final parts = text.split('.');
  if (parts.length > 2) {
    return null;
  }
  final wholeRaw = parts.first;
  final fractionRaw = parts.length == 2 ? parts[1] : '';
  if (wholeRaw.isEmpty || !_digits.hasMatch(wholeRaw)) {
    return null;
  }
  if (fractionRaw.isNotEmpty && !_digits.hasMatch(fractionRaw)) {
    return null;
  }
  if (fractionRaw.length > decimals) {
    return null;
  }
  final whole = int.tryParse(wholeRaw);
  if (whole == null) {
    return null;
  }
  var paddedFraction = fractionRaw;
  while (paddedFraction.length < decimals) {
    paddedFraction = '${paddedFraction}0';
  }
  final fraction = paddedFraction.isEmpty ? 0 : int.parse(paddedFraction);
  final scale = _pow10(decimals);
  if (whole > MoneyLimits.maxMinorUnits ~/ scale) {
    return null;
  }
  final minor = whole * scale + fraction;
  final minimum = allowZero ? 0 : MoneyLimits.minPositiveMinorUnits;
  if (minor < minimum || minor > MoneyLimits.maxMinorUnits) {
    return null;
  }
  return minor;
}

final _digits = RegExp(r'^\d+$');

int _pow10(int exponent) {
  var value = 1;
  for (var i = 0; i < exponent; i++) {
    value *= 10;
  }
  return value;
}
