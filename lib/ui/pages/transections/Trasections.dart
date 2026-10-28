
import 'package:Thinkpay/model/loan_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Thinkpay/core/constant/app_colors.dart';
import 'package:Thinkpay/model/transaction_model.dart';
import 'package:Thinkpay/providers/finance_provider.dart';
import 'package:Thinkpay/ui/component/add_transaction_sheet.dart';

import '../../../core/repository/categoryRepo.dart';
import '../../../core/repository/goalTrasection.dart';
import '../../../core/repository/loanRepo.dart';
import '../../../core/repository/trasectionRepo.dart';

/// Optional notifier to set the filter from outside.
final transactionFilterNotifier = ValueNotifier<TransactionType?>(null);

class Transection extends StatefulWidget {
  const Transection({super.key, this.type});
  final TransactionType? type;
  @override
  State<Transection> createState() => _TransectionState();
}

class _TransectionState extends State<Transection> {
  final _provider   = FinanceProvider();
  final _searchCtrl = TextEditingController();
  TransactionType? _filter; // null = all
  String _query = '';
  bool _isLoading = false;
  final _categoryRepo = CategoryRepository();
  final _transactionRepo = TransactionRepository();
  final _goalTransactionRepo = GoalTrasectionRepository();
  final _loanRepo = LoanRepository();
  String? _error;

  /// Unified list combining regular, goal, and loan transactions.
  List<_UnifiedTx> _allUnified = [];

  @override
  void initState() {
    super.initState();
    _filter = widget.type ?? transactionFilterNotifier.value;

    transactionFilterNotifier.addListener(_onFilterChanged);

    _searchCtrl.addListener(
        () => setState(() => _query = _searchCtrl.text.toLowerCase()));

    _loadTrasections();
  }

  Future<void> _loadTrasections() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Fetch regular transactions, goal transactions, and loan payments in
      // parallel – matching the exact parallel-fetch pattern used across the app.
      final results = await Future.wait([
        _transactionRepo.getTransactions(),
        _goalTransactionRepo.getGoalTransactions(),
        _loanRepo.getLoans(withPayments: true), // loans with embedded payments
      ]);

      final regularTxs = results[0] as List<ApiTransaction>;
      final goalTxs = results[1] as List<Map<String, dynamic>>;
      final loans = results[2] as List<LoanModel>;

      // Also refresh goal list in the provider so UI stays in sync
      final localModels = regularTxs.map((t) => t.toLocalModel()).toList();
      _provider.setTransactions(localModels);

      // Build unified list
      final unified = <_UnifiedTx>[];

      // 1. Regular transactions
      for (final t in regularTxs) {
        unified.add(_UnifiedTx(
          id: 'tx_${t.id}',
          category: t.categoryName ?? t.type.apiValue,
          amount: t.amount,
          type: t.type,
          date: t.date,
          source: _TxSource.regular,
        ));
      }

      // 2. Goal transactions
      for (final raw in goalTxs) {
        final amount = double.tryParse(raw['amount']?.toString() ?? '0') ?? 0;
        final date = raw['transaction_date'] != null
            ? (DateTime.tryParse(raw['transaction_date'].toString()) ??
                DateTime.now())
            : DateTime.now();
        final goalName = (raw['goal'] as Map<String, dynamic>?)?['name']
                as String? ??
            raw['goal_name'] as String? ??
            'Goal';
        unified.add(_UnifiedTx(
          id: 'gtx_${raw['id'] ?? unified.length}',
          category: goalName,
          amount: amount,
          type: TransactionType.transferOut,
          date: date,
          source: _TxSource.goal,
        ));
      }

      // 3. Loan payments (from loans that have payments loaded)
      for (final loan in loans) {
        for (final payment in loan.payments) {
          unified.add(_UnifiedTx(
            id: 'lp_${payment.id}',
            category: loan.purpose,
            amount: payment.amount,
            type: TransactionType.transferOut,
            date: payment.paidAt,
            source: _TxSource.loan,
          ));
        }
      }

      // Sort by date descending
      unified.sort((a, b) => b.date.compareTo(a.date));

      if (mounted) {
        setState(() => _allUnified = unified);
      }
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load Transaction data: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onFilterChanged() {
    if (mounted) {
      setState(() => _filter = transactionFilterNotifier.value);
    }
  }

  @override
  void dispose() {
    transactionFilterNotifier.removeListener(_onFilterChanged);
    _searchCtrl.dispose();
    super.dispose();
  }

