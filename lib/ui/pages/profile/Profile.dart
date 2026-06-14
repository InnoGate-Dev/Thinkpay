import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:Thinkpay/constant/app_colors.dart';
import 'package:Thinkpay/constant/theme_provider.dart';
import 'package:Thinkpay/providers/finance_provider.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = FinanceProvider();

    return ListenableBuilder(
      listenable: Listenable.merge([provider, ThemeNotifier()]),
      builder: (context, _) {
        final tc       = ThemeColors.of(context);
        final txCount  = provider.transactions.length;
        final balance  = provider.balance;
        final income   = provider.totalIncome;
        final expenses = provider.totalExpenses;
        final isDark   = ThemeNotifier().isDark;

        final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];

        return Scaffold(
          backgroundColor: tc.background,
          appBar: AppBar(
            backgroundColor: tc.surface,
            elevation: 0,
            titleSpacing: 20,
            title: Text('Profile',
                style: TextStyle(
                    color: tc.text100,
                    fontSize: 18,
                    fontWeight: FontWeight.w700)),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
            children: [
              // ── Avatar + info ─────────────────────────────────────────
              Center(
                child: Column(children: [
                  Container(
                    width: 88, height: 88,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [tc.cardGradientStart, tc.cardGradientEnd],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(color: tc.limeBorder, width: 2),
                    ),
                    child: Icon(Icons.person_rounded,
                        color: tc.lime, size: 44),
                  ),
                  const SizedBox(height: 14),
                  Text('User',
                      style: TextStyle(
                          color: tc.text100,
                          fontSize: 22,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text('user@thinkpay.app',
                      style:
                          TextStyle(color: tc.text40, fontSize: 13)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: tc.limeDim,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: tc.limeBorder),
                    ),
                    child: Text('Premium Member',
                        style: TextStyle(
                            color: tc.lime,
                            fontSize: 11,
                            fontWeight: FontWeight.w600)),
                  ),
                ]),
              ),
              const SizedBox(height: 28),

              // ── Stats row ─────────────────────────────────────────────
              Row(children: [
                _StatCard(
                    label: 'Transactions',
                    value: '$txCount',
                    icon: Icons.receipt_long_rounded,
                    tc: tc),
                const SizedBox(width: 12),
                _StatCard(
                    label: 'Balance',
                    value: 'Rs. ${_fmt(balance)}',
                    icon: Icons.account_balance_wallet_rounded,
                    valueColor: balance >= 0 ? tc.lime : tc.red,
                    tc: tc),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                _StatCard(
                    label: 'Total Income',
                    value: 'Rs. ${_fmt(income)}',
                    icon: Icons.arrow_downward_rounded,
                    valueColor: tc.lime,
                    tc: tc),
                const SizedBox(width: 12),
                _StatCard(
                    label: 'Total Expenses',
                    value: 'Rs. ${_fmt(expenses)}',
                    icon: Icons.arrow_upward_rounded,
                    valueColor: tc.red,
                    tc: tc),
              ]),
              const SizedBox(height: 24),

              // ── Monthly chart ─────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: tc.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: tc.border),
                ),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Monthly Overview',
                          style: TextStyle(
                              color: tc.text100,
                              fontSize: 14,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text('Income vs Expenses (last 6 months)',
                          style: TextStyle(
                              color: tc.text40, fontSize: 11)),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 160,
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            maxY: income > 0 ? income * 1.2 : 100000,
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: false,
                              getDrawingHorizontalLine: (_) => FlLine(
                                  color: tc.border, strokeWidth: 1),
                            ),
                            borderData: FlBorderData(show: false),
                            titlesData: FlTitlesData(
                              leftTitles: const AxisTitles(
                                  sideTitles:
                                      SideTitles(showTitles: false)),
                              rightTitles: const AxisTitles(
                                  sideTitles:
                                      SideTitles(showTitles: false)),
                              topTitles: const AxisTitles(
                                  sideTitles:
                                      SideTitles(showTitles: false)),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (v, _) => Text(
                                    months[v.toInt() % months.length],
                                    style: TextStyle(
                                        color: tc.text40,
                                        fontSize: 10),
                                  ),
                                ),
                              ),
                            ),
                            barGroups: List.generate(6, (i) {
                              final frac = (i + 1) / 6;
                              return BarChartGroupData(x: i, barRods: [
                                BarChartRodData(
                                  toY: income * frac * 0.9,
                                  color: tc.lime.withValues(alpha: 0.7),
                                  width: 10,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                BarChartRodData(
                                  toY: expenses * frac * 0.85,
                                  color: tc.red.withValues(alpha: 0.7),
                                  width: 10,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ]);
                            }),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(children: [
                        _Legend(color: tc.lime, label: 'Income', tc: tc),
                        const SizedBox(width: 16),
                        _Legend(color: tc.red, label: 'Expenses', tc: tc),
                      ]),
                    ]),
              ),
              const SizedBox(height: 24),

              // ── Settings ──────────────────────────────────────────────
              Text('Settings',
                  style: TextStyle(
                      color: tc.text40,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8)),
              const SizedBox(height: 10),
              _SettingsGroup(tc: tc, items: [
                // Theme toggle row (interactive)
                _ThemeToggleItem(isDark: isDark, tc: tc),
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
              ]),
              const SizedBox(height: 16),

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
          ),
        );
      },
    );
  }
}

// ── Theme toggle settings item ────────────────────────────────────────────────
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

// ── Stat card ─────────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.tc,
    this.valueColor,
  });
  final String label, value;
  final IconData icon;
  final ThemeColors tc;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: tc.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: tc.border),
          ),
          child: Row(children: [
            Icon(icon, color: tc.text40, size: 18),
            const SizedBox(width: 10),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(label,
                      style:
                          TextStyle(color: tc.text40, fontSize: 11)),
                  const SizedBox(height: 2),
                  Text(value,
                      style: TextStyle(
                          color: valueColor ?? tc.text100,
                          fontSize: 13,
                          fontWeight: FontWeight.w700),
                      overflow: TextOverflow.ellipsis),
                ])),
          ]),
        ),
      );
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

// ── Chart legend ──────────────────────────────────────────────────────────────
class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label, required this.tc});
  final Color color;
  final String label;
  final ThemeColors tc;

  @override
  Widget build(BuildContext context) =>
      Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label,
            style: TextStyle(color: tc.text40, fontSize: 11)),
      ]);
}

String _fmt(double v) {
  if (v >= 100000) return '${(v / 100000).toStringAsFixed(1)}L';
  if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
  return v.toStringAsFixed(0);
}
