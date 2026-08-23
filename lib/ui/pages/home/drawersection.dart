import 'package:flutter/material.dart';
import 'package:Thinkpay/core/constant/app_colors.dart';
import 'package:Thinkpay/core/constant/theme_provider.dart';
import 'package:Thinkpay/providers/user_profile_store.dart';
import 'package:Thinkpay/ui/pages/profile/Profile.dart';
import 'package:Thinkpay/ui/pages/profile/EditProfile.dart';
import 'package:Thinkpay/ui/pages/security/security.dart';
import 'package:Thinkpay/ui/pages/support/support.dart';

class ProfileDrawer extends StatelessWidget {
  const ProfileDrawer({super.key});

  // Navigate to a page and close drawer
  void _navigate(BuildContext context, Widget page) {
    Navigator.pop(context); // close drawer
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  void _showCurrencyPicker(BuildContext context, ThemeColors tc) {
    final store = UserProfileStore();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CurrencyPickerSheet(tc: tc, store: store),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([ThemeNotifier(), UserProfileStore()]),
      builder: (context, _) {
        final isDark    = ThemeNotifier().isDark;
        final tc        = ThemeColors.of(context);
        final store     = UserProfileStore();
        final currency  = store.selectedCurrency;

        return Column(
          children: [
            // ── Drawer header with user info ─────────────────────────────
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [tc.cardGradientStart, tc.cardGradientEnd],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border(bottom: BorderSide(color: tc.border)),
              ),
              padding: EdgeInsets.fromLTRB(
                  20, MediaQuery.of(context).padding.top + 20, 20, 20),
              child: Row(children: [
                Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: tc.limeDim,
                    border: Border.all(color: tc.limeBorder, width: 2),
                  ),
                  child: Icon(Icons.person_rounded, color: tc.lime, size: 30),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(store.name,
                        style: TextStyle(color: tc.text100, fontSize: 16, fontWeight: FontWeight.w700),
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text(store.email,
                        style: TextStyle(color: tc.text40, fontSize: 12),
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                          color: tc.limeDim,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: tc.limeBorder)),
                      child: Text('Premium', style: TextStyle(color: tc.lime, fontSize: 10, fontWeight: FontWeight.w600)),
                    ),
                  ]),
                ),
              ]),
            ),

            // ── Menu items ───────────────────────────────────────────────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
                    child: Text('SETTINGS',
                        style: TextStyle(color: tc.text40, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.2)),
                  ),

                  _SettingsGroup(tc: tc, items: [
                    // Dark/Light mode toggle
                    _ThemeToggleItem(isDark: isDark, tc: tc),

                    // Overview → navigates to Profile page
                    _SettingsItem(
                      icon: Icons.bar_chart_rounded,
                      label: 'Overview',
                      tc: tc,
                      onTap: () => _navigate(context, const Profile()),
                    ),

                    // Profile → navigates to Profile page (same)
                    _SettingsItem(
                      icon: Icons.person_outline_rounded,
                      label: 'Profile',
                      tc: tc,
                      onTap: () => _navigate(context, const Profile()),
                    ),

                    // Edit Profile → navigates to EditProfile
                    _SettingsItem(
                      icon: Icons.edit_outlined,
                      label: 'Edit Profile',
                      tc: tc,
                      onTap: () => _navigate(context, const EditProfilePage()),
                    ),

                    // Currency picker
                    _SettingsItem(
                      icon: Icons.currency_exchange_rounded,
                      label: 'Currency',
                      trailing: '${currency.symbol} ${currency.code}',
                      tc: tc,
                      onTap: () => _showCurrencyPicker(context, tc),
                    ),

                    // Privacy & Security
                    _SettingsItem(
                      icon: Icons.lock_outline_rounded,
                      label: 'Privacy & Security',
                      tc: tc,
                      onTap: () => _navigate(context, const SecurityPage()),
                    ),

                    // Help & Support
                    _SettingsItem(
                      icon: Icons.help_outline_rounded,
                      label: 'Help & Support',
                      tc: tc,
                      onTap: () => _navigate(context, const SupportPage()),
                    ),
                  ]),
                  const SizedBox(height: 16),
                ],
              ),
            ),

            // ── Logout ───────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              child: GestureDetector(
                onTap: () => Navigator.pushNamedAndRemoveUntil(
                    context, '/login', (_) => false),
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: tc.redDim,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: tc.red.withValues(alpha: 0.3)),
                  ),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.logout_rounded, color: tc.red, size: 18),
                    const SizedBox(width: 8),
                    Text('Log Out',
                        style: TextStyle(color: tc.red, fontSize: 14, fontWeight: FontWeight.w700)),
                  ]),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ── Currency picker sheet ─────────────────────────────────────────────────────
