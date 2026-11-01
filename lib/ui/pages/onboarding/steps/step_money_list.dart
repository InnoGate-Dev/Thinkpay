import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:Thinkpay/core/constant/app_colors.dart';
import 'package:Thinkpay/model/onboarding/onboarding_draft.dart';
import 'package:Thinkpay/ui/pages/onboarding/sheets/money_editor_sheet.dart';
import 'package:Thinkpay/ui/pages/onboarding/widgets/onboarding_scaffold.dart';
import 'package:Thinkpay/ui/pages/onboarding/widgets/onboarding_widgets.dart';

/// Steps 2 and 3 — income and expenses.
///
/// One widget for both lists: the second list has to feel as effortless as the
/// first, so the layout, motion and validation are literally the same code.
/// Rows are saved through the money editor sheet, not edited in place.
class MoneyListStep extends StatefulWidget {
  const MoneyListStep({
    super.key,
    required this.draft,
    required this.isIncome,
    required this.stepIndex,
    required this.onNext,
    required this.onBack,
    required this.onSkip,
  });

  final OnboardingDraft draft;
  final bool isIncome;
  final int stepIndex;
  final VoidCallback onNext;
  final VoidCallback onBack;
  final VoidCallback onSkip;

  @override
  State<MoneyListStep> createState() => _MoneyListStepState();
}

class _MoneyListStepState extends State<MoneyListStep> {
  static const _incomePresets = [
    'Salary',
    'Freelance',
    'Business',
    'Rent received',
    'Interest',
    'Other',
  ];

  static const _expensePresets = [
    'Rent',
    'Groceries',
    'Transport',
    'Utilities',
    'Dining',
    'Subscriptions',
    'Education',
    'Health',
    'Other',
  ];

  List<MoneyItem> get _items =>
      widget.isIncome ? widget.draft.incomes : widget.draft.expenses;

  double get _total => widget.isIncome
      ? widget.draft.monthlyIncome
      : widget.draft.monthlyExpense;

  MoneyItem? _findByLabel(String label) {
    for (final item in _items) {
      if (item.label.toLowerCase() == label.toLowerCase()) return item;
    }
    return null;
  }

  /// Opens the sheet and writes the result back into the shared draft.
  Future<void> _openEditor({MoneyItem? initial, String? presetLabel}) async {
    final saved = await showMoneyEditorSheet(
      context: context,
      isIncome: widget.isIncome,
      symbol: symbolForCode(widget.draft.currencyCode),
      initial: initial,
      presetLabel: presetLabel,
    );
    if (saved == null || !mounted) return;

    HapticFeedback.lightImpact();
    setState(() {
      if (initial == null) {
        _items.add(saved);
      } else {
        final index = _items.indexOf(initial);
        if (index >= 0) {
          _items[index] = saved;
        } else {
          _items.add(saved);
        }
      }
    });
  }

  /// A preset that is already on the list opens for editing rather than
  /// creating a duplicate row.
  void _onPreset(String label) {
    final existing = _findByLabel(label);
    _openEditor(
      initial: existing,
      presetLabel: existing == null ? label : null,
    );
  }

  void _remove(int index) => setState(() => _items.removeAt(index));

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    final accent = widget.isIncome ? tc.lime : tc.red;
    final symbol = symbolForCode(widget.draft.currencyCode);
    final noun = widget.isIncome ? 'income' : 'expense';

    final title = widget.isIncome
        ? 'What comes in each month?'
        : 'What do you spend on each month?';
    final subtitle = widget.isIncome
        ? 'Rough numbers are fine — you can adjust them later.'
        : 'Estimates are fine — you can adjust them later.';
    final presets = widget.isIncome ? _incomePresets : _expensePresets;

