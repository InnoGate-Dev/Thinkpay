import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Thinkpay/core/constant/app_colors.dart';

import '../../model/loan_model.dart';
import '../../util/loan_format.dart';


class BreakdownCard extends StatelessWidget {
  const BreakdownCard({super.key, required this.loan});
  final LoanModel loan;

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final total = loan.totalPayable <= 0 ? 1.0 : loan.totalPayable;
    final paidPct = clampD(loan.amountPaid / total, 0, 1);
    final interestPct = clampD(loan.totalInterest / total, 0, 1);
    final remainPct = clampD(loan.remainingBalance / total, 0, 1);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tc.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: tc.border, width: 0.8),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 12,
              child: Row(
                children: [
                  Flexible(flex: clampI((paidPct * 1000).round(), 1, 1000), child: Container(color: tc.coreAction)),
                  Flexible(
                    flex: clampI((interestPct * 1000).round(), 1, 1000),
                    child: Container(color: tc.accentExpense.withValues(alpha: 0.7)),
                  ),
                  Flexible(flex: clampI((remainPct * 1000).round(), 1, 1000), child: Container(color: tc.text10)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          _legend(tc, tc.coreAction, 'Paid', fmtRs(loan.amountPaid), paidPct),
          const SizedBox(height: 8),
          _legend(tc, tc.accentExpense.withValues(alpha: 0.7), 'Total Interest', fmtRs(loan.totalInterest), interestPct),
          const SizedBox(height: 8),
          _legend(tc, tc.text20, 'Remaining', fmtRs(loan.remainingBalance), remainPct),
        ],
      ),
    );
  }

  Widget _legend(ThemeColors tc, Color color, String label, String value, double pct) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 8),
        Expanded(child: Text(label, style: GoogleFonts.inter(color: tc.text70, fontSize: 12))),
        Text('${(pct * 100).toStringAsFixed(1)}%', style: GoogleFonts.inter(color: tc.text40, fontSize: 12)),
        const SizedBox(width: 10),
        SizedBox(
          width: 90,
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: GoogleFonts.manrope(color: tc.text100, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
