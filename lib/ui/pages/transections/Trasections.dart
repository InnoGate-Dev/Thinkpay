import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                // ── Header ──────────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Transactions',
                          style: GoogleFonts.manrope(
                            color: tc.text100,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      Text(
                        '${all.length} records',
                        style: GoogleFonts.inter(
                          color: tc.text40,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Search bar ───────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: Container(
                    height: 46,
                    decoration: BoxDecoration(
                      color: tc.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: tc.border, width: 0.8),
                      boxShadow: isDark
                          ? null
                          : [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              )
                            ],
                    ),
                    child: Row(children: [
                      const SizedBox(width: 14),
                      Icon(Icons.search_rounded, color: tc.text40, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _searchCtrl,
                          style: GoogleFonts.inter(
                              color: tc.text100, fontSize: 14),
                          decoration: InputDecoration(
                            hintText: 'Search transactions…',
                            hintStyle: GoogleFonts.inter(
                                color: tc.text40, fontSize: 14),
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
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Container(
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                color: tc.surface2,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.close_rounded,
                                  color: tc.text40, size: 12),
                            ),
                          ),
                        ),
                    ]),
                  ),
                ),

                // ── Filter chips ─────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: Row(children: [
                    _Chip(
                      label: 'All',
                      selected: _filter == null,
                      color: tc.text70,
                      tc: tc,
                      onTap: () => setState(() => _filter = null),
                    ),
                    const SizedBox(width: 8),
                    _Chip(
                      label: '↓ Income',
                      selected: _filter == TransactionType.income,
                      color: tc.coreAction,
                      tc: tc,
                      onTap: () =>
                          setState(() => _filter = TransactionType.income),
                    ),
                    const SizedBox(width: 8),
                    _Chip(
                      label: '↑ Expense',
                      selected: _filter == TransactionType.expense,
                      color: tc.accentExpense,
                      tc: tc,
                      onTap: () =>
                          setState(() => _filter = TransactionType.expense),
                    ),
                  ]),
                ),

                // ── List ──────────────────────────────────────────────────────
                Expanded(
                  child: grouped.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.receipt_long_outlined,
                                  color: tc.text20, size: 48),
                              const SizedBox(height: 12),
                              Text(
                                'No transactions found.',
                                style: GoogleFonts.inter(
                                    color: tc.text40, fontSize: 14),
                              ),
                            ],
                          ),
                        )
                      : ListView(
                          padding:
                              const EdgeInsets.fromLTRB(20, 4, 20, 120),
                          children: grouped.entries
                              .map((entry) => Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            0, 12, 0, 8),
                                        child: Text(
                                          entry.key,
                                          style: GoogleFonts.inter(
                                            color: tc.text40,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.6,
                                          ),
                                        ),
                                      ),
                                      _TransactionGroup(
                                          transactions: entry.value, tc: tc),
                                    ],
                                  ))
                              .toList(),
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

// ── Grouped transaction container ─────────────────────────────────────────────
class _TransactionGroup extends StatelessWidget {
  const _TransactionGroup({required this.transactions, required this.tc});
  final List<TransactionModel> transactions;
  final ThemeColors tc;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: tc.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: tc.border, width: 0.8),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              ],
      ),
      child: Column(
        children: [
          for (int i = 0; i < transactions.length; i++) ...[
            _TxTile(t: transactions[i], tc: tc),
            if (i < transactions.length - 1)
              Divider(
                color: tc.divider,
                height: 1,
                thickness: 0.5,
                indent: 68,
              ),
          ],
        ],
      ),
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
    final color = isIncome ? tc.coreAction : tc.accentExpense;

    return Dismissible(
      key: Key(t.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: tc.accentExpense.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.delete_outline_rounded, color: tc.accentExpense),
      ),
      onDismissed: (_) => FinanceProvider().deleteTransaction(t.id),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_catIcon(t.category), color: color, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.title,
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
                  t.category,
                  style: GoogleFonts.inter(
                      color: tc.text40, fontSize: 12),
                ),
              ],
            ),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(
              '${isIncome ? '+' : '−'} Rs. ${_fmt(t.amount)}',
              style: GoogleFonts.manrope(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              _timeStr(t.date),
              style: GoogleFonts.inter(color: tc.text40, fontSize: 11),
            ),
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
    final chipColor = color ?? tc.coreAction;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected
              ? chipColor.withValues(alpha: 0.12)
              : tc.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected
                ? chipColor.withValues(alpha: 0.4)
                : tc.border,
            width: 0.8,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            color: selected ? chipColor : tc.text40,
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────
String _dateKey(DateTime d) {
  final now = DateTime.now();
  if (d.year == now.year && d.month == now.month && d.day == now.day) {
    return 'TODAY';
  }
  if (d.year == now.year &&
      d.month == now.month &&
      d.day == now.day - 1) {
    return 'YESTERDAY';
  }
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  return '${d.day} ${months[d.month - 1]} ${d.year}'.toUpperCase();
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
