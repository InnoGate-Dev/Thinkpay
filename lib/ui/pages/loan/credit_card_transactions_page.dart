import 'package:flutter/material.dart';

import '../../../core/constant/app_colors.dart';
import '../../../core/repository/categoryRepo.dart';
import '../../../core/repository/creditCardTransactionRepo.dart';
import '../../../core/utils/number_format.dart';
import '../../../model/categoryModel.dart';
import '../../../model/credit_card_model.dart';
import '../../../model/credit_card_transaction_model.dart';
import '../../../model/transaction_model.dart';
import '../../../util/credit_card_format.dart';

/// Full-screen history of every entry charged to one credit card.
///
/// Rows come from `GET /credit-cards/{id}/transactions`, which lists
/// `creditcard_transactions` — the same rows the backend sums to build the
/// card's used-credit figure, so the list and the progress bar always agree.
class CreditCardTransactionsPage extends StatefulWidget {
  const CreditCardTransactionsPage({super.key, required this.card});

  final CreditCardModel card;

  @override
  State<CreditCardTransactionsPage> createState() =>
      _CreditCardTransactionsPageState();
}

class _CreditCardTransactionsPageState extends State<CreditCardTransactionsPage> {
  final _cardTxRepo = CreditCardTransactionRepository();
  final _categoryRepo = CategoryRepository();

  late Future<_CardHistoryData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_CardHistoryData> _load() async {
    final results = await Future.wait([
      _cardTxRepo.getCardTransactionsByCard(widget.card.id),
      _categoryRepo.getCategories(),
    ]);

    final rows = results[0] as List<CreditCardTransactionModel>;
    final categories = results[1] as List<Category>;

    // The API only carries `category_id`, so resolve the display names here.
    final names = <int, String>{
      for (final c in categories)
        if (c.name.trim().isNotEmpty) c.id: c.name.trim(),
    };

    final models = [
      for (final row in rows)
        row.toLocalModel(fallbackCategory: names[row.categoryId]),
    ];

    return _CardHistoryData(
      transactions: models,
      spent: models
          .where((t) => t.type == TransactionType.expense)
          .fold<double>(0, (sum, t) => sum + t.amount),
      refunded: models
          .where((t) => t.type != TransactionType.expense)
          .fold<double>(0, (sum, t) => sum + t.amount),
    );
  }

  Future<void> _refresh() async {
    final future = _load();
    setState(() => _future = future);
    try {
      await future;
    } catch (_) {
      // The body renders the error state.
    }
  }

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);

    return Scaffold(
      backgroundColor: tc.background,
      appBar: AppBar(
        backgroundColor: tc.background,
        surfaceTintColor: Colors.transparent,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.card.name,
              style: AppTypography.bodyMd.copyWith(
                color: tc.text100,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'Card transactions',
              style: AppTypography.bodySm.copyWith(
                color: tc.text40,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: _refresh,
          color: tc.coreAction,
          child: FutureBuilder<_CardHistoryData>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return _ErrorState(onRetry: _refresh);
              }

              final data = snapshot.data ?? const _CardHistoryData.empty();

              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                children: [
                  _LimitHeader(card: widget.card),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Text(
                        'Transactions',
                        style: AppTypography.bodyMd.copyWith(
                          color: tc.text100,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      if (data.transactions.isNotEmpty)
                        Text(
                          '${data.transactions.length}',
                          style: AppTypography.bodySm.copyWith(
                            color: tc.text40,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (data.transactions.isEmpty)
                    _EmptyState(tc: tc)
                  else
                    for (final tx in data.transactions)
                      _TransactionTile(transaction: tx, tc: tc),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Everything the history screen renders for one card.
class _CardHistoryData {
  const _CardHistoryData({
    required this.transactions,
    required this.spent,
    required this.refunded,
  });

  const _CardHistoryData.empty()
      : transactions = const [],
        spent = 0,
        refunded = 0;

  final List<TransactionModel> transactions;
  final double spent;
  final double refunded;
}

// ── Limit header ──────────────────────────────────────────────────────────────
/// Same limit / used / available trio and progress bar as the card tile in the
/// loan section, so the numbers stay recognisable after the tap.
class _LimitHeader extends StatelessWidget {
  const _LimitHeader({required this.card});

  final CreditCardModel card;

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.marginMobile),
      decoration: BoxDecoration(
        color: tc.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: tc.border, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _Stat(
                label: 'LIMIT',
                value: fmtCardMoney(card.creditLimit),
                color: tc.text100,
              ),
              const SizedBox(width: AppSpacing.md),
              _Stat(
                label: 'USED',
                value: fmtCardMoney(card.outstanding),
                color: tc.accentExpense,
              ),
              const SizedBox(width: AppSpacing.md),
              _Stat(
                label: 'AVAILABLE',
                value: fmtCardMoney(card.availableCredit),
                color: tc.intelligenceAccent,
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: card.utilisation,
              minHeight: 6,
              backgroundColor: tc.text10,
              valueColor: AlwaysStoppedAnimation(
                creditUtilisationColor(tc, card.utilisation),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${percentNumber(card.utilisation * 100, decimals: 0)} of your limit used',
            style: AppTypography.bodySm.copyWith(color: tc.text40, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, required this.color});

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.labelCaps.copyWith(
              color: tc.text40,
              fontSize: 9,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: AppTypography.bodyMd.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Row ───────────────────────────────────────────────────────────────────────
class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.transaction, required this.tc});

  final TransactionModel transaction;
  final ThemeColors tc;

  @override
  Widget build(BuildContext context) {
    final isExpense = transaction.type == TransactionType.expense;
    final amount = isExpense ? -transaction.amount : transaction.amount;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.marginMobile,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: tc.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: tc.border, width: 0.8),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: (isExpense ? tc.accentExpense : tc.intelligenceAccent)
                  .withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.base),
            ),
            child: Icon(
              isExpense
                  ? Icons.arrow_upward_rounded
                  : Icons.arrow_downward_rounded,
              size: 16,
              color: isExpense ? tc.accentExpense : tc.intelligenceAccent,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.category,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodySm.copyWith(
                    color: tc.text100,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${fmtShortDate(transaction.date)}, ${transaction.date.year}',
                  style: AppTypography.bodySm.copyWith(
                    color: tc.text40,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.base),
          Text(
            groupedMoney(amount),
            style: AppTypography.bodySm.copyWith(
              color: isExpense ? tc.text100 : tc.intelligenceAccent,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ── States ────────────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.tc});

  final ThemeColors tc;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg, horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: tc.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: tc.border, width: 0.8),
      ),
      child: Column(
        children: [
          Icon(Icons.receipt_long_outlined, size: 28, color: tc.text40),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'No transactions on this card yet',
            style: AppTypography.bodySm.copyWith(
              color: tc.text100,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Pick this card as “Paid with” when you add an expense.',
            textAlign: TextAlign.center,
            style: AppTypography.bodySm.copyWith(color: tc.text40, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});

  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.marginMobile),
      children: [
        const SizedBox(height: AppSpacing.lg),
        Icon(Icons.cloud_off_rounded, size: 34, color: tc.text40),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Could not load this card’s transactions.',
          textAlign: TextAlign.center,
          style: AppTypography.bodySm.copyWith(color: tc.text70),
        ),
        const SizedBox(height: AppSpacing.sm),
        Center(
          child: TextButton(
            onPressed: onRetry,
            child: const Text('Try again'),
          ),
        ),
      ],
    );
  }
}
