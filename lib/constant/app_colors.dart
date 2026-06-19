import 'package:flutter/material.dart';

// ── Legacy static palette (kept for chart colours) ────────────────────────────
class AppColors {
  AppColors._();

  static const Color dark     = Color(0xFF080A0D);
  static const Color surface  = Color(0xFF111318);
  static const Color surface2 = Color(0xFF1A1D24);
  static const Color border   = Color(0xFF252830);
  static const Color teal     = Color(0xFF00D4B4);
  static const Color red      = Color(0xFFFF5A5A);
  static const Color blue     = Color(0xFF7C86F5);

  // Text shades (dark mode)
  static const Color w100 = Color(0xFFF2F4F8);
  static const Color w70  = Color(0xFFB0B6C0);
  static const Color w40  = Color(0x66F2F4F8);
  static const Color w20  = Color(0x33F2F4F8);
  static const Color w10  = Color(0x1AF2F4F8);

  // Teal tinted surfaces
  static const Color tealDim    = Color(0x1A00D4B4);
  static const Color tealBorder = Color(0x4000D4B4);

  // Red tinted
  static const Color redDim = Color(0x1AFF5A5A);

  // Refined chart palette — desaturated, cohesive
  static const List<Color> chart = [
    Color(0xFF00D4B4), // teal
    Color(0xFF7C86F5), // indigo
    Color(0xFFFF8A65), // warm orange
    Color(0xFF4FC3F7), // sky blue
    Color(0xFFFFD166), // amber
    Color(0xFFEF6C9F), // rose
    Color(0xFF81C784), // green
    Color(0xFFBA68C8), // purple
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
    required this.surface3,
    required this.border,
    required this.divider,
    required this.text100,
    required this.text70,
    required this.text40,
    required this.text20,
    required this.text10,
    // Core action (teal — income / positive / primary CTA)
    required this.lime,
    required this.limeAccent,
    required this.limeDim,
    required this.limeBorder,
    // Expense accent (coral/red)
    required this.red,
    required this.redDim,
    // AI accent (indigo)
    required this.intelligenceAccent,
    required this.intelligenceAccentDim,
    // Aliases
    required this.cardGradientStart,
    required this.cardGradientEnd,
    required this.coreAction,
    required this.coreActionDim,
    required this.accentExpense,
    required this.accentExpenseDim,
  });

  final Color background;
  final Color surface;
  final Color surface2;
  final Color surface3;
  final Color border;
  final Color divider;
  final Color text100;
  final Color text70;
  final Color text40;
  final Color text20;
  final Color text10;

  // Income / positive / CTA — Electric Teal
  final Color lime;
  final Color limeAccent;
  final Color limeDim;
  final Color limeBorder;

  // Expense / negative — Coral Red
  final Color red;
  final Color redDim;

  // AI / intelligence — Indigo
  final Color intelligenceAccent;
  final Color intelligenceAccentDim;

  // Gradient tokens
  final Color cardGradientStart;
  final Color cardGradientEnd;

  // Semantic aliases
  final Color coreAction;
  final Color coreActionDim;
  final Color accentExpense;
  final Color accentExpenseDim;

  static ThemeColors of(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? _dark : _light;
  }

  // ── Dark theme tokens ("Deep Obsidian") ──────────────────────────────────
  static const ThemeColors _dark = ThemeColors._(
    background:              Color(0xFF080A0D),
    surface:                 Color(0xFF111318),
    surface2:                Color(0xFF1A1D24),
    surface3:                Color(0xFF21252E),
    border:                  Color(0xFF252830),
    divider:                 Color(0xFF1E2128),
    text100:                 Color(0xFFF2F4F8),
    text70:                  Color(0xFFB0B6C0),
    text40:                  Color(0xFF6B7280),
    text20:                  Color(0x33F2F4F8),
    text10:                  Color(0x1AF2F4F8),
    lime:                    Color(0xFF00D4B4),
    limeAccent:              Color(0xFF00D4B4),
    limeDim:                 Color(0x1A00D4B4),
    limeBorder:              Color(0x4000D4B4),
    red:                     Color(0xFFFF5A5A),
    redDim:                  Color(0x1AFF5A5A),
    intelligenceAccent:      Color(0xFF7C86F5),
    intelligenceAccentDim:   Color(0x1A7C86F5),
    cardGradientStart:       Color(0xFF111318),
    cardGradientEnd:         Color(0xFF1A1D24),
    coreAction:              Color(0xFF00D4B4),
    coreActionDim:           Color(0x1A00D4B4),
    accentExpense:           Color(0xFFFF5A5A),
    accentExpenseDim:        Color(0x1AFF5A5A),
  );

  // ── Light theme tokens ("Tailored Linen") ────────────────────────────────
  static const ThemeColors _light = ThemeColors._(
    background:              Color(0xFFF5F6F8),
    surface:                 Color(0xFFFFFFFF),
    surface2:                Color(0xFFEDEEF1),
    surface3:                Color(0xFFE5E7EC),
    border:                  Color(0xFFDFE2E8),
    divider:                 Color(0xFFF0F1F4),
    text100:                 Color(0xFF0F1117),
    text70:                  Color(0xFF4B5260),
    text40:                  Color(0xFF9199A6),
    text20:                  Color(0x33121416),
    text10:                  Color(0x1A121416),
    lime:                    Color(0xFF009A83),
    limeAccent:              Color(0xFF009A83),
    limeDim:                 Color(0x1A009A83),
    limeBorder:              Color(0x40009A83),
    red:                     Color(0xFFE05252),
    redDim:                  Color(0x1AE05252),
    intelligenceAccent:      Color(0xFF5558DD),
    intelligenceAccentDim:   Color(0x1A5558DD),
    cardGradientStart:       Color(0xFFFFFFFF),
    cardGradientEnd:         Color(0xFFF5F6F8),
    coreAction:              Color(0xFF009A83),
    coreActionDim:           Color(0x1A009A83),
    accentExpense:           Color(0xFFE05252),
    accentExpenseDim:        Color(0x1AE05252),
  );
}

// ── Material ThemeData factories ──────────────────────────────────────────────
class AppTheme {
  AppTheme._();

  static ThemeData dark() => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF080A0D),
    colorScheme: const ColorScheme.dark(
      primary:   Color(0xFF00D4B4),
      onPrimary: Color(0xFF080A0D),
      surface:   Color(0xFF111318),
      onSurface: Color(0xFFF2F4F8),
      error:     Color(0xFFFF5A5A),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF111318),
      foregroundColor: Color(0xFFF2F4F8),
      elevation: 0,
      centerTitle: false,
    ),
    dividerColor: const Color(0xFF1E2128),
    fontFamily: 'Inter',
  );

  static ThemeData light() => ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF5F6F8),
    colorScheme: const ColorScheme.light(
      primary:   Color(0xFF009A83),
      onPrimary: Color(0xFFFFFFFF),
      surface:   Color(0xFFFFFFFF),
      onSurface: Color(0xFF0F1117),
      error:     Color(0xFFE05252),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFFFFFFF),
      foregroundColor: Color(0xFF0F1117),
      elevation: 0,
      centerTitle: false,
    ),
    dividerColor: const Color(0xFFF0F1F4),
    fontFamily: 'Inter',
  );
}
