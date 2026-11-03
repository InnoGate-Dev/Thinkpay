import 'package:flutter/material.dart';

import 'package:Thinkpay/core/constant/app_colors.dart';
import 'package:Thinkpay/core/utils/number_format.dart';
import 'package:Thinkpay/providers/user_profile_store.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Profile building blocks
// ─────────────────────────────────────────────────────────────────────────────
//
// Scaffold-less pieces shared by the profile screen. Keeping them here leaves
// [Profile] as pure composition and lets the drawer reuse the same visual
// language for its header.

/// Gradient header card: avatar, identity and the country/currency the user
/// picked. Shows a skeleton line while the profile is still loading.
class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key, required this.store, required this.tc});

  final UserProfileStore store;
  final ThemeColors tc;

  @override
  Widget build(BuildContext context) {
    final loaded = store.isLoaded;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.marginMobile),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [tc.cardGradientStart, tc.cardGradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: tc.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ProfileAvatar(name: store.name, tc: tc, size: 64),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loaded ? store.name : 'Loading your profile…',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.headlineMd.copyWith(
                        color: tc.text100,
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      loaded ? store.email : 'Fetching account details',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodySm.copyWith(
                        color: tc.text40,
                        fontSize: 12,
                      ),
                    ),
                    if (loaded && store.createdAt != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        _memberSince(store.createdAt!),
                        style: AppTypography.bodySm.copyWith(
                          color: tc.text40,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.base,
            runSpacing: AppSpacing.base,
            children: [
              if (loaded && store.isLeader)
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
                muted: false,
              ),
            ],
          ),
        ],
      ),
    );
  }

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  String _memberSince(DateTime date) =>
      'Member since ${_months[date.month - 1]} ${date.year}';
}

/// Circle with the user's initials (falls back to a person icon).
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    required this.name,
    required this.tc,
    this.size = 56,
  });

  final String name;
  final ThemeColors tc;
  final double size;

  String get _initials {
    final parts =
        name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '';
    if (parts.length == 1) {
      final only = parts.first;
      return (only.length >= 2 ? only.substring(0, 2) : only).toUpperCase();
    }
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final initials = _initials;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: tc.limeDim,
        border: Border.all(color: tc.limeBorder, width: 1.5),
      ),
      child: initials.isEmpty
          ? Icon(Icons.person_rounded, color: tc.lime, size: size * 0.5)
          : Text(
              initials,
              style: AppTypography.headlineMd.copyWith(
                color: tc.lime,
                fontSize: size * 0.34,
                fontWeight: FontWeight.w700,
              ),
            ),
    );
  }
}

/// Small rounded status chip (Leader, country, currency).
class ProfilePill extends StatelessWidget {
  const ProfilePill({
    super.key,
    required this.tc,
    required this.label,
    this.icon,
    this.emoji,
    this.muted = false,
  });

  final ThemeColors tc;
  final String label;
  final IconData? icon;
  final String? emoji;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: muted ? tc.surface2 : tc.limeDim,
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: muted ? tc.border : tc.limeBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (emoji != null)
            Text(emoji!, style: const TextStyle(fontSize: 12))
          else if (icon != null)
            Icon(icon, color: tc.lime, size: 13),
          const SizedBox(width: 5),
          Text(
            label,
            style: AppTypography.bodySm.copyWith(
              color: muted ? tc.text40 : tc.text100,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Small uppercase label that opens a group of rows.
class ProfileSectionLabel extends StatelessWidget {
  const ProfileSectionLabel({
    super.key,
    required this.label,
    required this.tc,
    this.trailing,
  });

  final String label;
  final ThemeColors tc;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, AppSpacing.base),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label.toUpperCase(),
              style: AppTypography.labelCaps.copyWith(
                color: tc.text40,
                fontSize: 11,
                letterSpacing: 1.2,
              ),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// Rounded container that groups [ProfileSettingsRow]s with hairline dividers.
class ProfileSettingsCard extends StatelessWidget {
  const ProfileSettingsCard({super.key, required this.tc, required this.children});

  final ThemeColors tc;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: tc.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: tc.border),
      ),
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            children[i],
            if (i != children.length - 1)
              Divider(height: 1, color: tc.divider, indent: 60),
          ],
        ],
      ),
    );
  }
}

