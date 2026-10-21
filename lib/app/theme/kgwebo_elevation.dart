import 'package:flutter/material.dart';

import 'kgwebo_colors.dart';

/// Restrained elevation. Prefer borders; use shadow only for floating sheets.
abstract final class KgweboElevation {
  static const double none = 0;
  static const double low = 1;
  static const double mid = 3;

  static const List<BoxShadow> rest = [
    BoxShadow(color: Color(0x14000000), blurRadius: 18, offset: Offset(0, 8)),
  ];

  static const BorderSide hairline = BorderSide(color: KgweboColors.line);
}
