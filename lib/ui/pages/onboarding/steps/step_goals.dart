import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:Thinkpay/core/constant/app_colors.dart';
import 'package:Thinkpay/model/goal_model.dart';
import 'package:Thinkpay/model/onboarding/onboarding_draft.dart';
import 'package:Thinkpay/ui/pages/onboarding/widgets/onboarding_scaffold.dart';
import 'package:Thinkpay/ui/pages/onboarding/widgets/onboarding_widgets.dart';

/// Step 6 — goals.
class GoalsStep extends StatefulWidget {
  const GoalsStep({
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
  State<GoalsStep> createState() => _GoalsStepState();
}

/// Preset name, target and monthly plan are pre-filled so the user only has to
/// confirm — the fields stay editable.
class _GoalPreset {
  const _GoalPreset(this.name, this.target, this.monthly, this.type);

  final String name;
  final double target;
  final double monthly;
  final GoalType type;
}

const List<_GoalPreset> _presets = [
  _GoalPreset('Emergency fund', 300000, 25000, GoalType.savings),
  _GoalPreset('New phone', 150000, 12500, GoalType.savings),
  _GoalPreset('Travel', 250000, 20000, GoalType.savings),
  _GoalPreset('House deposit', 2000000, 60000, GoalType.savings),
  _GoalPreset('Invest monthly', 500000, 15000, GoalType.investment),
  _GoalPreset('Pay off debt', 500000, 25000, GoalType.debt),
];

class _GoalEditor {
  _GoalEditor(this.goal)
    : target = TextEditingController(text: plainAmount(goal.target)),
      saved = TextEditingController(text: plainAmount(goal.saved)),
      monthly = TextEditingController(text: plainAmount(goal.monthlyPlan));

  final GoalDraft goal;
  final TextEditingController target;
  final TextEditingController saved;
  final TextEditingController monthly;

  void dispose() {
    target.dispose();
    saved.dispose();
    monthly.dispose();
  }
}

class _GoalsStepState extends State<GoalsStep> {
  late List<_GoalEditor> _editors;

  @override
  void initState() {
    super.initState();
    _editors = [for (final goal in widget.draft.goals) _GoalEditor(goal)];
  }

  @override
  void dispose() {
    for (final editor in _editors) {
      editor.dispose();
    }
    super.dispose();
  }

  void _addPreset(_GoalPreset preset) {
    HapticFeedback.selectionClick();
    final goal = GoalDraft(
      name: preset.name,
      target: preset.target,
      monthlyPlan: preset.monthly,
      type: preset.type,
    );
    widget.draft.goals.add(goal);
    setState(() => _editors.add(_GoalEditor(goal)));
  }

  void _remove(int index) {
    final removed = _editors.removeAt(index);
    widget.draft.goals.remove(removed.goal);
    removed.dispose();
    setState(() {});
  }

  void _sync(_GoalEditor editor) {
    editor.goal.target = parseMoney(editor.target.text) ?? 0;
    editor.goal.saved = parseMoney(editor.saved.text) ?? 0;
    editor.goal.monthlyPlan = parseMoney(editor.monthly.text) ?? 0;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final symbol = symbolForCode(widget.draft.currencyCode);

    return OnboardingScaffold(
      stepIndex: widget.stepIndex,
      stepLabel: 'Goals',
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
          const StepTitle(
            title: 'What are you working toward?',
            subtitle:
                'Pick a starter or write your own. These become your '
                'Home goals and can be changed any time.',
          ),
          const SizedBox(height: AppSpacing.md),

          SectionLabel('Starters'),
          const SizedBox(height: AppSpacing.base),
          PresetChips(
            items: [for (final preset in _presets) preset.name],
            onTap: (label) {
              final preset = _presets.firstWhere((p) => p.name == label);
              _addPreset(preset);
            },
          ),
          const SizedBox(height: AppSpacing.md),

          if (_editors.isEmpty)
            const EmptyHint(
              'No goals yet. Pick a starter above, or skip and add one later '
              'from the Goals tab.',
            )
          else
            for (var i = 0; i < _editors.length; i++) ...[
              _GoalTile(
                editor: _editors[i],
                symbol: symbol,
                onChanged: () => _sync(_editors[i]),
                onRemove: () => _remove(i),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],

          if (_editors.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            InfoNote(
              icon: Icons.flag_outlined,
              text:
                  '${_editors.length} goal'
                  '${_editors.length == 1 ? '' : 's'} · '
                  '${moneyText(_editors.fold<double>(0, (sum, e) => sum + e.goal.monthlyPlan), symbol, decimals: 0)} '
                  'a month planned.',
            ),
          ],
        ],
      ),
      footer: PrimaryCta(label: 'Continue', onTap: widget.onNext),
    );
  }
}

class _GoalTile extends StatelessWidget {
  const _GoalTile({
    required this.editor,
    required this.symbol,
    required this.onChanged,
    required this.onRemove,
  });

  final _GoalEditor editor;
  final String symbol;
  final VoidCallback onChanged;
  final VoidCallback onRemove;

  String get _typeLabel => switch (editor.goal.type) {
    GoalType.savings => 'Savings',
    GoalType.investment => 'Investment',
    GoalType.debt => 'Debt',
  };

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    final goal = editor.goal;

    return TileCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  goal.name,
                  style: AppTypography.bodyMd.copyWith(
                    color: tc.text100,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.base,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: tc.surface2,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  _typeLabel,
                  style: AppTypography.labelCaps.copyWith(
                    color: tc.text70,
                    fontSize: 9,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              TileActionButton(
                icon: Icons.close_rounded,
                onTap: onRemove,
                tooltip: 'Remove goal',
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          _GoalField(
            label: 'Target',
            controller: editor.target,
            symbol: symbol,
            accent: tc.intelligenceAccent,
            onChanged: onChanged,
          ),
          const SizedBox(height: AppSpacing.base),
          _GoalField(
            label: 'Already saved',
            controller: editor.saved,
            symbol: symbol,
            accent: tc.intelligenceAccent,
            onChanged: onChanged,
          ),
          const SizedBox(height: AppSpacing.base),
          _GoalField(
            label: 'Save monthly',
            controller: editor.monthly,
            symbol: symbol,
            accent: tc.accent,
            onChanged: onChanged,
          ),
          const SizedBox(height: AppSpacing.sm),
          MiniProgress(value: goal.progress),
          const SizedBox(height: 6),
          Text(
            '${(goal.progress * 100).round()}% of '
            '${moneyText(goal.target, symbol, decimals: 0)}',
            style: AppTypography.bodySm.copyWith(
              color: tc.text40,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _GoalField extends StatelessWidget {
  const _GoalField({
    required this.label,
    required this.controller,
    required this.symbol,
    required this.accent,
    required this.onChanged,
  });

  final String label;
  final TextEditingController controller;
  final String symbol;
  final Color accent;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);

    return Row(
      children: [
        SizedBox(
          width: 92,
          child: Text(
            label,
            style: AppTypography.bodySm.copyWith(color: tc.text70),
          ),
        ),
        Expanded(
          child: MoneyField(
            controller: controller,
            symbol: symbol,
            accent: accent,
            onChanged: (_) => onChanged(),
          ),
        ),
      ],
    );
  }
}
