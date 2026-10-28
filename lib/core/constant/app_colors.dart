import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Typography ──────────────────────────────────────────────────────────────
class AppTypography {
  static TextStyle get display => GoogleFonts.manrope(
    fontSize: 40,
    fontWeight: FontWeight.w700,
    height: 48 / 40,
    letterSpacing: -0.02 * 40,
  );
  static TextStyle get headlineLg => GoogleFonts.manrope(
    fontSize: 32,
    fontWeight: FontWeight.w600,
    height: 40 / 32,
    letterSpacing: -0.01 * 32,
  );
  static TextStyle get headlineLgMobile => GoogleFonts.manrope(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 32 / 24,
  );
  static TextStyle get headlineMd => GoogleFonts.manrope(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 28 / 20,
  );
  static TextStyle get bodyLg => GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    height: 28 / 18,
  );
  static TextStyle get bodyMd => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 24 / 16,
  );
  static TextStyle get bodySm => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 20 / 14,
  );
  static TextStyle get labelCaps => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 16 / 12,
    letterSpacing: 0.05 * 12,
  );
  static TextStyle get dataMono => GoogleFonts.jetBrainsMono(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 20 / 14,
  );
}

// ── Radii ───────────────────────────────────────────────────────────────────
class AppRadius {
  static const double sm = 4.0;
  static const double base = 8.0; // DEFAULT
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double full = 9999.0;
}

// ── Spacing ─────────────────────────────────────────────────────────────────
class AppSpacing {
  static const double xs = 4.0;
  static const double base = 8.0;
  static const double sm = 12.0;
  static const double marginMobile = 16.0;
  static const double md = 24.0;
  static const double gutter = 24.0;
  static const double lg = 48.0;
  static const double xl = 80.0;
  static const double containerMax = 1200.0;
}

// ── Brand palette (DayOne: Forest · Ivory · Marigold) ─────────────────────────
// Raw brand values. Screens should prefer ThemeColors.of(context) so they
// adapt to light/dark; use these only where a fixed colour is needed.
class _Brand {
  _Brand._();

  // Forest (dark canvas)
  static const forestTop    = Color(0xFF17513A);
  static const forestBottom = Color(0xFF0B2218);
  static const forestRaised = Color(0xFF1F5C43);

  // Ivory (light canvas + text on forest)
  static const ivory       = Color(0xFFF6F2E7);
  static const ivoryMuted  = Color(0xFFB9CBBF);
  static const ivoryWarm   = Color(0xFFFFFDF8);

  // Ink (text on ivory)
  static const ink      = Color(0xFF12281D);
  static const inkMuted = Color(0xFF5E7266);

  // Accents
  static const marigold = Color(0xFFF2B84B); // primary action
  static const growth   = Color(0xFF1E7A4E); // positive / income (light mode)
  static const mint     = Color(0xFF7FD6A3); // positive / income (dark mode)
  static const mintTint = Color(0xFFD7EDDD);
  static const coral    = Color(0xFFFF8F80); // expense (dark mode)
  static const terracotta = Color(0xFFC0392B); // expense (light mode)
}

// ── Static palette (kept for chart colours & legacy usages) ───────────────────
class AppColors {
  AppColors._();

  static const Color dark     = Color(0xFF0B2218);
  static const Color surface  = Color(0xFF123222);
  static const Color surface2 = Color(0xFF1A402D);
  static const Color border   = Color(0xFF2F5A44);
  static const Color teal     = Color(0xFF7FD6A3); // now mint (growth)
  static const Color red      = Color(0xFFFF8F80);
  static const Color blue     = Color(0xFF8FA8E8);

  static const Color w100 = Color(0xFFF6F2E7);
  static const Color w70  = Color(0xFFB9CBBF);
  static const Color w40  = Color(0x66F6F2E7);
  static const Color w20  = Color(0x33F6F2E7);
  static const Color w10  = Color(0x1AF6F2E7);

  static const Color tealDim    = Color(0x1A7FD6A3);
  static const Color tealBorder = Color(0x407FD6A3);

  static const Color redDim = Color(0x1AFF8F80);

  static const List<Color> chart = [
    Color(0xFF17513A), // Forest
    Color(0xFF1E7A4E), // Growth Green
    Color(0xFF7FD6A3), // Mint
    Color(0xFFF2B84B), // Marigold
    Color(0xFF8AA597), // Muted Sage
    Color(0xFFC0392B), // Terracotta
    Color(0xFFFF8F80), // Coral
    Color(0xFFE4E0D3), // Ivory Dim
  ];
}

