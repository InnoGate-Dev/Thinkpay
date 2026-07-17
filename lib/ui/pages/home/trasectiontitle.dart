import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Thinkpay/constant/app_colors.dart';
import 'package:Thinkpay/model/transaction_model.dart';
import 'package:Thinkpay/ui/pages/home/home_helpers.dart';

// ── Transaction tile ──────────────────────────────────────────────────────────
class TransactionTile extends StatelessWidget {
  const TransactionTile({super.key, required this.transaction, required this.tc});
  final TransactionModel transaction;
  final ThemeColors tc;

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    final accentColor = isIncome ? tc.coreAction : tc.accentExpense;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        children: [
          // Category icon
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              getCategoryIcon(transaction.category),
              color: accentColor,
              size: 18,
            ),
          ),
          const SizedBox(width: 14),

          // Title & category
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  style: GoogleFonts.inter(
                    color: tc.text100,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  transaction.category,
                  style: GoogleFonts.inter(
                    color: tc.text40,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),

          // Amount & date
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isIncome ? '+' : '−'} Rs. ${formatAmount(transaction.amount)}',
                style: GoogleFonts.manrope(
                  color: isIncome ? tc.coreAction : tc.text100,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                formatDate(transaction.date),
                style: GoogleFonts.inter(color: tc.text40, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
