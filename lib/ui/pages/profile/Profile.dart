import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:Thinkpay/constant/app_colors.dart';
import 'package:Thinkpay/constant/theme_provider.dart';
import 'package:Thinkpay/providers/finance_provider.dart';
import 'package:Thinkpay/providers/user_profile_store.dart';
import 'package:Thinkpay/ui/pages/profile/EditProfile.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = FinanceProvider();
    final profileStore = UserProfileStore();

    return ListenableBuilder(
      listenable: Listenable.merge([provider, ThemeNotifier(), profileStore]),
      builder: (context, _) {
        final tc       = ThemeColors.of(context);
        final txCount  = provider.transactions.length;
        final balance  = provider.balance;
        final income   = provider.totalIncome;
        final expenses = provider.totalExpenses;
        final months   = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];

        return Scaffold(
          backgroundColor: tc.background,
          appBar: AppBar(
            backgroundColor: tc.surface,
            elevation: 0,
            titleSpacing: 20,
            title: Text('Profile',
                style: TextStyle(color: tc.text100, fontSize: 18, fontWeight: FontWeight.w700)),
            actions: [
              IconButton(
                icon: Icon(Icons.edit_outlined, color: tc.lime, size: 22),
                tooltip: 'Edit Profile',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EditProfilePage()),
                ),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
            children: [
              // ── Avatar + info ───────────────────────────────────────────
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
                    child: Icon(Icons.person_rounded, color: tc.lime, size: 44),
                  ),
                  const SizedBox(height: 14),
                  Text(profileStore.name,
                      style: TextStyle(color: tc.text100, fontSize: 22, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(profileStore.email,
                      style: TextStyle(color: tc.text40, fontSize: 13)),
                  if (profileStore.phone.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(profileStore.phone,
                        style: TextStyle(color: tc.text40, fontSize: 12)),
                  ],
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: tc.limeDim,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: tc.limeBorder),
                    ),
                    child: Text('Premium Member',
                        style: TextStyle(color: tc.lime, fontSize: 11, fontWeight: FontWeight.w600)),
                  ),
                  if (profileStore.bio.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(profileStore.bio,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: tc.text40, fontSize: 13)),
                    ),
                  ],
                  const SizedBox(height: 14),
                  OutlinedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const EditProfilePage()),
                    ),
                    icon: Icon(Icons.edit_outlined, size: 16, color: tc.lime),
                    label: Text('Edit Profile',
                        style: TextStyle(color: tc.lime, fontSize: 13, fontWeight: FontWeight.w600)),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: tc.limeBorder),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    ),
                  ),
                ]),
              ),
              const SizedBox(height: 28),

              // ── Stats row ──────────────────────────────────────────────
              Row(children: [
                _StatCard(label: 'Transactions', value: '$txCount', icon: Icons.receipt_long_rounded, tc: tc),
                const SizedBox(width: 12),
                _StatCard(label: 'Balance', value: 'Rs. ${_fmt(balance)}', icon: Icons.account_balance_wallet_rounded, valueColor: balance >= 0 ? tc.lime : tc.red, tc: tc),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                _StatCard(label: 'Total Income', value: 'Rs. ${_fmt(income)}', icon: Icons.arrow_downward_rounded, valueColor: tc.lime, tc: tc),
                const SizedBox(width: 12),
                _StatCard(label: 'Total Expenses', value: 'Rs. ${_fmt(expenses)}', icon: Icons.arrow_upward_rounded, valueColor: tc.red, tc: tc),
              ]),
              const SizedBox(height: 24),

              // ── Monthly chart ──────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: tc.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: tc.border),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Monthly Overview',
                      style: TextStyle(color: tc.text100, fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text('Income vs Expenses (last 6 months)',
                      style: TextStyle(color: tc.text40, fontSize: 11)),
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
                          getDrawingHorizontalLine: (_) =>
                              FlLine(color: tc.border, strokeWidth: 1),
                        ),
                        borderData: FlBorderData(show: false),
                        titlesData: FlTitlesData(
                          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (v, _) => Text(months[v.toInt() % months.length],
                                  style: TextStyle(color: tc.text40, fontSize: 10)),
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
            ],
          ),
        );
      },
    );
  }
}

// ── Stat card ──────────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value, required this.icon, required this.tc, this.valueColor});
  final String label, value; final IconData icon; final ThemeColors tc; final Color? valueColor;
  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: tc.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: tc.border)),
          child: Row(children: [
            Icon(icon, color: tc.text40, size: 18),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label, style: TextStyle(color: tc.text40, fontSize: 11)),
              const SizedBox(height: 2),
              Text(value, style: TextStyle(color: valueColor ?? tc.text100, fontSize: 13, fontWeight: FontWeight.w700), overflow: TextOverflow.ellipsis),
            ])),
          ]),
        ));
}

// ── Chart legend ───────────────────────────────────────────────────────────────
class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label, required this.tc});
  final Color color; final String label; final ThemeColors tc;
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(color: tc.text40, fontSize: 11)),
      ]);
}

String _fmt(double v) {
  if (v >= 100000) return '${(v / 100000).toStringAsFixed(1)}L';
  if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
  return v.toStringAsFixed(0);
}
