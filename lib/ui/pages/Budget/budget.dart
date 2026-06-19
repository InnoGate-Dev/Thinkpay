import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:Thinkpay/constant/app_colors.dart';
import 'package:Thinkpay/model/budget_model.dart';
import 'package:Thinkpay/model/transaction_model.dart';
import 'package:Thinkpay/providers/finance_provider.dart';
import 'package:Thinkpay/ui/component/add_budget_sheet.dart';

/// Published whenever the Budget page's Expense/Income tab changes.
/// AppShell reads this so its FAB can pre-select the correct type.
final budgetTabIndexNotifier = ValueNotifier<int>(0);

class BudgetPage extends StatefulWidget {
  const BudgetPage({super.key});
  @override
  State<BudgetPage> createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage>
    with SingleTickerProviderStateMixin {
  final _provider = FinanceProvider();
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _tab.addListener(() {
      setState(() {});
      budgetTabIndexNotifier.value = _tab.index;
    });
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
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
              radius: 52,
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
              radius: 52,
            ),
        ];

        return Scaffold(
          backgroundColor: tc.background,
          appBar: AppBar(
            backgroundColor: tc.surface,
            elevation: 0,
            titleSpacing: 20,
            title: Text(
              'Budget',
              style: TextStyle(
                  color: tc.text100,
                  fontSize: 18,
                  fontWeight: FontWeight.w700),
            ),
            bottom: TabBar(
              controller: _tab,
              indicatorColor: tc.lime,
              indicatorWeight: 2,
              labelColor: tc.lime,
              unselectedLabelColor: tc.text40,
              labelStyle: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 13),
              tabs: const [Tab(text: 'Expenses'), Tab(text: 'Income')],
            ),
          ),
          body: TabBarView(
            controller: _tab,
            children: [
              // ── Expense tab ────────────────────────────────────────────────
              _BudgetTab(
                budgets: expBudgets,
                actualMap: expActual,
                pieSections: expPieSections,
                catLabels: expCats.map((e) => e.key).toList(),
                accentColor: tc.red,
                chartTitle: 'Expense Breakdown',
                type: TransactionType.expense,
                tc: tc,
              ),
              // ── Income tab ─────────────────────────────────────────────────
              _BudgetTab(
                budgets: incBudgets,
                actualMap: incActual,
                pieSections: incPieSections,
                catLabels: incCats.map((e) => e.key).toList(),
                accentColor: tc.lime,
                chartTitle: 'Income Breakdown',
                type: TransactionType.income,
                tc: tc,
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Budget Tab ────────────────────────────────────────────────────────────────
class _BudgetTab extends StatelessWidget {
  const _BudgetTab({
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
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      children: [
        // ── Totals summary ─────────────────────────────────────────────────
        _SummaryRow(
            budgets: budgets, actualMap: actualMap, accent: accentColor, tc: tc),
        const SizedBox(height: 20),

        // ── Pie chart ──────────────────────────────────────────────────────
        if (pieSections.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: tc.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: tc.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  chartTitle,
                  style: TextStyle(
                      color: tc.text100,
                      fontSize: 14,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: Row(children: [
                    Expanded(
                      child: PieChart(PieChartData(
                        sections: pieSections,
                        sectionsSpace: 2,
                        centerSpaceRadius: 48,
                      )),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(
                        catLabels.length,
                        (i) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Row(children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: AppColors.chart[i % AppColors.chart.length],
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              catLabels[i],
                              style: TextStyle(
                                  color: tc.text70, fontSize: 12),
                            ),
                          ]),
                        ),
                      ),
                    ),
                  ]),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],

        // ── Category progress bars ─────────────────────────────────────────
        Text(
          'Category Breakdown',
          style: TextStyle(
              color: tc.text100, fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),

        if (budgets.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: tc.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: tc.border),
            ),
            child: Center(
              child: Text(
                'No budget categories.\nTap + to create one.',
                textAlign: TextAlign.center,
                style: TextStyle(color: tc.text40, fontSize: 14, height: 1.6),
              ),
            ),
          ),

        ...budgets.map((b) => _BudgetCard(
              b: b,
              actual: actualMap[b.name] ?? 0.0,
              accentColor: accentColor,
              tc: tc,
            )),
      ],
    );
  }
}

