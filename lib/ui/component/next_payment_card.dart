import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Thinkpay/core/constant/app_colors.dart';

import '../../model/loan_model.dart';
import '../../util/loan_format.dart';


class NextPaymentCard extends StatelessWidget {
  const NextPaymentCard({super.key, required this.loan, this.onAddPayment});
  final LoanModel loan;
  final VoidCallback? onAddPayment;

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isPaidOff = loan.status == LoanStatus.paidOff || loan.remainingMonths == 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tc.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: tc.coreAction.withValues(alpha: 0.3), width: 0.8),
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
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: tc.coreAction.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.calendar_month_rounded, color: tc.coreAction, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isPaidOff ? 'Loan Complete' : 'Next Payment Due',
                      style: GoogleFonts.inter(color: tc.text40, fontSize: 11),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      isPaidOff ? 'All payments made' : fmtDate(loan.nextPaymentDate),
                      style: GoogleFonts.manrope(color: tc.text100, fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              if (!isPaidOff)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Amount', style: GoogleFonts.inter(color: tc.text40, fontSize: 11)),
                    const SizedBox(height: 3),
                    Text(
                      fmtRs(loan.monthlyPayment),
                      style: GoogleFonts.manrope(
                        color: tc.coreAction,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          if (!isPaidOff && onAddPayment != null) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onAddPayment,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Record Payment'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: tc.coreAction,
                  side: BorderSide(color: tc.coreAction.withValues(alpha: 0.4)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
