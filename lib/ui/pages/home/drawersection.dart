import 'package:flutter/material.dart';

import 'package:Thinkpay/core/constant/app_colors.dart';
import 'package:Thinkpay/core/constant/theme_provider.dart';
import 'package:Thinkpay/core/repository/userRepo.dart';
import 'package:Thinkpay/providers/profile_sync.dart';
import 'package:Thinkpay/providers/user_profile_store.dart';
import 'package:Thinkpay/ui/pages/profile/Profile.dart';
import 'package:Thinkpay/ui/pages/profile/profile_settings.dart';
import 'package:Thinkpay/ui/pages/profile/profile_widgets.dart';
import 'package:Thinkpay/ui/pages/security/security.dart';
import 'package:Thinkpay/ui/pages/support/support.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Navigation drawer
// ─────────────────────────────────────────────────────────────────────────────
//
// The drawer is the first place people look to check who they are signed in as,
// so it loads the profile itself rather than trusting whatever the store holds.
// On a cold start the store still has the signed-out placeholder, which is why
// the header used to read "User / user@thinkpay.app"; [ProfileSync] shares one
// request with whoever else asked first.
//
// Items live in the same two bands as the profile screen — General for the
// everyday destinations, Advanced for the settings that change how the app
// behaves — so the two surfaces never disagree about where something is.

class ProfileDrawer extends StatefulWidget {
  const ProfileDrawer({super.key});

  @override
  State<ProfileDrawer> createState() => _ProfileDrawerState();
}

