import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:Thinkpay/core/constant/app_colors.dart';
import 'package:Thinkpay/core/repository/categoryRepo.dart';
import 'package:Thinkpay/core/repository/trasectionRepo.dart';
import 'package:Thinkpay/model/categoryModel.dart';
import 'package:Thinkpay/model/transaction_model.dart';
import 'package:Thinkpay/providers/finance_provider.dart';

import '../../component/add_transaction_sheet.dart';
import 'finance_cate.dart';

// TODO: point this at wherever your FinancePage widget actually lives.
// It's the file you pasted above (the one with _FinanceTab / _FinanceCard)
/// ============================================================================
/// FinanceDashboardPage
/// ----------------------------------------------------------------------------
/// Landing screen for the Finance section. Gives a fast read on where the user
/// stands — net balance, income vs expense vs transfers, a trend view, top
/// spend categories, and recent activity — then lets them drill into:
///
///   • "Manage Budgets"   → FinancePage   (add/edit/delete budget categories)
///   • "See all" / stat tap → Transection page (full transaction history)
///
/// DESIGN ASSUMPTIONS — please check these against your real models:
///   1. `TransactionType` has three values: income, expense, transfer
///      (your Finance page already excludes transfer from the budget tabs,
///      which matches "transfers = loans / other payments, not budgeted")
///   2. `TransactionModel` exposes: amount (double), type (TransactionType),
///      category (String), title (String), date (DateTime)
///      → rename fields in the `t.xxx` calls below if yours differ.
///   3. `FinanceProvider` exposes: transactions (List<TransactionModel>),
///      expenseByCategory (Map<String, double>) — already used by FinancePage.
///
/// If any of these don't line up 1:1, the fix is almost always a rename, not
/// a restructure — the layout/logic below doesn't depend on exact names.
/// ============================================================================
class FinanceDashboardPage extends StatefulWidget {
  const FinanceDashboardPage({super.key});

  @override
  State<FinanceDashboardPage> createState() => _FinanceDashboardPageState();
}

