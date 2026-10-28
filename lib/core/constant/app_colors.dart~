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

  static const Color w100 = Color(0xFFF2F4F8);
  static const Color w70  = Color(0xFFB0B6C0);
  static const Color w40  = Color(0x66F2F4F8);
  static const Color w20  = Color(0x33F2F4F8);
  static const Color w10  = Color(0x1AF2F4F8);

  static const Color tealDim    = Color(0x1A00D4B4);
  static const Color tealBorder = Color(0x4000D4B4);

  static const Color redDim = Color(0x1AFF5A5A);

  static const List<Color> chart = [
    Color(0xFF1B3022), // Forest Green
    Color(0xFF496640), // Sage Green
    Color(0xFFCAECBC), // Light Sage
    Color(0xFF819986), // Muted Green
    Color(0xFF4D6453), // Slate Green
    Color(0xFFBA1A1A), // Terracotta
    Color(0xFFFFDAD6), // Light Terracotta
    Color(0xFFDCD9D9), // Dim Surface
  ];
}

// ── Adaptive colour token set ─────────────────────────────────────────────────
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

  static ThemeColors of(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? _dark : _light;
  }

  // Deep Obsidian mapping (Dark Mode approximations using the same hue base)
  static const ThemeColors _dark = ThemeColors._(
    background:              Color(0xFF141817), // tertiary
    surface:                 Color(0xFF282C2B), // tertiary-container
    surface2:                Color(0xFF313030), // inverse-surface
    surface3:                Color(0xFF434846), // on-tertiary-fixed-variant
    border:                  Color(0xFF737973), // outline
    divider:                 Color(0xFF434843), // on-surface-variant
    text100:                 Color(0xFFFCF9F8), // surface-bright
    text70:                  Color(0xFFE5E2E1), // surface-variant
    text40:                  Color(0xFFC3C8C1), // outline-variant
    text20:                  Color(0x33FCF9F8),
    text10:                  Color(0x1AFCF9F8),
    lime:                    Color(0xFFD0E9D4), // primary-fixed
    limeAccent:              Color(0xFFB4CDB8), // inverse-primary
    limeDim:                 Color(0x1AD0E9D4),
    limeBorder:              Color(0x40D0E9D4),
    red:                     Color(0xFFFFDAD6), // error-container
    redDim:                  Color(0x1AFFDAD6),
    intelligenceAccent:      Color(0xFFCAECBC), // secondary-fixed
    intelligenceAccentDim:   Color(0x1ACAECBC),
    cardGradientStart:       Color(0xFF282C2B),
    cardGradientEnd:         Color(0xFF141817),
    coreAction:              Color(0xFFD0E9D4),
    coreActionDim:           Color(0x1AD0E9D4),
    accentExpense:           Color(0xFFFFDAD6),
    accentExpenseDim:        Color(0x1AFFDAD6),
  );

  // Rich Minimalism (Light Mode) mapping
  static const ThemeColors _light = ThemeColors._(
    background:              Color(0xFFFCF9F8), // surface / background
    surface:                 Color(0xFFFFFFFF), // surface-container-lowest
    surface2:                Color(0xFFF6F3F2), // surface-container-low
    surface3:                Color(0xFFF0EDEC), // surface-container
    border:                  Color(0xFFE5E2E1), // surface-variant
    divider:                 Color(0xFFEBE7E7), // surface-container-high
    text100:                 Color(0xFF1C1B1B), // on-surface
    text70:                  Color(0xFF434843), // on-surface-variant
    text40:                  Color(0xFF737973), // outline
    text20:                  Color(0xFFC3C8C1), // outline-variant
    text10:                  Color(0x1A1C1B1B),
    lime:                    Color(0xFF1B3022), // primary-container (Forest Green)
    limeAccent:              Color(0xFF061B0E), // primary
    limeDim:                 Color(0xFFD0E9D4), // primary-fixed
    limeBorder:              Color(0xFFB4CDB8), // primary-fixed-dim
    red:                     Color(0xFFBA1A1A), // error (Terracotta)
    redDim:                  Color(0xFFFFDAD6), // error-container
    intelligenceAccent:      Color(0xFF496640), // secondary (Sage Green)
    intelligenceAccentDim:   Color(0xFFCAECBC), // secondary-container
    cardGradientStart:       Color(0xFFFFFFFF),
    cardGradientEnd:         Color(0xFFFCF9F8),
    coreAction:              Color(0xFF1B3022),
    coreActionDim:           Color(0xFFD0E9D4),
    accentExpense:           Color(0xFFBA1A1A),
    accentExpenseDim:        Color(0xFFFFDAD6),
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
    final colorScheme = const ColorScheme.dark(
      primary:   Color(0xFFD0E9D4),
      onPrimary: Color(0xFF0B2013),
      primaryContainer: Color(0xFF1B3022),
      onPrimaryContainer: Color(0xFF819986),
      secondary: Color(0xFFCAECBC),
      onSecondary: Color(0xFF062104),
      secondaryContainer: Color(0xFF4F6C45),
      onSecondaryContainer: Color(0xFFCAECBC),
      surface:   Color(0xFF282C2B),
      onSurface: Color(0xFFFCF9F8),
      error:     Color(0xFFFFDAD6),
      onError:   Color(0xFF93000A),
    );

    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF141817),
      colorScheme: colorScheme,
      textTheme: _buildTextTheme(colorScheme.onSurface),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF141817),
        foregroundColor: Color(0xFFFCF9F8),
        elevation: 0,
        centerTitle: false,
      ),
      dividerColor: const Color(0xFF434843),
      fontFamily: 'Inter',
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primaryContainer,
          foregroundColor: colorScheme.onSurface, // Or white if preferred
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.base)),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.onSurface,
          side: BorderSide(color: colorScheme.primaryContainer),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.base)),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF282C2B),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.base),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.base),
          borderSide: BorderSide(color: colorScheme.primaryContainer),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: 1, // Will need custom shadows in UI for the exact blur
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.base),
          side: const BorderSide(color: Color(0xFF434843)),
        ),
        margin: EdgeInsets.zero,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
        labelStyle: AppTypography.bodySm.copyWith(color: colorScheme.onSurface),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
        side: BorderSide.none,
      ),
    );
  }

  static ThemeData light() {
    final colorScheme = const ColorScheme.light(
      primary:   Color(0xFF061B0E), // primary
      onPrimary: Color(0xFFFFFFFF), // on-primary
      primaryContainer: Color(0xFF1B3022), // primary-container
      onPrimaryContainer: Color(0xFF819986), // on-primary-container
      secondary: Color(0xFF496640), // secondary
      onSecondary: Color(0xFFFFFFFF), // on-secondary
      secondaryContainer: Color(0xFFCAECBC), // secondary-container
      onSecondaryContainer: Color(0xFF4F6C45), // on-secondary-container
      surface:   Color(0xFFFFFFFF), // surface-container-lowest
      onSurface: Color(0xFF1C1B1B), // on-surface
      error:     Color(0xFFBA1A1A), // error
      onError:   Color(0xFFFFFFFF), // on-error
    );

    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFFCF9F8), // background
      colorScheme: colorScheme,
      textTheme: _buildTextTheme(colorScheme.onSurface),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFFCF9F8),
        foregroundColor: Color(0xFF1C1B1B),
        elevation: 0,
        centerTitle: false,
      ),
      dividerColor: const Color(0xFFEBE7E7),
      fontFamily: 'Inter',
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primaryContainer, // Forest Green
          foregroundColor: Colors.white, // White text
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.base)),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primaryContainer,
          side: BorderSide(color: colorScheme.primaryContainer),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.base)),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF4F7F5),
        focusColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.base),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.base),
          borderSide: BorderSide(color: colorScheme.primaryContainer),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0, // Doing manual shadow in UI or relying on Material elevation with shadowColor
        shadowColor: colorScheme.primaryContainer.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.base),
          side: const BorderSide(color: Color(0xFFF0F0F0)),
        ),
        margin: EdgeInsets.zero,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.primaryContainer.withValues(alpha: 0.05),
        labelStyle: AppTypography.bodySm.copyWith(color: colorScheme.onSurface),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
        side: BorderSide.none,
      ),
    );
  }
}