  void _openAddTransaction() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddTransactionSheet(),
    ).then((_) => _loadTrasections()); // Refresh after adding
  }

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Filter by type and search query
    final filtered = _allUnified.where((t) {
      final matchFilter = _filter == null || t.type == _filter;
      final matchQuery = _query.isEmpty ||
          t.category.toLowerCase().contains(_query);
      return matchFilter && matchQuery;
    }).toList();

    // Group by date key
    final grouped = <String, List<_UnifiedTx>>{};
    for (final t in filtered) {
      final key = _dateKey(t.date);
      grouped.putIfAbsent(key, () => []).add(t);
    }

    return Scaffold(
      backgroundColor: tc.background,
      drawerEnableOpenDragGesture: false,
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_home',
        onPressed: _openAddTransaction,
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
          children: [
            // ── Header ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Icon(
                      Icons.arrow_back_ios,
                    ),
                  ),
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
                    '${filtered.length} records',
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
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
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
                  const SizedBox(width: 8),
                  _Chip(
                    label: '⇄ Transfer Out',
                    selected: _filter == TransactionType.transferOut,
                    color: tc.intelligenceAccent,
                    tc: tc,
                    onTap: () =>
                        setState(() => _filter = TransactionType.transferOut),
                  ),
                ]),
              ),
            ),

            // ── Loading / Error / List ────────────────────────────────────
            if (_isLoading)
              Expanded(
                child: Center(
                  child: CircularProgressIndicator(color: tc.coreAction),
                ),
              )
            else if (_error != null)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline_rounded,
                          color: tc.accentExpense, size: 36),
                      const SizedBox(height: 12),
                      Text(_error!,
                          style: GoogleFonts.inter(
                              color: tc.text40, fontSize: 13),
                          textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: _loadTrasections,
                        child: Text('Retry',
                            style: GoogleFonts.inter(color: tc.coreAction)),
                      ),
                    ],
                  ),
                ),
              )
            else
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
                    : RefreshIndicator(
                        onRefresh: _loadTrasections,
                        color: tc.coreAction,
                        child: ListView(
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
              ),
          ],
        ),
      ),
    );
  }
}

// ── Unified transaction model ─────────────────────────────────────────────────
/// Internal unified model that merges regular transactions, goal transactions,
/// and loan payments into a single list for display.
enum _TxSource { regular, goal, loan }

class _UnifiedTx {
  const _UnifiedTx({
    required this.id,
    required this.category,
    required this.amount,
    required this.type,
    required this.date,
    required this.source,
  });

  final String id;
  final String category;
  final double amount;
  final TransactionType type;
  final DateTime date;
  final _TxSource source;

  /// Badge label shown next to the category name.
  String get sourceBadge {
    switch (source) {
      case _TxSource.goal:
        return 'Goal';
      case _TxSource.loan:
        return 'Loan';
      case _TxSource.regular:
        return '';
    }
  }
}

// ── Grouped transaction container ─────────────────────────────────────────────
class _TransactionGroup extends StatelessWidget {
  const _TransactionGroup({required this.transactions, required this.tc});
  final List<_UnifiedTx> transactions;
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
  final _UnifiedTx t;
  final ThemeColors tc;

  @override
  Widget build(BuildContext context) {
    final isIncome = t.type == TransactionType.income ||
        t.type == TransactionType.otherIn;
    final isTransfer = t.type == TransactionType.transferOut ||
        t.type == TransactionType.transferIn;
    final color = isIncome
        ? tc.coreAction
        : isTransfer
            ? tc.intelligenceAccent
            : tc.accentExpense;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(_txIcon(t), color: color, size: 18),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      t.category,
                      style: GoogleFonts.inter(
                          color: tc.text70, fontSize: 13,
                          fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (t.sourceBadge.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        t.sourceBadge,
                        style: GoogleFonts.inter(
                          color: color,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 2),
              Text(
                isTransfer ? 'Transfer Out' : (isIncome ? 'Income' : 'Expense'),
                style: GoogleFonts.inter(color: tc.text40, fontSize: 11),
              ),
            ],
          ),
        ),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(
            '${isIncome ? '+' : isTransfer ? '⇄ ' : '−'} Rs. ${_fmt(t.amount)}',
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

IconData _txIcon(_UnifiedTx t) {
  if (t.source == _TxSource.goal) return Icons.flag_rounded;
  if (t.source == _TxSource.loan) return Icons.account_balance_rounded;
  return _catIcon(t.category);
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
    case 'savings':
    case 'savings account': return Icons.savings_rounded;
    case 'brokerage':
    case 'transfer':
    case 'bank transfer': return Icons.swap_horiz_rounded;
    case 'gift':          return Icons.card_giftcard_rounded;
    default:              return Icons.receipt_rounded;
  }
}
