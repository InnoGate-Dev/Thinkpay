import 'package:currency_country_picker/currency_country_picker.dart' as ccp;
import 'package:flutter/material.dart';

import 'package:Thinkpay/core/constant/app_colors.dart';
import 'package:Thinkpay/core/constant/theme_provider.dart';
import 'package:Thinkpay/core/errors/exceptions.dart';
import 'package:Thinkpay/core/repository/userRepo.dart';
import 'package:Thinkpay/core/utils/currency_catalog.dart';
import 'package:Thinkpay/model/account_deletion_schedule.dart';
import 'package:Thinkpay/providers/user_profile_store.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Profile settings — appearance, country, currency and account deletion
// ─────────────────────────────────────────────────────────────────────────────
//
// One place for the "Advanced" actions so the profile screen and the drawer
// stay identical. Each entry point does its own persistence and reports the
// outcome with a snackbar, which keeps the call sites to a single line.
//
// The appearance and the currency are both preferences of `profile_config`, so
// they follow the user to every device. The currency flow deliberately explains
// itself twice: a note on the sheet and a confirmation dialog. Amounts are never
// converted — the backend only stores the code, and every screen re-renders the
// same numbers with a new symbol.

/// Opens the country sheet and saves the choice.
Future<void> showProfileCountryPicker(BuildContext context) async {
  final store = UserProfileStore();
  final tc = ThemeColors.of(context);
  final messenger = ScaffoldMessenger.of(context);

  final picked = await showModalBottomSheet<ccp.Country>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _CountrySheet(tc: tc, selectedName: store.country),
  );
  if (picked == null || !context.mounted) return;
  if (picked.name == store.country) return;

  await _saveConfig(
    store: store,
    tc: tc,
    messenger: messenger,
    country: picked.name,
    currency: store.currencyCode,
    message: 'Country updated to ${picked.name}.',
  );
}

/// Opens the currency sheet, confirms the "no conversion" rule and saves.
Future<void> showProfileCurrencyPicker(BuildContext context) async {
  final store = UserProfileStore();
  final tc = ThemeColors.of(context);
  final messenger = ScaffoldMessenger.of(context);

  final picked = await showModalBottomSheet<ccp.Currency>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _CurrencySheet(
      tc: tc,
      selectedCode: store.currencyCode,
      currentSymbol: store.currencySymbol,
    ),
  );
  if (picked == null || !context.mounted) return;

  final code = picked.code.toUpperCase();
  if (code == store.currencyCode) return;

  final confirmed = await _confirmCurrencyChange(context, tc, picked, store);
  if (confirmed != true) return;

  await _saveConfig(
    store: store,
    tc: tc,
    messenger: messenger,
    country: store.country,
    currency: code,
    message: 'Currency is now ${picked.code} (${picked.symbol}).',
  );
}

/// Flips the appearance between light and dark and saves it on the profile.
///
/// The switch moves immediately — waiting for a round-trip before repainting
/// the whole app would feel broken — and rolls back if the write fails. Because
/// the value lives in `profile_config`, the next sign-in and every other device
/// start in the same theme.
Future<void> toggleProfileTheme(BuildContext context) async {
  final theme = ThemeNotifier();
  final store = UserProfileStore();
  final tc = ThemeColors.of(context);
  final messenger = ScaffoldMessenger.of(context);

  final previousMode = theme.mode;
  final previousCode = store.themeCode;

  theme.setMode(theme.isDark ? ThemeMode.light : ThemeMode.dark);
  store.setThemePreference(theme.preference);

  try {
    store.setUser(
      await UserRepository().updateProfileConfig(theme: theme.preference),
    );
  } on ApiException catch (e) {
    theme.setMode(previousMode);
    store.setThemePreference(previousCode);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(_toast(tc, e.message, error: true));
  } catch (_) {
    theme.setMode(previousMode);
    store.setThemePreference(previousCode);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        _toast(tc, 'Could not save the theme. Please try again.', error: true),
      );
  }
}

