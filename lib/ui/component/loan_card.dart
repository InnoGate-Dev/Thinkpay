import 'package:Thinkpay/ui/component/status_badge.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Thinkpay/core/constant/app_colors.dart';

import '../../model/loan_model.dart';
import '../../util/loan_format.dart';

class LoanCard extends StatelessWidget {
  const LoanCard({super.key, required this.loan, required this.onTap});
  final LoanModel loan;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = loan.progress;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
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
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loan.purpose,
                        style: GoogleFonts.manrope(color: tc.text100, fontSize: 14, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${fmtRs(loan.amount)} • ${loan.interestRate.toStringAsFixed(1)}% p.a.',
                        style: GoogleFonts.inter(color: tc.text40, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                StatusBadge(status: loan.status, dense: true),
              ],
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: tc.text10,
                valueColor: AlwaysStoppedAnimation(tc.coreAction),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Remaining: ${fmtRs(loan.remainingBalance)}',
                  style: GoogleFonts.inter(color: tc.text70, fontSize: 12, fontWeight: FontWeight.w600),
                ),
                Text('${loan.remainingMonths} mo left', style: GoogleFonts.inter(color: tc.text40, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
