import 'package:currency_country_picker/currency_country_picker.dart' as ccp;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:Thinkpay/core/constant/app_colors.dart';
import 'package:Thinkpay/core/utils/number_format.dart';
import 'package:Thinkpay/providers/user_profile_store.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Currency helpers
// ─────────────────────────────────────────────────────────────────────────────

/// The full `currency_country_picker` catalogue, read once.
final List<ccp.Currency> _catalogue = ccp.CurrencyService().getAllCurrencies();
final Map<String, String> _symbols = <String, String>{
  for (final currency in _catalogue) currency.code: currency.symbol,
};
final Map<String, String> _names = <String, String>{
  for (final currency in _catalogue) currency.code: currency.name,
};

/// The symbol for [code], resolved from the package catalogue so any of the 250
/// currencies formats correctly. Falls back to the app's own short list, then
/// to the code itself.
String symbolForCode(String code) {
  final upper = code.toUpperCase();
  final symbol = _symbols[upper];
  if (symbol != null && symbol.trim().isNotEmpty) return symbol;
  for (final c in currencies) {
    if (c.code == upper) return c.symbol;
  }
  return upper;
}

/// Full display name for [code], e.g. `LKR` → `Sri Lankan Rupee`.
String currencyNameForCode(String code) {
  final upper = code.toUpperCase();
  final name = _names[upper];
  if (name != null) return name;
  for (final c in currencies) {
    if (c.code == upper) return c.name;
  }
  return upper;
}

/// True when the rest of the app (profile, finance) knows this code.
bool isAppCurrencyCode(String code) =>
    currencies.any((c) => c.code == code.toUpperCase());

/// Display amount. Small values keep every digit (`185,000.00`, `1,250`),
/// large ones are abbreviated so they never overflow a tile (`1.25M`, `150K`).
String formatMoney(double value, {int decimals = 2}) {
  // Fixed precision only matters while the value is still shown in full.
  final places = value.abs() < kCompactThreshold ? decimals : null;
  return compactNumber(value, decimals: places);
}

/// Currency-prefixed display amount, e.g. `$symbol 1.25M` / `Rs. 185,000.00`.
String moneyText(double value, String symbol, {int decimals = 2}) {
  final places = value.abs() < kCompactThreshold ? decimals : null;
  return compactMoney(value, symbol: symbol, decimals: places);
}

/// Controller-friendly text: no grouping, no trailing zeros.
String plainAmount(double value) {
  if (value == 0) return '';
  return value == value.roundToDouble()
      ? value.toStringAsFixed(0)
      : value.toStringAsFixed(2);
}

/// Forgiving amount parser: accepts `1,200`, ` 1200.50 `, `Rs 1200`, `1.2k`,
/// `1.5m`, `2B`. Returns null when nothing numeric is present.
double? parseMoney(String raw) => parseAmount(raw);

/// Percentage without trailing zeros, e.g. `28` or `28.5`.
String fmtPercent(double value) => groupedNumber(value, decimals: 2, trimZeros: true);

// ─────────────────────────────────────────────────────────────────────────────
// Text & buttons
// ─────────────────────────────────────────────────────────────────────────────

class StepTitle extends StatelessWidget {
  const StepTitle({super.key, required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.headlineLgMobile.copyWith(
            color: tc.text100,
            fontWeight: FontWeight.w700,
            height: 1.2,
            letterSpacing: -0.4,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: AppSpacing.base),
          Text(
            subtitle!,
            style: AppTypography.bodyMd.copyWith(color: tc.text70),
          ),
        ],
      ],
    );
  }
}

/// Full-width primary action. Deliberately identical to the sign-up button so
/// the hand-off into account creation is invisible.
class PrimaryCta extends StatelessWidget {
  const PrimaryCta({super.key, required this.label, this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final enabled = onTap != null;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: tc.intelligenceAccent,
          foregroundColor: isDark ? tc.background : Colors.white,
          disabledBackgroundColor: tc.surface2,
          disabledForegroundColor: tc.text40,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
        ),
        child: Text(
          label,
          style: AppTypography.bodyMd.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
            color: enabled
                ? (isDark ? tc.background : Colors.white)
                : tc.text40,
          ),
        ),
      ),
    );
  }
}

