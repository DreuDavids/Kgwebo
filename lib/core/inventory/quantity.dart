/// Integer milli-units for stock quantities. 1000 milli = 1 unit.
///
/// Binary [double] is not used. Three decimal places cover kg and litres
/// while `each` / `pack` stay whole units in the UI and validators.
abstract final class Quantity {
  static const milliScale = 1000;

  /// Largest quantity that fits in a signed 64-bit milli-unit column.
  static const maxMilli = 999999999999;
}
