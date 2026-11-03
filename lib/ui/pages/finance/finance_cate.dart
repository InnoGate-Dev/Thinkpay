import 'package:Thinkpay/core/repository/categoryRepo.dart';
import 'package:Thinkpay/core/repository/goalRepo.dart';
import 'package:Thinkpay/core/repository/loanRepo.dart';
import 'package:Thinkpay/core/repository/trasectionRepo.dart';
import 'package:Thinkpay/model/categoryModel.dart';
import 'package:Thinkpay/model/goal_model.dart';
import 'package:Thinkpay/model/loan_model.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Thinkpay/core/constant/app_colors.dart';
import 'package:Thinkpay/core/utils/number_format.dart';
import 'package:Thinkpay/model/budget_model.dart';
import 'package:Thinkpay/model/transaction_model.dart';
import 'package:Thinkpay/providers/finance_provider.dart';
import 'package:Thinkpay/ui/component/add_budget_category_sheet.dart';

/// Published whenever the Finance page's Expense/Income/Transfer tab changes.
/// AppShell reads this so its FAB can pre-select the correct type.
final financeTabIndexNotifier = ValueNotifier<int>(0);

class FinancePage extends StatefulWidget {
  const FinancePage({super.key});
  @override
  State<FinancePage> createState() => _FinancePageState();
}