/// Two-step destructive flow: a sheet that spells out what happens and a typed
/// confirmation. The account is deactivated at once and its details are only
/// replaced after the 30-day grace period, which the app says out loud before
/// the session ends.
Future<void> showDeleteAccountSheet(BuildContext context) async {
  final store = UserProfileStore();
  final tc = ThemeColors.of(context);
  final navigator = Navigator.of(context, rootNavigator: true);

  final schedule = await showModalBottomSheet<AccountDeletionSchedule>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _DeleteAccountSheet(tc: tc, email: store.email),
  );
  if (schedule == null) return;

  // The session is over either way: the profile is inactive from now on.
  if (context.mounted) {
    await _showDeletionScheduledDialog(context, tc, schedule);
  }

  store.clear();
  navigator.pushNamedAndRemoveUntil('/startup', (_) => false);
}

/// Confirms the deletion the user just requested and tells them when it becomes
/// permanent — and how to stop it.
Future<void> _showDeletionScheduledDialog(
  BuildContext context,
  ThemeColors tc,
  AccountDeletionSchedule schedule,
) {
  final on = schedule.scheduledFor;
  final when = on == null
      ? '${schedule.graceDays} days from now'
      : '${_dayMonthYear(on)} (${schedule.graceDays} days)';

  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: tc.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      icon: Icon(Icons.event_available_rounded, color: tc.lime, size: 28),
      title: Text(
        'Deletion scheduled',
        textAlign: TextAlign.center,
        style: AppTypography.headlineMd.copyWith(color: tc.text100, fontSize: 17),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your profile is now inactive. Everything you own on DayOne is '
            'scheduled to be removed on $when.',
            style: AppTypography.bodySm.copyWith(color: tc.text70, height: 1.45),
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: tc.surface2,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: tc.border),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.undo_rounded, color: tc.lime, size: 18),
                const SizedBox(width: AppSpacing.base),
                Expanded(
                  child: Text(
                    'Changed your mind? Sign in before then and your account is '
                    'restored right away.',
                    style: AppTypography.bodySm.copyWith(
                      color: tc.text70,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: Text(
            'Got it',
            style: TextStyle(color: tc.lime, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    ),
  );
}

/// `5 Dec 2026` — the date the account's details are replaced for good.
String _dayMonthYear(DateTime date) =>
    '${date.day} ${_months[date.month - 1]} ${date.year}';

const List<String> _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

// ─────────────────────────────────────────────────────────────────────────────
// Persistence
// ─────────────────────────────────────────────────────────────────────────────

/// Writes the country and currency, keeping the stored theme, and keeps the UI
/// honest: optimistic update first, rollback if the call fails.
Future<void> _saveConfig({
  required UserProfileStore store,
  required ThemeColors tc,
  required ScaffoldMessengerState messenger,
  required String country,
  required String currency,
  required String message,
}) async {
  final previousCountry = store.country;
  final previousCurrency = store.currencyCode;

  store.setProfileConfig(
    country: country,
    currencyCode: currency,
    themeCode: store.themeCode,
  );
  store.setSavingConfig(true);
  try {
    store.setUser(
      await UserRepository().updateProfileConfig(
        country: country,
        currency: currency,
        theme: store.themeCode,
      ),
    );
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(_toast(tc, message));
  } on ApiException catch (e) {
    store.setProfileConfig(country: previousCountry, currencyCode: previousCurrency);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(_toast(tc, e.message, error: true));
  } catch (e) {
    store.setProfileConfig(country: previousCountry, currencyCode: previousCurrency);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(_toast(tc, 'Could not save. Please try again.', error: true));
  } finally {
    store.setSavingConfig(false);
  }
}

SnackBar _toast(ThemeColors tc, String message, {bool error = false}) => SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: error ? tc.red : tc.surface,
      content: Text(
        message,
        style: TextStyle(
          color: error ? Colors.white : tc.text100,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );

// ─────────────────────────────────────────────────────────────────────────────
// Country sheet
// ─────────────────────────────────────────────────────────────────────────────
// The package's own country picker fires a callback instead of returning a
// value, so this sheet drives the same catalogue directly: the selection comes
// back through `Navigator.pop`, and the styling matches the currency sheet.

class _CountrySheet extends StatefulWidget {
  const _CountrySheet({required this.tc, required this.selectedName});

  final ThemeColors tc;
  final String selectedName;

  @override
  State<_CountrySheet> createState() => _CountrySheetState();
}

class _CountrySheetState extends State<_CountrySheet> {
  final _searchCtrl = TextEditingController();
  late List<ccp.Country> _results;

  @override
  void initState() {
    super.initState();
    _results = _sortedCountries();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  static List<ccp.Country>? _sortedCache;

  static List<ccp.Country> _sortedCountries() {
    final cached = _sortedCache;
    if (cached != null) return cached;
    final sorted = [...countryCatalogue]
      ..sort((a, b) => a.name.compareTo(b.name));
    return _sortedCache = sorted;
  }

  void _filter(String query) {
    final q = query.trim().toLowerCase();
    setState(() {
      _results = q.isEmpty
          ? _sortedCountries()
          : _sortedCountries()
              .where((c) => c.name.toLowerCase().contains(q))
              .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final tc = widget.tc;
    final selected = widget.selectedName.trim().toLowerCase();

    return _SheetShell(
      tc: tc,
      title: 'Country',
      subtitle: 'Sets the flag shown on your profile',
      searchHint: 'Search country',
      searchCtrl: _searchCtrl,
      onSearch: _filter,
      emptyLabel: 'No country matches “${_searchCtrl.text.trim()}”',
      itemCount: _results.length,
      itemBuilder: (context, index) {
        final country = _results[index];
        return _PickerRow(
          tc: tc,
          badge: country.emoji.isEmpty ? '🌐' : country.emoji,
          title: country.name,
          subtitle: [
            if (country.currencyCode.isNotEmpty) country.currencyCode,
            if (country.currencyName.isNotEmpty) country.currencyName,
          ].join(' · '),
          isSelected: country.name.toLowerCase() == selected,
          onTap: () => Navigator.pop(context, country),
        );
      },
    );
  }
}

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

// ─────────────────────────────────────────────────────────────────────────────
// Currency sheet
// ─────────────────────────────────────────────────────────────────────────────

class _CurrencySheet extends StatefulWidget {
  const _CurrencySheet({
    required this.tc,
    required this.selectedCode,
    required this.currentSymbol,
  });

  final ThemeColors tc;
  final String selectedCode;
  final String currentSymbol;

  @override
  State<_CurrencySheet> createState() => _CurrencySheetState();
}

class _CurrencySheetState extends State<_CurrencySheet> {
  final _searchCtrl = TextEditingController();
  late List<ccp.Currency> _results;

  @override
  void initState() {
    super.initState();
    _results = _sortedCatalogue();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  static List<ccp.Currency> _sortedCatalogue() {
    final all = [...currencyCatalogue]
      ..sort((a, b) => a.code.compareTo(b.code));
    return all;
  }

  void _filter(String query) {
    final q = query.trim().toLowerCase();
    setState(() {
      _results = q.isEmpty
          ? _sortedCatalogue()
          : currencyCatalogue
              .where((c) =>
                  c.code.toLowerCase().contains(q) ||
                  c.name.toLowerCase().contains(q))
              .toList()
            ..sort((a, b) => a.code.compareTo(b.code));
    });
  }

  @override
  Widget build(BuildContext context) {
    final tc = widget.tc;
    final selected = widget.selectedCode.toUpperCase();
    final from = widget.currentSymbol;

    return _SheetShell(
      tc: tc,
      title: 'Currency',
      subtitle: 'Used for every amount in the app',
      searchHint: 'Search currency or code',
      searchCtrl: _searchCtrl,
      onSearch: _filter,
      note: _InfoNote(
        tc: tc,
        icon: Icons.swap_horiz_rounded,
        title: 'Symbols change, numbers do not',
        body:
            'Choosing a currency never converts your amounts at exchange '
            'rates. ${from.isEmpty ? '25,000' : '$from 25,000'} keeps the value '
            '25,000 — only the symbol in front of it changes.',
      ),
      emptyLabel: 'No currency matches “${_searchCtrl.text.trim()}”',
      itemCount: _results.length,
      itemBuilder: (context, index) {
        final currency = _results[index];
        return _PickerRow(
          tc: tc,
          badge: currency.symbol.isEmpty ? currency.code : currency.symbol,
          badgeMonospace: true,
          title: currency.code,
          subtitle: currency.name,
          isSelected: currency.code.toUpperCase() == selected,
          onTap: () => Navigator.pop(context, currency),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared sheet pieces
// ─────────────────────────────────────────────────────────────────────────────

/// Chrome shared by the country and currency sheets: grab handle, title, an
/// optional explanatory note, a search field and the scrolling list.
class _SheetShell extends StatelessWidget {
  const _SheetShell({
    required this.tc,
    required this.title,
    required this.subtitle,
    required this.searchHint,
    required this.searchCtrl,
    required this.onSearch,
    required this.emptyLabel,
    required this.itemCount,
    required this.itemBuilder,
    this.note,
  });

  final ThemeColors tc;
  final String title;
  final String subtitle;
  final String searchHint;
  final TextEditingController searchCtrl;
  final ValueChanged<String> onSearch;
  final Widget? note;
  final String emptyLabel;
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: BoxDecoration(
        color: tc.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.sm),
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: tc.text20,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.marginMobile,
              AppSpacing.md,
              AppSpacing.base,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTypography.headlineMd.copyWith(color: tc.text100),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: AppTypography.bodySm.copyWith(
                          color: tc.text40,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close_rounded, color: tc.text40, size: 20),
                ),
              ],
            ),
          ),
          if (note != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: note,
            ),
          if (note != null) const SizedBox(height: AppSpacing.sm),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: TextField(
              controller: searchCtrl,
              onChanged: onSearch,
              style: AppTypography.bodySm.copyWith(color: tc.text100),
              decoration: _searchDecoration(tc).copyWith(hintText: searchHint),
            ),
          ),
          const SizedBox(height: AppSpacing.base),
          Expanded(
            child: itemCount == 0
                ? Center(
                    child: Text(
                      emptyLabel,
                      style: AppTypography.bodySm.copyWith(color: tc.text40),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.base,
                      0,
                      AppSpacing.base,
                      AppSpacing.md,
                    ),
                    itemCount: itemCount,
                    itemBuilder: itemBuilder,
                  ),
          ),
        ],
      ),
    );
  }
}

/// A selectable row of a picker sheet: badge, title, optional subtitle and a
/// check/chevron on the right.
class _PickerRow extends StatelessWidget {
  const _PickerRow({
    required this.tc,
    required this.badge,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
    this.badgeMonospace = false,
  });

  final ThemeColors tc;
  final String badge;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;
  final bool badgeMonospace;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base,
          vertical: 10,
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? tc.limeDim : tc.surface2,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: isSelected ? tc.limeBorder : tc.border),
              ),
              child: Text(
                badge,
                style: badgeMonospace
                    ? AppTypography.dataMono.copyWith(
                        color: isSelected ? tc.lime : tc.text70,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      )
                    : const TextStyle(fontSize: 20),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodySm.copyWith(
                      color: tc.text100,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodySm.copyWith(
                        color: tc.text40,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: tc.lime, size: 20)
            else
              Icon(Icons.chevron_right_rounded, color: tc.text20, size: 18),
          ],
        ),
      ),
    );
  }
}

