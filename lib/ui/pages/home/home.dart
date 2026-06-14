import 'package:flutter/material.dart';
import 'package:Thinkpay/constant/app_colors.dart';
import 'package:Thinkpay/model/transaction_model.dart';
import 'package:Thinkpay/providers/finance_provider.dart';
import 'package:Thinkpay/ui/component/add_transaction_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _provider = FinanceProvider();

  void _openAdd() => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => const AddTransactionSheet(),
      );

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);

    return ListenableBuilder(
      listenable: _provider,
      builder: (context, _) {
        final balance  = _provider.balance;
        final income   = _provider.totalIncome;
        final expenses = _provider.totalExpenses;
        final recent   = _provider.recentTransactions;

        return Scaffold(
          backgroundColor: tc.background,
          appBar: AppBar(
            backgroundColor: tc.surface,
            elevation: 0,
            titleSpacing: 20,
            title: RichText(
              text: TextSpan(
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600),
                children: [
                  TextSpan(
                      text: 'Hello, ',
                      style: TextStyle(color: tc.text40)),
                  TextSpan(
                      text: 'User 👋',
                      style: TextStyle(color: tc.text100)),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.notifications_none_rounded,
                    color: tc.text70),
                onPressed: () =>
                    Navigator.pushNamed(context, '/notification'),
              ),
              const SizedBox(width: 8),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _openAdd,
            backgroundColor: tc.lime,
            foregroundColor: tc.background,
            child: const Icon(Icons.add_rounded, size: 28),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
            children: [
              // ── Balance card ───────────────────────────────────────────
              _BalanceCard(
                  balance: balance,
                  income: income,
                  expenses: expenses,
                  tc: tc),
              const SizedBox(height: 24),

              // ── Savings progress ───────────────────────────────────────
              _SavingsProgress(income: income, expenses: expenses, tc: tc),
              const SizedBox(height: 24),

              // ── Recent transactions ────────────────────────────────────
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Recent Transactions',
                        style: TextStyle(
                            color: tc.text100,
                            fontSize: 16,
                            fontWeight: FontWeight.w700)),
                    GestureDetector(
                      onTap: () {},
                      child: Text('See all',
                          style: TextStyle(
                              color: tc.lime,
                              fontSize: 13,
                              fontWeight: FontWeight.w600)),
                    ),
                  ]),
              const SizedBox(height: 12),

              if (recent.isEmpty)
                _EmptyState(
                    message:
                        'No transactions yet.\nTap + to add one.',
                    tc: tc),
              ...recent.map((t) =>
                  _TransactionTile(transaction: t, tc: tc)),
            ],
          ),
        );
      },
    );
  }
}

// ── Balance card ──────────────────────────────────────────────────────────────
class _BalanceCard extends StatelessWidget {
  const _BalanceCard({
    required this.balance,
    required this.income,
    required this.expenses,
    required this.tc,
  });
  final double balance, income, expenses;
  final ThemeColors tc;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [tc.cardGradientStart, tc.cardGradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: tc.limeBorder),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Total Balance',
            style: TextStyle(
                color: tc.text40, fontSize: 13, letterSpacing: 0.5)),
        const SizedBox(height: 8),
        Text(
          'Rs. ${_fmt(balance)}',
          style: TextStyle(
            color: balance >= 0 ? tc.lime : tc.red,
            fontSize: 36,
            fontWeight: FontWeight.w800,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 20),
        Divider(color: tc.text10, thickness: 1),
        const SizedBox(height: 16),
        Row(children: [
          _StatPill(
              label: 'Income',
              value: income,
              color: tc.lime,
              icon: Icons.arrow_downward_rounded),
          const SizedBox(width: 12),
          _StatPill(
              label: 'Expenses',
              value: expenses,
              color: tc.red,
              icon: Icons.arrow_upward_rounded),
        ]),
      ]),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });
  final String label;
  final double value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    return Expanded(
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 15),
          ),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label,
                style:
                    TextStyle(color: tc.text40, fontSize: 11)),
            Text('Rs. ${_fmt(value)}',
                style: TextStyle(
                    color: color,
                    fontSize: 13,
                    fontWeight: FontWeight.w700)),
          ]),
        ]),
      ),
    );
  }
}

