
import 'package:Thinkpay/model/categoryModel.dart';
import 'package:Thinkpay/model/credit_card_model.dart';
import 'package:Thinkpay/model/credit_card_transaction_model.dart';
import 'package:Thinkpay/model/goal_model.dart';
import 'package:Thinkpay/model/loan_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Thinkpay/core/constant/app_colors.dart';
import 'package:Thinkpay/core/utils/number_format.dart';
import 'package:Thinkpay/model/transaction_model.dart';
import 'package:Thinkpay/providers/finance_provider.dart';
import 'package:Thinkpay/ui/component/add_transaction_sheet.dart';
import 'package:Thinkpay/ui/component/amount_text.dart';
import 'package:Thinkpay/ui/component/transaction_detail_sheet.dart';
import 'package:Thinkpay/ui/component/transaction_edit_sheet.dart';

import '../../../core/repository/categoryRepo.dart';
import '../../../core/repository/creditCardRepo.dart';
import '../../../core/repository/creditCardTransactionRepo.dart';
import '../../../core/repository/goalRepo.dart';
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
  final _goalRepo = GoalRepository();
  final _loanRepo = LoanRepository();
  final _cardTransactionRepo = CreditCardTransactionRepository();
  final _cardRepo = CreditCardRepository();
  String? _error;

  /// Unified list combining regular, goal, loan and credit card transactions.
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
      // Fetch regular transactions, goal transactions, loan payments, card
      // transactions, the category list, the goals and the cards in parallel –
      // matching the exact parallel-fetch pattern used across the app.
      // Categories and goals are required because GET /transactions and
      // GET /goaltrasections return only `category_id` / `goal_id`; without the
      // lookups every record would fall back to a bare "INCOME" / "EXPENSE" /
      // "Goal" label. Cards name the card a card-charged row belongs to.
      final results = await Future.wait([
        _transactionRepo.getTransactions(),
        _goalTransactionRepo.getGoalTransactions(),
        _loanRepo.getLoans(withPayments: true), // loans with embedded payments
        _fetchCategoriesSafe(),
        _fetchGoalsSafe(),
        _fetchCardTransactionsSafe(),
        _fetchCardsSafe(),
      ]);

      final regularTxs = results[0] as List<ApiTransaction>;
      final goalTxs = results[1] as List<Map<String, dynamic>>;
      final loans = results[2] as List<LoanModel>;
      final categories = results[3] as List<Category>;
      final goals = results[4] as List<GoalModel>;
      final cardTxs = results[5] as List<CreditCardTransactionModel>;
      final cards = results[6] as List<CreditCardModel>;

      final categoryNames = <int, String>{
        for (final c in categories)
          if (c.name.trim().isNotEmpty) c.id: c.name.trim(),
      };

      // Goals arrive with a typed composite id (e.g. `42_S`); goal rows only
      // carry the numeric `goal_id`, so index them by their numeric part.
      final goalsById = <int, GoalModel>{};
      for (final g in goals) {
        final numeric = int.tryParse(g.id.split('_').first);
        if (numeric != null) goalsById[numeric] = g;
      }

      final cardsById = <int, CreditCardModel>{
        for (final c in cards) c.id: c,
      };

      // Also refresh the provider's transaction list so the dashboard stays in
      // sync. Names are resolved here, so its category breakdown groups by real
      // category instead of the transaction type.
      final localModels = regularTxs
          .map((t) => t.toLocalModel(
                fallbackCategory: categoryNames[t.categoryId],
              ))
          .toList();
      _provider.setTransactions(localModels);

      // Build unified list
      final unified = <_UnifiedTx>[];

      // 1. Regular transactions
      for (final t in regularTxs) {
        unified.add(_UnifiedTx(
          id: 'tx_${t.id}',
          category: t.categoryName ??
              categoryNames[t.categoryId] ??
              'Uncategorised',
          amount: t.amount,
          type: t.type,
          date: t.date,
          source: _TxSource.regular,
          recordId: t.id,
          categoryId: t.categoryId,
          goalId: t.goalId,
          recordedAt: t.createdAt,
          goal: t.goalId == null ? null : goalsById[t.goalId],
        ));
      }

      // 2. Goal transactions
      for (final raw in goalTxs) {
        final amount = double.tryParse(raw['amount']?.toString() ?? '0') ?? 0;
        final date = raw['transaction_date'] != null
            ? (DateTime.tryParse(raw['transaction_date'].toString()) ??
                DateTime.now())
            : DateTime.now();
        final goal = goalsById[int.tryParse(raw['goal_id']?.toString() ?? '')];
        final goalName = goal?.name ??
            (raw['goal'] as Map<String, dynamic>?)?['name'] as String? ??
            raw['goal_name'] as String? ??
            'Goal';
        unified.add(_UnifiedTx(
          id: 'gtx_${raw['id'] ?? unified.length}',
          category: goalName,
          amount: amount,
          type: TransactionType.transferOut,
          date: date,
          source: _TxSource.goal,
          recordId: int.tryParse(raw['id']?.toString() ?? ''),
          reference: goalName,
          goal: goal,
        ));
      }

      // 3. Loan payments (from loans that have payments loaded)
      for (final loan in loans) {
        // Oldest first, so the instalment position matches the loan schedule.
        final payments = [...loan.payments]
          ..sort((a, b) => a.paidAt.compareTo(b.paidAt));
        for (var i = 0; i < payments.length; i++) {
          final payment = payments[i];
          unified.add(_UnifiedTx(
            id: 'lp_${payment.id}',
            category: loan.purpose,
            amount: payment.amount,
            type: TransactionType.transferOut,
            date: payment.paidAt,
            source: _TxSource.loan,
            recordId: payment.id,
            loanId: loan.id,
            reference: loan.purpose,
            installment: loan.loanDurationMonths > 0
                ? '${i + 1} of ${loan.loanDurationMonths}'
                : null,
            note: payment.note,
          ));
        }
      }

      // 4. Credit card spending
      //
      // Card charges are written to `creditcard_transactions`, never to the main
      // ledger, so GET /transactions cannot list them. They are merged here so a
      // card-paid expense appears alongside cash and loan rows.
      for (final raw in cardTxs) {
        unified.add(_UnifiedTx(
          id: 'ctx_${raw.id}',
          category: categoryNames[raw.categoryId] ?? 'Uncategorised',
          amount: raw.amount,
          type: raw.type,
          date: raw.date,
          source: _TxSource.card,
          recordId: raw.id,
          categoryId: raw.categoryId,
          cardId: raw.cardId,
          cardName: cardsById[raw.cardId]?.name,
          recordedAt: raw.createdAt,
          note: raw.note,
        ));
      }

      // Sort by date descending
      unified.sort((a, b) => b.date.compareTo(a.date));

      if (mounted) {
        setState(() => _allUnified = unified);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load Transaction data: ${e.toString()}'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Categories power the name lookup for transaction rows. A lookup failure
  /// must not hide the transaction list, so it degrades to an empty list.
  Future<List<Category>> _fetchCategoriesSafe() async {
    try {
      return await _categoryRepo.getCategories();
    } catch (_) {
      return const <Category>[];
    }
  }

  /// Goals supply the name, target and progress shown on goal rows and their
  /// detail sheet. Degrades to an empty list so the ledger still renders.
  Future<List<GoalModel>> _fetchGoalsSafe() async {
    try {
      return await _goalRepo.getGoals();
    } catch (_) {
      return const <GoalModel>[];
    }
  }

  /// Card spending lives in `creditcard_transactions`, not in the ledger, so it
  /// has to be asked for explicitly. Degrades to an empty list like the others.
  Future<List<CreditCardTransactionModel>> _fetchCardTransactionsSafe() async {
    try {
      return await _cardTransactionRepo.getCardTransactions();
    } catch (_) {
      return const <CreditCardTransactionModel>[];
    }
  }

  /// Cards give a card-charged row its display name. Same degradation rule.
  Future<List<CreditCardModel>> _fetchCardsSafe() async {
    try {
      return await _cardRepo.getCards();
    } catch (_) {
      return const <CreditCardModel>[];
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

  void _openDetail(_UnifiedTx t) {
    final tc = ThemeColors.of(context);
    // Records whose own backend id did not arrive cannot be addressed by the
    // edit / delete routes, so the sheet falls back to read-only.
    final draft = t.toEditDraft();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TransactionDetailSheet(
        data: t.toDetailData(tc),
        onEdit: draft == null ? null : () => _editTx(draft),
        onDelete: draft == null ? null : () => _deleteTx(t),
      ),
    );
  }

  /// Opens the edit form for [draft] and reloads the ledger once the backend
  /// record actually changed.
  Future<void> _editTx(TransactionEditDraft draft) async {
    final changed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TransactionEditSheet(draft: draft),
    );
    if (changed != true || !mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transaction updated.')),
    );
    await _loadTrasections();
  }

  /// Confirms, deletes and refreshes. Routes to the table the row belongs to;
  /// goal transfers also roll their amount back out of the goal's saved total,
  /// because `goaltrasections` does not touch the goal balance server-side.
  Future<void> _deleteTx(_UnifiedTx t) async {
    final confirmed = await _confirmDelete(t);
    if (confirmed != true || !mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    try {
      switch (t.source) {
        case _TxSource.regular:
          await _transactionRepo.deleteTransaction(t.recordId!);
        case _TxSource.goal:
          await _goalTransactionRepo.deleteGoalTrasection(t.recordId!);
          final goal = t.goal;
          if (goal != null && t.amount > 0) {
            final updated =
                await _goalRepo.addAmountToGoal(goal.id, -t.amount, goal);
            _provider.addAmountToGoal(goal.id, updated.savedAmount);
          }
        case _TxSource.loan:
          await _loanRepo.deleteLoanPayment(
            loanId: t.loanId!,
            paymentId: t.recordId!,
          );
        case _TxSource.card:
          await _cardTransactionRepo.deleteCardTransaction(t.recordId!);
      }
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('${t.recordRef} deleted.')),
      );
      await _loadTrasections();
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text('Delete failed: $e'),
          backgroundColor: ThemeColors.of(context).red,
        ),
      );
    }
  }

  Future<bool?> _confirmDelete(_UnifiedTx t) {
    final tc = ThemeColors.of(context);
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: tc.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Delete this record?',
          style: GoogleFonts.manrope(
            color: tc.text100,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          '${t.category} · ${groupedMoney(t.amount)} will be removed '
          'permanently. This cannot be undone.',
          style: GoogleFonts.inter(
            color: tc.text70,
            fontSize: 13,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(color: tc.text40, fontSize: 13),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Delete',
              style: GoogleFonts.inter(
                color: tc.accentExpense,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Filter by type and search query
    final filtered = _allUnified.where((t) {
      final matchFilter = _filter == null || t.type == _filter;
      return matchFilter && t.matches(_query);
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
                                        child: Row(children: [
                                          Expanded(
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
                                          _DayTotals(
                                              transactions: entry.value,
                                              tc: tc),
                                        ]),
                                      ),
                                      _TransactionGroup(
                                          transactions: entry.value,
                                          tc: tc,
                                          onSelect: _openDetail),
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
/// loan payments and credit card spending into a single list for display.
enum _TxSource { regular, goal, loan, card }

class _UnifiedTx {
  const _UnifiedTx({
    required this.id,
    required this.category,
    required this.amount,
    required this.type,
    required this.date,
    required this.source,
    this.recordId,
    this.categoryId,
    this.goalId,
    this.loanId,
    this.cardId,
    this.reference,
    this.installment,
    this.recordedAt,
    this.note,
    this.goal,
    this.cardName,
  });

  final String id;
  final String category;
  final double amount;
  final TransactionType type;
  final DateTime date;
  final _TxSource source;

  /// Id of the row in its own backend table. `null` when the API did not send
  /// one, which also disables edit and delete for that row.
  final int? recordId;

  /// `category_id` of a regular transaction — `PUT /transactions/{id}` requires
  /// one on every update.
  final int? categoryId;

  /// Goal attached to a regular TRANSFER row, preserved on save.
  final int? goalId;

  /// Parent loan of a payment row.
  final int? loanId;

  /// Card a card-charged row was paid with. Null when the card was deleted,
  /// which also freezes the edit path (the update route needs a `card_id`).
  final int? cardId;

  /// Display name of [cardId]'s card, when the card still exists.
  final String? cardName;

  /// Goal name / loan purpose this record belongs to, when it has one.
  final String? reference;

  /// Position of a loan repayment in its schedule, e.g. `3 of 12`.
  final String? installment;

  /// Server-side creation stamp — only regular transactions expose one.
  final DateTime? recordedAt;

  /// Free-text note, when the source record carries one (loan payments).
  final String? note;

  /// Goal the money was moved into, with its live target and progress.
  final GoalModel? goal;

  bool get isIncome =>
      type == TransactionType.income || type == TransactionType.otherIn;

  bool get isTransfer =>
      type == TransactionType.transferOut ||
      type == TransactionType.transferIn;

  /// True when the money lands in the wallet rather than leaving it.
  bool get isMoneyIn =>
      type == TransactionType.income ||
      type == TransactionType.otherIn ||
      type == TransactionType.transferIn;

  /// Badge label shown next to the category name.
  String get sourceBadge {
    switch (source) {
      case _TxSource.goal:
        return 'Goal';
      case _TxSource.loan:
        return 'Loan';
      case _TxSource.card:
        return 'Card';
      case _TxSource.regular:
        return '';
    }
  }

  /// Readable direction of the money movement.
  String get typeLabel {
    switch (type) {
      case TransactionType.income:
        return 'Income';
      case TransactionType.expense:
        return 'Expense';
      case TransactionType.transferIn:
        return 'Transfer in';
      case TransactionType.transferOut:
        return 'Transfer out';
      case TransactionType.otherIn:
        return 'Other income';
      case TransactionType.otherOut:
        return 'Other expense';
    }
  }

  /// Second line of the list row — what the record actually is, in context.
  String get subtitle {
    switch (source) {
      case _TxSource.goal:
        final g = goal;
        if (g == null || g.targetAmount <= 0) return 'Transfer to goal';
        return 'Transfer to goal · ${percentNumber(g.progress * 100)} funded';
      case _TxSource.loan:
        return installment == null
            ? 'Loan payment'
            : 'Loan payment · instalment $installment';
      case _TxSource.card:
        final parts = <String>[
          typeLabel,
          if (cardName != null && cardName!.trim().isNotEmpty) cardName!.trim(),
          if (note != null && note!.trim().isNotEmpty) note!.trim(),
        ];
        return parts.join(' · ');
      case _TxSource.regular:
        final trimmed = note?.trim();
        return (trimmed == null || trimmed.isEmpty)
            ? typeLabel
            : '$typeLabel · $trimmed';
    }
  }

  /// Row icon: goal / loan / card markers, else the category glyph.
  IconData get icon {
    switch (source) {
      case _TxSource.goal:
        return Icons.flag_rounded;
      case _TxSource.loan:
        return Icons.account_balance_rounded;
      case _TxSource.card:
        return Icons.credit_card_rounded;
      case _TxSource.regular:
        return _catIcon(category);
    }
  }

  /// Accent colour used for the icon, amount and badge.
  Color accent(ThemeColors tc) => isIncome
      ? tc.coreAction
      : isTransfer
          ? tc.intelligenceAccent
          : tc.accentExpense;

  /// Backend reference of the record, e.g. `TXN-42`.
  String get recordRef {
    final numeric = id.contains('_') ? id.split('_').last : id;
    final prefix = switch (source) {
      _TxSource.regular => 'TXN',
      _TxSource.goal => 'GOAL',
      _TxSource.loan => 'LOAN',
      _TxSource.card => 'CARD',
    };
    return '$prefix-$numeric';
  }

  /// Case-insensitive match used by the search field.
  bool matches(String query) {
    if (query.isEmpty) return true;
    final haystack = [
      category,
      typeLabel,
      subtitle,
      reference ?? '',
      cardName ?? '',
      installment ?? '',
      note ?? '',
      if (goal != null) _goalTypeLabel(goal!.type),
    ].join(' ').toLowerCase();
    return haystack.contains(query);
  }

  /// Payload for [TransactionEditSheet], or `null` when this record cannot be
  /// addressed by an update or delete route.
  TransactionEditDraft? toEditDraft() {
    final record = recordId;
    if (record == null) return null;
    if (source == _TxSource.loan && loanId == null) return null;
    if (source == _TxSource.card && cardId == null) return null;

    return TransactionEditDraft(
      kind: switch (source) {
        _TxSource.regular => TransactionRecordKind.transaction,
        _TxSource.goal => TransactionRecordKind.goalTransfer,
        _TxSource.loan => TransactionRecordKind.loanPayment,
        _TxSource.card => TransactionRecordKind.cardTransaction,
      },
      recordId: record,
      recordRef: recordRef,
      title: category,
      amount: amount,
      date: date,
      type: type,
      // `ApiTransaction` defaults a missing id to 0; the update route needs a
      // real one, so a zero is treated as absent and the user has to pick.
      categoryId: (categoryId ?? 0) > 0 ? categoryId : null,
      goalId: goalId,
      goal: goal,
      loanId: loanId,
      cardId: cardId,
    );
  }

  /// Expands this row into the payload of [TransactionDetailSheet].
  TransactionDetailData toDetailData(ThemeColors tc) {
    return TransactionDetailData(
      title: category,
      typeLabel: typeLabel,
      amountText:
          '${isIncome ? '+' : isTransfer ? '⇄ ' : '− '}${groupedMoney(amount)}',
      amountColor: accent(tc),
      icon: icon,
      badge: sourceBadge.isEmpty ? null : sourceBadge,
      note: note,
      progress: goal?.progress,
      progressLabel:
          goal == null ? null : '${percentNumber(goal!.progress * 100)} funded',
      facts: [
        TransactionFact('Type', typeLabel),
        if (source == _TxSource.regular || source == _TxSource.card)
          TransactionFact('Category', category),
        if (source == _TxSource.card)
          TransactionFact('Card', cardName ?? 'Deleted card'),
        if (reference != null && source != _TxSource.regular && goal == null)
          TransactionFact(
            source == _TxSource.goal ? 'Goal' : 'Loan',
            reference!,
          ),
        if (goal != null) ...[
          TransactionFact('Goal', goal!.name),
          TransactionFact('Goal type', _goalTypeLabel(goal!.type)),
          TransactionFact('Target', groupedMoney(goal!.targetAmount)),
          TransactionFact('Saved so far', groupedMoney(goal!.savedAmount)),
          TransactionFact(
            'Remaining',
            groupedMoney(goal!.remaining > 0 ? goal!.remaining : 0),
          ),
          TransactionFact(
            'Status',
            goal!.isCompleted ? 'Completed' : 'In progress',
          ),
        ],
        if (installment != null) TransactionFact('Instalment', installment!),
        TransactionFact('Date', _fullDateStr(date)),
        if (recordedAt != null)
          TransactionFact('Recorded', _fullDateStr(recordedAt!)),
        TransactionFact('Reference', recordRef),
      ],
    );
  }
}

// ── Grouped transaction container ─────────────────────────────────────────────
class _TransactionGroup extends StatelessWidget {
  const _TransactionGroup({
    required this.transactions,
    required this.tc,
    required this.onSelect,
  });
  final List<_UnifiedTx> transactions;
  final ThemeColors tc;
  final ValueChanged<_UnifiedTx> onSelect;

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
            _TxTile(
              t: transactions[i],
              tc: tc,
              onTap: () => onSelect(transactions[i]),
            ),
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
  const _TxTile({required this.t, required this.tc, required this.onTap});
  final _UnifiedTx t;
  final ThemeColors tc;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = t.accent(tc);

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
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
              child: Icon(t.icon, color: color, size: 18),
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
                          maxLines: 1,
                          style: GoogleFonts.inter(
                              color: tc.text100,
                              fontSize: 13,
                              fontWeight: FontWeight.w600),
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
                  const SizedBox(height: 3),
                  Text(
                    t.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(color: tc.text40, fontSize: 11),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              AmountText(
                '${t.isIncome ? '+' : t.isTransfer ? '⇄ ' : '− '}${compactMoney(t.amount)}',
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
            const SizedBox(width: 2),
            Icon(Icons.chevron_right_rounded, size: 16, color: tc.text20),
          ]),
        ),
      ),
    );
  }
}

// ── Per-day totals ────────────────────────────────────────────────────────────
/// Money in / out for one date group, shown beside the date header so a day is
/// readable at a glance without opening a single record.
class _DayTotals extends StatelessWidget {
  const _DayTotals({required this.transactions, required this.tc});
  final List<_UnifiedTx> transactions;
  final ThemeColors tc;

  @override
  Widget build(BuildContext context) {
    var moneyIn = 0.0;
    var moneyOut = 0.0;
    for (final t in transactions) {
      if (t.isMoneyIn) {
        moneyIn += t.amount;
      } else {
        moneyOut += t.amount;
      }
    }

    final style = GoogleFonts.inter(
      fontSize: 10.5,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.4,
    );

    return Text.rich(
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      TextSpan(children: [
        if (moneyIn > 0)
          TextSpan(
            text: 'IN ${compactMoney(moneyIn)}',
            style: style.copyWith(color: tc.coreAction),
          ),
        if (moneyIn > 0 && moneyOut > 0) const TextSpan(text: '   '),
        if (moneyOut > 0)
          TextSpan(
            text: 'OUT ${compactMoney(moneyOut)}',
            style: style.copyWith(color: tc.accentExpense),
          ),
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

/// Full timestamp used by the detail sheet, e.g. `12 November 2026 · 14:32`.
String _fullDateStr(DateTime d) {
  const months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];
  return '${d.day} ${months[d.month - 1]} ${d.year} · ${_timeStr(d)}';
}

/// Readable label for the goal bucket a transfer was made into.
String _goalTypeLabel(GoalType type) {
  switch (type) {
    case GoalType.savings:
      return 'Savings';
    case GoalType.investment:
      return 'Investment';
    case GoalType.debt:
      return 'Debt';
  }
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