// ── Adaptive colour token set ─────────────────────────────────────────────────
// Field names are unchanged so existing screens keep compiling.
//   lime / coreAction        → main brand action colour
//   intelligenceAccent       → AI + positive/growth colour
//   red / accentExpense      → expenses and errors
// New: accent / accentDim / onAccent → the marigold highlight used on primary
// buttons, streaks and key callouts (same in light and dark).
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
    required this.lime,
    required this.limeAccent,
    required this.limeDim,
    required this.limeBorder,
    required this.red,
    required this.redDim,
    required this.intelligenceAccent,
    required this.intelligenceAccentDim,
    required this.cardGradientStart,
    required this.cardGradientEnd,
    required this.coreAction,
    required this.coreActionDim,
    required this.accentExpense,
    required this.accentExpenseDim,
    required this.accent,
    required this.accentDim,
    required this.onAccent,
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

  final Color lime;
  final Color limeAccent;
  final Color limeDim;
  final Color limeBorder;

  final Color red;
  final Color redDim;

  final Color intelligenceAccent;
  final Color intelligenceAccentDim;

  final Color cardGradientStart;
  final Color cardGradientEnd;

  final Color coreAction;
  final Color coreActionDim;
  final Color accentExpense;
  final Color accentExpenseDim;

  /// Marigold highlight (primary buttons, streaks, key callouts).
  final Color accent;
  final Color accentDim;

  /// Text/icon colour to place on top of [accent].
  final Color onAccent;

  static ThemeColors of(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? _dark : _light;
  }

  // Forest (dark mode): same canvas as the startup screen.
  static const ThemeColors _dark = ThemeColors._(
    background:              _Brand.forestBottom,
    surface:                 Color(0xFF123222),
    surface2:                Color(0xFF1A402D),
    surface3:                _Brand.forestRaised,
    border:                  Color(0xFF2F5A44),
    divider:                 Color(0xFF1F4231),
    text100:                 _Brand.ivory,
    text70:                  _Brand.ivoryMuted,
    text40:                  Color(0xFF8AA597),
    text20:                  Color(0x33F6F2E7),
    text10:                  Color(0x1AF6F2E7),
    lime:                    _Brand.marigold,
    limeAccent:              Color(0xFFFFD27A),
    limeDim:                 Color(0x1AF2B84B),
    limeBorder:              Color(0x40F2B84B),
    red:                     _Brand.coral,
    redDim:                  Color(0x1AFF8F80),
    intelligenceAccent:      _Brand.mint,
    intelligenceAccentDim:   Color(0x1A7FD6A3),
    cardGradientStart:       Color(0xFF1A402D),
    cardGradientEnd:         Color(0xFF123222),
    coreAction:              _Brand.marigold,
    coreActionDim:           Color(0x1AF2B84B),
    accentExpense:           _Brand.coral,
    accentExpenseDim:        Color(0x1AFF8F80),
    accent:                  _Brand.marigold,
    accentDim:               Color(0x1AF2B84B),
    onAccent:                _Brand.ink,
  );

  // Ivory (light mode): warm paper canvas, forest for brand text and icons.
  static const ThemeColors _light = ThemeColors._(
    background:              _Brand.ivory,
    surface:                 _Brand.ivoryWarm,
    surface2:                Color(0xFFEFEADD),
    surface3:                Color(0xFFE4E0D3),
    border:                  Color(0xFFD9D4C4),
    divider:                 Color(0xFFE6E1D2),
    text100:                 _Brand.ink,
    text70:                  Color(0xFF3F5448),
    text40:                  _Brand.inkMuted,
    text20:                  Color(0xFFB9C4BB),
    text10:                  Color(0x1A12281D),
    lime:                    _Brand.forestTop,
    limeAccent:              _Brand.forestBottom,
    limeDim:                 _Brand.mintTint,
    limeBorder:              Color(0xFFA9CDB7),
    red:                     _Brand.terracotta,
    redDim:                  Color(0xFFFBE0DB),
    intelligenceAccent:      _Brand.growth,
    intelligenceAccentDim:   _Brand.mintTint,
    cardGradientStart:       _Brand.ivoryWarm,
    cardGradientEnd:         _Brand.ivory,
    coreAction:              _Brand.forestTop,
    coreActionDim:           _Brand.mintTint,
    accentExpense:           _Brand.terracotta,
    accentExpenseDim:        Color(0xFFFBE0DB),
    accent:                  _Brand.marigold,
    accentDim:               Color(0x33F2B84B),
    onAccent:                _Brand.ink,
  );
}

// ── Material ThemeData factories ──────────────────────────────────────────────
class AppTheme {
  AppTheme._();

