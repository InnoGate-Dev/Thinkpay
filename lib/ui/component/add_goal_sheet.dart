import 'package:flutter/material.dart';
import '../../core/constant/app_colors.dart';
import '../../core/repository/goalRepo.dart';
import 'package:Thinkpay/model/goal_model.dart';
import 'package:Thinkpay/providers/finance_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Add / Edit Goal Bottom Sheet
// ─────────────────────────────────────────────────────────────────────────────
class AddGoalSheet extends StatefulWidget {
  const AddGoalSheet({super.key, this.existing, this.initialType});

  /// When provided, the sheet opens in edit mode prefilled with this goal.
  final GoalModel? existing;

  /// Default type derived from the active tab.
  final GoalType? initialType;

  @override
  State<AddGoalSheet> createState() => _AddGoalSheetState();
}

class _AddGoalSheetState extends State<AddGoalSheet> {
  final _nameCtrl         = TextEditingController();
  final _targetAmountCtrl = TextEditingController();
  final _actualAmountCtrl = TextEditingController();
  late GoalType _type;
  bool _submitting = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _nameCtrl.text         = widget.existing!.name;
      _targetAmountCtrl.text = widget.existing!.targetAmount.toStringAsFixed(2);
      _actualAmountCtrl.text = widget.existing!.savedAmount.toStringAsFixed(2);
      _type                  = widget.existing!.type;
    } else {
      _type                  = widget.initialType ?? GoalType.savings;
      _actualAmountCtrl.text = '0.00';
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _targetAmountCtrl.dispose();
    _actualAmountCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name         = _nameCtrl.text.trim();
    final targetAmount = double.tryParse(_targetAmountCtrl.text.replaceAll(',', ''));
    final actualAmount = double.tryParse(_actualAmountCtrl.text.replaceAll(',', '')) ?? 0.0;

    if (name.isEmpty || targetAmount == null || targetAmount <= 0) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a goal name and valid target amount.'),
          backgroundColor: ThemeColors.of(context).red,
        ),
      );
      return;
    }

    if (actualAmount < 0) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Actual amount cannot be negative.'),
          backgroundColor: ThemeColors.of(context).red,
        ),
      );
      return;
    }

    final isComplete = actualAmount >= targetAmount && targetAmount > 0;

    setState(() => _submitting = true);
    try {
      final repo     = GoalRepository();
      final provider = FinanceProvider();

      if (_isEditing) {
        // ── Edit existing goal ────────────────────────────────────────────
        final updated = await repo.updateGoal(
          widget.existing!.id,
          widget.existing!,
          name: name,
          targetAmount: targetAmount,
          actualAmount: actualAmount,
          type: _type,
        );
        provider.updateGoal(updated, preserveSaved: false);
      } else {
        // ── Create new goal ───────────────────────────────────────────────
        final created = await repo.createGoal(
          name: name,
          targetAmount: targetAmount,
          actualAmount: actualAmount,
          isComplete: isComplete,
          type: _type,
        );
        provider.addGoal(created);
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? 'Failed to update goal: $e'
                : 'Failed to create goal: $e',
          ),
          backgroundColor: ThemeColors.of(context).red,
        ),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tc          = ThemeColors.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final accent      = _type == GoalType.savings ? tc.lime : const Color(0xFF72B4FF);

    return Container(
      decoration: BoxDecoration(
        color: tc.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(24, 16, 24, 24 + bottomInset),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // handle
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                    color: tc.text20,
                    borderRadius: BorderRadius.circular(4)),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _isEditing ? 'Edit Goal' : 'Create New Goal',
              style: TextStyle(
                  color: tc.text100,
                  fontSize: 20,
                  fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              _isEditing
                  ? 'Update your goal details below.'
                  : 'Set a savings or investment target and track your progress.',
              style: TextStyle(color: tc.text40, fontSize: 13),
            ),
            const SizedBox(height: 20),

            // Type toggle
            Container(
              decoration: BoxDecoration(
                  color: tc.surface2,
                  borderRadius: BorderRadius.circular(14)),
              child: Row(children: [
                _TypeBtn(
                  label: 'Savings',
                  icon: Icons.savings_rounded,
                  selected: _type == GoalType.savings,
                  color: tc.lime,
                  onTap: () => setState(() => _type = GoalType.savings),
                ),
                _TypeBtn(
                  label: 'Investment',
                  icon: Icons.trending_up_rounded,
                  selected: _type == GoalType.investment,
                  color: const Color(0xFF72B4FF),
                  onTap: () => setState(() => _type = GoalType.investment),
                ),
              ]),
            ),
            const SizedBox(height: 16),

            _Label('Goal Name', tc),
            const SizedBox(height: 6),
            _Field(
                controller: _nameCtrl,
                hint: 'e.g. Emergency Fund',
                icon: Icons.flag_rounded,
                tc: tc),
            const SizedBox(height: 14),

            _Label('Actual Amount (Rs.)', tc),
            const SizedBox(height: 6),
            _Field(
                controller: _actualAmountCtrl,
                hint: '500.00',
                icon: Icons.account_balance_wallet_rounded,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                tc: tc),
            const SizedBox(height: 14),

            _Label('Target Amount (Rs.)', tc),
            const SizedBox(height: 6),
            _Field(
                controller: _targetAmountCtrl,
                hint: '6000.00',
                icon: Icons.currency_rupee_rounded,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                tc: tc),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _submitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: tc.background,
                  disabledBackgroundColor: accent.withValues(alpha: 0.5),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: _submitting
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: tc.background,
                        ),
                      )
                    : Text(
                        _isEditing ? 'Save Changes' : 'Create Goal',
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Add Amount to Goal Bottom Sheet
// ─────────────────────────────────────────────────────────────────────────────
class AddAmountToGoalSheet extends StatefulWidget {
  const AddAmountToGoalSheet({
    super.key,
    required this.goal,
  });

  /// The goal to contribute to. The full model is needed so the repo can
  /// issue a proper update call.
  final GoalModel goal;

  @override
  State<AddAmountToGoalSheet> createState() => _AddAmountToGoalSheetState();
}

class _AddAmountToGoalSheetState extends State<AddAmountToGoalSheet> {
  final _amountCtrl = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final amount = double.tryParse(_amountCtrl.text.replaceAll(',', ''));
    if (amount == null || amount <= 0) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Enter a valid amount.'),
          backgroundColor: ThemeColors.of(context).red,
        ),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      final repo     = GoalRepository();
      final provider = FinanceProvider();

      final updated = await repo.addAmountToGoal(
        widget.goal.id,
        amount,
        widget.goal,
      );

      // Sync provider with the backend response
      provider.addAmountToGoal(widget.goal.id, updated.savedAmount);

      if (!mounted) return;
      Navigator.pop(context);

      if (updated.isCompleted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🎉 Goal "${widget.goal.name}" completed!'),
            backgroundColor: ThemeColors.of(context).lime,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add amount: $e'),
          backgroundColor: ThemeColors.of(context).red,
        ),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tc          = ThemeColors.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: tc.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(24, 16, 24, 24 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                  color: tc.text20, borderRadius: BorderRadius.circular(4)),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Add to "${widget.goal.name}"',
            style: TextStyle(
                color: tc.text100, fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            'How much are you adding to this goal?',
            style: TextStyle(color: tc.text40, fontSize: 13),
          ),
          const SizedBox(height: 20),

          _Label('Amount (Rs.)', tc),
          const SizedBox(height: 6),
          _Field(
              controller: _amountCtrl,
              hint: '0.00',
              icon: Icons.currency_rupee_rounded,
              keyboardType: TextInputType.number,
              tc: tc),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _submitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: tc.lime,
                foregroundColor: tc.background,
                disabledBackgroundColor: tc.lime.withValues(alpha: 0.5),
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: _submitting
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: tc.background,
                      ),
                    )
                  : const Text('Add Amount',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Type toggle button ────────────────────────────────────────────────────────
class _TypeBtn extends StatelessWidget {
  const _TypeBtn({
    required this.label,
    required this.icon,
    required this.selected,
    required this.color,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            margin: const EdgeInsets.all(4),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: selected
                  ? color.withValues(alpha: 0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              border: selected
                  ? Border.all(color: color.withValues(alpha: 0.4))
                  : null,
            ),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon,
                      color: selected
                          ? color
                          : ThemeColors.of(context).text40,
                      size: 16),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: TextStyle(
                        color: selected
                            ? color
                            : ThemeColors.of(context).text40,
                        fontWeight: FontWeight.w600,
                        fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}

// ── Shared field ──────────────────────────────────────────────────────────────
class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.hint,
    required this.icon,
    required this.tc,
    this.keyboardType = TextInputType.text,
  });
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final ThemeColors tc;
  final TextInputType keyboardType;

  @override
  Widget build(BuildContext context) => Container(
        height: 50,
        decoration: BoxDecoration(
          color: tc.surface2,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: tc.border),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(children: [
          Icon(icon, color: tc.text40, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              style: TextStyle(color: tc.text100, fontSize: 14),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(color: tc.text40, fontSize: 14),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ]),
      );
}

// ── Label ─────────────────────────────────────────────────────────────────────
class _Label extends StatelessWidget {
  const _Label(this.text, this.tc);
  final String text;
  final ThemeColors tc;
  @override
  Widget build(BuildContext context) => Text(
        text.toUpperCase(),
        style: TextStyle(
            color: tc.text40,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8),
      );
}
