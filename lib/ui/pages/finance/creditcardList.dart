import 'package:flutter/material.dart';
import 'package:Thinkpay/core/constant/app_colors.dart';

import '../../../core/errors/exceptions.dart';
import '../../../model/credit_card_model.dart';
import '../../../services/creditCardService.dart';
import '../../../util/credit_card_format.dart';
import 'creditcardDetails.dart';

// ── Screen ────────────────────────────────────────────────────────────────────
/// Lists the user's saved credit cards.
///   • tap a card        → read-only details sheet
///   • ⋮ menu / sheet    → edit or delete
///   • + button          → add a new card
///
/// Cards are loaded from `GET /credit-cards`. Adding, editing and deleting hit
/// the matching endpoints and reload the list on success.
class CreditCardListScreen extends StatefulWidget {
  CreditCardListScreen({super.key, CreditCardService? service})
      : service = service ?? CreditCardService();

  final CreditCardService service;

  @override
  State<CreditCardListScreen> createState() => _CreditCardListScreenState();
}

class _CreditCardListScreenState extends State<CreditCardListScreen> {
  late Future<List<CreditCardModel>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.service.fetchCards();
  }

  Future<void> _reload() async {
    final future = widget.service.fetchCards();
    if (!mounted) return;
    setState(() {
      _future = future;
    });
    // Swallowed here on purpose: the FutureBuilder renders the error state.
    try {
      await future;
    } catch (_) {}
  }

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
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
        builder: (_) => AddCreditCardScreen(
          service: widget.service,
          initial: card,
        ),
      ),
    );
    if (updated == null) return;
    await _reload();
    _toast('${updated.name} updated');
  }

  Future<void> _confirmDelete(CreditCardModel card) async {
    final c = ThemeColors.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete card?'),
        content: Text(
          '"${card.name}" will be removed. This can\'t be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: c.red),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
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

  void _showDetails(CreditCardModel card) {
    final c = ThemeColors.of(context);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: c.surface,
      shape: const RoundedRectangleBorder(
        borderRadius:
        BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (sheetContext) => _CardDetailsSheet(
        card: card,
        onEdit: () {
          Navigator.of(sheetContext).pop();
          _openEdit(card);
        },
        onDelete: () {
          Navigator.of(sheetContext).pop();
          _confirmDelete(card);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = ThemeColors.of(context);

    return FutureBuilder<List<CreditCardModel>>(
      future: _future,
      builder: (context, snapshot) {
        final cards = snapshot.data ?? const <CreditCardModel>[];
        final showFab =
            snapshot.connectionState == ConnectionState.done && cards.isNotEmpty;

        return Scaffold(
          appBar: AppBar(title: const Text('My credit cards')),
          floatingActionButton: showFab
              ? FloatingActionButton.extended(
                  onPressed: _openAdd,
                  backgroundColor: c.accent,
                  foregroundColor: c.onAccent,
                  icon: const Icon(Icons.add),
                  label: Text(
                    'Add card',
                    style: AppTypography.bodyMd
                        .copyWith(fontWeight: FontWeight.w700),
                  ),
                )
              : null,
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: _reload,
              color: c.accent,
              child: _buildBody(c, snapshot, cards),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(
    ThemeColors c,
    AsyncSnapshot<List<CreditCardModel>> snapshot,
    List<CreditCardModel> cards,
  ) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return Center(
        child: CircularProgressIndicator(color: c.accent),
      );
    }
    if (snapshot.hasError) {
      return _ErrorState(onRetry: _reload);
    }
    if (cards.isEmpty) {
      return _EmptyState(onAdd: _openAdd);
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.marginMobile,
        AppSpacing.base,
        AppSpacing.marginMobile,
        96, // room for the floating button
      ),
      itemCount: cards.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, i) {
        final card = cards[i];
        return _CardTile(
          card: card,
          onTap: () => _showDetails(card),
          onEdit: () => _openEdit(card),
          onDelete: () => _confirmDelete(card),
        );
      },
    );
  }
}

// ── List tile ─────────────────────────────────────────────────────────────────
enum _TileAction { edit, delete }

class _CardTile extends StatelessWidget {
  const _CardTile({
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
    final c = ThemeColors.of(context);

    return Material(
      color: c.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        side: BorderSide(color: c.border),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.md, AppSpacing.sm, AppSpacing.base, AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration:
                    BoxDecoration(color: c.accentDim, shape: BoxShape.circle),
                    child: Icon(Icons.credit_card, size: 20, color: c.text100),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      card.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.headlineMd
                          .copyWith(color: c.text100),
                    ),
                  ),
                  PopupMenuButton<_TileAction>(
                    tooltip: 'More',
                    icon: Icon(Icons.more_vert, color: c.text70),
                    onSelected: (a) {
                      switch (a) {
                        case _TileAction.edit:
                          onEdit();
                        case _TileAction.delete:
                          onDelete();
                      }
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                        value: _TileAction.edit,
                        child: Text('Edit'),
                      ),
                      PopupMenuItem(
                        value: _TileAction.delete,
                        child: Text('Delete', style: TextStyle(color: c.red)),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text('CARD LIMIT',
                  style: AppTypography.labelCaps.copyWith(color: c.text40)),
              const SizedBox(height: AppSpacing.xs),
              Text(
                fmtCardMoney(card.creditLimit),
                style: AppTypography.headlineLgMobile
                    .copyWith(color: c.text100),
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.base,
                runSpacing: AppSpacing.base,
                children: [
                  _InfoChip(
                    icon: Icons.percent,
                    text: '${fmtApr(card.apr)}% p.a.',
                  ),
                  _InfoChip(
                    icon: Icons.event_outlined,
                    text: 'Closes ${ordinalDay(card.statementDay)}',
                  ),
                  _InfoChip(
                    icon: Icons.schedule,
                    text: '${card.graceDays} day grace',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final c = ThemeColors.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm, vertical: AppSpacing.xs + 2),
      decoration: BoxDecoration(
        color: c.surface2,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: c.text70),
          const SizedBox(width: AppSpacing.xs),
          Text(text, style: AppTypography.bodySm.copyWith(color: c.text100)),
        ],
      ),
    );
  }
}

// ── Read-only details sheet ───────────────────────────────────────────────────
class _CardDetailsSheet extends StatelessWidget {
  const _CardDetailsSheet({
    required this.card,
    required this.onEdit,
    required this.onDelete,
  });

  final CreditCardModel card;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final c = ThemeColors.of(context);

    final nextClose = card.nextCloseDate();
    final due = card.nextDueDate();

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.marginMobile,
            AppSpacing.md, AppSpacing.marginMobile, AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(card.name,
                style: AppTypography.headlineMd.copyWith(color: c.text100)),
            const SizedBox(height: AppSpacing.sm),
            _DetailRow(
                label: 'Card limit', value: fmtCardMoney(card.creditLimit)),
            _DetailRow(
                label: 'Interest rate',
                value: '${fmtApr(card.apr)}% per year'),
            _DetailRow(
                label: 'Statement closes',
                value: '${ordinalDay(card.statementDay)} of every month'),
            _DetailRow(
                label: 'Grace period', value: '${card.graceDays} days'),
            Divider(color: c.divider, height: AppSpacing.md * 2),
            _DetailRow(
                label: 'Next statement closes',
                value: fmtShortDate(nextClose)),
            _DetailRow(
                label: 'Payment due for that statement',
                value: fmtShortDate(due)),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text('Edit'),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: c.red,
                      side: BorderSide(color: c.red, width: 1.5),
                    ),
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text('Delete'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final c = ThemeColors.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs + 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Text(label,
                style: AppTypography.bodySm.copyWith(color: c.text70)),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            flex: 4,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: AppTypography.bodyMd.copyWith(
                  color: c.text100, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final c = ThemeColors.of(context);

    // A ListView (not Center) so pull-to-refresh still works when empty.
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.12),
        Center(
          child: Container(
            width: 72,
            height: 72,
            decoration:
            BoxDecoration(color: c.accentDim, shape: BoxShape.circle),
            child: Icon(Icons.credit_card, size: 32, color: c.text100),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Center(
          child: Text('No credit cards yet',
              style: AppTypography.headlineMd.copyWith(color: c.text100)),
        ),
        const SizedBox(height: AppSpacing.base),
        Center(
          child: Text(
            'Add a card to track your limit, due dates and payments.',
            textAlign: TextAlign.center,
            style: AppTypography.bodySm.copyWith(color: c.text70),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Center(
          child: ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: const Text('Add credit card'),
          ),
        ),
      ],
    );
  }
}

// ── Error state ───────────────────────────────────────────────────────────────
class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});

  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final c = ThemeColors.of(context);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.12),
        Icon(Icons.error_outline, size: 48, color: c.red),
        const SizedBox(height: AppSpacing.md),
        Center(
          child: Text('Could not load your cards',
              style: AppTypography.headlineMd.copyWith(color: c.text100)),
        ),
        const SizedBox(height: AppSpacing.base),
        Center(
          child: Text(
            'Check your connection and try again.',
            textAlign: TextAlign.center,
            style: AppTypography.bodySm.copyWith(color: c.text70),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Center(
          child: OutlinedButton(
            onPressed: () => onRetry(),
            child: const Text('Retry'),
          ),
        ),
      ],
    );
  }
}
