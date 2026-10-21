import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'kgwebo_colors.dart';
import 'kgwebo_elevation.dart';
import 'kgwebo_radii.dart';
import 'kgwebo_spacing.dart';
import 'kgwebo_typography.dart';

/// Light-only Kgwebo theme. Material 3 is off so surfaces are not seed-tinted.
abstract final class KgweboTheme {
  static ThemeData light() {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: KgweboColors.ink,
      onPrimary: KgweboColors.onInk,
      secondary: KgweboColors.lime,
      onSecondary: KgweboColors.onLime,
      error: KgweboColors.danger,
      onError: Colors.white,
      surface: KgweboColors.surface,
      onSurface: KgweboColors.ink,
    );

    final textTheme = KgweboTypography.textTheme;
    const pill = RoundedRectangleBorder(borderRadius: KgweboRadii.borderPill);
    const fieldBorder = OutlineInputBorder(
      borderRadius: KgweboRadii.borderMd,
      borderSide: BorderSide.none,
    );

    return ThemeData(
      useMaterial3: false,
      brightness: Brightness.light,
      applyElevationOverlayColor: false,
      colorScheme: colorScheme,
      primaryColor: KgweboColors.ink,
      scaffoldBackgroundColor: KgweboColors.canvas,
      canvasColor: KgweboColors.canvas,
      cardColor: KgweboColors.surface,
      dividerColor: KgweboColors.line,
      splashColor: KgweboColors.surfaceMuted,
      highlightColor: Colors.transparent,
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
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: KgweboColors.lime,
          foregroundColor: KgweboColors.onLime,
          disabledBackgroundColor: KgweboColors.surfaceMuted,
          disabledForegroundColor: KgweboColors.inkFaint,
          minimumSize: const Size(48, 52),
          elevation: KgweboElevation.none,
          shadowColor: Colors.transparent,
          shape: pill,
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: KgweboColors.ink,
          backgroundColor: KgweboColors.surface,
          minimumSize: const Size(48, 52),
          side: const BorderSide(color: KgweboColors.line),
          shape: pill,
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: KgweboColors.ink,
          minimumSize: const Size(48, 40),
          textStyle: textTheme.labelLarge,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: KgweboColors.ink,
          minimumSize: const Size(48, 48),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: KgweboColors.surfaceMuted,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: KgweboSpacing.md,
          vertical: KgweboSpacing.md,
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(color: KgweboColors.inkFaint),
        labelStyle: textTheme.titleSmall?.copyWith(
          color: KgweboColors.inkMuted,
        ),
        errorStyle: textTheme.bodySmall?.copyWith(color: KgweboColors.danger),
        border: fieldBorder,
        enabledBorder: fieldBorder,
        focusedBorder: OutlineInputBorder(
          borderRadius: KgweboRadii.borderMd,
          borderSide: const BorderSide(color: KgweboColors.ink, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: KgweboRadii.borderMd,
          borderSide: const BorderSide(color: KgweboColors.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: KgweboRadii.borderMd,
          borderSide: const BorderSide(color: KgweboColors.danger, width: 1.6),
        ),
      ),
      cardTheme: const CardThemeData(
        color: KgweboColors.surface,
        elevation: KgweboElevation.none,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: KgweboRadii.borderLg),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: KgweboColors.surfaceMuted,
        selectedColor: KgweboColors.lime,
        labelStyle: textTheme.labelMedium?.copyWith(color: KgweboColors.ink),
        shape: pill,
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(horizontal: KgweboSpacing.sm),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: KgweboColors.surface,
        elevation: 0,
        selectedItemColor: KgweboColors.ink,
        unselectedItemColor: KgweboColors.inkMuted,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: KgweboColors.canvas,
        elevation: KgweboElevation.none,
        indicatorColor: KgweboColors.ink,
        selectedIconTheme: const IconThemeData(color: KgweboColors.lime),
        unselectedIconTheme: const IconThemeData(color: KgweboColors.inkMuted),
        selectedLabelTextStyle: textTheme.labelMedium?.copyWith(
          color: KgweboColors.ink,
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
          color: KgweboColors.onInk,
        ),
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(borderRadius: KgweboRadii.borderLg),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: KgweboColors.surface,
        elevation: KgweboElevation.low,
        shape: RoundedRectangleBorder(borderRadius: KgweboRadii.borderXl),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: KgweboColors.surface,
        elevation: KgweboElevation.mid,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(KgweboRadii.xl),
          ),
        ),
      ),
      popupMenuTheme: const PopupMenuThemeData(
        color: KgweboColors.surface,
        elevation: KgweboElevation.mid,
        shape: RoundedRectangleBorder(borderRadius: KgweboRadii.borderLg),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: KgweboColors.ink,
        linearTrackColor: KgweboColors.surfaceMuted,
      ),
    );
  }
}
