import 'package:currency_country_picker/currency_country_picker.dart' as ccp;
import 'package:flutter/material.dart';

import 'package:Thinkpay/core/constant/app_colors.dart';
import 'package:Thinkpay/model/onboarding/onboarding_draft.dart';
import 'package:Thinkpay/ui/pages/onboarding/widgets/onboarding_scaffold.dart';
import 'package:Thinkpay/ui/pages/onboarding/widgets/onboarding_widgets.dart';

/// Step 1 — country and currency, driven by `currency_country_picker`.
///
/// Picking a country adopts its currency straight away, so the common path is
/// one tap; the currency row exists only for the rare override.
class CountryStep extends StatefulWidget {
  const CountryStep({super.key, required this.draft, required this.onNext});

  final OnboardingDraft draft;
  final VoidCallback onNext;

  @override
  State<CountryStep> createState() => _CountryStepState();
}

class _CountryStepState extends State<CountryStep> {
  void _pickCountry() {
    ccp.showCountryPickerFullScreen(
      context: context,
      showFlag: true,
      theme: _countryTheme(ThemeColors.of(context)),
      onSelect: (picked) {
        if (!mounted) return;
        setState(() => widget.draft.applyCountry(picked));
      },
    );
  }

  void _pickCurrency() {
    ccp.showCurrencyPickerBottomSheet(
      context: context,
      theme: _currencyTheme(ThemeColors.of(context)),
      onSelect: (picked) {
        if (!mounted) return;
        setState(() => widget.draft.currencyCode = picked.code);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    final draft = widget.draft;
    final country = draft.country;
    final code = draft.currencyCode;
    final symbol = symbolForCode(code);

    final flag = country == null || country.emoji.isEmpty
        ? '🌐'
        : country.emoji;

    return OnboardingScaffold(
      stepIndex: 0,
      stepLabel: 'Country',
      showBack: false,
      showSkip: false,
      content: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.base,
          AppSpacing.md,
          AppSpacing.md,
        ),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        children: [
          const StepTitle(
            title: 'Where do you live?',
            subtitle:
                'Six quick questions, about 90 seconds. '
                'Every one of them is optional.',
          ),
          const SizedBox(height: AppSpacing.md),

          LabeledField(
            label: 'Country',
            child: _SelectorRow(
              badge: Text(flag, style: const TextStyle(fontSize: 20)),
              title: country?.name ?? 'Select your country',
              subtitle: country == null
                  ? 'Any of 250 countries'
                  : '+${country.phoneCode} · ${country.currencyCode}',
              onTap: _pickCountry,
            ),
          ),
          const SizedBox(height: AppSpacing.marginMobile),

          LabeledField(
            label: 'Currency',
            child: _SelectorRow(
              badge: Text(
                symbol,
                style: AppTypography.dataMono.copyWith(
                  color: tc.text100,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              title: '$code · ${currencyNameForCode(code)}',
              subtitle: 'Tap to change',
              onTap: _pickCurrency,
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          if (country != null && !isAppCurrencyCode(code))
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: InfoNote(
                icon: Icons.info_outline_rounded,
                text:
                    '$code is not supported everywhere in the app yet — you '
                    'can switch it any time.',
                tone: NoteTone.caution,
              ),
            ),

          InfoNote(
            icon: Icons.shield_outlined,
            text:
                'Your numbers stay on this phone until you create an '
                'account. Everything you enter in the next steps can be '
                'changed later in your profile.',
          ),
          const SizedBox(height: AppSpacing.base),
          Text(
            'Amounts will be shown as $symbol${formatMoney(1250, decimals: 0)}',
            style: AppTypography.bodySm.copyWith(
              color: tc.text40,
              fontSize: 11,
            ),
          ),
        ],
      ),
      footer: PrimaryCta(label: 'Continue', onTap: widget.onNext),
    );
  }
}

class _SelectorRow extends StatelessWidget {
  const _SelectorRow({
    required this.badge,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  final Widget badge;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        constraints: const BoxConstraints(minHeight: 64),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.base,
        ),
        decoration: BoxDecoration(
          color: tc.surface2,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: tc.surface3,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: badge,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodySm.copyWith(
                      color: tc.text100,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodySm.copyWith(
                        color: tc.text40,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, size: 20, color: tc.text40),
          ],
        ),
      ),
    );
  }
}

// ── Picker theming ────────────────────────────────────────────────────────────
// The package ships its own UI; these themes keep it on the app's tokens.

InputDecoration _searchDecoration(ThemeColors tc) => InputDecoration(
  hintText: 'Search',
  hintStyle: AppTypography.bodySm.copyWith(color: tc.text40),
  prefixIcon: Icon(Icons.search_rounded, size: 20, color: tc.text40),
  filled: true,
  fillColor: tc.surface2,
  isDense: true,
  contentPadding: const EdgeInsets.symmetric(
    vertical: 12,
    horizontal: AppSpacing.base,
  ),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppRadius.md),
    borderSide: BorderSide(color: tc.border),
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppRadius.md),
    borderSide: BorderSide(color: tc.border),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppRadius.md),
    borderSide: BorderSide(color: tc.intelligenceAccent, width: 1.5),
  ),
);

ccp.CountryPickerThemeData _countryTheme(ThemeColors tc) =>
    ccp.CountryPickerThemeData(
      backgroundColor: tc.background,
      titleTextStyle: AppTypography.bodyMd.copyWith(color: tc.text100),
      countryCodeTextStyle: AppTypography.dataMono.copyWith(
        color: tc.text40,
        fontSize: 12,
      ),
      searchTextStyle: AppTypography.bodyMd.copyWith(color: tc.text100),
      inputDecoration: _searchDecoration(tc),
      flagSize: 22,
    );

ccp.CurrencyPickerThemeData _currencyTheme(ThemeColors tc) =>
    ccp.CurrencyPickerThemeData(
      backgroundColor: tc.background,
      titleTextStyle: AppTypography.bodyMd.copyWith(
        color: tc.text100,
        fontWeight: FontWeight.w700,
      ),
      subtitleTextStyle: AppTypography.bodySm.copyWith(
        color: tc.text40,
        fontSize: 12,
      ),
      currencySignTextStyle: AppTypography.dataMono.copyWith(
        color: tc.text70,
        fontSize: 14,
      ),
      inputDecoration: _searchDecoration(tc),
      flagSize: 20,
    );
