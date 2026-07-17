import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Thinkpay/constant/app_colors.dart';
import 'package:Thinkpay/model/budget_model.dart';
import 'package:Thinkpay/model/transaction_model.dart';
import 'package:Thinkpay/providers/finance_provider.dart';
import 'package:Thinkpay/ui/component/add_budget_sheet.dart';
import 'package:Thinkpay/ui/component/navbar.dart';
import 'package:Thinkpay/ui/pages/transections/Trasections.dart';

/// Published whenever the Finance page's Expense/Income tab changes.
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
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _tab.addListener(() {
      setState(() {});
      financeTabIndexNotifier.value = _tab.index;
    });
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  void _openAddBudget() {
    final type = _tab.index == 0
        ? TransactionType.expense
        : TransactionType.income;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddBudgetSheet(initialType: type),
    );
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
        final expActual = _provider.expenseByCategory;
        final incActual = _provider.incomeByCategory;

        // ── Pie sections — Expenses ──────────────────────────────────────────
        final expCats = expActual.entries.toList();
        final expPieSections = <PieChartSectionData>[
          for (int i = 0; i < expCats.length; i++)
            PieChartSectionData(
              value: expCats[i].value,
              color: AppColors.chart[i % AppColors.chart.length],
              title: '',
              radius: 44,
            ),
        ];

        // ── Pie sections — Income ────────────────────────────────────────────
        final incCats = incActual.entries.toList();
        final incPieSections = <PieChartSectionData>[
          for (int i = 0; i < incCats.length; i++)
            PieChartSectionData(
              value: incCats[i].value,
              color: AppColors.chart[i % AppColors.chart.length],
              title: '',
              radius: 44,
            ),
        ];

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
                // ── Header ───────────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                  child: Text(
                    'Finance',
                    style: GoogleFonts.manrope(
                      color: tc.text100,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),

                // ── Pill segmented control tabs ──────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _SegmentedControl(
                    controller: _tab,
                    tabs: const ['Expenses', 'Income'],
                    tc: tc,
                  ),
                ),
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
                        tc: tc,
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
    required this.tc,
  });

  final List<BudgetCategory> budgets;
  final Map<String, double> actualMap;
  final List<PieChartSectionData> pieSections;
  final List<String> catLabels;
  final Color accentColor;
  final String chartTitle;
  final TransactionType type;
  final ThemeColors tc;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView(
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
                                  'categories',
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
                        children: List.generate(
                          catLabels.length,
                          (i) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: AppColors
                                        .chart[i % AppColors.chart.length],
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  catLabels[i],
                                  style: GoogleFonts.inter(
                                    color: tc.text70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
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
              '${budgets.length} total',
              style: GoogleFonts.inter(color: tc.text40, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 10),

        if (budgets.isEmpty)
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
            actual: actualMap[b.name] ?? 0.0,
            accentColor: accentColor,
            tc: tc,
          ),
        ),
      ],
    );
  }
}

// ── Finance Category Card ──────────────────────────────────────────────────────
class _FinanceCard extends StatelessWidget {
  const _FinanceCard({
    required this.b,
    required this.actual,
    required this.accentColor,
    required this.tc,
  });

  final BudgetCategory b;
  final double actual;
  final Color accentColor;
  final ThemeColors tc;

  void _openEdit(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddBudgetSheet(existing: b),
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
              FinanceProvider().deleteBudget(b.id);
              Navigator.pop(ctx);
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
    final pct = expected > 0 ? (actual / expected).clamp(0.0, 1.0) : 0.0;
    final over = actual > expected;
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
                  '${(pct * 100).toStringAsFixed(0)}%',
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
                  'Rs. ${_fmt(actual)} spent',
                  style: GoogleFonts.inter(
                    color: bar,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'of Rs. ${_fmt(expected)}',
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
      (s, b) => s + (actualMap[b.name] ?? 0),
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
                  'Rs. ${_fmt(totalExpected)}',
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
                transactionFilterNotifier.value = type;
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
                    'Rs. ${_fmt(totalActual)}',
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

String _fmt(double v) {
  if (v >= 100000) return '${(v / 100000).toStringAsFixed(1)}L';
  if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
  return v.toStringAsFixed(0);
}
