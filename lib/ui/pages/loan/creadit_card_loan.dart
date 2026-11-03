import 'package:flutter/material.dart';

import 'package:Thinkpay/core/constant/app_colors.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/utils/number_format.dart';
import '../../../model/credit_card_model.dart';
import '../../../services/creditCardService.dart';
import '../../../util/credit_card_format.dart';
import '../../component/pinned_fab.dart';
import '../finance/creditcardDetails.dart';
import 'credit_card_transactions_page.dart';

/// **Credit Card** tab of the loan section — the credit-card loan portfolio.
///
/// Every card is treated as a loan against its limit:
///  • a portfolio hero sums limit / used / available across all cards
///  • each card shows how much of its limit is used with a progress bar
///  • tapping a card opens its card-transaction history
///    ([CreditCardTransactionsPage]) — the same `creditcard_transactions` rows
///    the backend sums to build the used-credit figure, so the numbers always
///    agree
///  • ⋮ / swipe edits or deletes, + adds a card
///
/// Deliberately has no [Scaffold]: `LoanHubPage` already renders the page
/// chrome and hosts this view inside its `TabBarView`.
class CreditCardLoanView extends StatefulWidget {
  CreditCardLoanView({super.key, CreditCardService? service})
      : service = service ?? CreditCardService();

  final CreditCardService service;

  @override
  State<CreditCardLoanView> createState() => _CreditCardLoanViewState();
}

