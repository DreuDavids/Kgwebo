import 'quantity.dart';
import 'unit_of_measure.dart';

/// Parses a user-entered decimal quantity into integer milli-units.
int? tryParseQuantityMilli(
  String raw, {
  UnitOfMeasure? unit,
  bool allowZero = true,
}) {
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
  if (fractionRaw.length > 3) {
    return null;
  }
  if (unit != null && !unit.allowsFraction && fractionRaw.isNotEmpty) {
    if (int.tryParse(fractionRaw) != 0) {
      return null;
    }
  }
  final whole = int.tryParse(wholeRaw);
  if (whole == null) {
    return null;
  }
  var paddedFraction = fractionRaw;
  while (paddedFraction.length < 3) {
    paddedFraction = '${paddedFraction}0';
  }
  final fraction = paddedFraction.isEmpty ? 0 : int.parse(paddedFraction);
  if (whole > Quantity.maxMilli ~/ Quantity.milliScale) {
    return null;
  }
  final milli = whole * Quantity.milliScale + fraction;
  if (milli > Quantity.maxMilli) {
    return null;
  }
  if (milli < 0) {
    return null;
  }
  if (milli == 0 && !allowZero) {
    return null;
  }
  if (unit != null &&
      !unit.allowsFraction &&
      milli % Quantity.milliScale != 0) {
    return null;
  }
  return milli;
}

final _digits = RegExp(r'^\d+$');
