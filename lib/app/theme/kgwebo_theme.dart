import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'kgwebo_colors.dart';
import 'kgwebo_elevation.dart';
import 'kgwebo_radii.dart';
import 'kgwebo_spacing.dart';
import 'kgwebo_typography.dart';

/// Light-only Kgwebo Material 3 theme.
abstract final class KgweboTheme {
  static ThemeData light() {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: KgweboColors.forest,
      onPrimary: KgweboColors.onForest,
      primaryContainer: KgweboColors.forestContainer,
      onPrimaryContainer: KgweboColors.forest,
      secondary: KgweboColors.teal,
      onSecondary: Colors.white,
      secondaryContainer: KgweboColors.tealSoft,
      onSecondaryContainer: KgweboColors.forest,
      tertiary: KgweboColors.amber,
      onTertiary: Colors.white,
      tertiaryContainer: KgweboColors.amberSoft,
      onTertiaryContainer: KgweboColors.ink,
      error: KgweboColors.danger,
      onError: Colors.white,
      errorContainer: Color(0xFFF9DEDC),
      onErrorContainer: KgweboColors.danger,
      surface: KgweboColors.surface,
      onSurface: KgweboColors.ink,
      onSurfaceVariant: KgweboColors.inkMuted,
      outline: KgweboColors.line,
      outlineVariant: KgweboColors.line,
      shadow: Color(0x1A000000),
      scrim: Color(0x99000000),
      inverseSurface: KgweboColors.ink,
      onInverseSurface: KgweboColors.canvas,
      inversePrimary: KgweboColors.forestContainer,
    );

    final textTheme = KgweboTypography.textTheme;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: KgweboColors.canvas,
      canvasColor: KgweboColors.canvas,
      fontFamily: KgweboTypography.sans,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      appBarTheme: AppBarTheme(
        elevation: KgweboElevation.none,
        scrolledUnderElevation: KgweboElevation.none,
        backgroundColor: KgweboColors.canvas,
        foregroundColor: KgweboColors.ink,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
        systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: KgweboColors.canvas,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: KgweboColors.forest,
          foregroundColor: KgweboColors.onForest,
          disabledBackgroundColor: KgweboColors.surfaceMuted,
          disabledForegroundColor: KgweboColors.inkFaint,
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(
            horizontal: KgweboSpacing.lg,
            vertical: KgweboSpacing.sm,
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: KgweboRadii.borderMd,
          ),
          elevation: KgweboElevation.none,
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: KgweboColors.forest,
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(
            horizontal: KgweboSpacing.lg,
            vertical: KgweboSpacing.sm,
          ),
          side: const BorderSide(color: KgweboColors.forest, width: 1.2),
          shape: const RoundedRectangleBorder(
            borderRadius: KgweboRadii.borderMd,
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: KgweboColors.teal,
          minimumSize: const Size(48, 40),
          textStyle: textTheme.labelLarge,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: KgweboColors.forest,
          minimumSize: const Size(48, 48),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: KgweboColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: KgweboSpacing.md,
          vertical: KgweboSpacing.md,
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(color: KgweboColors.inkFaint),
        labelStyle: textTheme.titleSmall?.copyWith(
          color: KgweboColors.inkMuted,
        ),
        errorStyle: textTheme.bodySmall?.copyWith(color: KgweboColors.danger),
        border: const OutlineInputBorder(
          borderRadius: KgweboRadii.borderMd,
          borderSide: BorderSide(color: KgweboColors.line),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: KgweboRadii.borderMd,
          borderSide: BorderSide(color: KgweboColors.line),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: KgweboRadii.borderMd,
          borderSide: BorderSide(color: KgweboColors.forest, width: 1.6),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: KgweboRadii.borderMd,
          borderSide: BorderSide(color: KgweboColors.danger),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: KgweboRadii.borderMd,
          borderSide: BorderSide(color: KgweboColors.danger, width: 1.6),
        ),
      ),
      cardTheme: const CardThemeData(
        color: KgweboColors.surface,
        elevation: KgweboElevation.none,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: KgweboRadii.borderMd,
          side: KgweboElevation.hairline,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: KgweboElevation.none,
        height: 72,
        backgroundColor: KgweboColors.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: KgweboColors.tealSoft,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final base = textTheme.labelMedium;
          if (states.contains(WidgetState.selected)) {
            return base?.copyWith(color: KgweboColors.forest);
          }
          return base?.copyWith(color: KgweboColors.inkMuted);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: KgweboColors.forest, size: 24);
          }
          return const IconThemeData(color: KgweboColors.inkMuted, size: 24);
        }),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: KgweboColors.surface,
        elevation: KgweboElevation.none,
        indicatorColor: KgweboColors.tealSoft,
        selectedIconTheme: const IconThemeData(color: KgweboColors.forest),
        unselectedIconTheme: const IconThemeData(color: KgweboColors.inkMuted),
        selectedLabelTextStyle: textTheme.labelMedium?.copyWith(
          color: KgweboColors.forest,
        ),
        unselectedLabelTextStyle: textTheme.labelMedium?.copyWith(
          color: KgweboColors.inkMuted,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: KgweboColors.line,
        space: 1,
        thickness: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: KgweboColors.ink,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: KgweboColors.canvas,
        ),
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(borderRadius: KgweboRadii.borderMd),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: KgweboColors.surface,
        elevation: KgweboElevation.low,
        shape: RoundedRectangleBorder(borderRadius: KgweboRadii.borderLg),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: KgweboColors.surface,
        elevation: KgweboElevation.mid,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(KgweboRadii.lg),
          ),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: KgweboColors.forest,
        linearTrackColor: KgweboColors.surfaceMuted,
      ),
    );
  }
}