    return OnboardingScaffold(
      stepIndex: widget.stepIndex,
      stepLabel: widget.isIncome ? 'Income' : 'Expenses',
      onBack: widget.onBack,
      onSkip: widget.onSkip,
      content: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.base,
          AppSpacing.md,
          AppSpacing.md,
        ),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        children: [
          StepTitle(title: title, subtitle: subtitle),
          const SizedBox(height: AppSpacing.md),

          if (_items.isEmpty) ...[
            EmptyHint(
              widget.isIncome
                  ? 'Nothing added yet. Pick a source below, or skip and add it later from Home.'
                  : 'Nothing added yet. Pick a category below, or skip and add it later from Home.',
            ),
            const SizedBox(height: AppSpacing.md),
          ],

          SectionLabel(widget.isIncome ? 'Common sources' : 'Common expenses'),
          const SizedBox(height: AppSpacing.base),
          PresetChips(items: presets, onTap: _onPreset),
          const SizedBox(height: AppSpacing.md),

          for (var i = 0; i < _items.length; i++) ...[
            _MoneyTile(
              item: _items[i],
              symbol: symbol,
              accent: accent,
              onEdit: () => _openEditor(initial: _items[i]),
              onRemove: () => _remove(i),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],

          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: _openEditor,
              icon: Icon(Icons.add_rounded, size: 18, color: tc.text70),
              style: TextButton.styleFrom(
                foregroundColor: tc.text70,
                minimumSize: const Size(44, 44),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.base,
                ),
              ),
              label: Text(
                _items.isEmpty ? 'Add $noun' : 'Add another $noun',
                style: AppTypography.bodySm.copyWith(
                  fontWeight: FontWeight.w600,
                  color: tc.text70,
                ),
              ),
            ),
          ),
        ],
      ),
      footer: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!widget.isIncome) ...[
            _ExpenseInsight(draft: widget.draft),
            const SizedBox(height: AppSpacing.marginMobile),
          ],
          Row(
            children: [
              Text(
                widget.isIncome ? 'Monthly income' : 'Monthly spend',
                style: AppTypography.bodySm.copyWith(color: tc.text70),
              ),
              const Spacer(),
              Text(
                '$symbol ${formatMoney(_total)}',
                style: AppTypography.dataMono.copyWith(
                  color: tc.text100,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.marginMobile),
          PrimaryCta(label: 'Continue', onTap: widget.onNext),
        ],
      ),
    );
  }
}

/// One saved row: what it is, what it costs, and the two things you can do
/// with it. Editing happens in the sheet, so the tile never holds a keyboard.
class _MoneyTile extends StatelessWidget {
  const _MoneyTile({
    required this.item,
    required this.symbol,
    required this.accent,
    required this.onEdit,
    required this.onRemove,
  });

  final MoneyItem item;
  final String symbol;
  final Color accent;
  final VoidCallback onEdit;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    final decimals = item.amount == item.amount.roundToDouble() ? 0 : 2;

    return TileCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodySm.copyWith(
                    color: tc.text100,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$symbol${formatMoney(item.amount, decimals: decimals)}',
                  style: AppTypography.dataMono.copyWith(
                    color: accent,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          TileActionButton(
            icon: Icons.edit_outlined,
            onTap: onEdit,
            tooltip: 'Edit ${item.label}',
          ),
          TileActionButton(
            icon: Icons.close_rounded,
            onTap: onRemove,
            tooltip: 'Remove ${item.label}',
          ),
        ],
      ),
    );
  }
}

/// The payoff moment: shows what the two lists together actually mean.
class _ExpenseInsight extends StatelessWidget {
  const _ExpenseInsight({required this.draft});

  final OnboardingDraft draft;

  @override
  Widget build(BuildContext context) {
    final symbol = symbolForCode(draft.currencyCode);

    if (draft.monthlyIncome <= 0) {
      return const InfoNote(
        icon: Icons.savings_outlined,
        text: 'Add income later to see what you keep each month.',
      );
    }

    if (draft.monthlyKeep < 0) {
      return const InfoNote(
        icon: Icons.info_outline_rounded,
        tone: NoteTone.caution,
        text:
            'Spending is higher than income this month — '
            "we'll help you close that gap.",
      );
    }

    final percent = ((draft.keepRatio ?? 0) * 100).round();
    return InfoNote(
      icon: Icons.savings_outlined,
      tone: NoteTone.positive,
      text:
          'You keep $symbol${formatMoney(draft.monthlyKeep)} '
          '($percent%) each month.',
    );
  }
}
