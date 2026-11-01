import 'package:flutter/material.dart';
import 'package:Thinkpay/core/constant/app_colors.dart';

import '../../../core/errors/exceptions.dart';
import '../../../model/credit_card_model.dart';
import '../../../services/creditCardService.dart';
import '../../../util/credit_card_format.dart';
import '../../component/pinned_fab.dart';
import 'creditcardDetails.dart';

// ── Route wrapper ─────────────────────────────────────────────────────────────
/// Full-screen host for [CreditCardListView], used by the `/credit-card-list`
/// route and by the finance dashboard.
class CreditCardListScreen extends StatelessWidget {
  const CreditCardListScreen({super.key, this.service});

  final CreditCardService? service;

  @override
  Widget build(BuildContext context) {
    final c = ThemeColors.of(context);

    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        bottom: false,
        child: CreditCardListView(
          service: service,
          onBack: () => Navigator.of(context).maybePop(),
        ),
      ),
    );
  }
}

// ── View ──────────────────────────────────────────────────────────────────────
/// Lists the user's saved credit cards with a portfolio snapshot on top.
///   • tap a card        → read-only details sheet
///   • ⋮ menu / swipe    → edit or delete
///   • + button          → add a new card
///
/// Cards are loaded from `GET /credit-cards`. Adding, editing and deleting hit
/// the matching endpoints and reload the list on success.
///
/// Deliberately has no [Scaffold]: the same view is hosted by a route
/// ([CreditCardListScreen]) and embedded in the loan section's Credit Card tab.
class CreditCardListView extends StatefulWidget {
  CreditCardListView({
    super.key,
    CreditCardService? service,
    this.showHeader = true,
    this.onBack,
  }) : service = service ?? CreditCardService();

  final CreditCardService service;

  /// Renders the in-view title row above the list. Turn it off when the host
  /// page already provides a title.
  final bool showHeader;

  /// Back button handler. Defaults to popping the enclosing route.
  final VoidCallback? onBack;

  @override
  State<CreditCardListView> createState() => _CreditCardListViewState();
}

class _CreditCardListViewState extends State<CreditCardListView> {
  late Future<List<CreditCardModel>> _future;
  _SortMode _sort = _SortMode.dueSoon;

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
    // Swallowed here on purpose: the body renders the error state.
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