class _ProfileDrawerState extends State<ProfileDrawer> {
  final _store = UserProfileStore();
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (_failed) setState(() => _failed = false);
    final ok = await ProfileSync.ensureLoaded();
    if (!mounted || ok) return;
    setState(() => _failed = true);
  }

  /// Leaves the drawer and opens a full page on the shell's navigator.
  void _navigate(Widget page) {
    final navigator = Navigator.of(context);
    navigator.pop(); // close the drawer
    navigator.push(MaterialPageRoute(builder: (_) => page));
  }

  /// Closes the drawer, then runs [open] on the page underneath: a bottom sheet
  /// cannot be shown while the drawer route is still animating out, and this
  /// drawer's own context dies with it.
  Future<void> _openAfterClose(void Function(BuildContext host) open) async {
    final host = Navigator.of(context).context;
    Scaffold.maybeOf(context)?.closeDrawer();
    await Future<void>.delayed(const Duration(milliseconds: 260));
    if (!host.mounted) return;
    open(host);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([ThemeNotifier(), _store]),
      builder: (context, _) {
        final tc = ThemeColors.of(context);
        final isDark = ThemeNotifier().isDark;

        return ColoredBox(
          color: tc.background,
          child: Column(
            children: [
              _DrawerHeader(
                store: _store,
                tc: tc,
                failed: _failed,
                onRetry: _load,
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.marginMobile,
                    AppSpacing.marginMobile,
                    AppSpacing.marginMobile,
                    AppSpacing.base,
                  ),
                  children: [
                    ProfileSectionLabel(label: 'General', tc: tc),
                    ProfileSettingsCard(
                      tc: tc,
                      children: [
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
                          onTap: () => toggleProfileTheme(context),
                          trailing: Switch.adaptive(
                            value: isDark,
                            onChanged: (_) => toggleProfileTheme(context),
                            activeThumbColor: tc.background,
                            activeTrackColor: tc.lime,
                            inactiveThumbColor: tc.text40,
                            inactiveTrackColor: tc.surface3,
                          ),
                        ),
                        ProfileSettingsRow(
                          tc: tc,
                          leading: ProfileIconBadge(
                            tc: tc,
                            icon: Icons.person_outline_rounded,
                          ),
                          title: 'Profile',
                          subtitle: 'View and edit your details',
                          onTap: () => _navigate(const Profile()),
                        ),
                        ProfileSettingsRow(
                          tc: tc,
                          leading: ProfileIconBadge(
                            tc: tc,
                            icon: Icons.verified_user_outlined,
                          ),
                          title: 'Privacy & security',
                          subtitle: 'Password and active sessions',
                          onTap: () => _navigate(const SecurityPage()),
                        ),
                        ProfileSettingsRow(
                          tc: tc,
                          leading: ProfileIconBadge(
                            tc: tc,
                            icon: Icons.help_outline_rounded,
                          ),
                          title: 'Help & support',
                          subtitle: 'Get answers or reach us',
                          onTap: () => _navigate(const SupportPage()),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    ProfileSectionLabel(label: 'Advanced', tc: tc),
                    ProfileSettingsCard(
                      tc: tc,
                      children: [
                        ProfileSettingsRow(
                          tc: tc,
                          leading: ProfileIconBadge(
                            tc: tc,
                            text: _store.countryFlag,
                          ),
                          title: 'Country',
                          subtitle: 'Shown on your profile',
                          value: _store.hasCountry ? _store.country : 'Not set',
                          busy: _store.isSavingConfig,
                          onTap: () => _openAfterClose(showProfileCountryPicker),
                        ),
                        ProfileSettingsRow(
                          tc: tc,
                          leading: ProfileIconBadge(
                            tc: tc,
                            text: _store.currencySymbol,
                          ),
                          title: 'Currency',
                          subtitle: 'Symbol only — amounts are not converted',
                          value:
                              '${_store.currencyCode} · ${_store.currencySymbol}',
                          busy: _store.isSavingConfig,
                          onTap: () =>
                              _openAfterClose(showProfileCurrencyPicker),
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
                          onTap: () => _openAfterClose(showDeleteAccountSheet),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.marginMobile,
                  AppSpacing.base,
                  AppSpacing.marginMobile,
                  AppSpacing.marginMobile,
                ),
                child: _LogoutButton(tc: tc),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────
/// Identity block: avatar, name, email and the country/currency the app renders
/// with. While the profile is in flight it shows a progress line instead of the
/// signed-out placeholder, and offers a retry if the call failed.
class _DrawerHeader extends StatelessWidget {
  const _DrawerHeader({
    required this.store,
    required this.tc,
    required this.failed,
    required this.onRetry,
  });

  final UserProfileStore store;
  final ThemeColors tc;
  final bool failed;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final loaded = store.isLoaded;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        AppSpacing.marginMobile,
        MediaQuery.of(context).padding.top + AppSpacing.marginMobile,
        AppSpacing.marginMobile,
        AppSpacing.marginMobile,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [tc.cardGradientStart, tc.cardGradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border(bottom: BorderSide(color: tc.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ProfileAvatar(
                name: loaded ? store.name : '',
                tc: tc,
                size: 52,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loaded
                          ? store.name
                          : (failed
                              ? 'Profile unavailable'
                              : 'Loading your profile…'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.headlineMd.copyWith(
                        color: loaded ? tc.text100 : tc.text70,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      loaded
                          ? store.email
                          : (failed
                              ? 'Tap retry to try again'
                              : 'Fetching account details'),
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
              if (!loaded)
                IconButton(
                  onPressed: failed ? onRetry : null,
                  tooltip: 'Retry',
                  icon: Icon(
                    Icons.refresh_rounded,
                    size: 18,
                    color: failed ? tc.lime : tc.text20,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          if (loaded)
            Wrap(
              spacing: AppSpacing.base,
              runSpacing: AppSpacing.base,
              children: [
                if (store.isLeader)
                  ProfilePill(
                    tc: tc,
                    label: 'Leader',
                    icon: Icons.workspace_premium_rounded,
                  ),
                ProfilePill(
                  tc: tc,
                  label: store.hasCountry ? store.country : 'Country not set',
                  emoji: store.countryFlag,
                  muted: !store.hasCountry,
                ),
                ProfilePill(
                  tc: tc,
                  label: '${store.currencyCode} · ${store.currencySymbol}',
                ),
              ],
            )
          else
            Row(
              children: [
                SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.6,
                    color: failed ? tc.red : tc.lime,
                  ),
                ),
                const SizedBox(width: AppSpacing.base),
                Text(
                  failed
                      ? 'Could not load your profile'
                      : 'Syncing your country and currency',
                  style: AppTypography.bodySm.copyWith(
                    color: tc.text40,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

// ── Logout button ─────────────────────────────────────────────────────────────
class _LogoutButton extends StatefulWidget {
  const _LogoutButton({required this.tc});
  final ThemeColors tc;

  @override
  State<_LogoutButton> createState() => _LogoutButtonState();
}

class _LogoutButtonState extends State<_LogoutButton> {
  final UserRepository _userRepo = UserRepository();
  bool _busy = false;

  Future<void> _confirmAndLogout() async {
    if (_busy) return;

    final tc = widget.tc;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: tc.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Log out?',
            style: TextStyle(color: tc.text100, fontSize: 17, fontWeight: FontWeight.w700)),
        content: Text(
            'Your session will be revoked and you will need to sign in again.',
            style: TextStyle(color: tc.text70, fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text('Cancel',
                style: TextStyle(color: tc.text70, fontWeight: FontWeight.w600)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text('Log Out',
                style: TextStyle(color: tc.red, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _busy = true);
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    // Close the drawer before leaving the shell, otherwise its "open" state
    // would outlive the AppShell and keep the bottom nav bar hidden.
    Scaffold.maybeOf(context)?.closeDrawer();

    try {
      // Revokes the token on the backend, then clears it locally.
      await _userRepo.logout();
      UserProfileStore().clear();
      navigator.pushNamedAndRemoveUntil('/startup', (_) => false);
    } catch (e) {
      debugPrint('LOGOUT ERROR: $e');
      if (!mounted) return;
      setState(() => _busy = false);
      messenger.showSnackBar(
        const SnackBar(content: Text('Could not log out. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tc = widget.tc;
    return GestureDetector(
      onTap: _busy ? null : _confirmAndLogout,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: tc.redDim,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: tc.red.withValues(alpha: 0.3)),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          if (_busy)
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: tc.red),
            )
          else
            Icon(Icons.logout_rounded, color: tc.red, size: 18),
          const SizedBox(width: 8),
          Text(_busy ? 'Logging out…' : 'Log Out',
              style: TextStyle(color: tc.red, fontSize: 14, fontWeight: FontWeight.w700)),
        ]),
      ),
    );
  }
}