class _FinancePageState extends State<FinancePage>
    with SingleTickerProviderStateMixin {
  final _provider = FinanceProvider();
  final _categoryRepo = CategoryRepository();
  final _transactionRepo = TransactionRepository();
  final _goalRepo = GoalRepository();
  final _loanRepo = LoanRepository();
  List<GoalModel> _goals = [];
  List<LoanModel> _loans = [];
  late TabController _tab;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this); // Expenses, Income, Transfers
    _tab.addListener(() {
      setState(() {});
      financeTabIndexNotifier.value = _tab.index;
    });
    _loadFinanceData();
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  /// Fetches the user's financial categories, transactions, goals, and loans
  /// from the backend API and populates the [FinanceProvider] so the charts
  /// and lists reflect live DB data.
  Future<void> _loadFinanceData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        _categoryRepo.getCategories(),
        _transactionRepo.getTransactions(),
        _goalRepo.getGoals(),
        _loanRepo.getLoans(),
      ]);
      final categories = results[0] as List<Category>;
      final apiTransactions = results[1] as List<ApiTransaction>;
      final goals = results[2] as List<GoalModel>;
      final loans = results[3] as List<LoanModel>;

      _provider.setBudgetCategories(
        categories.map((c) => c.toBudgetCategory()).toList(),
      );
      // Transactions only carry `category_id`; resolve the names so the
      // breakdown groups by real category instead of the transaction type.
      _provider.setTransactions(apiTransactions.toLocalModels(categories));
      _provider.setGoals(goals);

      if (mounted) {
        setState(() {
          _goals = goals;
          _loans = loans;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load financial data: ${e.toString()}')),
        );
      }
      debugPrint('Failed to load financial data: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _openAddBudget() {
    final type = _tab.index == 0
        ? TransactionType.expense
        : _tab.index == 1
        ? TransactionType.income
        : TransactionType.transferOut; // Transfer tab defaults to transferOut

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddBudgetCategorySheet(initialType: type),
    ).then((_) => _loadFinanceData()); // Refresh after sheet closes
  }

  /// Calls the real DELETE /categories/{id} API and removes the item from the
  /// local [FinanceProvider], giving user feedback via SnackBar.
  Future<void> _deleteCategory(int id) async {
    try {
      await _categoryRepo.deleteCategory(id);
      _provider.deleteBudget(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Category deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete category: ${e.toString()}'),
            backgroundColor: ThemeColors.of(context).red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);

    return ListenableBuilder(
      listenable: _provider,
      builder: (context, _) {
        final expBudgets = _provider.budgets
            .where((b) => b.type == TransactionType.expense)
            .toList();
        final incBudgets = _provider.budgets
            .where((b) => b.type == TransactionType.income)
            .toList();
        final trfBudgets = _provider.budgets
            .where((b) =>
                b.type == TransactionType.transferIn ||
                b.type == TransactionType.transferOut)
            .toList();

        final expActual = _resolveActuals(expBudgets, _provider.expenseByCategory);
        final incActual = _resolveActuals(incBudgets, _provider.incomeByCategory);
        final trfActual = _resolveActuals(trfBudgets, _provider.transferByCategory);

        // ── Pie sections — Expenses ──────────────────────────────────────────
        final expCats = _pieEntries(expActual);
        final expPieSections = _pieSections(expCats);

        // ── Pie sections — Income ────────────────────────────────────────────
        final incCats = _pieEntries(incActual);
        final incPieSections = _pieSections(incCats);

        // ── Pie sections — Transfers ─────────────────────────────────────────
        final trfCats = _pieEntries(trfActual);
        final trfPieSections = _pieSections(trfCats);

        return Scaffold(
          backgroundColor: tc.background,
          drawerEnableOpenDragGesture: false,
          floatingActionButton: FloatingActionButton(
            heroTag: 'fab_budget',
            onPressed: _openAddBudget,
            backgroundColor: tc.coreAction,
            foregroundColor: tc.background,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.add_rounded, size: 24),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          body: SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header with back button ───────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 12, 20, 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: tc.text100,
                          size: 20,
                        ),
                        onPressed: () => Navigator.pop(context),
                        tooltip: 'Back',
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Manage Budgets',
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

                // ── Pill segmented control tabs ──────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _SegmentedControl(
                    controller: _tab,
                    tabs: const ['Expenses', 'Income', 'Transfers'],
                    tc: tc,
                  ),
                ),
                if (_isLoading)
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 6),
                    child: LinearProgressIndicator(
                      minHeight: 2,
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation(tc.coreAction),
                    ),
                  )
                else
                  const SizedBox(height: 16),

                // ── Tab content ──────────────────────────────────────────────
                Expanded(
                  child: TabBarView(
                    controller: _tab,
                    children: [
                      _FinanceTab(
                        budgets: expBudgets,
                        actualMap: expActual,
                        pieSections: expPieSections,
                        catLabels: expCats.map((e) => e.key).toList(),
                        accentColor: tc.accentExpense,
                        chartTitle: 'Expense Breakdown',
                        type: TransactionType.expense,
                        onDelete: _deleteCategory,
                        onRefresh: _loadFinanceData,
                        tc: tc,
                      ),
                      _FinanceTab(
                        budgets: incBudgets,
                        actualMap: incActual,
                        pieSections: incPieSections,
                        catLabels: incCats.map((e) => e.key).toList(),
                        accentColor: tc.coreAction,
                        chartTitle: 'Income Breakdown',
                        type: TransactionType.income,
                        onDelete: _deleteCategory,
                        onRefresh: _loadFinanceData,
                        tc: tc,
                      ),
                      _FinanceTab(
                        budgets: trfBudgets,
                        actualMap: trfActual,
                        pieSections: trfPieSections,
                        catLabels: trfCats.map((e) => e.key).toList(),
                        accentColor: tc.text70,
                        chartTitle: 'Transfer Breakdown',
                        type: TransactionType.transferOut,
                        onDelete: _deleteCategory,
                        onRefresh: _loadFinanceData,
                        tc: tc,
                        goals: _goals,
                        loans: _loans,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Segmented control ─────────────────────────────────────────────────────────
class _SegmentedControl extends StatelessWidget {
  const _SegmentedControl({
    required this.controller,
    required this.tabs,
    required this.tc,
  });
  final TabController controller;
  final List<String> tabs;
  final ThemeColors tc;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: tc.surface2,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: tc.border, width: 0.5),
      ),
      child: TabBar(
        controller: controller,
        indicator: BoxDecoration(
          color: tc.surface,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        padding: const EdgeInsets.all(3),
        labelColor: tc.text100,
        unselectedLabelColor: tc.text40,
        labelStyle: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontWeight: FontWeight.w400,
          fontSize: 13,
        ),
        tabs: tabs.map((t) => Tab(text: t, height: 34)).toList(),
      ),
    );
  }
}