class SecondaryLink extends StatelessWidget {
  const SecondaryLink({super.key, required this.label, this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        minimumSize: const Size(44, 44),
        foregroundColor: tc.text70,
      ),
      child: Text(
        label,
        style: AppTypography.bodySm.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}

class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    return Text(
      text.toUpperCase(),
      style: AppTypography.labelCaps.copyWith(
        color: tc.text40,
        fontSize: 10,
        letterSpacing: 0.8,
      ),
    );
  }
}

class LabeledField extends StatelessWidget {
  const LabeledField({super.key, required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(label),
        const SizedBox(height: AppSpacing.base),
        child,
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Notes / hints
// ─────────────────────────────────────────────────────────────────────────────

enum NoteTone { neutral, positive, caution }

class InfoNote extends StatelessWidget {
  const InfoNote({
    super.key,
    required this.icon,
    required this.text,
    this.tone = NoteTone.neutral,
  });

  final IconData icon;
  final String text;
  final NoteTone tone;

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);

    final Color background;
    final Color foreground;
    switch (tone) {
      case NoteTone.positive:
        background = tc.intelligenceAccentDim;
        foreground = tc.text100;
      case NoteTone.caution:
        background = tc.accentDim;
        foreground = tc.text100;
      case NoteTone.neutral:
        background = tc.surface2;
        foreground = tc.text70;
    }

    final iconColor = switch (tone) {
      NoteTone.positive => tc.intelligenceAccent,
      NoteTone.caution => tc.accent,
      NoteTone.neutral => tc.text40,
    };

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(width: AppSpacing.base),
          Expanded(
            child: Text(
              text,
              style: AppTypography.bodySm.copyWith(
                color: foreground,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class EmptyHint extends StatelessWidget {
  const EmptyHint(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.marginMobile,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: tc.divider),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: AppTypography.bodySm.copyWith(color: tc.text40, height: 1.5),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Gate question
// ─────────────────────────────────────────────────────────────────────────────

class GateOption extends StatelessWidget {
  const GateOption({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.all(AppSpacing.marginMobile),
        decoration: BoxDecoration(
          color: selected ? tc.intelligenceAccentDim : tc.surface2,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: selected ? tc.intelligenceAccent : tc.divider,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: selected
                    ? tc.intelligenceAccent.withValues(alpha: 0.18)
                    : tc.surface3,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(
                icon,
                size: 20,
                color: selected ? tc.intelligenceAccent : tc.text40,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              title,
              style: AppTypography.bodySm.copyWith(
                color: tc.text100,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              subtitle,
              style: AppTypography.bodySm.copyWith(
                color: tc.text40,
                fontSize: 12,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Preset chips
// ─────────────────────────────────────────────────────────────────────────────

class PresetChips extends StatelessWidget {
  const PresetChips({super.key, required this.items, required this.onTap});

  final List<String> items;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);

    return Wrap(
      spacing: AppSpacing.base,
      runSpacing: AppSpacing.base,
      children: [
        for (final item in items)
          InkWell(
            onTap: () => onTap(item),
            borderRadius: BorderRadius.circular(AppRadius.full),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: 9,
              ),
              decoration: BoxDecoration(
                color: tc.surface2,
                borderRadius: BorderRadius.circular(AppRadius.full),
                border: Border.all(color: tc.divider),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add_rounded, size: 14, color: tc.text40),
                  const SizedBox(width: 5),
                  Text(
                    item,
                    style: AppTypography.bodySm.copyWith(
                      color: tc.text70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Amount input
// ─────────────────────────────────────────────────────────────────────────────

class MoneyField extends StatelessWidget {
  const MoneyField({
    super.key,
    required this.controller,
    required this.symbol,
    required this.accent,
    this.hint = '0.00',
    this.onChanged,
    this.focusNode,
    this.autofocus = false,
  });

  final TextEditingController controller;
  final String symbol;
  final Color accent;
  final String hint;
  final ValueChanged<String>? onChanged;
  final FocusNode? focusNode;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);

    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      decoration: BoxDecoration(
        color: tc.surface2,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.base + 1),
            ),
            child: Text(
              symbol,
              style: AppTypography.labelCaps.copyWith(
                color: accent,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              autofocus: autofocus,
              onChanged: onChanged,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,kmKM]')),
              ],
              style: AppTypography.headlineMd.copyWith(
                color: tc.text100,
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: AppTypography.headlineMd.copyWith(
                  color: tc.text20,
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Cards & tiles
// ─────────────────────────────────────────────────────────────────────────────

class TileCard extends StatelessWidget {
  const TileCard({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(AppSpacing.marginMobile),
      decoration: BoxDecoration(
        color: tc.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: tc.divider),
      ),
      child: child,
    );
  }
}

class TileActionButton extends StatelessWidget {
  const TileActionButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    final button = InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.base),
      child: SizedBox(
        width: 36,
        height: 36,
        child: Icon(icon, size: 18, color: tc.text40),
      ),
    );
    if (tooltip == null) return button;
    return Tooltip(message: tooltip!, child: button);
  }
}

/// Thin progress line used inside goal and loan tiles.
class MiniProgress extends StatelessWidget {
  const MiniProgress({
    super.key,
    required this.value,
    this.color,
    this.height = 4,
  });

  final double value;
  final Color? color;
  final double height;

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.full),
      child: Stack(
        children: [
          Container(height: height, color: tc.surface3),
          FractionallySizedBox(
            widthFactor: value.clamp(0.0, 1.0),
            child: Container(
              height: height,
              color: color ?? tc.intelligenceAccent,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom sheets
// ─────────────────────────────────────────────────────────────────────────────

Future<T?> showOnboardingSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: const Color(0x99000000),
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
      child: builder(ctx),
    ),
  );
}

/// Shared frame for every onboarding sheet: handle, title, scrollable body,
/// optional pinned footer.
class SheetShell extends StatelessWidget {
  const SheetShell({
    super.key,
    required this.title,
    this.subtitle,
    this.body,
    this.footer,
    this.onClose,
    this.maxHeightFactor = 0.88,
  });

  final String title;
  final String? subtitle;
  final Widget? body;
  final Widget? footer;
  final VoidCallback? onClose;
  final double maxHeightFactor;

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * maxHeightFactor,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: tc.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppRadius.xl + 4),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          AppSpacing.md,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: tc.text20,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.marginMobile),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTypography.headlineMd.copyWith(
                          color: tc.text100,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle!,
                          style: AppTypography.bodySm.copyWith(
                            color: tc.text40,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (onClose != null)
                  TileActionButton(
                    icon: Icons.close_rounded,
                    onTap: onClose!,
                    tooltip: 'Close',
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.marginMobile),
            Flexible(
              child: SingleChildScrollView(
                child: body ?? const SizedBox.shrink(),
              ),
            ),
            if (footer != null) ...[
              const SizedBox(height: AppSpacing.md),
              footer!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Labelled text field used inside the sheets, styled to match
/// `creditcardDetails.dart`.
class SheetTextField extends StatelessWidget {
  const SheetTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.prefixText,
    this.suffixText,
    this.helperText,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.readOnly = false,
    this.onTap,
    this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final String? prefixText;
  final String? suffixText;
  final String? helperText;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final bool readOnly;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);

    return TextField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      onChanged: onChanged,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      style: AppTypography.bodyMd.copyWith(color: tc.text100),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        helperText: helperText,
        prefixText: prefixText,
        suffixText: suffixText,
        labelStyle: AppTypography.bodySm.copyWith(color: tc.text70),
        hintStyle: AppTypography.bodySm.copyWith(color: tc.text20),
        helperStyle: AppTypography.bodySm.copyWith(
          color: tc.text40,
          fontSize: 11,
        ),
        prefixStyle: AppTypography.bodySm.copyWith(color: tc.text70),
        suffixStyle: AppTypography.bodySm.copyWith(color: tc.text70),
        filled: true,
        fillColor: tc.surface2,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: tc.intelligenceAccent, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.marginMobile,
          vertical: AppSpacing.marginMobile,
        ),
      ),
    );
  }
}