// ── Budget Category Card (with edit / delete) ─────────────────────────────────
class _BudgetCard extends StatelessWidget {
  const _BudgetCard({
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete Category',
          style: TextStyle(color: tc.text100, fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Remove "${b.name}" from your budget?',
          style: TextStyle(color: tc.text70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: tc.text40)),
          ),
          TextButton(
            onPressed: () {
              FinanceProvider().deleteBudget(b.id);
              Navigator.pop(ctx);
            },
            child: Text('Delete', style: TextStyle(color: tc.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final expected = b.expectedAmount;
    final pct      = expected > 0 ? (actual / expected).clamp(0.0, 1.0) : 0.0;
    final over     = actual > expected;
    final bar      = over ? tc.red : accentColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: tc.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: over
                ? tc.red.withValues(alpha: 0.4)
                : tc.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Expanded(
                child: Text(
                  b.name,
                  style: TextStyle(
                      color: tc.text100,
                      fontSize: 14,
                      fontWeight: FontWeight.w600),
                ),
              ),
              if (over)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: tc.redDim,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Over budget',
                    style: TextStyle(
                        color: tc.red,
                        fontSize: 11,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              const SizedBox(width: 4),
              // ── Action menu ──────────────────────────────────────────
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert_rounded, color: tc.text40, size: 20),
                color: tc.surface2,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                onSelected: (v) {
                  if (v == 'edit') _openEdit(context);
                  if (v == 'delete') _confirmDelete(context);
                },
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(children: [
                      Icon(Icons.edit_outlined, color: tc.lime, size: 18),
                      const SizedBox(width: 8),
                      Text('Edit', style: TextStyle(color: tc.text100)),
                    ]),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(children: [
                      Icon(Icons.delete_outline_rounded, color: tc.red, size: 18),
                      const SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: tc.red)),
                    ]),
                  ),
                ],
              ),
            ]),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: pct,
                minHeight: 8,
                backgroundColor: tc.text10,
                valueColor: AlwaysStoppedAnimation(bar),
              ),
            ),
            const SizedBox(height: 8),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Actual: Rs. ${_fmt(actual)}',
                    style: TextStyle(
                        color: bar,
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
                  ),
                  Text(
                    'Budget: Rs. ${_fmt(expected)}',
                    style: TextStyle(color: tc.text40, fontSize: 12),
                  ),
                ]),
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
    required this.tc,
  });
  final List<BudgetCategory> budgets;
  final Map<String, double> actualMap;
  final Color accent;
  final ThemeColors tc;

  @override
  Widget build(BuildContext context) {
    final totalExpected =
        budgets.fold<double>(0, (s, b) => s + b.expectedAmount);
    final totalActual =
        budgets.fold<double>(0, (s, b) => s + (actualMap[b.name] ?? 0));

    return Row(children: [
      _SummaryCard(
          label: 'Expected', value: totalExpected, color: tc.text70, tc: tc),
      const SizedBox(width: 12),
      _SummaryCard(label: 'Actual', value: totalActual, color: accent, tc: tc),
    ]);
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard(
      {required this.label,
      required this.value,
      required this.color,
      required this.tc});
  final String label;
  final double value;
  final Color color;
  final ThemeColors tc;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: tc.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: tc.border),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label,
                style: TextStyle(color: tc.text40, fontSize: 12)),
            const SizedBox(height: 4),
            Text(
              'Rs. ${_fmt(value)}',
              style: TextStyle(
                  color: color, fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ]),
        ),
      );
}

String _fmt(double v) {
  if (v >= 100000) return '${(v / 100000).toStringAsFixed(1)}L';
  if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
  return v.toStringAsFixed(0);
}