  static TextTheme _buildTextTheme(Color textColor) {
    return TextTheme(
      displayLarge: AppTypography.display.copyWith(color: textColor),
      headlineLarge: AppTypography.headlineLg.copyWith(color: textColor),
      headlineMedium: AppTypography.headlineMd.copyWith(color: textColor),
      bodyLarge: AppTypography.bodyLg.copyWith(color: textColor),
      bodyMedium: AppTypography.bodyMd.copyWith(color: textColor),
      bodySmall: AppTypography.bodySm.copyWith(color: textColor),
      labelSmall: AppTypography.labelCaps.copyWith(color: textColor),
    );
  }

  static ThemeData dark() {
    const colorScheme = ColorScheme.dark(
      primary: _Brand.marigold,
      onPrimary: _Brand.ink,
      primaryContainer: _Brand.forestRaised,
      onPrimaryContainer: Color(0xFFD7EDDD),
      secondary: _Brand.mint,
      onSecondary: _Brand.forestBottom,
      secondaryContainer: Color(0xFF1A402D),
      onSecondaryContainer: Color(0xFFA9E3BD),
      tertiary: _Brand.marigold,
      onTertiary: _Brand.ink,
      surface: Color(0xFF123222),
      onSurface: _Brand.ivory,
      error: _Brand.coral,
      onError: Color(0xFF410E0B),
    );

    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: _Brand.forestBottom,
      colorScheme: colorScheme,
      textTheme: _buildTextTheme(colorScheme.onSurface),
      appBarTheme: const AppBarTheme(
        backgroundColor: _Brand.forestBottom,
        foregroundColor: _Brand.ivory,
        elevation: 0,
        centerTitle: false,
      ),
      dividerColor: const Color(0xFF1F4231),
      fontFamily: 'Inter',
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _Brand.marigold,
          foregroundColor: _Brand.ink,
          minimumSize: const Size(64, 52),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg)),
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          textStyle: GoogleFonts.manrope(
              fontSize: 16, fontWeight: FontWeight.w800),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _Brand.ivory,
          side: const BorderSide(color: Color(0x33F6F2E7), width: 1.5),
          minimumSize: const Size(64, 52),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg)),
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: _Brand.marigold),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1A402D),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: _Brand.marigold, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          side: const BorderSide(color: Color(0xFF2F5A44)),
        ),
        margin: EdgeInsets.zero,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: _Brand.marigold.withValues(alpha: 0.12),
        labelStyle: AppTypography.bodySm.copyWith(color: colorScheme.onSurface),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.full)),
        side: BorderSide.none,
      ),
      progressIndicatorTheme:
      const ProgressIndicatorThemeData(color: _Brand.marigold),
    );
  }

  static ThemeData light() {
    const colorScheme = ColorScheme.light(
      primary: _Brand.forestTop,
      onPrimary: Colors.white,
      primaryContainer: _Brand.mintTint,
      onPrimaryContainer: _Brand.forestBottom,
      secondary: _Brand.growth,
      onSecondary: Colors.white,
      secondaryContainer: _Brand.mintTint,
      onSecondaryContainer: Color(0xFF0F4A2E),
      tertiary: _Brand.marigold,
      onTertiary: _Brand.ink,
      surface: _Brand.ivoryWarm,
      onSurface: _Brand.ink,
      error: _Brand.terracotta,
      onError: Colors.white,
    );

    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: _Brand.ivory,
      colorScheme: colorScheme,
      textTheme: _buildTextTheme(colorScheme.onSurface),
      appBarTheme: const AppBarTheme(
        backgroundColor: _Brand.ivory,
        foregroundColor: _Brand.ink,
        elevation: 0,
        centerTitle: false,
      ),
      dividerColor: const Color(0xFFE6E1D2),
      fontFamily: 'Inter',
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _Brand.marigold,
          foregroundColor: _Brand.ink,
          minimumSize: const Size(64, 52),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg)),
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          textStyle: GoogleFonts.manrope(
              fontSize: 16, fontWeight: FontWeight.w800),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _Brand.forestTop,
          side: const BorderSide(color: _Brand.forestTop, width: 1.5),
          minimumSize: const Size(64, 52),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg)),
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: _Brand.forestTop),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFEFEADD),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: _Brand.forestTop, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
      cardTheme: CardThemeData(
        color: _Brand.ivoryWarm,
        elevation: 0,
        shadowColor: _Brand.forestBottom.withValues(alpha: 0.12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          side: const BorderSide(color: Color(0xFFE6E1D2)),
        ),
        margin: EdgeInsets.zero,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: _Brand.marigold.withValues(alpha: 0.2),
        labelStyle: AppTypography.bodySm.copyWith(color: colorScheme.onSurface),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.full)),
        side: BorderSide.none,
      ),
      progressIndicatorTheme:
      const ProgressIndicatorThemeData(color: _Brand.forestTop),
    );
  }
}