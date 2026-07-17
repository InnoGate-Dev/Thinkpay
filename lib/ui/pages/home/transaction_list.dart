import 'package:flutter/material.dart';
import 'package:Thinkpay/constant/app_colors.dart';
import 'package:Thinkpay/model/transaction_model.dart';
import 'package:Thinkpay/ui/pages/home/trasectiontitle.dart';

// ── Transaction list (flush grouped style) ────────────────────────────────────
class TransactionList extends StatelessWidget {
  const TransactionList({super.key, required this.transactions, required this.tc});
  final List<TransactionModel> transactions;
  final ThemeColors tc;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: tc.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: tc.border, width: 0.8),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        children: [
          for (int i = 0; i < transactions.length; i++) ...[
            TransactionTile(transaction: transactions[i], tc: tc),
            if (i < transactions.length - 1)
              Divider(color: tc.divider, height: 1, thickness: 0.5, indent: 68),
          ],
        ],
      ),
    );
  }
}
