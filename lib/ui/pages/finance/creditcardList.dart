import 'package:flutter/material.dart';

// Adjust these imports to your project structure.
import 'package:Thinkpay/core/constant/app_colors.dart';

import 'creditcardDetails.dart';
// ── Formatting helpers ────────────────────────────────────────────────────────
String _money(double v) {
  final fixed =
  v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2);
  final parts = fixed.split('.');
  final whole = parts[0]
      .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');
  return 'Rs. ${parts.length > 1 ? '$whole.${parts[1]}' : whole}';
}

String _percent(double v) =>
    v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();

String _ordinal(int n) {
  if (n >= 11 && n <= 13) return '${n}th';
  switch (n % 10) {
    case 1:
      return '${n}st';
    case 2:
      return '${n}nd';
    case 3:
      return '${n}rd';
    default:
      return '${n}th';
  }
}

// ── Screen ────────────────────────────────────────────────────────────────────
/// Lists the user's saved credit cards.
///   • tap a card        → read-only details sheet
///   • ⋮ menu / sheet    → edit or delete
///   • + button          → add a new card
///
/// The screen holds no state itself. Keep the list in your own state
/// management (setState, Provider, Riverpod, Bloc...) and update it inside
/// [onAdd], [onEdit] and [onDelete].
class CreditCardListScreen extends StatefulWidget {
  const CreditCardListScreen({
    super.key,
    this.cards,
    this.onAdd,
    this.onEdit,
    this.onDelete,
  });

  final List<CreditCardDetails>? cards;

  /// New card from the form (id is null: assign one when you save it).
  final ValueChanged<CreditCardDetails>? onAdd;

  /// Edited card. It has the same id as the original.
  final ValueChanged<CreditCardDetails>? onEdit;

  /// Called after the user confirms deletion.
  final ValueChanged<CreditCardDetails>? onDelete;

  @override
  State<CreditCardListScreen> createState() => _CreditCardListScreenState();
}

class _CreditCardListScreenState extends State<CreditCardListScreen> {
  late List<CreditCardDetails> _cards;

  @override
  void initState() {
    super.initState();
    _cards = List.from(widget.cards ?? []);
  }

  @override
  void didUpdateWidget(covariant CreditCardListScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.cards != null) {
      _cards = List.from(widget.cards!);
    }
  }

  void _openAdd(BuildContext context) async {
    final newCard = await Navigator.of(context).push<CreditCardDetails>(
      MaterialPageRoute<CreditCardDetails>(
        builder: (_) => AddCreditCardScreen(onSave: widget.onAdd),
      ),
    );
    if (newCard != null) {
      widget.onAdd?.call(newCard);
      setState(() {
        _cards.add(newCard);
      });
    }
  }

  void _openEdit(BuildContext context, CreditCardDetails card) async {
    final updatedCard = await Navigator.of(context).push<CreditCardDetails>(
      MaterialPageRoute<CreditCardDetails>(
        builder: (_) => _EditCreditCardScreen(card: card, onSave: widget.onEdit),
      ),
    );
    if (updatedCard != null) {
      widget.onEdit?.call(updatedCard);
      setState(() {
        final index = _cards.indexOf(card);
        if (index != -1) {
          _cards[index] = updatedCard;
        }
      });
    }
  }

  Future<void> _confirmDelete(
      BuildContext context, CreditCardDetails card) async {
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
    widget.onDelete?.call(card);
    setState(() {
      _cards.remove(card);
    });

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${card.name} deleted')),
      );
    }
  }

  void _showDetails(BuildContext context, CreditCardDetails card) {
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
          _openEdit(context, card);
        },
        onDelete: () {
          Navigator.of(sheetContext).pop();
          _confirmDelete(context, card);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = ThemeColors.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('My credit cards')),
      floatingActionButton: _cards.isEmpty
          ? null
          : FloatingActionButton.extended(
        onPressed: () => _openAdd(context),
        backgroundColor: c.accent,
        foregroundColor: c.onAccent,
        icon: const Icon(Icons.add),
        label: Text(
          'Add card',
          style: AppTypography.bodyMd
              .copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: _cards.isEmpty
            ? _EmptyState(onAdd: () => _openAdd(context))
            : ListView.separated(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.marginMobile,
            AppSpacing.base,
            AppSpacing.marginMobile,
            96, // room for the floating button
          ),
          itemCount: _cards.length,
          separatorBuilder: (_, _) =>
          const SizedBox(height: AppSpacing.sm),
          itemBuilder: (context, i) {
            final card = _cards[i];
            return _CardTile(
              card: card,
              onTap: () => _showDetails(context, card),
              onEdit: () => _openEdit(context, card),
              onDelete: () => _confirmDelete(context, card),
            );
          },
        ),
      ),
    );
  }
}

// ── Edit screen (reuses the add form) ─────────────────────────────────────────
class _EditCreditCardScreen extends StatelessWidget {
  const _EditCreditCardScreen({required this.card, this.onSave});

  final CreditCardDetails card;
  final ValueChanged<CreditCardDetails>? onSave;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit credit card')),
      body: SafeArea(
        child: AddCreditCardForm(
          initial: card,
          submitLabel: 'Save changes',
          onSubmit: (updated) {
            onSave?.call(updated);
            Navigator.of(context).maybePop(updated);
          },
        ),
      ),
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

  final CreditCardDetails card;
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
                _money(card.creditLimit),
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
                    text: '${_percent(card.apr)}% p.a.',
                  ),
                  _InfoChip(
                    icon: Icons.event_outlined,
                    text: 'Closes ${_ordinal(card.statementDay)}',
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

  final CreditCardDetails card;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final c = ThemeColors.of(context);

    final nextClose = nextStatementClose(card.statementDay, DateTime.now());
    final due = nextClose.add(Duration(days: card.graceDays));

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
            _DetailRow(label: 'Card limit', value: _money(card.creditLimit)),
            _DetailRow(
                label: 'Interest rate', value: '${_percent(card.apr)}% per year'),
            _DetailRow(
                label: 'Statement closes',
                value: '${_ordinal(card.statementDay)} of every month'),
            _DetailRow(
                label: 'Grace period', value: '${card.graceDays} days'),
            Divider(color: c.divider, height: AppSpacing.md * 2),
            _DetailRow(
                label: 'Next statement closes',
                value: formatShortDate(nextClose)),
            _DetailRow(
                label: 'Payment due for that statement',
                value: formatShortDate(due)),
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

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration:
              BoxDecoration(color: c.accentDim, shape: BoxShape.circle),
              child: Icon(Icons.credit_card, size: 32, color: c.text100),
            ),
            const SizedBox(height: AppSpacing.md),
            Text('No credit cards yet',
                style: AppTypography.headlineMd.copyWith(color: c.text100)),
            const SizedBox(height: AppSpacing.base),
            Text(
              'Add a card to track your limit, due dates and payments.',
              textAlign: TextAlign.center,
              style: AppTypography.bodySm.copyWith(color: c.text70),
            ),
            const SizedBox(height: AppSpacing.md),
            ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Add credit card'),
            ),
          ],
        ),
      ),
    );
  }
}