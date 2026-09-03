import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Thinkpay/core/constant/app_colors.dart';

import '../../model/loan_model.dart';
import '../../util/loan_format.dart';
import 'arc_progress_ring.dart';


/// Aggregates every loan the user has into a single portfolio snapshot:
/// active loan count, total payable, total paid, total remaining, and an
/// overall progress ring. This replaces the single-loan hero card from the
/// original screen now that a user can hold multiple loans.
class HeroOverviewCard extends StatelessWidget {
  const HeroOverviewCard({super.key, required this.loans});
  final List<LoanModel> loans;

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final activeLoans = loans.where((l) => l.status != LoanStatus.paidOff).toList();
    final totalPayable = loans.fold<double>(0, (s, l) => s + l.totalPayable);
    final totalPaid = loans.fold<double>(0, (s, l) => s + l.amountPaid);
    final totalRemaining = loans.fold<double>(0, (s, l) => s + l.remainingBalance);
    final progress = totalPayable <= 0 ? 0.0 : clampD(totalPaid / totalPayable, 0, 1);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [tc.coreAction.withValues(alpha: isDark ? 0.25 : 0.12), tc.surface],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: tc.coreAction.withValues(alpha: 0.25), width: 0.8),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${activeLoans.length} Active Loan${activeLoans.length == 1 ? '' : 's'}',
                      style: GoogleFonts.manrope(color: tc.text100, fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 3),
                    Text('${loans.length} total in portfolio', style: GoogleFonts.inter(color: tc.text40, fontSize: 12)),
                    const SizedBox(height: 12),
                    Text('Total Payable', style: GoogleFonts.inter(color: tc.text40, fontSize: 11)),
                    const SizedBox(height: 3),
                    Text(
                      fmtRs(totalPayable),
                      style: GoogleFonts.manrope(
                        color: tc.text100,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
              ArcProgressRing(pct: progress, size: 80),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutCubic,
              builder: (_, val, _) => LinearProgressIndicator(
                value: val,
                minHeight: 7,
                backgroundColor: tc.text10,
                valueColor: AlwaysStoppedAnimation(tc.coreAction),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Paid: ${fmtRs(totalPaid)}',
                style: GoogleFonts.inter(color: tc.coreAction, fontSize: 12, fontWeight: FontWeight.w600),
              ),
              Text('Remaining: ${fmtRs(totalRemaining)}', style: GoogleFonts.inter(color: tc.text40, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}
