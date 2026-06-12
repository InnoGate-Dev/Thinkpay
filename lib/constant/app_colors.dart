import 'package:flutter/material.dart';

// ── Dark-mode colours (existing) ──────────────────────────────────────────────
class AppColors {
  AppColors._();

  static const Color dark     = Color(0xFF0A0A0A);
  static const Color surface  = Color(0xFF141414);
  static const Color surface2 = Color(0xFF1E1E1E);
  static const Color border   = Color(0xFF2A2A2A);
  static const Color lime     = Color(0xFFC1FF72);
  static const Color red      = Color(0xFFFF6B6B);
  static const Color blue     = Color(0xFF72B4FF);

  // Text shades (dark mode)
  static const Color w100 = Color(0xFFFFFFFF);
  static const Color w70  = Color(0xB3FFFFFF);
  static const Color w40  = Color(0x66FFFFFF);
  static const Color w20  = Color(0x33FFFFFF);
  static const Color w10  = Color(0x1AFFFFFF);

  // Lime tinted surfaces
  static const Color limeDim    = Color(0x1AC1FF72);
  static const Color limeBorder = Color(0x40C1FF72);

  // Red tinted
  static const Color redDim = Color(0x1AFF6B6B);

  // Chart palette
  static const List<Color> chart = [
    Color(0xFFC1FF72),
    Color(0xFF72B4FF),
    Color(0xFFFF72C1),
    Color(0xFFFFC172),
    Color(0xFF72FFC1),
    Color(0xFFFF7272),
    Color(0xFF9072FF),
    Color(0xFFFF9072),
  ];
}

// ── Adaptive colour token set ─────────────────────────────────────────────────
/// Get the right colour for the current theme brightness.
/// Usage: `ThemeColors.of(context).background`
class ThemeColors {
  const ThemeColors._({
    required this.background,
    required this.surface,
    required this.surface2,
    required this.border,
    required this.text100,
    required this.text70,
    required this.text40,
    required this.text20,
    required this.text10,
    required this.lime,
    required this.limeAccent,   // darker lime variant for light-mode text
    required this.limeDim,
    required this.limeBorder,
    required this.red,
    required this.redDim,
    required this.cardGradientStart,
    required this.cardGradientEnd,
  });

  final Color background;
  final Color surface;
  final Color surface2;
  final Color border;
  final Color text100;
  final Color text70;
  final Color text40;
  final Color text20;
  final Color text10;
  final Color lime;
  final Color limeAccent;
  final Color limeDim;
  final Color limeBorder;
  final Color red;
  final Color redDim;
  final Color cardGradientStart;
  final Color cardGradientEnd;

  static ThemeColors of(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? _dark : _light;
  }

  // ── Dark theme tokens ──────────────────────────────────────────────────────
  static const ThemeColors _dark = ThemeColors._(
    background:         Color(0xFF0A0A0A),
    surface:            Color(0xFF141414),
    surface2:           Color(0xFF1E1E1E),
    border:             Color(0xFF2A2A2A),
    text100:            Color(0xFFFFFFFF),
    text70:             Color(0xB3FFFFFF),
    text40:             Color(0x66FFFFFF),
    text20:             Color(0x33FFFFFF),
    text10:             Color(0x1AFFFFFF),
    lime:               Color(0xFFC1FF72),
    limeAccent:         Color(0xFFC1FF72),
    limeDim:            Color(0x1AC1FF72),
    limeBorder:         Color(0x40C1FF72),
    red:                Color(0xFFFF6B6B),
    redDim:             Color(0x1AFF6B6B),
    cardGradientStart:  Color(0xFF1C2E10),
    cardGradientEnd:    Color(0xFF0F1A08),
  );

  // ── Light theme tokens ─────────────────────────────────────────────────────
  static const ThemeColors _light = ThemeColors._(
    background:         Color(0xFFF5F7F2),
    surface:            Color(0xFFFFFFFF),
    surface2:           Color(0xFFF0F4EA),
    border:             Color(0xFFDDE5D4),
    text100:            Color(0xFF111111),
    text70:             Color(0xFF444444),
    text40:             Color(0xFF888888),
    text20:             Color(0xFFCCCCCC),
    text10:             Color(0xFFEEEEEE),
    lime:               Color(0xFF5CAD00),   // darker for contrast on light bg
    limeAccent:         Color(0xFF5CAD00),
    limeDim:            Color(0x1A5CAD00),
    limeBorder:         Color(0x405CAD00),
    red:                Color(0xFFD94F4F),
    redDim:             Color(0x1AD94F4F),
    cardGradientStart:  Color(0xFFE8F5D6),
    cardGradientEnd:    Color(0xFFD4EDBC),
  );
}

// ── Material ThemeData factories ──────────────────────────────────────────────
class AppTheme {
  AppTheme._();

  static ThemeData dark() => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF0A0A0A),
    colorScheme: const ColorScheme.dark(
      primary:   Color(0xFFC1FF72),
      onPrimary: Color(0xFF0A0A0A),
      surface:   Color(0xFF141414),
      onSurface: Color(0xFFFFFFFF),
      error:     Color(0xFFFF6B6B),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF141414),
      foregroundColor: Color(0xFFFFFFFF),
      elevation: 0,
    ),
    fontFamily: 'Roboto',
  );

  static ThemeData light() => ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF5F7F2),
    colorScheme: const ColorScheme.light(
      primary:   Color(0xFF5CAD00),
      onPrimary: Color(0xFFFFFFFF),
      surface:   Color(0xFFFFFFFF),
      onSurface: Color(0xFF111111),
      error:     Color(0xFFD94F4F),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFFFFFFF),
      foregroundColor: Color(0xFF111111),
      elevation: 0,
    ),
    fontFamily: 'Roboto',
  );
}