class _FinanceDashboardPageState extends State<FinanceDashboardPage> {
  final _provider = FinanceProvider();
  final _categoryRepo = CategoryRepository();
  final _transactionRepo = TransactionRepository();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        _categoryRepo.getCategories(),
        _transactionRepo.getTransactionsAsLocalModels(),
      ]);
      final categories = results[0] as List<Category>;
      final transactions = results[1] as List<TransactionModel>;
      _provider.setBudgetCategories(
        categories.map((c) => c.toBudgetCategory()).toList(),
      );
      _provider.setTransactions(transactions);
    } catch (e) {
      debugPrint('Failed to load finance dashboard: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _goToFinancePage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const FinancePage()),
    );
  }

  void _goToTransactions() {
    Navigator.pushNamed(context, '/transaction');
  }

  void _openAddTransaction() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddTransactionSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);

    return ListenableBuilder(
      listenable: _provider,
      builder: (context, _) {
        final txns = _provider.transactions;

        final incomeTxns = txns.where((t) => t.type == TransactionType.income);
        final expenseTxns = txns.where(
              (t) => t.type == TransactionType.expense,
        );
        final transferTxns = txns.where(
              (t) => t.type == TransactionType.income || t.type == TransactionType.expense,
        );

        final totalIncome = incomeTxns.fold<double>(0, (s, t) => s + t.amount);
        final totalExpense = expenseTxns.fold<double>(
          0,
              (s, t) => s + t.amount,
        );
        final totalTransfer = transferTxns.fold<double>(
          0,
              (s, t) => s + t.amount,
        );
        final netBalance = totalIncome - totalExpense - totalTransfer;

        final recent = [...txns]..sort((a, b) => b.date.compareTo(a.date));
        final recentFive = recent.take(5).toList();

        return Scaffold(
          floatingActionButton: FloatingActionButton.extended(
            heroTag: 'fab_transaction',
            onPressed: _openAddTransaction,
            backgroundColor: tc.coreAction,
            foregroundColor: tc.background,
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            icon: const Icon(Icons.add_rounded, size: 20),
            label: Text(
              "",
              style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ),
          backgroundColor: tc.background,
          body: SafeArea(
            bottom: false,
            child: RefreshIndicator(
              onRefresh: _load,
              color: tc.coreAction,
              backgroundColor: tc.surface,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
                children: [
                  _Header(tc: tc),
                  const SizedBox(height: 18),
                  if (_isLoading)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: LinearProgressIndicator(
                        minHeight: 2,
                        backgroundColor: Colors.transparent,
                        valueColor: AlwaysStoppedAnimation(tc.coreAction),
                      ),
                    ),
                  _NetBalanceCard(netBalance: netBalance, tc: tc),
                  const SizedBox(height: 16),
                  _StatRow(
                    income: totalIncome,
                    expense: totalExpense,
                    transfer: totalTransfer,
                    tc: tc,
                    onTap: _goToTransactions,
                  ),
                  const SizedBox(height: 20),
                  _QuickActionsRow(
                    tc: tc,
                    onManageBudget: _goToFinancePage,
                    onViewAll: _goToTransactions,
                  ),
                  const SizedBox(height: 20),
                  _CashFlowCard(
                    income: totalIncome,
                    expense: totalExpense,
                    transfer: totalTransfer,
                    tc: tc,
                  ),
                  const SizedBox(height: 20),
                  _TopCategoriesCard(
                    expenseByCategory: _provider.expenseByCategory,
                    tc: tc,
                    onSeeAll: _goToFinancePage,
                  ),
                  const SizedBox(height: 20),
                  _RecentActivityCard(
                    transactions: recentFive,
                    tc: tc,
                    onSeeAll: _goToTransactions,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Header ───────────────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  const _Header({required this.tc});
  final ThemeColors tc;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Finance',
              style: GoogleFonts.manrope(
                color: tc.text100,
                fontSize: 24,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${months[now.month - 1]} overview',
              style: GoogleFonts.inter(color: tc.text40, fontSize: 13),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Net balance hero card ───────────────────────────────────────────────────
class _NetBalanceCard extends StatelessWidget {
  const _NetBalanceCard({required this.netBalance, required this.tc});
  final double netBalance;
  final ThemeColors tc;

  @override
  Widget build(BuildContext context) {
    final positive = netBalance >= 0;
    final base = tc.coreAction;
    final darker = Color.lerp(base, Colors.black, 0.35)!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [base, darker],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: base.withValues(alpha: 0.28),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Net Balance',
                style: GoogleFonts.inter(
                  color: Colors.white.withValues(alpha: 0.75),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                positive
                    ? Icons.trending_up_rounded
                    : Icons.trending_down_rounded,
                color: Colors.white.withValues(alpha: 0.75),
                size: 14,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${positive ? '' : '-'}Rs. ${_fmt(netBalance.abs())}',
            style: GoogleFonts.manrope(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            positive
                ? 'You\'re in good shape this month'
                : 'Spending is outpacing income',
            style: GoogleFonts.inter(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Income / Expense / Transfer stat row ────────────────────────────────────
class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.income,
    required this.expense,
    required this.transfer,
    required this.tc,
    required this.onTap,
  });
  final double income;
  final double expense;
  final double transfer;
  final ThemeColors tc;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatTile(
            label: 'Income',
            value: income,
            icon: Icons.arrow_downward_rounded,
            color: tc.coreAction,
            tc: tc,
            onTap: onTap,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatTile(
            label: 'Expense',
            value: expense,
            icon: Icons.arrow_upward_rounded,
            color: tc.accentExpense,
            tc: tc,
            onTap: onTap,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatTile(
            label: 'Transfers',
            value: transfer,
            icon: Icons.swap_horiz_rounded,
            color: tc.text70,
            tc: tc,
            onTap: onTap,
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.tc,
    required this.onTap,
  });
  final String label;
  final double value;
  final IconData icon;
  final Color color;
  final ThemeColors tc;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: tc.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: tc.border, width: 0.8),
          boxShadow: isDark
              ? null
              : [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 14),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: GoogleFonts.inter(color: tc.text40, fontSize: 11),
            ),
            const SizedBox(height: 2),
            Text(
              'Rs. ${_fmt(value)}',
              style: GoogleFonts.manrope(
                color: tc.text100,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Quick actions ────────────────────────────────────────────────────────────
class _QuickActionsRow extends StatelessWidget {
  const _QuickActionsRow({
    required this.tc,
    required this.onManageBudget,
    required this.onViewAll,
  });
  final ThemeColors tc;
  final VoidCallback onManageBudget;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickActionCard(
            tc: tc,
            icon: Icons.pie_chart_rounded,
            title: 'Manage Budgets',
            subtitle: 'Add or edit categories',
            onTap: onManageBudget,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _QuickActionCard(
            tc: tc,
            icon: Icons.receipt_long_rounded,
            title: 'All Transactions',
            subtitle: 'Full history',
            onTap: onViewAll,
          ),
        ),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.tc,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final ThemeColors tc;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: tc.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: tc.border, width: 0.8),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: tc.coreAction.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: tc.coreAction, size: 17),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      color: tc.text100,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(color: tc.text40, fontSize: 10),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Cash flow (income vs outflow) proportion card ──────────────────────────
class _CashFlowCard extends StatelessWidget {
  const _CashFlowCard({
    required this.income,
    required this.expense,
    required this.transfer,
    required this.tc,
  });
  final double income;
  final double expense;
  final double transfer;
  final ThemeColors tc;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final total = income + expense + transfer;
    final incomeFrac = total > 0 ? income / total : 0.0;
    final expenseFrac = total > 0 ? expense / total : 0.0;
    final transferFrac = total > 0 ? transfer / total : 0.0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: tc.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: tc.border, width: 0.8),
        boxShadow: isDark
            ? null
            : [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cash Flow',
            style: GoogleFonts.manrope(
              color: tc.text100,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 10,
              child: total > 0
                  ? Row(
                children: [
                  if (incomeFrac > 0)
                    Expanded(
                      flex: (incomeFrac * 1000).round(),
                      child: Container(color: tc.coreAction),
                    ),
                  if (expenseFrac > 0)
                    Expanded(
                      flex: (expenseFrac * 1000).round(),
                      child: Container(color: tc.accentExpense),
                    ),
                  if (transferFrac > 0)
                    Expanded(
                      flex: (transferFrac * 1000).round(),
                      child: Container(color: tc.text40),
                    ),
                ],
              )
                  : Container(color: tc.text10),
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _LegendDot(color: tc.coreAction, label: 'Income', tc: tc),
              _LegendDot(color: tc.accentExpense, label: 'Expense', tc: tc),
              _LegendDot(color: tc.text40, label: 'Transfers', tc: tc),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({
    required this.color,
    required this.label,
    required this.tc,
  });
  final Color color;
  final String label;
  final ThemeColors tc;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: GoogleFonts.inter(color: tc.text70, fontSize: 12)),
      ],
    );
  }
}

// ── Top spending categories ─────────────────────────────────────────────────
class _TopCategoriesCard extends StatelessWidget {
  const _TopCategoriesCard({
    required this.expenseByCategory,
    required this.tc,
    required this.onSeeAll,
  });
  final Map<String, double> expenseByCategory;
  final ThemeColors tc;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final entries = expenseByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top = entries.take(4).toList();
    final maxVal = top.isNotEmpty ? top.first.value : 1.0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: tc.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: tc.border, width: 0.8),
        boxShadow: isDark
            ? null
            : [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Top Categories',
                style: GoogleFonts.manrope(
                  color: tc.text100,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              GestureDetector(
                onTap: onSeeAll,
                child: Text(
                  'Manage',
                  style: GoogleFonts.inter(
                    color: tc.coreAction,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (top.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                'No expenses recorded yet.',
                style: GoogleFonts.inter(color: tc.text40, fontSize: 12),
              ),
            )
          else
            ...List.generate(top.length, (i) {
              final e = top[i];
              final frac = maxVal > 0
                  ? (e.value / maxVal).clamp(0.0, 1.0)
                  : 0.0;
              final color = AppColors.chart[i % AppColors.chart.length];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          e.key,
                          style: GoogleFonts.inter(
                            color: tc.text70,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          'Rs. ${_fmt(e.value)}',
                          style: GoogleFonts.manrope(
                            color: tc.text100,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: frac,
                        minHeight: 6,
                        backgroundColor: tc.text10,
                        valueColor: AlwaysStoppedAnimation(color),
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}

// ── Recent activity ──────────────────────────────────────────────────────────
class _RecentActivityCard extends StatelessWidget {
  const _RecentActivityCard({
    required this.transactions,
    required this.tc,
    required this.onSeeAll,
  });
  final List<TransactionModel> transactions;
  final ThemeColors tc;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: tc.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: tc.border, width: 0.8),
        boxShadow: isDark
            ? null
            : [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Activity',
                style: GoogleFonts.manrope(
                  color: tc.text100,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              GestureDetector(
                onTap: onSeeAll,
                child: Text(
                  'See all',
                  style: GoogleFonts.inter(
                    color: tc.coreAction,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (transactions.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  'No transactions yet.',
                  style: GoogleFonts.inter(color: tc.text40, fontSize: 12),
                ),
              ),
            )
          else
            ...transactions.map((t) => _TxnTile(t: t, tc: tc)),
        ],
      ),
    );
  }
}

class _TxnTile extends StatelessWidget {
  const _TxnTile({required this.t, required this.tc});
  final TransactionModel t;
  final ThemeColors tc;

  Color _typeColor() {
    switch (t.type) {
      case TransactionType.income:
        return tc.coreAction;
      case TransactionType.expense:
        return tc.accentExpense;
      default:
        return tc.text70;
    }
  }

  IconData _typeIcon() {
    switch (t.type) {
      case TransactionType.income:
        return Icons.arrow_downward_rounded;
      case TransactionType.expense:
        return Icons.arrow_upward_rounded;
      default:
        return Icons.swap_horiz_rounded;
    }
  }

  String _sign() => t.type == TransactionType.expense
      ? '-'
      : (t.type == TransactionType.income ? '+' : '');

  @override
  Widget build(BuildContext context) {
    final color = _typeColor();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_typeIcon(), color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  '${t.category} · ${_formatDate(t.date)}',
                  style: GoogleFonts.inter(color: tc.text40, fontSize: 11),
                ),
              ],
            ),
          ),
          Text(
            '${_sign()}Rs. ${_fmt(t.amount)}',
            style: GoogleFonts.manrope(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shared helpers ───────────────────────────────────────────────────────────
String _fmt(double v) {
  if (v >= 100000) return '${(v / 100000).toStringAsFixed(1)}L';
  if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
  return v.toStringAsFixed(0);
}

String _formatDate(DateTime d) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${months[d.month - 1]} ${d.day}';
}
