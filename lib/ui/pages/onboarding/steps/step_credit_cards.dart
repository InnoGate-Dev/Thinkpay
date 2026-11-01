import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:Thinkpay/core/constant/app_colors.dart';
import 'package:Thinkpay/model/onboarding/onboarding_draft.dart';
import 'package:Thinkpay/ui/pages/onboarding/sheets/card_editor_sheet.dart';
import 'package:Thinkpay/ui/pages/onboarding/widgets/onboarding_scaffold.dart';
import 'package:Thinkpay/ui/pages/onboarding/widgets/onboarding_widgets.dart';
import 'package:Thinkpay/util/credit_card_format.dart';

/// Step 4 — credit cards.
///
/// Opens with a gate question so users without cards answer in one tap and
/// never meet an empty form.
class CreditCardsStep extends StatefulWidget {
  const CreditCardsStep({
    super.key,
    required this.draft,
    required this.stepIndex,
    required this.onNext,
    required this.onBack,
    required this.onSkip,
  });

  final OnboardingDraft draft;
  final int stepIndex;
  final VoidCallback onNext;
  final VoidCallback onBack;
  final VoidCallback onSkip;

  @override
  State<CreditCardsStep> createState() => _CreditCardsStepState();
}

class _CreditCardsStepState extends State<CreditCardsStep> {
  /// null = unanswered, true = has cards, false = no cards.
  bool? _hasCards;

  @override
  void initState() {
    super.initState();
    final draft = widget.draft;
    if (draft.cards.isNotEmpty) {
      _hasCards = true;
    } else if (draft.noCards) {
      _hasCards = false;
    }
  }

  void _answer(bool value) {
    HapticFeedback.selectionClick();
    setState(() {
      _hasCards = value;
      widget.draft.noCards = !value;
    });
  }

  Future<void> _addCard() async {
    final card = await showCardEditorSheet(
      context: context,
      symbol: symbolForCode(widget.draft.currencyCode),
    );
    if (card == null || !mounted) return;
    setState(() => widget.draft.cards.add(card));
    HapticFeedback.lightImpact();
  }

  Future<void> _editCard(int index) async {
    final card = await showCardEditorSheet(
      context: context,
      symbol: symbolForCode(widget.draft.currencyCode),
      initial: widget.draft.cards[index],
    );
    if (card == null || !mounted) return;
    setState(() => widget.draft.cards[index] = card);
  }

  void _removeCard(int index) {
    setState(() => widget.draft.cards.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    final symbol = symbolForCode(widget.draft.currencyCode);

    return OnboardingScaffold(
      stepIndex: widget.stepIndex,
      stepLabel: 'Credit cards',
      onBack: widget.onBack,
      onSkip: widget.onSkip,
      content: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.base,
          AppSpacing.md,
          AppSpacing.md,
        ),
        children: [
          const StepTitle(
            title: 'Do you have a credit card?',
            subtitle: 'Cards help us warn you before interest kicks in.',
          ),
          const SizedBox(height: AppSpacing.md),

          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: GateOption(
                    icon: Icons.credit_card_rounded,
                    title: 'Yes, I have one',
                    subtitle: 'Add the card you use most',
                    selected: _hasCards == true,
                    onTap: () => _answer(true),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: GateOption(
                    icon: Icons.remove_circle_outline_rounded,
                    title: 'No cards',
                    subtitle: 'Right now',
                    selected: _hasCards == false,
                    onTap: () => _answer(false),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          if (_hasCards == true) ...[
            if (widget.draft.cards.isEmpty)
              const EmptyHint(
                'No cards added yet. You can also add them later from the '
                'Finance tab.',
              )
            else
              for (var i = 0; i < widget.draft.cards.length; i++) ...[
                _CardTile(
                  card: widget.draft.cards[i],
                  symbol: symbol,
                  onEdit: () => _editCard(i),
                  onRemove: () => _removeCard(i),
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: _addCard,
                icon: Icon(Icons.add_rounded, size: 18, color: tc.text70),
                style: TextButton.styleFrom(
                  foregroundColor: tc.text70,
                  minimumSize: const Size(44, 44),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.base,
                  ),
                ),
                label: Text(
                  widget.draft.cards.isEmpty ? 'Add card' : 'Add another card',
                  style: AppTypography.bodySm.copyWith(
                    fontWeight: FontWeight.w600,
                    color: tc.text70,
                  ),
                ),
              ),
            ),
          ] else if (_hasCards == false)
            const InfoNote(
              icon: Icons.check_circle_outline_rounded,
              text:
                  'Good to know. You can add a card any time from the '
                  'Finance tab.',
              tone: NoteTone.positive,
            )
          else
            const EmptyHint(
              'Pick either option to continue. Nothing is required here.',
            ),
        ],
      ),
      footer: PrimaryCta(label: 'Continue', onTap: widget.onNext),
    );
  }
}

class _CardTile extends StatelessWidget {
  const _CardTile({
    required this.card,
    required this.symbol,
    required this.onEdit,
    required this.onRemove,
  });

  final CardDraft card;
  final String symbol;
  final VoidCallback onEdit;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    final close = nextStatementClose(card.statementDay, DateTime.now());
    final due = close.add(Duration(days: card.graceDays));

    return TileCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  card.name,
                  style: AppTypography.bodyMd.copyWith(
                    color: tc.text100,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              TileActionButton(
                icon: Icons.edit_outlined,
                onTap: onEdit,
                tooltip: 'Edit card',
              ),
              TileActionButton(
                icon: Icons.close_rounded,
                onTap: onRemove,
                tooltip: 'Remove card',
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.base),
          Row(
            children: [
              _Meta(
                label: 'Limit',
                value: '$symbol ${formatMoney(card.creditLimit, decimals: 0)}',
              ),
              const SizedBox(width: AppSpacing.md),
              _Meta(label: 'Rate', value: '${fmtPercent(card.apr)}% p.a.'),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Statement closes ${fmtShortDate(close)}  ·  payment due '
            '${fmtShortDate(due)}',
            style: AppTypography.bodySm.copyWith(
              color: tc.text40,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: AppTypography.labelCaps.copyWith(
            color: tc.text40,
            fontSize: 9,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTypography.dataMono.copyWith(
            color: tc.text100,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