class _CreditCardLoanViewState extends State<CreditCardLoanView> {
  late Future<List<CreditCardModel>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.service.fetchCards();
  }

  Future<void> _reload() async {
    final future = widget.service.fetchCards();
    if (!mounted) return;
    setState(() => _future = future);
    // Swallowed on purpose: the body renders the error state.
    try {
      await future;
    } catch (_) {}
  }

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _openAdd() async {
    final created = await Navigator.of(context).push<CreditCardModel>(
      MaterialPageRoute<CreditCardModel>(
        builder: (_) => AddCreditCardScreen(service: widget.service),
      ),
    );
    if (created == null) return;
    await _reload();
    _toast('${created.name} added');
  }

  Future<void> _openEdit(CreditCardModel card) async {
    final updated = await Navigator.of(context).push<CreditCardModel>(
      MaterialPageRoute<CreditCardModel>(
        builder: (_) => AddCreditCardScreen(service: widget.service, initial: card),
      ),
    );
    if (updated == null) return;
    await _reload();
    _toast('${updated.name} updated');
  }

  Future<void> _confirmDelete(CreditCardModel card) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => _DeleteCardDialog(cardName: card.name),
    );
    if (confirmed != true) return;

    try {
      await widget.service.deleteCard(card.id);
      await _reload();
      _toast('${card.name} deleted');
    } catch (e) {
      _toast(e is ApiException
          ? e.message
          : 'Could not delete the card. Please try again.');
    }
  }

  /// Opens the ledger of everything spent with this card. The card is refetched
  /// afterwards because spending may have changed while the page was open.
  Future<void> _openHistory(CreditCardModel card) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CreditCardTransactionsPage(card: card),
      ),
    );
    await _reload();
  }

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);

    return Stack(
      fit: StackFit.expand,
      children: [
        RefreshIndicator(
          onRefresh: _reload,
          color: tc.coreAction,
          backgroundColor: tc.surface,
          child: FutureBuilder<List<CreditCardModel>>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return _ErrorState(onRetry: _reload);
              }

              final cards = snapshot.data ?? const <CreditCardModel>[];
              if (cards.isEmpty) return _EmptyState(onAdd: _openAdd);

              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 120),
                children: [
                  _PortfolioHero(cards: cards),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Text(
                        'Credit Card Loans',
                        style: AppTypography.bodyMd.copyWith(
                          color: tc.text100,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${cards.length}',
                        style: AppTypography.bodySm.copyWith(
                          color: tc.text40,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  for (final card in cards)
                    _SwipeToDelete(
                      card: card,
                      onDelete: () => _confirmDelete(card),
                      child: _CreditCardLoanTile(
                        card: card,
                        onTap: () => _openHistory(card),
                        onEdit: () => _openEdit(card),
                        onDelete: () => _confirmDelete(card),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
        PinnedFab(
          heroTag: 'fab_credit_card_loan',
          icon: Icons.add_rounded,
          label: 'Add card',
          onPressed: _openAdd,
        ),
      ],
    );
  }
}

// ── Portfolio hero ────────────────────────────────────────────────────────────
/// Aggregates every card into one limit / used / available snapshot.
class _PortfolioHero extends StatelessWidget {
  const _PortfolioHero({required this.cards});

  final List<CreditCardModel> cards;

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);

    final limit = cards.fold<double>(0, (sum, c) => sum + c.creditLimit);
    final used = cards.fold<double>(0, (sum, c) => sum + c.outstanding);
    final available = cards.fold<double>(0, (sum, c) => sum + c.availableCredit);
    final utilisation = limit <= 0 ? 0.0 : (used / limit).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.marginMobile),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [tc.cardGradientStart, tc.cardGradientEnd],
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: tc.border, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TOTAL CREDIT USED',
            style: AppTypography.labelCaps.copyWith(
              color: tc.text40,
              fontSize: 9,
            ),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              fmtCardMoney(used),
              style: AppTypography.headlineLgMobile.copyWith(
                color: tc.text100,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'of ${fmtCardMoney(limit)} across ${cards.length} '
            '${cards.length == 1 ? 'card' : 'cards'}',
            style: AppTypography.bodySm.copyWith(
              color: tc.text40,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: utilisation,
              minHeight: 8,
              backgroundColor: tc.text10,
              valueColor: AlwaysStoppedAnimation(
                creditUtilisationColor(tc, utilisation),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _MiniStat(
                label: 'Used',
                value: fmtCardMoney(used),
                color: tc.accentExpense,
              ),
              const SizedBox(width: AppSpacing.md),
              _MiniStat(
                label: 'Available',
                value: fmtCardMoney(available),
                color: tc.intelligenceAccent,
              ),
              const SizedBox(width: AppSpacing.md),
              _MiniStat(
                label: 'Utilisation',
                value: percentNumber(utilisation * 100, decimals: 0),
                color: tc.text70,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.label,
    required this.value,
    required this.color,
  });

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
            style: AppTypography.bodySm.copyWith(color: tc.text40, fontSize: 10),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: AppTypography.bodySm.copyWith(
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

// ── Card tile ─────────────────────────────────────────────────────────────────
/// One credit card read as a loan: limit, used credit and the progress bar
/// between them. Tapping the tile opens the card's transaction history.
class _CreditCardLoanTile extends StatelessWidget {
  const _CreditCardLoanTile({
    required this.card,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final CreditCardModel card;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bar = creditUtilisationColor(tc, card.utilisation);

    return Semantics(
      button: true,
      label: '${card.name}. Limit ${fmtCardMoney(card.creditLimit)}. '
          'Used ${fmtCardMoney(card.outstanding)}. '
          'Available ${fmtCardMoney(card.availableCredit)}.',
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        decoration: BoxDecoration(
          color: tc.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
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
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.marginMobile,
                14,
                6,
                14,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 30,
                        height: 22,
                        decoration: BoxDecoration(
                          color: tc.intelligenceAccent.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            color: tc.intelligenceAccent.withValues(alpha: 0.35),
                            width: 0.8,
                          ),
                        ),
                        child: Icon(
                          Icons.credit_card_rounded,
                          size: 13,
                          color: tc.intelligenceAccent,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          card.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.bodyMd.copyWith(
                            color: tc.text100,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      PopupMenuButton<_CardAction>(
                        tooltip: 'Card options',
                        color: tc.surface,
                        elevation: 8,
                        padding: EdgeInsets.zero,
                        iconSize: 20,
                        icon: Icon(Icons.more_vert_rounded, color: tc.text40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          side: BorderSide(color: tc.border, width: 0.8),
                        ),
                        onSelected: (action) {
                          switch (action) {
                            case _CardAction.edit:
                              onEdit();
                            case _CardAction.delete:
                              onDelete();
                          }
                        },
                        itemBuilder: (_) => [
                          PopupMenuItem(
                            value: _CardAction.edit,
                            height: 42,
                            child: Row(
                              children: [
                                Icon(Icons.edit_outlined,
                                    size: 16, color: tc.text70),
                                const SizedBox(width: 10),
                                Text(
                                  'Edit card',
                                  style: AppTypography.bodySm
                                      .copyWith(color: tc.text100),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: _CardAction.delete,
                            height: 42,
                            child: Row(
                              children: [
                                Icon(Icons.delete_outline_rounded,
                                    size: 16, color: tc.accentExpense),
                                const SizedBox(width: 10),
                                Text(
                                  'Delete card',
                                  style: AppTypography.bodySm
                                      .copyWith(color: tc.accentExpense),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Used vs limit, with the bar carrying the alarm colour.
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'USED',
                              style: AppTypography.labelCaps.copyWith(
                                color: tc.text40,
                                fontSize: 9,
                              ),
                            ),
                            const SizedBox(height: 2),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                fmtCardMoney(card.outstanding),
                                style: AppTypography.bodyMd.copyWith(
                                  color: tc.text100,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.md),
                        child: Text(
                          '${percentNumber(card.utilisation * 100, decimals: 0)} '
                          'of ${fmtCardMoney(card.creditLimit)}',
                          style: AppTypography.bodySm
                              .copyWith(color: tc.text40, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.md),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: card.utilisation,
                        minHeight: 6,
                        backgroundColor: tc.text10,
                        valueColor: AlwaysStoppedAnimation(bar),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.md),
                    child: Row(
                      children: [
                        Icon(
                          Icons.account_balance_wallet_outlined,
                          size: 12,
                          color: tc.intelligenceAccent,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${fmtCardMoney(card.availableCredit)} available',
                          style: AppTypography.bodySm
                              .copyWith(color: tc.text70, fontSize: 11),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 12,
                          color: tc.text40,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'History',
                          style: AppTypography.bodySm
                              .copyWith(color: tc.text40, fontSize: 11),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          size: 16,
                          color: tc.text40,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum _CardAction { edit, delete }

// ── Swipe-to-delete wrapper ───────────────────────────────────────────────────
class _SwipeToDelete extends StatelessWidget {
  const _SwipeToDelete({
    required this.card,
    required this.onDelete,
    required this.child,
  });

  final CreditCardModel card;
  final VoidCallback onDelete;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);

    return Dismissible(
      key: ValueKey('credit_card_loan_${card.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: tc.accentExpense.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: tc.accentExpense.withValues(alpha: 0.3),
            width: 0.8,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_outline_rounded,
                color: tc.accentExpense, size: 22),
            const SizedBox(height: 4),
            Text(
              'Delete',
              style: AppTypography.bodySm.copyWith(
                color: tc.accentExpense,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      confirmDismiss: (_) async {
        onDelete();
        // _confirmDelete owns the dialog and the refresh, so never dismiss
        // optimistically.
        return false;
      },
      child: child,
    );
  }
}

// ── Delete dialog ─────────────────────────────────────────────────────────────
class _DeleteCardDialog extends StatelessWidget {
  const _DeleteCardDialog({required this.cardName});

  final String cardName;

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);

    return AlertDialog(
      backgroundColor: tc.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        'Delete card?',
        style: AppTypography.bodyMd.copyWith(
          color: tc.text100,
          fontWeight: FontWeight.w700,
        ),
      ),
      content: Text(
        'Delete "$cardName"? Card transactions already recorded with it are '
        'kept, but they will no longer be linked to a card.',
        style: AppTypography.bodySm.copyWith(color: tc.text70, height: 1.5),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.pop(context, false),
          style: OutlinedButton.styleFrom(
            foregroundColor: tc.text70,
            side: BorderSide(color: tc.border),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: tc.accentExpense,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text('Delete'),
        ),
      ],
    );
  }
}

// ── States ────────────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 32),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.1),
        Icon(Icons.credit_card_off_outlined, size: 54, color: tc.text20),
        const SizedBox(height: 16),
        Center(
          child: Text(
            'No credit cards yet',
            style: AppTypography.bodyMd.copyWith(
              color: tc.text100,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Center(
          child: Text(
            'Add a card to track how much of its limit is used and see every '
            'transaction paid with it.',
            textAlign: TextAlign.center,
            style: AppTypography.bodySm.copyWith(color: tc.text40),
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Add card'),
            style: ElevatedButton.styleFrom(
              backgroundColor: tc.coreAction,
              foregroundColor: tc.background,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
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
      padding: const EdgeInsets.symmetric(horizontal: 32),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.1),
        Icon(Icons.error_outline_rounded, size: 48, color: tc.accentExpense),
        const SizedBox(height: 16),
        Center(
          child: Text(
            'Could not load credit cards',
            style: AppTypography.bodyMd.copyWith(
              color: tc.text100,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Center(
          child: Text(
            'Check your connection and try again.',
            textAlign: TextAlign.center,
            style: AppTypography.bodySm.copyWith(color: tc.text40),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: OutlinedButton(
            onPressed: () => onRetry(),
            style: OutlinedButton.styleFrom(
              foregroundColor: tc.coreAction,
              side: BorderSide(color: tc.coreAction.withValues(alpha: 0.4)),
            ),
            child: const Text('Retry'),
          ),
        ),
      ],
    );
  }
}
