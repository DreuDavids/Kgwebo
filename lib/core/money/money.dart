/// Integer minor-unit amount plus ISO currency code.
///
/// Binary [double] is not used. Arithmetic requires an explicit matching
/// currency; mixed currencies must not be added together.
class Money {
  const Money({required this.minorUnits, required this.currencyCode})
    : assert(currencyCode != '');

  final int minorUnits;
  final String currencyCode;

  bool get isZero => minorUnits == 0;

  bool get isNegative => minorUnits < 0;

  Money operator +(Money other) {
    _requireSameCurrency(other);
    return Money(
      minorUnits: minorUnits + other.minorUnits,
      currencyCode: currencyCode,
    );
  }

  Money operator -(Money other) {
    _requireSameCurrency(other);
    return Money(
      minorUnits: minorUnits - other.minorUnits,
      currencyCode: currencyCode,
    );
  }

  Money operator -() {
    return Money(minorUnits: -minorUnits, currencyCode: currencyCode);
  }

  void _requireSameCurrency(Money other) {
    if (currencyCode != other.currencyCode) {
      throw ArgumentError(
        'Cannot combine ${other.currencyCode} with $currencyCode.',
      );
    }
  }

  @override
  bool operator ==(Object other) {
    return other is Money &&
        other.minorUnits == minorUnits &&
        other.currencyCode == currencyCode;
  }

  @override
  int get hashCode => Object.hash(minorUnits, currencyCode);

  @override
  String toString() => 'Money($minorUnits $currencyCode)';
}