/// One tappable line inside a [ProfileSettingsCard].
class ProfileSettingsRow extends StatelessWidget {
  const ProfileSettingsRow({
    super.key,
    required this.tc,
    required this.leading,
    required this.title,
    this.subtitle,
    this.value,
    this.trailing,
    this.onTap,
    this.danger = false,
    this.busy = false,
  });

  final ThemeColors tc;
  final Widget leading;
  final String title;
  final String? subtitle;

  /// Short right-aligned text (country name, currency code, …).
  final String? value;

  /// Replaces [value] and the chevron (e.g. the appearance switch).
  final Widget? trailing;

  final VoidCallback? onTap;
  final bool danger;

  /// Shows a spinner in place of the trailing value.
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final titleColor = danger ? tc.red : tc.text100;
    final canTap = onTap != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: busy ? null : onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.marginMobile,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              leading,
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.bodyMd.copyWith(
                        color: titleColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 1),
                      Text(
                        subtitle!,
                        maxLines: 2,
                        style: AppTypography.bodySm.copyWith(
                          color: danger ? tc.red.withValues(alpha: 0.75) : tc.text40,
                          fontSize: 11,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (busy)
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: tc.lime),
                )
              else ...[
                if (value != null)
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 130),
                    child: Text(
                      value!,
                      textAlign: TextAlign.right,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodySm.copyWith(
                        color: tc.text40,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ?trailing,
                if (trailing == null && canTap) ...[
                  const SizedBox(width: 4),
                  Icon(Icons.chevron_right_rounded, color: tc.text20, size: 18),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Square icon badge used as the leading widget of a settings row.
class ProfileIconBadge extends StatelessWidget {
  const ProfileIconBadge({
    super.key,
    required this.tc,
    this.icon,
    this.text,
    this.danger = false,
  });

  final ThemeColors tc;
  final IconData? icon;
  final String? text;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final accent = danger ? tc.red : tc.text70;
    return Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: danger ? tc.redDim : tc.surface2,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: danger ? tc.red.withValues(alpha: 0.35) : tc.border),
      ),
      child: text != null
          ? Text(text!, style: const TextStyle(fontSize: 17))
          : Icon(icon, color: accent, size: 17),
    );
  }
}

/// Compact metric tile used by the profile summary grid.
class ProfileStatTile extends StatelessWidget {
  const ProfileStatTile({
    super.key,
    required this.tc,
    required this.label,
    required this.value,
    required this.icon,
    this.valueColor,
  });

  final ThemeColors tc;
  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: tc.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: tc.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: tc.text40, size: 14),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodySm.copyWith(
                    color: tc.text40,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: AppTypography.headlineMd.copyWith(
                color: valueColor ?? tc.text100,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Money tile helper so every amount on this screen uses the profile currency.
String profileMoney(num value, UserProfileStore store) =>
    compactMoney(value, symbol: store.currencySymbol);

/// Inline banner for a failed profile refresh.
class ProfileErrorBanner extends StatelessWidget {
  const ProfileErrorBanner({
    super.key,
    required this.tc,
    required this.message,
    required this.onRetry,
  });

  final ThemeColors tc;
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.marginMobile),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.base,
      ),
      decoration: BoxDecoration(
        color: tc.redDim,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: tc.red.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.cloud_off_rounded, color: tc.red, size: 18),
          const SizedBox(width: AppSpacing.base),
          Expanded(
            child: Text(
              message,
              style: AppTypography.bodySm.copyWith(color: tc.text100, fontSize: 12),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            child: Text(
              'Retry',
              style: TextStyle(color: tc.red, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
