import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Thinkpay/core/constant/app_colors.dart';

import '../../model/loan_model.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status, this.dense = false});
  final LoanStatus status;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    final (color, dimColor) = switch (status) {
      LoanStatus.active => (tc.coreAction, tc.coreActionDim),
      LoanStatus.paidOff => (tc.intelligenceAccent, tc.intelligenceAccentDim),
      LoanStatus.overdue => (tc.accentExpense, tc.accentExpenseDim),
    };

    return Container(
      padding: EdgeInsets.symmetric(horizontal: dense ? 8 : 10, vertical: dense ? 4 : 5),
      decoration: BoxDecoration(
        color: dimColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 5),
          Text(
            status.label,
            style: GoogleFonts.inter(color: color, fontSize: dense ? 11 : 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
