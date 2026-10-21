import 'package:flutter/material.dart';

import 'kgwebo_colors.dart';

/// Neutral soft shadows. Cards sit on the cool canvas, not a tinted overlay.
abstract final class KgweboElevation {
  static const double none = 0;
  static const double low = 1;
  static const double mid = 3;

  static const List<BoxShadow> rest = [
    BoxShadow(color: Color(0x14000000), blurRadius: 24, offset: Offset(0, 10)),
  ];

  static const List<BoxShadow> soft = [
    BoxShadow(color: Color(0x12000000), blurRadius: 16, offset: Offset(0, 6)),
  ];

  static const BorderSide hairline = BorderSide(color: KgweboColors.line);
}
