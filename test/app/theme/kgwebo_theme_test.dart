import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kgwebo/app/theme/kgwebo_colors.dart';
import 'package:kgwebo/app/theme/kgwebo_theme.dart';
import 'package:kgwebo/app/theme/kgwebo_typography.dart';

void main() {
  test('light theme constructs with the intended appearance', () {
    final theme = KgweboTheme.light();

    expect(theme.brightness, Brightness.light);
    expect(theme.useMaterial3, isFalse);
    expect(theme.scaffoldBackgroundColor, KgweboColors.canvas);
    expect(theme.colorScheme.primary, KgweboColors.ink);
    expect(theme.colorScheme.secondary, KgweboColors.lime);
    expect(theme.colorScheme.surface, KgweboColors.surface);
    expect(theme.colorScheme.onSurface, KgweboColors.ink);
  });

  test('required text styles use the bundled typefaces', () {
    final theme = KgweboTheme.light();
    final text = theme.textTheme;

    expect(text.displayLarge?.fontFamily, KgweboTypography.sans);
    expect(text.displayMedium?.fontFamily, KgweboTypography.sans);
    expect(text.headlineLarge?.fontFamily, KgweboTypography.sans);
    expect(text.bodyLarge?.fontFamily, KgweboTypography.sans);
    expect(text.bodyMedium?.fontFamily, KgweboTypography.sans);
    expect(text.labelLarge?.fontFamily, KgweboTypography.sans);
    expect(text.titleMedium?.fontFamily, KgweboTypography.sans);
    expect(KgweboTypography.brandMark.fontFamily, KgweboTypography.serif);
  });

  test('component themes are configured', () {
    final theme = KgweboTheme.light();

    expect(theme.appBarTheme.elevation, 0);
    expect(theme.appBarTheme.backgroundColor, KgweboColors.canvas);
    expect(theme.inputDecorationTheme.filled, isTrue);
    expect(theme.inputDecorationTheme.fillColor, KgweboColors.surfaceMuted);
    expect(theme.navigationRailTheme.backgroundColor, KgweboColors.canvas);
    expect(theme.cardTheme.elevation, 0);
    expect(theme.chipTheme.showCheckmark, isFalse);
    expect(theme.progressIndicatorTheme.color, KgweboColors.ink);
  });
}
