import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:Thinkpay/constant/app_colors.dart';
import 'package:Thinkpay/model/transaction_model.dart';
import 'package:Thinkpay/providers/finance_provider.dart';
import 'package:Thinkpay/ui/component/add_budget_sheet.dart';

class BudgetPage extends StatefulWidget {
  const BudgetPage({super.key});
  @override
  State<BudgetPage> createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage> with SingleTickerProviderStateMixin {
  final _provider = FinanceProvider();
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _tab.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  void _openAdd() => showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const AddBudgetSheet(),
  );

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _provider,
      builder: (context, _) {
        final expBudgets = _provider.budgets.where((b) => b.type == TransactionType.expense).toList();
        final incBudgets = _provider.budgets.where((b) => b.type == TransactionType.income).toList();
        final expActual  = _provider.expenseByCategory;
        final incActual  = _provider.incomeByCategory;

        // Pie sections for expenses
        final expPieSections = <PieChartSectionData>[];
        final cats = expActual.entries.toList();
        for (int i = 0; i < cats.length; i++) {
          expPieSections.add(PieChartSectionData(
            value: cats[i].value,
            color: AppColors.chart[i % AppColors.chart.length],
            title: '',
            radius: 52,
          ));
        }

        return Scaffold(
          backgroundColor: AppColors.dark,
          appBar: AppBar(
            actions: [],
            backgroundColor: AppColors.surface,
            elevation: 0,
            titleSpacing: 20,
            title: const Text('Budget', style: TextStyle(color: AppColors.w100, fontSize: 18, fontWeight: FontWeight.w700)),
            bottom: TabBar(
              controller: _tab,
              indicatorColor: AppColors.lime,
              indicatorWeight: 2,
              labelColor: AppColors.lime,
              unselectedLabelColor: AppColors.w40,
              labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              tabs: const [Tab(text: 'Expenses'), Tab(text: 'Income')],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _openAdd,
            backgroundColor: AppColors.lime,
            foregroundColor: AppColors.dark,
            child: const Icon(Icons.add_rounded, size: 28),
          ),
          body: TabBarView(
            controller: _tab,
            children: [
              // ── Expense tab ─────────────────────────────────────────────
              _BudgetTab(
                budgets: expBudgets,
                actualMap: expActual,
                pieSections: expPieSections,
                catLabels: cats.map((e) => e.key).toList(),
                accentColor: AppColors.red,
                type: TransactionType.expense,
              ),
              // ── Income tab ──────────────────────────────────────────────
              _BudgetTab(
                budgets: incBudgets,
                actualMap: incActual,
                pieSections: [],
                catLabels: [],
                accentColor: AppColors.lime,
                type: TransactionType.income,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BudgetTab extends StatelessWidget {
  const _BudgetTab({
    required this.budgets, required this.actualMap, required this.pieSections,
    required this.catLabels, required this.accentColor, required this.type,
  });
  final List budgets;
  final Map<String, double> actualMap;
  final List<PieChartSectionData> pieSections;
  final List<String> catLabels;
  final Color accentColor;
  final TransactionType type;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      children: [
        // ── Totals summary ───────────────────────────────────────────────
        _SummaryRow(budgets: budgets, actualMap: actualMap, accent: accentColor),
        const SizedBox(height: 20),

        // ── Pie chart (only for expenses) ────────────────────────────────
        if (pieSections.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface, borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Expense Breakdown',
                style: TextStyle(color: AppColors.w100, fontSize: 14, fontWeight: FontWeight.w600)),
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
                    children: List.generate(catLabels.length, (i) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(children: [
                        Container(width: 10, height: 10,
                          decoration: BoxDecoration(
                            color: AppColors.chart[i % AppColors.chart.length],
                            shape: BoxShape.circle,
                          )),
                        const SizedBox(width: 6),
                        Text(catLabels[i],
                          style: const TextStyle(color: AppColors.w70, fontSize: 12)),
                      ]),
                    )),
                  ),
                ]),
              ),
            ]),
          ),
          const SizedBox(height: 20),
        ],

        // ── Category progress bars ───────────────────────────────────────
        const Text('Category Breakdown',
          style: TextStyle(color: AppColors.w100, fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),

        if (budgets.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border)),
            child: const Center(child: Text('No budget categories.\nTap + to create one.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.w40, fontSize: 14, height: 1.6))),
          ),

        ...budgets.map((b) {
          final actual   = actualMap[b.name] ?? 0.0;
          final expected = b.expectedAmount;
          final pct      = expected > 0 ? (actual / expected).clamp(0.0, 1.0) : 0.0;
          final over     = actual > expected;
          final bar      = over ? AppColors.red : accentColor;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface, borderRadius: BorderRadius.circular(16),
              border: Border.all(color: over ? AppColors.red.withValues(alpha: 0.4) : AppColors.border),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text(b.name,
                  style: const TextStyle(color: AppColors.w100, fontSize: 14, fontWeight: FontWeight.w600))),
                if (over)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: AppColors.redDim, borderRadius: BorderRadius.circular(6)),
                    child: const Text('Over budget', style: TextStyle(color: AppColors.red, fontSize: 11, fontWeight: FontWeight.w600)),
                  ),
              ]),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: pct,
                  minHeight: 8,
                  backgroundColor: AppColors.w10,
                  valueColor: AlwaysStoppedAnimation(bar),
                ),
              ),
              const SizedBox(height: 8),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Actual: Rs. ${_fmt(actual)}',
                  style: TextStyle(color: bar, fontSize: 12, fontWeight: FontWeight.w600)),
                Text('Budget: Rs. ${_fmt(expected)}',
                  style: const TextStyle(color: AppColors.w40, fontSize: 12)),
              ]),
            ]),
          );
        }),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.budgets, required this.actualMap, required this.accent});
  final List budgets;
  final Map<String, double> actualMap;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final totalExpected = budgets.fold<double>(0, (s, b) => s + b.expectedAmount);
    final totalActual   = budgets.fold<double>(0, (s, b) => s + (actualMap[b.name] ?? 0));

    return Row(children: [
      _SummaryCard(label: 'Expected', value: totalExpected, color: AppColors.w70),
      const SizedBox(width: 12),
      _SummaryCard(label: 'Actual', value: totalActual, color: accent),
    ]);
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.label, required this.value, required this.color});
  final String label; final double value; final Color color;
  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface, borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(color: AppColors.w40, fontSize: 12)),
        const SizedBox(height: 4),
        Text('Rs. ${_fmt(value)}',
          style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.w700)),
      ]),
    ),
  );
}

String _fmt(double v) {
  if (v >= 100000) return '${(v / 100000).toStringAsFixed(1)}L';
  if (v >= 1000)   return '${(v / 1000).toStringAsFixed(1)}K';
  return v.toStringAsFixed(0);
}
