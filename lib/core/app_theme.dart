import 'package:flutter/cupertino.dart';

/// Semantic color tokens. Every token adapts to light / dark mode.
abstract final class AppColors {
  static const accent = CupertinoColors.systemIndigo;
  static const income = CupertinoColors.systemGreen;
  static const expense = CupertinoColors.systemRed;

  static const background = CupertinoColors.systemGroupedBackground;
  static const surface = CupertinoColors.secondarySystemGroupedBackground;
  static const label = CupertinoColors.label;
  static const secondaryLabel = CupertinoColors.secondaryLabel;
  static const tertiaryLabel = CupertinoColors.tertiaryLabel;
  static const separator = CupertinoColors.separator;
  static const fill = CupertinoColors.tertiarySystemFill;

  /// Hero card gradient (kept the same in both themes – white text on top).
  static const heroGradient = [Color(0xFF5E5CE6), Color(0xFF8E44EC)];
}

abstract final class AppTheme {
  static const theme = CupertinoThemeData(
    primaryColor: AppColors.accent,
    scaffoldBackgroundColor: AppColors.background,
    barBackgroundColor: CupertinoDynamicColor.withBrightness(
      color: Color(0xCCF2F2F7),
      darkColor: Color(0xCC000000),
    ),
  );
}

/// 4pt spacing scale.
abstract final class Gap {
  static const xs = 4.0;
  static const s = 8.0;
  static const m = 12.0;
  static const l = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;
}

abstract final class Fmt {
  /// Change this to 'so\'m', '€', etc.
  static const currency = '\$';

  static String money(double value, {bool signed = false, bool? income}) {
    final abs = value.abs();
    final parts = abs.toStringAsFixed(2).split('.');
    final whole = parts[0].replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => ',',
    );
    final sign = signed ? (income == true ? '+' : '−') : (value < 0 ? '−' : '');
    return '$sign$currency$whole.${parts[1]}';
  }
}

const tabular = [FontFeature.tabularFigures()];