/// Confirmation before the symbol actually changes.
Future<bool?> _confirmCurrencyChange(
  BuildContext context,
  ThemeColors tc,
  ccp.Currency picked,
  UserProfileStore store,
) {
  final from = store.currencySymbol;
  final to = picked.symbol.isEmpty ? picked.code : picked.symbol;
  const sample = '25,000';

  return showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: tc.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      title: Text(
        'Change currency to ${picked.code}?',
        style: AppTypography.headlineMd.copyWith(color: tc.text100, fontSize: 17),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your amounts are not converted. Only the symbol changes:',
            style: AppTypography.bodySm.copyWith(color: tc.text70, height: 1.45),
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.base,
            ),
            decoration: BoxDecoration(
              color: tc.surface2,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: tc.border),
            ),
            child: Text(
              '$from $sample  →  $to $sample',
              textAlign: TextAlign.center,
              style: AppTypography.dataMono.copyWith(
                color: tc.text100,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Balances, budgets, goals and reports keep the same numbers, now '
            'shown with the ${picked.name} symbol.',
            style: AppTypography.bodySm.copyWith(color: tc.text40, fontSize: 12, height: 1.4),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: Text(
            'Cancel',
            style: TextStyle(color: tc.text70, fontWeight: FontWeight.w600),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: Text(
            'Change symbol',
            style: TextStyle(color: tc.lime, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Delete account sheet
// ─────────────────────────────────────────────────────────────────────────────

class _DeleteAccountSheet extends StatefulWidget {
  const _DeleteAccountSheet({required this.tc, required this.email});

  final ThemeColors tc;
  final String email;

  @override
  State<_DeleteAccountSheet> createState() => _DeleteAccountSheetState();
}

class _DeleteAccountSheetState extends State<_DeleteAccountSheet> {
  static const _phrase = 'DELETE';

  final _confirmCtrl = TextEditingController();
  bool _busy = false;
  String? _error;

  bool get _canDelete =>
      !_busy && _confirmCtrl.text.trim().toUpperCase() == _phrase;

  @override
  void dispose() {
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _delete() async {
    if (!_canDelete) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final schedule = await UserRepository().deleteAccount();
      if (!mounted) return;
      Navigator.pop(context, schedule);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = e.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = 'Could not schedule the deletion. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final tc = widget.tc;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: tc.background,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
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
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.marginMobile),
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: tc.redDim,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Icon(Icons.delete_outline_rounded, color: tc.red, size: 20),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'Delete account',
                        style: AppTypography.headlineMd.copyWith(color: tc.text100),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Your profile is deactivated right away and schedule to delete 30 '
                  'days later.',
                  style: AppTypography.bodySm.copyWith(
                    color: tc.text70,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                _InfoNote(
                  tc: tc,
                  icon: Icons.undo_rounded,
                  title: 'Changed your mind?',
                  body:
                      'Sign in again within 30 days and your account is '
                      'restored with all of its data.',
                ),
                const SizedBox(height: AppSpacing.sm),
                _DeletionSteps(tc: tc),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: tc.surface2,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: tc.border),
                  ),
                  child: Text(
                    widget.email,
                    style: AppTypography.dataMono.copyWith(
                      color: tc.text70,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.marginMobile),
                Text(
                  'Type $_phrase to confirm',
                  style: AppTypography.bodySm.copyWith(
                    color: tc.text100,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.base),
                TextField(
                  controller: _confirmCtrl,
                  enabled: !_busy,
                  textCapitalization: TextCapitalization.characters,
                  onChanged: (_) => setState(() {}),
                  style: AppTypography.bodyMd.copyWith(color: tc.text100),
                  decoration: _searchDecoration(tc).copyWith(
                    hintText: _phrase,
                    prefixIcon: Icon(Icons.keyboard_rounded, size: 20, color: tc.text40),
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: AppSpacing.base),
                  Text(
                    _error!,
                    style: AppTypography.bodySm.copyWith(color: tc.red, fontSize: 12),
                  ),
                ],
                const SizedBox(height: AppSpacing.marginMobile),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _canDelete ? _delete : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: tc.red,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: tc.redDim,
                      disabledForegroundColor: tc.red.withValues(alpha: 0.6),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                    ),
                    child: _busy
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'Delete my account',
                            style: AppTypography.bodyMd.copyWith(
                              fontWeight: FontWeight.w700,
                              color: _canDelete ? Colors.white : tc.red,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: AppSpacing.base),
                SizedBox(
                  height: 48,
                  child: TextButton(
                    onPressed: _busy ? null : () => Navigator.pop(context, false),
                    child: Text(
                      'Keep my account',
                      style: AppTypography.bodyMd.copyWith(
                        color: tc.text70,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The three stages a deleted account goes through. Nothing is removed, so the
/// list states what happens to the profile rather than what is thrown away.
class _DeletionSteps extends StatelessWidget {
  const _DeletionSteps({required this.tc});

  final ThemeColors tc;

  static const _items = [
    'Transactions, budgets and categories',
    'Goals and their contributions',
    'Loans, payments and credit cards',
    'Profile, appearance and currency settings',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: tc.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: tc.border),
      ),
      child: Column(
        children: [
          for (final item in _items)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(Icons.remove_circle_outline_rounded, color: tc.red, size: 15),
                  const SizedBox(width: AppSpacing.base),
                  Expanded(
                    child: Text(
                      item,
                      style: AppTypography.bodySm.copyWith(
                        color: tc.text70,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared note
// ─────────────────────────────────────────────────────────────────────────────

class _InfoNote extends StatelessWidget {
  const _InfoNote({
    required this.tc,
    required this.icon,
    required this.title,
    required this.body,
  });

  final ThemeColors tc;
  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: tc.accentDim,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: tc.accent.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: tc.accent, size: 18),
          const SizedBox(width: AppSpacing.base),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.bodySm.copyWith(
                    color: tc.text100,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  body,
                  style: AppTypography.bodySm.copyWith(
                    color: tc.text70,
                    fontSize: 11,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
