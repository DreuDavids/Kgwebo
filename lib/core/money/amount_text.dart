/// Formats integer minor units as the decimal text the write maps parse.
String amountTextFromMinor(int minor, {int decimals = 2}) {
  if (decimals < 0 || decimals > 8) {
    throw ArgumentError.value(decimals, 'decimals');
  }
  final sign = minor < 0 ? '-' : '';
  final absolute = minor.abs();
  var scale = 1;
  for (var i = 0; i < decimals; i++) {
    scale *= 10;
  }
  final whole = absolute ~/ scale;
  final fraction = (absolute % scale).toString().padLeft(decimals, '0');
  if (decimals == 0) {
    return '$sign$whole';
  }
  return '$sign$whole.$fraction';
}
