import 'package:flutter/material.dart';

import 'package:Thinkpay/core/constant/app_colors.dart';
import 'package:Thinkpay/core/constant/theme_provider.dart';
import 'package:Thinkpay/providers/finance_provider.dart';
import 'package:Thinkpay/providers/profile_sync.dart';
import 'package:Thinkpay/providers/user_profile_store.dart';
import 'package:Thinkpay/ui/pages/profile/ChangePassword.dart';
import 'package:Thinkpay/ui/pages/profile/EditProfile.dart';
import 'package:Thinkpay/ui/pages/profile/profile_settings.dart';
import 'package:Thinkpay/ui/pages/profile/profile_widgets.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Profile
// ─────────────────────────────────────────────────────────────────────────────
//
// The screen is a short stack of groups, ordered by how often they are used:
//
//   header    who you are, plus the country and currency the app renders with
//   glance    your numbers, already formatted in that currency
//   account   personal details, password, appearance
//   advanced  country, currency and the delete door
//
// Country and currency sit under Advanced because they are set once and then
// forgotten — and because the currency one needs explaining every time: it
// swaps the symbol in front of an amount, it never converts the amount. That
// warning is repeated on the sheet, in the confirm dialog and as the row's
// subtitle, since an exchange-rate assumption here would quietly mislead about
// what the user's money is worth.

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final _store = UserProfileStore();
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  /// Pulls the latest profile. Runs on open so the country/currency shown here
  /// always match the backend, and again on pull-to-refresh.
  Future<void> _refresh() async {
    if (mounted) setState(() => _loadError = null);
    final ok = await ProfileSync.ensureLoaded(force: true);
    if (!mounted || ok) return;
    setState(() {
      _loadError = 'We could not refresh your profile. Check your connection '
          'and try again.';
    });
  }

  void _open(Widget page) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => page));

  @override
  Widget build(BuildContext context) {
    final finance = FinanceProvider();

    return ListenableBuilder(
      listenable: Listenable.merge([finance, ThemeNotifier(), _store]),
      builder: (context, _) {
        final tc = ThemeColors.of(context);
        final isDark = ThemeNotifier().isDark;

        return Scaffold(
          backgroundColor: tc.background,
          appBar: AppBar(
            backgroundColor: tc.background,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            titleSpacing: AppSpacing.marginMobile,
            title: Text(
              'Profile',
              style: AppTypography.headlineMd.copyWith(
                color: tc.text100,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            actions: [
              IconButton(
                onPressed: () => _open(const EditProfilePage()),
                tooltip: 'Edit profile',
                icon: Icon(Icons.edit_outlined, color: tc.lime, size: 21),
              ),
              const SizedBox(width: AppSpacing.xs),
            ],
          ),
          body: RefreshIndicator(
            color: tc.lime,
            backgroundColor: tc.surface,
            onRefresh: _refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.marginMobile,
                AppSpacing.base,
                AppSpacing.marginMobile,
                110,
              ),
              children: [
                if (_loadError != null)
                  ProfileErrorBanner(
                    tc: tc,
                    message: _loadError!,
                    onRetry: _refresh,
                  ),
                ProfileHeader(store: _store, tc: tc),
                const SizedBox(height: AppSpacing.md),

                // ── At a glance ───────────────────────────────────────────
                ProfileSectionLabel(
                  label: 'At a glance',
                  tc: tc,
                  trailing: Text(
                    _store.currencyCode,
                    style: AppTypography.labelCaps.copyWith(
                      color: tc.text40,
                      fontSize: 10,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                _StatGrid(
                  tiles: [
                    ProfileStatTile(
                      tc: tc,
                      label: 'Transactions',
                      value: '${finance.transactions.length}',
                      icon: Icons.receipt_long_rounded,
                    ),
                    ProfileStatTile(
                      tc: tc,
                      label: 'Balance',
                      value: profileMoney(finance.balance, _store),
                      icon: Icons.account_balance_wallet_rounded,
                      valueColor: finance.balance >= 0 ? tc.lime : tc.red,
                    ),
                    ProfileStatTile(
                      tc: tc,
                      label: 'Total income',
                      value: profileMoney(finance.totalIncome, _store),
                      icon: Icons.south_west_rounded,
                      valueColor: tc.lime,
                    ),
                    ProfileStatTile(
                      tc: tc,
                      label: 'Total expenses',
                      value: profileMoney(finance.totalExpenses, _store),
                      icon: Icons.north_east_rounded,
                      valueColor: tc.red,
                    ),
                  ],
                ),

                // ── Account ───────────────────────────────────────────────
                const SizedBox(height: AppSpacing.md),
                ProfileSectionLabel(label: 'Account', tc: tc),
                ProfileSettingsCard(
                  tc: tc,
                  children: [
                    ProfileSettingsRow(
                      tc: tc,
                      leading: ProfileIconBadge(
                        tc: tc,
                        icon: Icons.badge_outlined,
                      ),
                      title: 'Personal details',
                      subtitle: 'Name, email and birthday',
                      onTap: () => _open(const EditProfilePage()),
                    ),
                    ProfileSettingsRow(
                      tc: tc,
                      leading: ProfileIconBadge(
                        tc: tc,
                        icon: Icons.lock_outline_rounded,
                      ),
                      title: 'Password',
                      subtitle: 'Change your password',
                      onTap: () => _open(const ChangePasswordPage()),
                    ),
                    ProfileSettingsRow(
                      tc: tc,
                      leading: ProfileIconBadge(
                        tc: tc,
                        icon: isDark
                            ? Icons.dark_mode_outlined
                            : Icons.light_mode_outlined,
                      ),
                      title: 'Appearance',
                      subtitle: isDark ? 'Dark theme' : 'Light theme',
                      trailing: Switch.adaptive(
                        value: isDark,
                        onChanged: (_) => toggleProfileTheme(context),
                        activeThumbColor: tc.background,
                        activeTrackColor: tc.lime,
                        inactiveThumbColor: tc.text40,
                        inactiveTrackColor: tc.surface3,
                      ),
                    ),
                  ],
                ),

                // ── Advanced ──────────────────────────────────────────────
                const SizedBox(height: AppSpacing.md),
                ProfileSectionLabel(label: 'Advanced', tc: tc),
                ProfileSettingsCard(
                  tc: tc,
                  children: [
                    ProfileSettingsRow(
                      tc: tc,
                      leading: ProfileIconBadge(tc: tc, text: _store.countryFlag),
                      title: 'Country',
                      subtitle: 'Changes the flag shown on your profile',
                      value: _store.hasCountry ? _store.country : 'Not set',
                      busy: _store.isSavingConfig,
                      onTap: () => showProfileCountryPicker(context),
                    ),
                    ProfileSettingsRow(
                      tc: tc,
                      leading: ProfileIconBadge(
                        tc: tc,
                        text: _store.currencySymbol,
                      ),
                      title: 'Currency',
                      subtitle: 'Symbol only — your amounts are not converted',
                      value: '${_store.currencyCode} · ${_store.currencySymbol}',
                      busy: _store.isSavingConfig,
                      onTap: () => showProfileCurrencyPicker(context),
                    ),
                    ProfileSettingsRow(
                      tc: tc,
                      leading: ProfileIconBadge(
                        tc: tc,
                        icon: Icons.delete_outline_rounded,
                        danger: true,
                      ),
                      title: 'Delete account',
                      subtitle: 'Deactivated now, removed after 30 days',
                      danger: true,
                      onTap: () => showDeleteAccountSheet(context),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.base),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs,
                  ),
                  child: Text(
                    'Changing your country or currency changes how amounts are '
                    'displayed — the numbers themselves stay exactly the same.',
                    style: AppTypography.bodySm.copyWith(
                      color: tc.text40,
                      fontSize: 11,
                      height: 1.45,
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.md),
                Center(
                  child: Text(
                    'DayOne · ThinkPay',
                    style: AppTypography.labelCaps.copyWith(
                      color: tc.text20,
                      fontSize: 10,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Two-column stat grid
// ─────────────────────────────────────────────────────────────────────────────
/// Lays tiles out two per row and equalises their heights, so a long label in
/// one tile never leaves its neighbour looking cropped.
class _StatGrid extends StatelessWidget {
  const _StatGrid({required this.tiles});

  final List<Widget> tiles;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < tiles.length; i += 2) ...[
          if (i > 0) const SizedBox(height: AppSpacing.sm),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: tiles[i]),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: i + 1 < tiles.length
                      ? tiles[i + 1]
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
