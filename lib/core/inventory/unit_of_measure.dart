enum UnitOfMeasure { each, pack, kilogram, litre, metre }

extension UnitOfMeasureX on UnitOfMeasure {
  String get storageValue {
    return switch (this) {
      UnitOfMeasure.each => 'each',
      UnitOfMeasure.pack => 'pack',
      UnitOfMeasure.kilogram => 'kilogram',
      UnitOfMeasure.litre => 'litre',
      UnitOfMeasure.metre => 'metre',
    };
  }

  String get label {
    return switch (this) {
      UnitOfMeasure.each => 'each',
      UnitOfMeasure.pack => 'pack',
      UnitOfMeasure.kilogram => 'kg',
      UnitOfMeasure.litre => 'litre',
      UnitOfMeasure.metre => 'metre',
    };
  }

  bool get allowsFraction {
    return switch (this) {
      UnitOfMeasure.each || UnitOfMeasure.pack => false,
      UnitOfMeasure.kilogram ||
      UnitOfMeasure.litre ||
      UnitOfMeasure.metre => true,
    };
  }

  static UnitOfMeasure fromStorage(String raw) {
    return switch (raw) {
      'each' => UnitOfMeasure.each,
      'pack' => UnitOfMeasure.pack,
      'kilogram' => UnitOfMeasure.kilogram,
      'litre' => UnitOfMeasure.litre,
      'metre' => UnitOfMeasure.metre,
      _ => throw FormatException('Unknown unit of measure', raw),
    };
  }
}
