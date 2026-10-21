import 'package:flutter/material.dart';

import 'kgwebo_colors.dart';

/// Type scale. Plus Jakarta Sans is the UI and greeting face.
/// Fraunces is reserved for the brand mark.
abstract final class KgweboTypography {
  static const String sans = 'PlusJakartaSans';
  static const String serif = 'Fraunces';

  static const TextStyle _sans = TextStyle(
    fontFamily: sans,
    color: KgweboColors.ink,
    height: 1.4,
  );

  static const TextStyle _serif = TextStyle(
    fontFamily: serif,
    color: KgweboColors.ink,
    height: 1.2,
  );

  /// Brand-mark face. Do not use for page titles or body copy.
  static TextStyle get brandMark => _serif.copyWith(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: KgweboColors.lime,
  );

  static TextTheme get textTheme {
    return TextTheme(
      displayLarge: _sans.copyWith(
        fontSize: 40,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.8,
        height: 1.15,
      ),
      displayMedium: _sans.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        height: 1.15,
      ),
      displaySmall: _sans.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 1.2,
      ),
      headlineLarge: _sans.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 1.25,
      ),
      headlineMedium: _sans.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        height: 1.25,
      ),
      headlineSmall: _sans.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        height: 1.3,
      ),
      titleLarge: _sans.copyWith(fontSize: 18, fontWeight: FontWeight.w700),
      titleMedium: _sans.copyWith(fontSize: 16, fontWeight: FontWeight.w600),
      titleSmall: _sans.copyWith(fontSize: 14, fontWeight: FontWeight.w600),
      bodyLarge: _sans.copyWith(fontSize: 16, fontWeight: FontWeight.w400),
      bodyMedium: _sans.copyWith(fontSize: 14, fontWeight: FontWeight.w400),
      bodySmall: _sans.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: KgweboColors.inkMuted,
      ),
      labelLarge: _sans.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
      labelMedium: _sans.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
      labelSmall: _sans.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
        color: KgweboColors.inkMuted,
      ),
    );
  }
}