// ── Finance Tab ────────────────────────────────────────────────────────────────
class _FinanceTab extends StatelessWidget {
  const _FinanceTab({
    required this.budgets,
    required this.actualMap,
    required this.pieSections,
    required this.catLabels,
    required this.accentColor,
    required this.chartTitle,
    required this.type,
    required this.onDelete,
    required this.onRefresh,
    required this.tc,
    this.goals = const [],
    this.loans = const [],
  });

  final List<BudgetCategory> budgets;
  final Map<String, double> actualMap;
  final List<PieChartSectionData> pieSections;
  final List<String> catLabels;
  final Color accentColor;
  final String chartTitle;
  final TransactionType type;

  /// Called when the user confirms deletion of a category.
  /// Receives the category [id] and returns a [Future] so errors propagate.
  final Future<void> Function(int id) onDelete;

  /// Pull-to-refresh callback to reload categories from the backend.
  final Future<void> Function() onRefresh;

  final ThemeColors tc;

  /// Goals shown as virtual transfer-out items in the Transfers tab.
  final List<GoalModel> goals;

  /// Loans shown as virtual transfer-out items in the Transfers tab.
  final List<LoanModel> loans;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // The donut legend sits in a fixed-height card, so only the largest few
    // categories get a row; the rest are summarised by a "+N more" entry.
    const maxLegendRows = 5;
    final legendLabels = catLabels.take(maxLegendRows).toList();
    final hiddenLegendCount = catLabels.length - legendLabels.length;

