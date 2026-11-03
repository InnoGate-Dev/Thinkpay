import 'package:Thinkpay/core/constant/app_colors.dart';
import 'package:Thinkpay/core/repository/creditCardRepo.dart';
import 'package:Thinkpay/core/repository/creditCardTransactionRepo.dart';
import 'package:Thinkpay/core/repository/trasectionRepo.dart';
import 'package:Thinkpay/core/utils/number_format.dart';
import 'package:Thinkpay/model/credit_card_model.dart';
import 'package:Thinkpay/model/credit_card_transaction_model.dart';
import 'package:Thinkpay/model/transaction_model.dart';
import 'package:Thinkpay/ui/component/amount_text.dart';
import 'package:Thinkpay/ui/component/transaction_detail_sheet.dart';
import 'package:Thinkpay/ui/pages/home/home_helpers.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Every transaction that belongs to one budget category.
///
/// Opened from a category card on the Finance page. Rows come from two tables:
/// the ledger (`GET /transactions`) and card spending
/// (`GET /credit-card-transactions`). Both feed the category's
/// `actual_amount`, so listing the ledger alone would contradict the total
/// shown on the card that opened this screen.
class CategoryTransactionsPage extends StatefulWidget {
  const CategoryTransactionsPage({
    super.key,
    required this.categoryId,
    required this.categoryName,
    required this.categoryType,
    required this.accentColor,
    this.plannedAmount = 0,
    this.actualAmount = 0,
  });

  /// Backend id of the `transaction_categories` row these rows belong to.
  final int categoryId;

  final String categoryName;

  /// Expense, income or transfer — drives the wording ("spent" vs "received").
  final TransactionType categoryType;

  /// Accent of the tab this category was opened from.
  final Color accentColor;

  /// Planned amount of the category (`expected_amount`).
  final double plannedAmount;

  /// Running total shown on the category card. The server maintains it, so it
  /// stays correct even when the ledger has more rows than were loaded here.
  final double actualAmount;

  @override
  State<CategoryTransactionsPage> createState() =>
      _CategoryTransactionsPageState();
}

class _CategoryTransactionsPageState extends State<CategoryTransactionsPage> {
  final _transactionRepo = TransactionRepository();
  final _cardTransactionRepo = CreditCardTransactionRepository();
  final _cardRepo = CreditCardRepository();

  List<_CategoryEntry> _entries = const <_CategoryEntry>[];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Ledger and card rows are independent, so they are fetched together.
      final results = await Future.wait([
        _transactionRepo.getTransactionsByCategory(widget.categoryId),
        _fetchCardEntriesSafe(),
      ]);
      final ledgerRows = results[0] as List<ApiTransaction>;
      final cardRows = results[1] as List<CreditCardTransactionModel>;

      // Card names are only needed when card rows exist, so the extra call is
      // skipped for a cash-only category.
      final cards = cardRows.isEmpty
          ? const <CreditCardModel>[]
          : await _fetchCardsSafe();
      final namesById = <int, String>{
        for (final c in cards) c.id: c.name,
      };

      final entries = <_CategoryEntry>[
        for (final t in ledgerRows)
          _CategoryEntry(
            recordId: t.id,
            amount: t.amount,
            type: t.type,
            date: t.date,
            source: _EntrySource.ledger,
            recordedAt: t.createdAt,
          ),
        for (final t in cardRows)
          _CategoryEntry(
            recordId: t.id,
            amount: t.amount,
            type: t.type,
            date: t.date,
            source: _EntrySource.card,
            cardName: namesById[t.cardId],
            note: t.note,
            recordedAt: t.createdAt,
          ),
      ]..sort(_newestFirst);