class _CurrencyPickerSheet extends StatefulWidget {
  const _CurrencyPickerSheet({required this.tc, required this.store});
  final ThemeColors tc;
  final UserProfileStore store;

  @override
  State<_CurrencyPickerSheet> createState() => _CurrencyPickerSheetState();
}

class _CurrencyPickerSheetState extends State<_CurrencyPickerSheet> {
  late Currency _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.store.selectedCurrency;
  }

  @override
  Widget build(BuildContext context) {
    final tc = widget.tc;
    return Container(
      decoration: BoxDecoration(
          color: tc.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28))),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const SizedBox(height: 12),
        Center(
          child: Container(width: 40, height: 4,
              decoration: BoxDecoration(color: tc.text20, borderRadius: BorderRadius.circular(4))),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text('Select Currency',
              style: TextStyle(color: tc.text100, fontSize: 18, fontWeight: FontWeight.w700)),
        ),
        const SizedBox(height: 12),
        ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.55),
          child: ListView.separated(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            itemCount: currencies.length,
            separatorBuilder: (_, __) => Divider(height: 1, color: tc.border),
            itemBuilder: (_, i) {
              final c = currencies[i];
              final isSelected = c.code == _selected.code;
              return ListTile(
                onTap: () {
                  setState(() => _selected = c);
                  widget.store.setCurrency(c);
                  Navigator.pop(context);
                },
                leading: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: isSelected ? tc.limeDim : tc.surface2,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: isSelected ? tc.limeBorder : tc.border),
                  ),
                  child: Center(
                    child: Text(c.symbol,
                        style: TextStyle(color: isSelected ? tc.lime : tc.text70, fontSize: 16, fontWeight: FontWeight.w700)),
                  ),
                ),
                title: Text(c.name, style: TextStyle(color: tc.text100, fontSize: 14)),
                subtitle: Text(c.code, style: TextStyle(color: tc.text40, fontSize: 12)),
                trailing: isSelected
                    ? Icon(Icons.check_circle_rounded, color: tc.lime, size: 20)
                    : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ]),
    );
  }
}

// ── Theme toggle ──────────────────────────────────────────────────────────────
class _ThemeToggleItem extends StatelessWidget {
  const _ThemeToggleItem({required this.isDark, required this.tc});
  final bool isDark;
  final ThemeColors tc;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(children: [
        Icon(isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
            color: tc.text70, size: 20),
        const SizedBox(width: 14),
        Expanded(
          child: Text(isDark ? 'Dark Mode' : 'Light Mode',
              style: TextStyle(color: tc.text100, fontSize: 14)),
        ),
        GestureDetector(
          onTap: () => ThemeNotifier().toggle(),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            width: 48, height: 26,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: isDark ? tc.lime.withValues(alpha: 0.85) : tc.text20,
              borderRadius: BorderRadius.circular(13),
            ),
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeInOut,
              alignment: isDark ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 20, height: 20,
                decoration: BoxDecoration(
                  color: isDark ? tc.background : Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 4)],
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

// ── Settings group ────────────────────────────────────────────────────────────
class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.items, required this.tc});
  final List<Widget> items;
  final ThemeColors tc;

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: tc.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: tc.border),
        ),
        child: Column(
          children: items.asMap().entries.map((e) {
            final isLast = e.key == items.length - 1;
            return Column(children: [
              e.value,
              if (!isLast) Divider(height: 1, color: tc.border, indent: 52),
            ]);
          }).toList(),
        ),
      );
}

// ── Settings item ─────────────────────────────────────────────────────────────
class _SettingsItem extends StatelessWidget {
  const _SettingsItem({
    required this.icon,
    required this.label,
    required this.tc,
    this.trailing,
    this.onTap,
  });
  final IconData icon;
  final String label;
  final ThemeColors tc;
  final String? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(children: [
            Icon(icon, color: tc.text70, size: 20),
            const SizedBox(width: 14),
            Expanded(child: Text(label, style: TextStyle(color: tc.text100, fontSize: 14))),
            if (trailing != null)
              Text(trailing!, style: TextStyle(color: tc.text40, fontSize: 13)),
            const SizedBox(width: 6),
            Icon(Icons.chevron_right_rounded, color: tc.text20, size: 18),
          ]),
        ),
      );
}