    // Build virtual BudgetCategory entries for goals (Transfer tab only).
    final List<_VirtualTransferItem> virtualItems = [];
    if (type == TransactionType.transferOut) {
      for (final g in goals) {
        virtualItems.add(_VirtualTransferItem(
          label: g.name,
          subtitle: 'Goal · Transfer Out',
          icon: Icons.flag_rounded,
          color: tc.coreAction,
          actual: g.savedAmount,
          target: g.targetAmount,
          tc: tc,
        ));
      }
      for (final l in loans) {
        virtualItems.add(_VirtualTransferItem(
          label: l.purpose,
          subtitle: 'Loan · Transfer Out',
          icon: Icons.account_balance_rounded,
          color: tc.intelligenceAccent,
          actual: l.amountPaid,
          target: l.totalPayable,
          tc: tc,
        ));
      }
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      color: accentColor,
      backgroundColor: tc.surface,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
        children: [
          // ── Totals summary ─────────────────────────────────────────────────
          _SummaryRow(
            budgets: budgets,
            actualMap: actualMap,
            accent: accentColor,
            type: type,
            tc: tc,
          ),
          const SizedBox(height: 16),

          // ── Donut chart ────────────────────────────────────────────────────
          if (pieSections.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(20),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chartTitle,
                    style: GoogleFonts.manrope(
                      color: tc.text100,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 180,
                    child: Row(
                      children: [
                        Expanded(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              PieChart(
                                PieChartData(
                                  sections: pieSections,
                                  sectionsSpace: 2,
                                  centerSpaceRadius: 52,
                                ),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${pieSections.length}',
                                    style: GoogleFonts.manrope(
                                      color: tc.text100,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  Text(
                                    pieSections.length == 1
                                        ? 'category'
                                        : 'categories',
                                    style: GoogleFonts.inter(
                                      color: tc.text40,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (int i = 0; i < legendLabels.length; i++)
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: AppColors.chart[
                                            i % AppColors.chart.length],
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      legendLabels[i],
                                      style: GoogleFonts.inter(
                                        color: tc.text70,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            if (hiddenLegendCount > 0)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  '+$hiddenLegendCount more',
                                  style: GoogleFonts.inter(
                                    color: tc.text40,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // ── Category progress bars ─────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Categories',
                style: GoogleFonts.manrope(
                  color: tc.text100,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '${budgets.length + virtualItems.length} total',
                style: GoogleFonts.inter(color: tc.text40, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 10),

          if (budgets.isEmpty && virtualItems.isEmpty)
            Container(
              padding: const EdgeInsets.all(36),
              decoration: BoxDecoration(
                color: tc.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: tc.border, width: 0.8),
              ),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.pie_chart_outline_rounded,
                      color: tc.text20,
                      size: 36,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'No budget categories yet.\nTap + to create one.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        color: tc.text40,
                        fontSize: 13,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          ...budgets.map(
                (b) => _FinanceCard(
              b: b,
              actual: actualMap[b.name] ?? b.actualAmount,
              accentColor: accentColor,
              onDelete: onDelete,
              tc: tc,
            ),
          ),

          // ── Virtual Goal / Loan transfer-out items ─────────────────────────
          if (virtualItems.isNotEmpty) ...[
            if (budgets.isNotEmpty) const SizedBox(height: 6),
            ...virtualItems,
          ],
        ],
      ),
    );
  }
}

// ── Finance Category Card ──────────────────────────────────────────────────────
class _FinanceCard extends StatelessWidget {
  const _FinanceCard({
    required this.b,
    required this.actual,
    required this.accentColor,
    required this.onDelete,
    required this.tc,
  });

  final BudgetCategory b;
  final double actual;
  final Color accentColor;

  /// Callback for when the user confirms deletion of this card's category.
  final Future<void> Function(int id) onDelete;

  final ThemeColors tc;

  void _openEdit(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddBudgetCategorySheet(existing: b),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: tc.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text(
          'Delete Category',
          style: GoogleFonts.manrope(
            color: tc.text100,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'Remove "${b.name}" from your budget?',
          style: GoogleFonts.inter(color: tc.text70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.inter(color: tc.text40)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              onDelete(b.id);
            },
            child: Text(
              'Delete',
              style: GoogleFonts.inter(color: tc.accentExpense),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final expected = b.expectedAmount;
    // Without a planned amount there is no ratio to draw, so the bar stays empty
    // and the card shows the running total only instead of a misleading 100%.
    final hasTarget = expected > 0;
    final pct = hasTarget ? (actual / expected).clamp(0.0, 1.0) : 0.0;
    final over = hasTarget && actual > expected;
    final bar = over ? tc.accentExpense : accentColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: tc.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: over ? tc.accentExpense.withValues(alpha: 0.35) : tc.border,
          width: 0.8,
        ),
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    b.name,
                    style: GoogleFonts.inter(
                      color: tc.text100,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (over)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: tc.accentExpenseDim,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Over budget',
                      style: GoogleFonts.inter(
                        color: tc.accentExpense,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                const SizedBox(width: 4),
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert_rounded,
                    color: tc.text40,
                    size: 18,
                  ),
                  color: tc.surface2,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  onSelected: (v) {
                    if (v == 'edit') _openEdit(context);
                    if (v == 'delete') _confirmDelete(context);
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(
                            Icons.edit_outlined,
                            color: tc.coreAction,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Edit',
                            style: GoogleFonts.inter(color: tc.text100),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_outline_rounded,
                            color: tc.accentExpense,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Delete',
                            style: GoogleFonts.inter(color: tc.accentExpense),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Progress bar with percentage
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: pct,
                      minHeight: 6,
                      backgroundColor: tc.text10,
                      valueColor: AlwaysStoppedAnimation(bar),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  hasTarget ? '${(pct * 100).toStringAsFixed(0)}%' : '—',
                  style: GoogleFonts.manrope(
                    color: bar,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_fmt(actual)} ${b.type == TransactionType.expense ? 'spent' : 'received'}',
                  style: GoogleFonts.inter(
                    color: bar,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  hasTarget ? 'of ${_fmt(expected)}' : 'no planned amount',
                  style: GoogleFonts.inter(color: tc.text40, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Virtual transfer-out card (Goal / Loan) ────────────────────────────────────
/// A read-only budget card displayed in the Transfers tab for goals and loans.
/// These items are not stored as budget categories but are shown so users
/// can see their transfer-out progress and select them when adding a transaction.
class _VirtualTransferItem extends StatelessWidget {
  const _VirtualTransferItem({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.actual,
    required this.target,
    required this.tc,
  });

  final String label;
  final String subtitle;
  final IconData icon;
  final Color color;
  final double actual;
  final double target;
  final ThemeColors tc;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pct = target > 0 ? (actual / target).clamp(0.0, 1.0) : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: tc.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.25),
          width: 0.8,
        ),
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 16),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: GoogleFonts.inter(
                          color: tc.text100,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: GoogleFonts.inter(
                          color: tc.text40,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Transfer Out',
                    style: GoogleFonts.inter(
                      color: color,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: pct,
                      minHeight: 6,
                      backgroundColor: tc.text10,
                      valueColor: AlwaysStoppedAnimation(color),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '${(pct * 100).toStringAsFixed(0)}%',
                  style: GoogleFonts.manrope(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_fmt(actual)} transferred',
                  style: GoogleFonts.inter(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'of ${_fmt(target)}',
                  style: GoogleFonts.inter(color: tc.text40, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Summary row ───────────────────────────────────────────────────────────────
class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.budgets,
    required this.actualMap,
    required this.accent,
    required this.type,
    required this.tc,
  });
  final List<BudgetCategory> budgets;
  final Map<String, double> actualMap;
  final Color accent;
  final TransactionType type;
  final ThemeColors tc;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final totalExpected = budgets.fold<double>(
      0,
          (s, b) => s + b.expectedAmount,
    );
    final totalActual = budgets.fold<double>(
      0,
          (s, b) => s + (actualMap[b.name] ?? b.actualAmount),
    );

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
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Planned',
                  style: GoogleFonts.inter(color: tc.text40, fontSize: 11),
                ),
                const SizedBox(height: 4),
                Text(
                  _fmt(totalExpected),
                  style: GoogleFonts.manrope(
                    color: tc.text100,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 0.5,
            height: 36,
            color: tc.border,
            margin: const EdgeInsets.symmetric(horizontal: 16),
          ),
          Expanded(
            child: InkWell(
              onTap: () {
                // Assuming transactionFilterNotifier is defined elsewhere
                // transactionFilterNotifier.value = type;
                Navigator.pushNamed(context, '/transaction');
              },
              borderRadius: BorderRadius.circular(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Actual',
                        style: GoogleFonts.inter(
                          color: tc.text40,
                          fontSize: 11,
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: tc.text40,
                        size: 16,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _fmt(totalActual),
                    style: GoogleFonts.manrope(
                      color: accent,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _fmt(double v) => compactMoney(v);

/// Resolves the "actual" figure shown for every category in [budgets].
///
/// The server-maintained `actual_amount` is the source of truth because the
/// transaction endpoint is paginated (so a client-side sum would only cover the
/// latest page). [localActuals] is used as a fallback for categories whose
/// running total is still zero, which keeps the screen useful for accounts whose
/// historical transactions have not been folded into `actual_amount` yet.
Map<String, double> _resolveActuals(
  List<BudgetCategory> budgets,
  Map<String, double> localActuals,
) {
  return {
    for (final b in budgets)
      b.name:
          b.actualAmount > 0 ? b.actualAmount : (localActuals[b.name] ?? 0.0),
  };
}

/// Chart entries for [actuals], skipping zero values because a zero-value
/// section would still claim a colour and a legend row.
List<MapEntry<String, double>> _pieEntries(Map<String, double> actuals) =>
    actuals.entries.where((e) => e.value > 0).toList();

/// Builds donut sections in the same order as [entries], so the legend colours
/// in [_FinanceTab] always match the painted slices.
List<PieChartSectionData> _pieSections(List<MapEntry<String, double>> entries) {
  return [
    for (int i = 0; i < entries.length; i++)
      PieChartSectionData(
        value: entries[i].value,
        color: AppColors.chart[i % AppColors.chart.length],
        title: '',
        radius: 44,
      ),
  ];
}