import 'package:flutter/material.dart';

/// Canonical Kgwebo colour tokens. Widgets must use these instead of
/// ad-hoc hex values.
///
/// Light canvas with black hero cards and lime accents only. Lime is never
/// a full-screen fill.
abstract final class KgweboColors {
  static const Color ink = Color(0xFF111111);
  static const Color onInk = Color(0xFFFFFFFF);
  static const Color inkMuted = Color(0xFF6B7280);
  static const Color inkFaint = Color(0xFF9CA3AF);

  static const Color lime = Color(0xFFC6FF4A);
  static const Color onLime = Color(0xFF111111);
  static const Color limeSoft = Color(0xFFEEF8C8);
  static const Color heroWell = Color(0xFF2A2A2A);

  static const Color canvas = Color(0xFFF4F5F7);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFEEF0F3);

  static const Color line = Color(0xFFE6E8EC);

  static const Color amber = Color(0xFFC4841D);
  static const Color amberSoft = Color(0xFFF6E7C8);

  static const Color success = Color(0xFF166534);
  static const Color warning = Color(0xFFB45309);
  static const Color danger = Color(0xFFB42318);
}
