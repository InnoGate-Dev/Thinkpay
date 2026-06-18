import 'package:flutter/material.dart';

import '../../../constant/app_colors.dart';
import '../../../constant/theme_provider.dart';

class ProfileDrawer extends StatelessWidget {
  const ProfileDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeNotifier(),
      builder: (context, _) {
        final isDark = ThemeNotifier().isDark;
        final tc     = ThemeColors.of(context);
        return Column(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.lightGreenAccent,
              ),
              child: Center(child: Text('Drawer Header')),
            ),
            Expanded(
              child: ListView(
                // Important: Remove any padding from the ListView.
                padding: EdgeInsets.zero,
                children: [
                  // ── Settings ──────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    child: Text('Settings',
                        style: TextStyle(
                            color: tc.text40,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.8)),
                  ),
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _SettingsGroup(tc: tc, items: [
                      // Theme toggle row (interactive)
                      _ThemeToggleItem(isDark: isDark, tc: tc),
                      _SettingsItem(
                          icon: Icons.person_outline_rounded,
                          label: 'Overview',
                          trailing: 'INR (Rs.)',
                          tc: tc),
                      _SettingsItem(
                          icon: Icons.currency_rupee_rounded,
                          label: 'Currency',
                          trailing: 'INR (Rs.)',
                          tc: tc),
                      _SettingsItem(
                          icon: Icons.notifications_none_rounded,
                          label: 'Notifications',
                          trailing: 'On',
                          tc: tc),
                      _SettingsItem(
                          icon: Icons.lock_outline_rounded,
                          label: 'Privacy & Security',
                          tc: tc),
                      _SettingsItem(
                          icon: Icons.help_outline_rounded,
                          label: 'Help & Support',
                          tc: tc),
                      _SettingsItem(
                          icon: Icons.person_outline_rounded,
                          label: 'Profile',
                          trailing: 'INR (Rs.)',
                          tc: tc),
                    ]),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            // ── Logout ────────────────────────────────────────────────
            GestureDetector(
              onTap: () => Navigator.pushNamedAndRemoveUntil(
                  context, '/login', (_) => false),
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: tc.redDim,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: tc.red.withValues(alpha: 0.3)),
                ),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout_rounded,
                          color: tc.red, size: 18),
                      const SizedBox(width: 8),
                      Text('Log Out',
                          style: TextStyle(
                              color: tc.red,
                              fontSize: 14,
                              fontWeight: FontWeight.w700)),
                    ]),
              ),
            ),
          ],
        );
      },
    );
  }
}


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
            width: 48,
            height: 26,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: isDark
                  ? tc.lime.withValues(alpha: 0.85)
                  : tc.text20,
              borderRadius: BorderRadius.circular(13),
            ),
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeInOut,
              alignment:
              isDark ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: isDark ? tc.background : Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 4)
                  ],
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
          if (!isLast)
            Divider(height: 1, color: tc.border, indent: 52),
        ]);
      }).toList(),
    ),
  );
}

class _SettingsItem extends StatelessWidget {
  const _SettingsItem(
      {required this.icon,
        required this.label,
        required this.tc,
        this.trailing});
  final IconData icon;
  final String label;
  final ThemeColors tc;
  final String? trailing;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    child: Row(children: [
      Icon(icon, color: tc.text70, size: 20),
      const SizedBox(width: 14),
      Expanded(
          child: Text(label,
              style: TextStyle(color: tc.text100, fontSize: 14))),
      if (trailing != null)
        Text(trailing!,
            style: TextStyle(color: tc.text40, fontSize: 13)),
      const SizedBox(width: 6),
      Icon(Icons.chevron_right_rounded, color: tc.text20, size: 18),
    ]),
  );
}