      if (!mounted) return;
      setState(() {
        _entries = entries;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  /// Card spending has its own endpoint; a failure there must not hide the
  /// ledger rows, so it degrades to an empty list like the other lookups.
  Future<List<CreditCardTransactionModel>> _fetchCardEntriesSafe() async {
    try {
      return await _cardTransactionRepo.getCardTransactionsByCategory(
        widget.categoryId,
      );
    } catch (_) {
      return const <CreditCardTransactionModel>[];
    }
  }

  Future<List<CreditCardModel>> _fetchCardsSafe() async {
    try {
      return await _cardRepo.getCards();
    } catch (_) {
      return const <CreditCardModel>[];
    }
  }

  void _openDetail(_CategoryEntry entry) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TransactionDetailSheet(
        data: entry.toDetailData(
          tc: ThemeColors.of(context),
          categoryName: widget.categoryName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    final groups = _groupByDay(_entries);

    return Scaffold(
      backgroundColor: tc.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(tc),
            if (_isLoading)
              Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 6),
                child: LinearProgressIndicator(
                  minHeight: 2,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation(tc.coreAction),
                ),
              )
            else
              const SizedBox(height: 8),
            Expanded(child: _body(tc, groups)),
          ],
        ),
      ),
    );
  }

  Widget _header(ThemeColors tc) {
    final count = _entries.length;
    final subtitle = _isLoading
        ? 'Loading transactions…'
        : '$count ${count == 1 ? 'transaction' : 'transactions'} · '
            '${_categoryTypeLabel(widget.categoryType)}';

    return Padding(
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.categoryName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.manrope(
                    color: tc.text100,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(color: tc.text40, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _body(ThemeColors tc, Map<String, List<_CategoryEntry>> groups) {
    if (_isLoading && _entries.isEmpty) {
      return Center(child: CircularProgressIndicator(color: tc.coreAction));
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline_rounded,
                color: tc.accentExpense,
                size: 36,
              ),
              const SizedBox(height: 12),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: tc.text40,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _load,
                child: Text(
                  'Retry',
                  style: GoogleFonts.inter(
                    color: tc.coreAction,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      color: widget.accentColor,
      backgroundColor: tc.surface,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
        children: [
          _SummaryCard(
            categoryName: widget.categoryName,
            type: widget.categoryType,
            planned: widget.plannedAmount,
            actual: widget.actualAmount,
            accent: widget.accentColor,
            tc: tc,
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Transactions',
                style: GoogleFonts.manrope(
                  color: tc.text100,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '${_entries.length} total',
                style: GoogleFonts.inter(color: tc.text40, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 10),

          if (groups.isEmpty)
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
                      Icons.receipt_long_outlined,
                      color: tc.text20,
                      size: 36,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'No transactions in this category yet.',
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
            )
          else
            for (final group in groups.entries) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 12, 0, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        group.key,
                        style: GoogleFonts.inter(
                          color: tc.text40,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                    _DayTotals(entries: group.value, tc: tc),
                  ],
                ),
              ),
              _EntryGroup(
                entries: group.value,
                categoryName: widget.categoryName,
                tc: tc,
                onSelect: _openDetail,
              ),
            ],
        ],
      ),
    );
  }
}

// ── Category summary ──────────────────────────────────────────────────────────
/// Running total shown on the card that opened this page, with the planned
/// amount and the progress towards it.
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.categoryName,
    required this.type,
    required this.planned,
    required this.actual,
    required this.accent,
    required this.tc,
  });

  final String categoryName;
  final TransactionType type;
  final double planned;
  final double actual;
  final Color accent;
  final ThemeColors tc;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasTarget = planned > 0;
    final pct = hasTarget ? (actual / planned).clamp(0.0, 1.0) : 0.0;
    final over = hasTarget && actual > planned;
    final bar = over ? tc.accentExpense : accent;
    final remaining = planned - actual;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tc.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: over ? tc.accentExpense.withValues(alpha: 0.35) : tc.border,
          width: 0.8,
        ),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  getCategoryIcon(categoryName),
                  color: accent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      type == TransactionType.income
                          ? 'Total received'
                          : 'Total spent',
                      style: GoogleFonts.inter(color: tc.text40, fontSize: 11),
                    ),
                    const SizedBox(height: 3),
                    // Compact form matches the category card that opened this
                    // page; the detail sheet carries the exact figure.
                    AmountText(
                      compactMoney(actual),
                      style: GoogleFonts.manrope(
                        color: accent,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                      ),
                    ),
                  ],
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
            ],
          ),
          const SizedBox(height: 14),
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
                hasTarget ? '${compactMoney(planned)} planned' : 'No planned amount',
                style: GoogleFonts.inter(color: tc.text40, fontSize: 12),
              ),
              if (hasTarget)
                Text(
                  remaining >= 0
                      ? '${compactMoney(remaining)} left'
                      : '${compactMoney(-remaining)} over',
                  style: GoogleFonts.inter(
                    color: remaining >= 0 ? tc.text40 : tc.accentExpense,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Grouped rows ──────────────────────────────────────────────────────────────
class _EntryGroup extends StatelessWidget {
  const _EntryGroup({
    required this.entries,
    required this.categoryName,
    required this.tc,
    required this.onSelect,
  });

  final List<_CategoryEntry> entries;
  final String categoryName;
  final ThemeColors tc;
  final ValueChanged<_CategoryEntry> onSelect;

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
                ),
              ],
      ),
      child: Column(
        children: [
          for (int i = 0; i < entries.length; i++) ...[
            _EntryTile(
              entry: entries[i],
              categoryName: categoryName,
              tc: tc,
              onTap: () => onSelect(entries[i]),
            ),
            if (i < entries.length - 1)
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

// ── Transaction row ───────────────────────────────────────────────────────────
class _EntryTile extends StatelessWidget {
  const _EntryTile({
    required this.entry,
    required this.categoryName,
    required this.tc,
    required this.onTap,
  });

  final _CategoryEntry entry;
  final String categoryName;
  final ThemeColors tc;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = entry.accentColor(tc);
    final subtitle = entry.subtitle;

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(entry.icon(categoryName), color: color, size: 18),
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
                            entry.typeLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              color: tc.text100,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (entry.source == _EntrySource.card) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Card',
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
                    if (subtitle != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          color: tc.text40,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  AmountText(
                    '${entry.amountPrefix}${compactMoney(entry.amount)}',
                    style: GoogleFonts.manrope(
                      color: color,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _timeLabel(entry.date),
                    style: GoogleFonts.inter(color: tc.text40, fontSize: 11),
                  ),
                ],
              ),
              const SizedBox(width: 2),
              Icon(Icons.chevron_right_rounded, size: 16, color: tc.text20),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Per-day totals ────────────────────────────────────────────────────────────
class _DayTotals extends StatelessWidget {
  const _DayTotals({required this.entries, required this.tc});

  final List<_CategoryEntry> entries;
  final ThemeColors tc;

  @override
  Widget build(BuildContext context) {
    var moneyIn = 0.0;
    var moneyOut = 0.0;
    for (final e in entries) {
      if (e.isMoneyIn) {
        moneyIn += e.amount;
      } else {
        moneyOut += e.amount;
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
      TextSpan(
        children: [
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
        ],
      ),
    );
  }
}

// ── Row model ─────────────────────────────────────────────────────────────────
/// Table a row came from. Both tables carry `category_id`, but only card rows
/// name the card they were charged to.
enum _EntrySource { ledger, card }

class _CategoryEntry {
  const _CategoryEntry({
    required this.recordId,
    required this.amount,
    required this.type,
    required this.date,
    required this.source,
    this.cardName,
    this.note,
    this.recordedAt,
  });

  /// Id in [source]'s own table.
  final int recordId;
  final double amount;
  final TransactionType type;
  final DateTime date;
  final _EntrySource source;

  /// Card a card entry was charged to. Null when the card was deleted.
  final String? cardName;

  final String? note;

  /// Server-side creation stamp, used to order rows that share a date.
  final DateTime? recordedAt;

  bool get isMoneyIn =>
      type == TransactionType.income ||
      type == TransactionType.otherIn ||
      type == TransactionType.transferIn;

  bool get isTransfer =>
      type == TransactionType.transferIn || type == TransactionType.transferOut;

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

  /// Sign / arrow that leads the amount on a row.
  String get amountPrefix => isMoneyIn ? '+' : isTransfer ? '⇄ ' : '− ';

  /// Second line of the row: what makes this record distinct from its
  /// neighbours in the same category (the source card, or its note).
  String? get subtitle {
    final card = cardName?.trim();
    final trimmedNote = note?.trim();
    final parts = <String>[
      if (source == _EntrySource.card)
        'Card · ${(card == null || card.isEmpty) ? 'Deleted card' : card}',
      if (trimmedNote != null && trimmedNote.isNotEmpty) trimmedNote,
    ];
    return parts.isEmpty ? null : parts.join(' · ');
  }

  /// Backend reference, e.g. `TXN-42` for the ledger, `CARD-7` for a card row.
  String get reference =>
      source == _EntrySource.card ? 'CARD-$recordId' : 'TXN-$recordId';

  IconData icon(String categoryName) => source == _EntrySource.card
      ? Icons.credit_card_rounded
      : getCategoryIcon(categoryName);

  Color accentColor(ThemeColors tc) => isMoneyIn
      ? tc.coreAction
      : isTransfer
          ? tc.intelligenceAccent
          : tc.accentExpense;

  /// Expands this row into the payload of [TransactionDetailSheet].
  ///
  /// The sheet is opened read-only: edits and deletes stay on the Transactions
  /// page, which owns the flows that also reverse the category's running total.
  TransactionDetailData toDetailData({
    required ThemeColors tc,
    required String categoryName,
  }) {
    return TransactionDetailData(
      title: categoryName,
      typeLabel: typeLabel,
      amountText: '$amountPrefix${groupedMoney(amount)}',
      amountColor: accentColor(tc),
      icon: icon(categoryName),
      badge: source == _EntrySource.card ? 'Card' : null,
      note: note,
      facts: [
        TransactionFact('Type', typeLabel),
        TransactionFact('Category', categoryName),
        if (source == _EntrySource.card)
          TransactionFact('Card', cardName ?? 'Deleted card'),
        TransactionFact('Date', _fullDate(date)),
        if (recordedAt != null)
          TransactionFact('Recorded', _fullDate(recordedAt!)),
        TransactionFact('Reference', reference),
      ],
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────
/// Newest first, falling back to the creation stamp for same-day rows.
int _newestFirst(_CategoryEntry a, _CategoryEntry b) {
  final byDate = b.date.compareTo(a.date);
  if (byDate != 0) return byDate;
  return (b.recordedAt ?? b.date).compareTo(a.recordedAt ?? a.date);
}

/// Groups [entries] by calendar day, keeping their newest-first order.
Map<String, List<_CategoryEntry>> _groupByDay(List<_CategoryEntry> entries) {
  final grouped = <String, List<_CategoryEntry>>{};
  for (final e in entries) {
    grouped.putIfAbsent(_dayKey(e.date), () => <_CategoryEntry>[]).add(e);
  }
  return grouped;
}

String _dayKey(DateTime d) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(d.year, d.month, d.day);
  final diff = today.difference(day).inDays;
  if (diff == 0) return 'TODAY';
  if (diff == 1) return 'YESTERDAY';

  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${d.day} ${months[d.month - 1]} ${d.year}'.toUpperCase();
}

String _timeLabel(DateTime d) =>
    '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

/// Full timestamp used by the detail sheet, e.g. `12 November 2026 · 14:32`.
String _fullDate(DateTime d) {
  const months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];
  return '${d.day} ${months[d.month - 1]} ${d.year} · ${_timeLabel(d)}';
}

String _categoryTypeLabel(TransactionType type) {
  switch (type) {
    case TransactionType.income:
    case TransactionType.otherIn:
      return 'Income category';
    case TransactionType.transferIn:
    case TransactionType.transferOut:
      return 'Transfer category';
    case TransactionType.expense:
    case TransactionType.otherOut:
      return 'Expense category';
  }
}