  void _showDetails(CreditCardModel card) {
    final c = ThemeColors.of(context);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: c.surface,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      clipBehavior: Clip.antiAlias,
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

  /// Soonest payment first, or largest limit first.
  List<CreditCardModel> _sorted(List<CreditCardModel> cards) {
    final list = [...cards];
    switch (_sort) {
      case _SortMode.dueSoon:
        list.sort((a, b) => a.nextDueDate().compareTo(b.nextDueDate()));
      case _SortMode.limit:
        list.sort((a, b) => b.creditLimit.compareTo(a.creditLimit));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final c = ThemeColors.of(context);

    return FutureBuilder<List<CreditCardModel>>(
      future: _future,
      builder: (context, snapshot) {
        final cards = snapshot.data ?? const <CreditCardModel>[];
        final hasCards =
            snapshot.connectionState == ConnectionState.done && cards.isNotEmpty;

        return Stack(
          fit: StackFit.expand,
          children: [
            Column(
              children: [
                if (widget.showHeader)
                  _Header(
                    onBack: widget.onBack ?? () => Navigator.of(context).maybePop(),
                  ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _reload,
                    color: c.coreAction,
                    backgroundColor: c.surface,
                    child: _buildBody(c, snapshot, cards),
                  ),
                ),
              ],
            ),
            if (hasCards)
              PinnedFab(
                heroTag: 'fab_add_card',
                icon: Icons.add_rounded,
                label: 'Add card',
                onPressed: _openAdd,
              ),
          ],
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
      return const _LoadingSkeleton();
    }
    if (snapshot.hasError) {
      return _ErrorState(onRetry: _reload);
    }
    if (cards.isEmpty) {
      return _EmptyState(onAdd: _openAdd);
    }

    final sorted = _sorted(cards);

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 120),
      children: [
        _PortfolioHero(cards: cards),
        const SizedBox(height: 22),
        _ListHeader(
          showSort: cards.length > 1,
          sort: _sort,
          onSort: (mode) => setState(() => _sort = mode),
        ),
        const SizedBox(height: AppSpacing.sm),
        for (final card in sorted) ...[
          _SwipeToDelete(
            card: card,
            onDelete: () => _confirmDelete(card),
            child: _CardTile(
              card: card,
              onTap: () => _showDetails(card),
              onEdit: () => _openEdit(card),
              onDelete: () => _confirmDelete(card),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Tap a card for details · swipe left to delete',
          textAlign: TextAlign.center,
          style: AppTypography.bodySm.copyWith(color: c.text40, fontSize: 11),
        ),
      ],
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  const _Header({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final c = ThemeColors.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
      child: Row(
        children: [
          _BackButton(onTap: onBack),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Credit cards',
                  style: AppTypography.headlineLgMobile.copyWith(
                    color: c.text100,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Limits, statements & payment dates',
                  style:
                      AppTypography.bodySm.copyWith(color: c.text40, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = ThemeColors.of(context);

    return Tooltip(
      message: 'Back',
      child: Material(
        color: c.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: c.border, width: 0.8),
            ),
            child: Icon(Icons.arrow_back_rounded, size: 20, color: c.text100),
          ),
        ),
      ),
    );
  }
}

// ── Portfolio snapshot ────────────────────────────────────────────────────────
/// Aggregate across every card: total limit, average rate and the single
/// payment that lands next — the one thing the user actually needs to act on.
class _PortfolioHero extends StatelessWidget {
  const _PortfolioHero({required this.cards});

  final List<CreditCardModel> cards;

  @override
  Widget build(BuildContext context) {
    final c = ThemeColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final totalLimit =
        cards.fold<double>(0, (sum, card) => sum + card.creditLimit);
    final avgApr =
        cards.fold<double>(0, (sum, card) => sum + card.apr) / cards.length;
    final soonest = cards.reduce(
      (a, b) => a.nextDueDate().isBefore(b.nextDueDate()) ? a : b,
    );
    final due = soonest.nextDueDate();
    final days = _daysUntil(due);

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            c.coreAction.withValues(alpha: isDark ? 0.24 : 0.11),
            c.surface,
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg + 2),
        border: Border.all(
          color: c.coreAction.withValues(alpha: 0.25),
          width: 0.8,
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: c.coreAction.withValues(alpha: 0.10),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TOTAL CREDIT LIMIT',
                      style: AppTypography.labelCaps.copyWith(
                        color: c.text40,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: totalLimit),
                      duration: const Duration(milliseconds: 850),
                      curve: Curves.easeOutCubic,
                      builder: (_, value, _) => FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          fmtCardMoney(value),
                          style: AppTypography.headlineLgMobile.copyWith(
                            color: c.text100,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.6,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Across ${cards.length} card${cards.length == 1 ? '' : 's'}',
                      style:
                          AppTypography.bodySm.copyWith(color: c.text70, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              _HeroMark(color: c.coreAction, iconColor: c.background),
            ],
          ),
          const SizedBox(height: 16),
          Divider(height: 1, color: c.divider),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _HeroStat(
                  label: 'AVG. APR',
                  value: '${fmtApr(avgApr)}% p.a.',
                ),
              ),
              Container(width: 1, height: 28, color: c.divider),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: AppSpacing.md),
                  child: _HeroStat(
                    label: 'NEXT DUE',
                    value: fmtShortDate(due),
                    caption: _relativeDays(days),
                    captionColor: _urgencyColor(c, days),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({
    required this.label,
    required this.value,
    this.caption,
    this.captionColor,
  });

  final String label;
  final String value;
  final String? caption;
  final Color? captionColor;

  @override
  Widget build(BuildContext context) {
    final c = ThemeColors.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.labelCaps.copyWith(
            color: c.text40,
            fontSize: 9.5,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          children: [
            Flexible(
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.bodySm.copyWith(
                  color: c.text100,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (caption != null) ...[
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  caption!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodySm.copyWith(
                    color: captionColor ?? c.text40,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

/// Decorative mini card so the summary reads as a card, not a chart panel.
class _HeroMark extends StatelessWidget {
  const _HeroMark({required this.color, required this.iconColor});

  final Color color;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.14,
      child: Container(
        width: 54,
        height: 38,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color, Color.lerp(color, Colors.black, 0.35)!],
          ),
          borderRadius: BorderRadius.circular(9),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.28),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          Icons.credit_card_rounded,
          size: 17,
          color: iconColor.withValues(alpha: 0.85),
        ),
      ),
    );
  }
}

// ── List header + sort ────────────────────────────────────────────────────────
class _ListHeader extends StatelessWidget {
  const _ListHeader({
    required this.showSort,
    required this.sort,
    required this.onSort,
  });

  final bool showSort;
  final _SortMode sort;
  final ValueChanged<_SortMode> onSort;

  @override
  Widget build(BuildContext context) {
    final c = ThemeColors.of(context);

    return Row(
      children: [
        Text(
          'Your cards',
          style: AppTypography.bodyMd.copyWith(
            color: c.text100,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        if (showSort) ...[
          _SortPill(
            label: 'Due soon',
            selected: sort == _SortMode.dueSoon,
            onTap: () => onSort(_SortMode.dueSoon),
          ),
          const SizedBox(width: AppSpacing.base),
          _SortPill(
            label: 'Highest limit',
            selected: sort == _SortMode.limit,
            onTap: () => onSort(_SortMode.limit),
          ),
        ],
      ],
    );
  }
}

class _SortPill extends StatelessWidget {
  const _SortPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = ThemeColors.of(context);

    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected
            ? c.coreAction.withValues(alpha: 0.12)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.full),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.full),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.full),
              border: Border.all(
                color: selected
                    ? c.coreAction.withValues(alpha: 0.45)
                    : c.border,
                width: 0.8,
              ),
            ),
            child: Text(
              label,
              style: AppTypography.bodySm.copyWith(
                color: selected ? c.text100 : c.text40,
                fontSize: 11,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Card tile ─────────────────────────────────────────────────────────────────
enum _CardAction { edit, delete }

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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final due = card.nextDueDate();
    final days = _daysUntil(due);
    final urgency = _urgencyColor(c, days);

    return Semantics(
      button: true,
      label: '${card.name}. Limit ${fmtCardMoney(card.creditLimit)}. '
          'Next payment ${_relativeDays(days)}.',
      child: Container(
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: c.border, width: 0.8),
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
                      _CardArt(tint: _tintFor(card)),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          card.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.bodyMd.copyWith(
                            color: c.text100,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      PopupMenuButton<_CardAction>(
                        tooltip: 'Card options',
                        color: c.surface,
                        elevation: 8,
                        padding: EdgeInsets.zero,
                        iconSize: 20,
                        icon: Icon(Icons.more_vert_rounded, color: c.text40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          side: BorderSide(color: c.border, width: 0.8),
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
                            child: Row(
                              children: [
                                Icon(Icons.edit_outlined,
                                    size: 18, color: c.text70),
                                const SizedBox(width: AppSpacing.sm),
                                Text(
                                  'Edit',
                                  style: AppTypography.bodySm
                                      .copyWith(color: c.text100),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: _CardAction.delete,
                            child: Row(
                              children: [
                                Icon(Icons.delete_outline_rounded,
                                    size: 18, color: c.accentExpense),
                                const SizedBox(width: AppSpacing.sm),
                                Text(
                                  'Delete',
                                  style: AppTypography.bodySm
                                      .copyWith(color: c.accentExpense),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'LIMIT',
                              style: AppTypography.labelCaps.copyWith(
                                color: c.text40,
                                fontSize: 10,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                fmtCardMoney(card.creditLimit),
                                style:
                                    AppTypography.headlineLgMobile.copyWith(
                                  color: c.text100,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.6,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'NEXT DUE',
                            style: AppTypography.labelCaps.copyWith(
                              color: c.text40,
                              fontSize: 10,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            fmtShortDate(due),
                            style: AppTypography.bodyMd.copyWith(
                              color: c.text100,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          _DuePill(
                            label: _relativeDays(days),
                            color: urgency,
                          ),
                        ],
                      ),
                      const SizedBox(width: AppSpacing.xs),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Divider(height: 1, color: c.divider),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: 14,
                    runSpacing: 6,
                    children: [
                      _MetaItem(
                        icon: Icons.percent_rounded,
                        text: '${fmtApr(card.apr)}% p.a.',
                      ),
                      _MetaItem(
                        icon: Icons.event_repeat_rounded,
                        text: 'Closes ${ordinalDay(card.statementDay)}',
                      ),
                      _MetaItem(
                        icon: Icons.schedule_rounded,
                        text: '${card.graceDays}-day grace',
                      ),
                    ],
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

/// Miniature card thumbnail. The tint is stable per card so cards stay
/// recognisable while scrolling.
class _CardArt extends StatelessWidget {
  const _CardArt({required this.tint, this.width = 44, this.height = 31});

  final Color tint;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [tint, Color.lerp(tint, Colors.black, 0.42)!],
        ),
        borderRadius: BorderRadius.circular(height * 0.22),
        boxShadow: [
          BoxShadow(
            color: tint.withValues(alpha: isDark ? 0.35 : 0.22),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            left: width * 0.16,
            top: height * 0.27,
            child: Container(
              width: width * 0.24,
              height: height * 0.26,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Positioned(
            left: width * 0.16,
            bottom: height * 0.18,
            child: Container(
              width: width * 0.4,
              height: 2,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DuePill extends StatelessWidget {
  const _DuePill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        label,
        style: AppTypography.bodySm.copyWith(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          height: 1.25,
        ),
      ),
    );
  }
}

class _MetaItem extends StatelessWidget {
  const _MetaItem({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final c = ThemeColors.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: c.text40),
        const SizedBox(width: AppSpacing.xs),
        Text(
          text,
          style: AppTypography.bodySm.copyWith(color: c.text70, fontSize: 12),
        ),
      ],
    );
  }
}

// ── Swipe to delete ───────────────────────────────────────────────────────────
class _SwipeToDelete extends StatelessWidget {
  const _SwipeToDelete({
    required this.card,
    required this.onDelete,
    required this.child,
  });

  final CreditCardModel card;
  final Future<void> Function() onDelete;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = ThemeColors.of(context);

    return Dismissible(
      key: ValueKey('card_${card.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        decoration: BoxDecoration(
          color: c.accentExpenseDim,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: c.accentExpense.withValues(alpha: 0.35),
            width: 0.8,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.delete_outline_rounded,
                color: c.accentExpense, size: 22),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Delete',
              style: AppTypography.bodySm.copyWith(
                color: c.accentExpense,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      confirmDismiss: (_) async {
        await onDelete();
        // _confirmDelete reloads the list on success; don't animate the row away.
        return false;
      },
      child: child,
    );
  }
}

// ── Delete confirmation ───────────────────────────────────────────────────────
class _DeleteCardDialog extends StatelessWidget {
  const _DeleteCardDialog({required this.cardName});

  final String cardName;

  @override
  Widget build(BuildContext context) {
    final c = ThemeColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      backgroundColor: c.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      contentPadding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
      actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      title: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: c.accentExpenseDim,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.delete_outline_rounded,
                size: 20, color: c.accentExpense),
          ),
          const SizedBox(height: 14),
          Text(
            'Delete this card?',
            style: AppTypography.headlineMd.copyWith(color: c.text100),
          ),
        ],
      ),
      content: Text(
        '"$cardName" will be removed along with its statement schedule. '
        'This can\'t be undone.',
        style: AppTypography.bodySm.copyWith(color: c.text70, height: 1.5),
      ),
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(false),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(0, 44),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.marginMobile),
            foregroundColor: c.text70,
            side: BorderSide(color: c.border, width: 1.2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            textStyle:
                AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w600),
          ),
          child: const Text('Keep card'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: c.accentExpense,
            foregroundColor: isDark ? c.background : Colors.white,
            minimumSize: const Size(0, 44),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            textStyle:
                AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w700),
          ),
          child: const Text('Delete'),
        ),
      ],
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

    final close = card.nextCloseDate();
    final due = card.nextDueDate();

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: c.text20,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 12, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _CardArt(
                        tint: _tintFor(card),
                        width: 46,
                        height: 32,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              card.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.headlineMd
                                  .copyWith(color: c.text100),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Credit card',
                              style: AppTypography.bodySm.copyWith(
                                color: c.text40,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Close',
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(Icons.close_rounded, color: c.text40),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.marginMobile),
                    decoration: BoxDecoration(
                      color: c.surface2,
                      borderRadius: BorderRadius.circular(AppRadius.md + 2),
                      border: Border.all(
                        color: c.border.withValues(alpha: 0.7),
                        width: 0.8,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CARD LIMIT',
                          style: AppTypography.labelCaps.copyWith(
                            color: c.text40,
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          fmtCardMoney(card.creditLimit),
                          style:
                              AppTypography.headlineLgMobile.copyWith(
                            color: c.text100,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Expanded(
                        child: _DetailStatTile(
                          icon: Icons.percent_rounded,
                          label: 'Interest rate',
                          value: '${fmtApr(card.apr)}% p.a.',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _DetailStatTile(
                          icon: Icons.schedule_rounded,
                          label: 'Grace period',
                          value: '${card.graceDays} days',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _DetailStatTile(
                          icon: Icons.event_repeat_rounded,
                          label: 'Statement closes',
                          value: ordinalDay(card.statementDay),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _DetailStatTile(
                          icon: Icons.event_available_rounded,
                          label: 'Next close',
                          value: fmtShortDate(close),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _DueCallout(
                    close: close,
                    due: due,
                    graceDays: card.graceDays,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: onEdit,
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          label: const Text('Edit card'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(0, 52),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppRadius.lg),
                            ),
                            textStyle: AppTypography.bodyMd.copyWith(
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Tooltip(
                        message: 'Delete card',
                        child: SizedBox(
                          width: 52,
                          height: 52,
                          child: OutlinedButton(
                            onPressed: onDelete,
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              foregroundColor: c.accentExpense,
                              side: BorderSide(
                                color:
                                    c.accentExpense.withValues(alpha: 0.5),
                                width: 1.2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(AppRadius.lg),
                              ),
                            ),
                            child: const Icon(Icons.delete_outline_rounded,
                                size: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailStatTile extends StatelessWidget {
  const _DetailStatTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final c = ThemeColors.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: c.border.withValues(alpha: 0.7),
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 13, color: c.text40),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style:
                      AppTypography.bodySm.copyWith(color: c.text40, fontSize: 11),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.bodyMd.copyWith(
              color: c.text100,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// The one date that matters, plus the arithmetic behind it.
class _DueCallout extends StatelessWidget {
  const _DueCallout({
    required this.close,
    required this.due,
    required this.graceDays,
  });

  final DateTime close;
  final DateTime due;
  final int graceDays;

  @override
  Widget build(BuildContext context) {
    final c = ThemeColors.of(context);
    final days = _daysUntil(due);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: c.accentDim,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: c.accent.withValues(alpha: 0.35),
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.event_available_rounded,
                  size: 18, color: c.text70),
              const SizedBox(width: AppSpacing.base),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PAYMENT DUE',
                      style: AppTypography.labelCaps.copyWith(
                        color: c.text40,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      fmtShortDate(due),
                      style: AppTypography.bodyLg.copyWith(
                        color: c.text100,
                        fontWeight: FontWeight.w700,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              _DuePill(
                label: _relativeDays(days),
                color: _urgencyColor(c, days),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Statement closes ${fmtShortDate(close)} · '
            '$graceDays-day grace window',
            style: AppTypography.bodySm.copyWith(
              color: c.text70,
              fontSize: 12,
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
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(32, 0, 32, 48),
      children: [
        SizedBox(height: MediaQuery.sizeOf(context).height * 0.07),
        const Center(child: _EmptyCardStack()),
        const SizedBox(height: 28),
        Text(
          'No credit cards yet',
          textAlign: TextAlign.center,
          style: AppTypography.headlineMd.copyWith(color: c.text100),
        ),
        const SizedBox(height: AppSpacing.base),
        Text(
          'Add your card to see its limit, statement date and next '
          'payment due in one place.',
          textAlign: TextAlign.center,
          style: AppTypography.bodySm.copyWith(color: c.text70, height: 1.55),
        ),
        const SizedBox(height: 24),
        Center(
          child: ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add_rounded, size: 20),
            label: const Text('Add your first card'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(0, 50),
              padding:
                  const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              textStyle:
                  AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyCardStack extends StatelessWidget {
  const _EmptyCardStack();

  @override
  Widget build(BuildContext context) {
    final c = ThemeColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget ghost({
      required double width,
      required double height,
      required Color color,
      required double angle,
    }) {
      return Transform.rotate(
        angle: angle,
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: c.border, width: 0.8),
          ),
        ),
      );
    }

    return SizedBox(
      width: 172,
      height: 118,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ghost(width: 128, height: 80, color: c.surface2, angle: -0.16),
          ghost(width: 136, height: 86, color: c.surface3, angle: 0.10),
          Transform.rotate(
            angle: -0.03,
            child: Container(
              width: 144,
              height: 90,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    c.coreAction,
                    Color.lerp(c.coreAction, Colors.black, 0.4)!,
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: c.coreAction.withValues(alpha: isDark ? 0.35 : 0.22),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: 18,
                    top: 26,
                    child: Container(
                      width: 22,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 18,
                    bottom: 22,
                    child: Container(
                      width: 54,
                      height: 3,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 16,
                    bottom: 18,
                    child: Row(
                      children: [
                        for (var i = 0; i < 3; i++)
                          Padding(
                            padding: const EdgeInsets.only(left: 3),
                            child: Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.25),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Loading skeleton ──────────────────────────────────────────────────────────
class _LoadingSkeleton extends StatelessWidget {
  const _LoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    final c = ThemeColors.of(context);

    return _Pulse(
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 120),
        children: [
          _SkeletonBox(height: 152, radius: AppRadius.lg + 2, color: c.surface2),
          const SizedBox(height: 22),
          _SkeletonBox(height: 16, radius: AppRadius.sm, color: c.surface2),
          const SizedBox(height: AppSpacing.sm),
          for (var i = 0; i < 3; i++) ...[
            _SkeletonBox(
              height: 138,
              radius: AppRadius.lg,
              color: c.surface2,
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ],
      ),
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  const _SkeletonBox({
    required this.height,
    required this.radius,
    required this.color,
  });

  final double height;
  final double radius;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

class _Pulse extends StatefulWidget {
  const _Pulse({required this.child});

  final Widget child;

  @override
  State<_Pulse> createState() => _PulseState();
}

class _PulseState extends State<_Pulse> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.45, end: 0.95).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      ),
      child: widget.child,
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
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(32, 0, 32, 48),
      children: [
        SizedBox(height: MediaQuery.sizeOf(context).height * 0.10),
        Center(
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: c.accentExpenseDim,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.cloud_off_rounded,
                size: 28, color: c.accentExpense),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Could not load your cards',
          textAlign: TextAlign.center,
          style: AppTypography.headlineMd.copyWith(color: c.text100),
        ),
        const SizedBox(height: AppSpacing.base),
        Text(
          'Check your connection and try again.',
          textAlign: TextAlign.center,
          style: AppTypography.bodySm.copyWith(color: c.text70, height: 1.55),
        ),
        const SizedBox(height: 20),
        Center(
          child: OutlinedButton.icon(
            onPressed: () => onRetry(),
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Try again'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(0, 48),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              foregroundColor: c.coreAction,
              side: BorderSide(
                color: c.coreAction.withValues(alpha: 0.4),
                width: 1.2,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              textStyle:
                  AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Shared helpers ────────────────────────────────────────────────────────────
enum _SortMode { dueSoon, limit }

/// Stable per-card thumbnail tint so each card is visually distinguishable.
const List<Color> _cardTints = [
  Color(0xFF17513A), // forest
  Color(0xFF1E7A4E), // growth
  Color(0xFFF2B84B), // marigold
  Color(0xFF5E7266), // sage
  Color(0xFFC0392B), // terracotta
];

Color _tintFor(CreditCardModel card) =>
    _cardTints[card.id.abs() % _cardTints.length];

/// Whole days between today and [date] (negative when already passed).
int _daysUntil(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  return DateTime(date.year, date.month, date.day).difference(today).inDays;
}

/// Short, human countdown used next to a due date.
String _relativeDays(int days) {
  if (days < 0) return 'overdue';
  if (days == 0) return 'today';
  if (days == 1) return 'tomorrow';
  return 'in $days days';
}

/// Payments inside a week shout, inside a fortnight warn, further out stay quiet.
Color _urgencyColor(ThemeColors c, int days) {
  if (days <= 5) return c.accentExpense;
  if (days <= 14) return c.lime;
  return c.text40;
}
