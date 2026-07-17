import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Thinkpay/constant/app_colors.dart';
import 'package:Thinkpay/ui/pages/home/home_helpers.dart';

// ── Balance card ──────────────────────────────────────────────────────────────
class BalanceCard extends StatelessWidget {
  const BalanceCard({
    super.key,
    required this.balance,
    required this.income,
    required this.expenses,
    required this.tc,
  });
  final double balance, income, expenses;
  final ThemeColors tc;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF151922), const Color(0xFF0F1116)]
              : [Colors.white, const Color(0xFFF8FAFB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: tc.border, width: 0.8),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          Text(
            'TOTAL BALANCE',
            style: GoogleFonts.inter(
              color: tc.text40,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 10),

          // Balance amount
          Text(
            'Rs. ${formatAmount(balance)}',
            style: GoogleFonts.manrope(
              color: tc.text100,
              fontSize: 26,
              fontWeight: FontWeight.w800,
              letterSpacing: -1.0,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 6),

          // Balance change indicator
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: balance >= 0 ? tc.coreActionDim : tc.accentExpenseDim,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Icon(
                      balance >= 0
                          ? Icons.trending_up_rounded
                          : Icons.trending_down_rounded,
                      size: 12,
                      color: balance >= 0 ? tc.coreAction : tc.accentExpense,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      balance >= 0 ? 'Positive balance' : 'Negative balance',
                      style: GoogleFonts.inter(
                        color: balance >= 0 ? tc.coreAction : tc.accentExpense,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
          Divider(color: tc.border, height: 1, thickness: 0.5),
          const SizedBox(height: 16),

          // Income & Expenses row
          Row(
            children: [
              Expanded(
                child: _BalanceStat(
                  label: 'Income',
                  amount: income,
                  color: tc.coreAction,
                  icon: Icons.arrow_downward_rounded,
                  tc: tc,
                ),
              ),
              Container(width: 0.5, height: 36, color: tc.border),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: _BalanceStat(
                    label: 'Expenses',
                    amount: expenses,
                    color: tc.accentExpense,
                    icon: Icons.arrow_upward_rounded,
                    tc: tc,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BalanceStat extends StatelessWidget {
  const _BalanceStat({
    required this.label,
    required this.amount,
    required this.color,
    required this.icon,
    required this.tc,
  });
  final String label;
  final double amount;
  final Color color;
  final IconData icon;
  final ThemeColors tc;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 14),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                color: tc.text40,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Rs. ${formatAmount(amount)}',
              style: GoogleFonts.manrope(
                color: tc.text100,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