// ── Savings progress ──────────────────────────────────────────────────────────
class _SavingsProgress extends StatelessWidget {
  const _SavingsProgress({
    required this.income,
    required this.expenses,
    required this.tc,
  });
  final double income, expenses;
  final ThemeColors tc;

  @override
  Widget build(BuildContext context) {
    final pct =
        income > 0 ? ((income - expenses) / income).clamp(0.0, 1.0) : 0.0;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: tc.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: tc.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text('Savings Rate',
              style: TextStyle(
                  color: tc.text100,
                  fontSize: 14,
                  fontWeight: FontWeight.w600)),
          const Spacer(),
          Text(
            '${(pct * 100).toStringAsFixed(1)}%',
            style: TextStyle(
                color: tc.lime,
                fontSize: 14,
                fontWeight: FontWeight.w700),
          ),
        ]),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: pct,
            minHeight: 8,
            backgroundColor: tc.text10,
            valueColor: AlwaysStoppedAnimation(tc.lime),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          pct >= 0.2
              ? '🎉 Great job! You\'re saving more than 20% of your income.'
              : '💡 Aim to save at least 20% of your income each month.',
          style:
              TextStyle(color: tc.text40, fontSize: 12, height: 1.4),
        ),
      ]),
    );
  }
}

// ── Transaction tile ──────────────────────────────────────────────────────────
class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.transaction, required this.tc});
  final TransactionModel transaction;
  final ThemeColors tc;

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    final color    = isIncome ? tc.lime : tc.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: tc.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: tc.border),
      ),
      child: Row(children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12)),
          child:
              Icon(_categoryIcon(transaction.category), color: color, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(transaction.title,
                    style: TextStyle(
                        color: tc.text100,
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(transaction.category,
                    style: TextStyle(color: tc.text40, fontSize: 12)),
              ]),
        ),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(
            '${isIncome ? '+' : '-'} Rs. ${_fmt(transaction.amount)}',
            style: TextStyle(
                color: color, fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 2),
          Text(_dateStr(transaction.date),
              style: TextStyle(color: tc.text40, fontSize: 11)),
        ]),
      ]),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message, required this.tc});
  final String message;
  final ThemeColors tc;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
            color: tc.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: tc.border)),
        child: Center(
          child: Text(message,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: tc.text40, fontSize: 14, height: 1.6)),
        ),
      );
}

// ── Helpers ───────────────────────────────────────────────────────────────────
String _fmt(double v) {
  if (v >= 100000) return '${(v / 100000).toStringAsFixed(1)}L';
  if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
  return v.toStringAsFixed(0);
}

String _dateStr(DateTime d) {
  final now = DateTime.now();
  if (d.year == now.year && d.month == now.month && d.day == now.day) {
    return 'Today';
  }
  if (d.year == now.year && d.month == now.month && d.day == now.day - 1) {
    return 'Yesterday';
  }
  return '${d.day}/${d.month}/${d.year}';
}

IconData _categoryIcon(String cat) {
  switch (cat.toLowerCase()) {
    case 'food':          return Icons.restaurant_rounded;
    case 'transport':     return Icons.directions_car_rounded;
    case 'shopping':      return Icons.shopping_bag_rounded;
    case 'entertainment': return Icons.movie_rounded;
    case 'utilities':     return Icons.bolt_rounded;
    case 'health':        return Icons.favorite_rounded;
    case 'education':     return Icons.school_rounded;
    case 'rent':          return Icons.home_rounded;
    case 'salary':        return Icons.account_balance_wallet_rounded;
    case 'freelance':     return Icons.work_rounded;
    case 'business':      return Icons.business_center_rounded;
    case 'investment':    return Icons.trending_up_rounded;
    case 'gift':          return Icons.card_giftcard_rounded;
    default:              return Icons.receipt_rounded;
  }
}
