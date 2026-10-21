import 'package:flutter/material.dart';

/// Canonical Kgwebo colour tokens. Widgets must use these instead of
/// ad-hoc hex values.
abstract final class KgweboColors {
  static const Color forest = Color(0xFF143D2C);
  static const Color forestBright = Color(0xFF1F5C40);
  static const Color onForest = Color(0xFFF7F4EE);
  static const Color forestContainer = Color(0xFFD7E8DC);

  static const Color teal = Color(0xFF1A7A72);
  static const Color tealSoft = Color(0xFFD7EDEA);

  static const Color amber = Color(0xFFC4841D);
  static const Color amberSoft = Color(0xFFF6E7C8);

  static const Color canvas = Color(0xFFF5F1E8);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFEFEBE1);

  static const Color ink = Color(0xFF1C1917);
  static const Color inkMuted = Color(0xFF5C574F);
  static const Color inkFaint = Color(0xFF8A8478);

  static const Color line = Color(0xFFDDD6C7);

  static const Color success = Color(0xFF166534);
  static const Color warning = Color(0xFFB45309);
  static const Color danger = Color(0xFFB42318);
}
