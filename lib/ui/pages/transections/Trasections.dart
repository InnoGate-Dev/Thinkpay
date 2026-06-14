import 'package:flutter/material.dart';
import 'package:Thinkpay/constant/app_colors.dart';
import 'package:Thinkpay/model/transaction_model.dart';
import 'package:Thinkpay/providers/finance_provider.dart';
import 'package:Thinkpay/ui/component/add_transaction_sheet.dart';

class Transection extends StatefulWidget {
  const Transection({super.key});
  @override
  State<Transection> createState() => _TransectionState();
}

class _TransectionState extends State<Transection> {
  final _provider   = FinanceProvider();
  final _searchCtrl = TextEditingController();
  TransactionType? _filter; // null = all
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(
        () => setState(() => _query = _searchCtrl.text.toLowerCase()));
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

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
        final all = _provider.transactions.where((t) {
          final matchFilter = _filter == null || t.type == _filter;
          final matchQuery = _query.isEmpty ||
              t.title.toLowerCase().contains(_query) ||
              t.category.toLowerCase().contains(_query);
          return matchFilter && matchQuery;
        }).toList();

        // Group by date
        final grouped = <String, List<TransactionModel>>{};
        for (final t in all) {
          final key = _dateKey(t.date);
          grouped.putIfAbsent(key, () => []).add(t);
        }

        return Scaffold(
          backgroundColor: tc.background,
          appBar: AppBar(
            backgroundColor: tc.surface,
            elevation: 0,
            titleSpacing: 20,
            title: Text(
              'Transactions',
              style: TextStyle(
                  color: tc.text100,
                  fontSize: 18,
                  fontWeight: FontWeight.w700),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _openAdd,
            backgroundColor: tc.lime,
            foregroundColor: tc.background,
            child: const Icon(Icons.add_rounded, size: 28),
          ),
          body: Column(
            children: [
              // ── Search bar ──────────────────────────────────────────────
              Container(
                color: tc.surface,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: tc.surface2,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: tc.border),
                  ),
                  child: Row(children: [
                    const SizedBox(width: 12),
                    Icon(Icons.search_rounded, color: tc.text40, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchCtrl,
                        style:
                            TextStyle(color: tc.text100, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Search transactions…',
                          hintStyle:
                              TextStyle(color: tc.text40, fontSize: 14),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    if (_query.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          _searchCtrl.clear();
                          setState(() => _query = '');
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Icon(Icons.close_rounded,
                              color: tc.text40, size: 16),
                        ),
                      ),
                  ]),
                ),
              ),

              // ── Filter chips ────────────────────────────────────────────
              Container(
                color: tc.surface,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Row(children: [
                  _Chip(
                    label: 'All',
                    selected: _filter == null,
                    color: tc.lime,
                    tc: tc,
                    onTap: () => setState(() => _filter = null),
                  ),
                  const SizedBox(width: 8),
                  _Chip(
                    label: 'Income',
                    selected: _filter == TransactionType.income,
                    color: tc.lime,
                    tc: tc,
                    onTap: () =>
                        setState(() => _filter = TransactionType.income),
                  ),
                  const SizedBox(width: 8),
                  _Chip(
                    label: 'Expense',
                    selected: _filter == TransactionType.expense,
                    color: tc.red,
                    tc: tc,
                    onTap: () =>
                        setState(() => _filter = TransactionType.expense),
                  ),
                ]),
              ),

              // ── List ────────────────────────────────────────────────────
              Expanded(
                child: grouped.isEmpty
                    ? Center(
                        child: Text(
                          'No transactions found.',
                          style: TextStyle(color: tc.text40, fontSize: 14),
                        ),
                      )
                    : ListView(
                        padding:
                            const EdgeInsets.fromLTRB(16, 12, 16, 100),
                        children: grouped.entries
                            .map((entry) => Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      child: Text(
                                        entry.key,
                                        style: TextStyle(
                                            color: tc.text40,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.5),
                                      ),
                                    ),
                                    ...entry.value
                                        .map((t) => _TxTile(t: t, tc: tc)),
                                  ],
                                ))
                            .toList(),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Transaction tile ──────────────────────────────────────────────────────────
class _TxTile extends StatelessWidget {
  const _TxTile({required this.t, required this.tc});
  final TransactionModel t;
  final ThemeColors tc;

  @override
  Widget build(BuildContext context) {
    final isIncome = t.type == TransactionType.income;
    final color    = isIncome ? tc.lime : tc.red;

    return Dismissible(
      key: Key(t.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: tc.red.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(Icons.delete_outline_rounded, color: tc.red),
      ),
      onDismissed: (_) => FinanceProvider().deleteTransaction(t.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: tc.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: tc.border),
        ),
        child: Row(children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_catIcon(t.category), color: color, size: 19),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.title,
                      style: TextStyle(
                          color: tc.text100,
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(t.category,
                      style: TextStyle(color: tc.text40, fontSize: 11)),
                ]),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(
              '${isIncome ? '+' : '-'} Rs. ${_fmt(t.amount)}',
              style: TextStyle(
                  color: color, fontSize: 13, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 2),
            Text(_timeStr(t.date),
                style: TextStyle(color: tc.text40, fontSize: 11)),
          ]),
        ]),
      ),
    );
  }
}

// ── Filter chip ───────────────────────────────────────────────────────────────
class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.tc,
    this.color,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final ThemeColors tc;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? tc.lime;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: selected
              ? chipColor.withValues(alpha: 0.15)
              : tc.surface2,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? chipColor.withValues(alpha: 0.5)
                : tc.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
              color: selected ? chipColor : tc.text40,
              fontSize: 12,
              fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────
String _dateKey(DateTime d) {
  final now = DateTime.now();
  if (d.year == now.year && d.month == now.month && d.day == now.day) {
    return 'Today';
  }
  if (d.year == now.year && d.month == now.month && d.day == now.day - 1) {
    return 'Yesterday';
  }
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  return '${d.day} ${months[d.month - 1]} ${d.year}';
}

String _timeStr(DateTime d) =>
    '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

String _fmt(double v) {
  if (v >= 100000) return '${(v / 100000).toStringAsFixed(1)}L';
  if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
  return v.toStringAsFixed(0);
}

IconData _catIcon(String cat) {
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
