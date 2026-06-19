import 'package:flutter/material.dart';
import 'package:Thinkpay/constant/app_colors.dart';
import 'package:Thinkpay/model/goal_model.dart';
import 'package:Thinkpay/providers/finance_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Add / Edit Goal Bottom Sheet
// ─────────────────────────────────────────────────────────────────────────────
class AddGoalSheet extends StatefulWidget {
  const AddGoalSheet({super.key, this.existing});

  /// When provided, the sheet opens in edit mode prefilled with this goal.
  final GoalModel? existing;

  @override
  State<AddGoalSheet> createState() => _AddGoalSheetState();
}

class _AddGoalSheetState extends State<AddGoalSheet> {
  final _nameCtrl   = TextEditingController();
  final _amountCtrl = TextEditingController();
  late GoalType _type;
  DateTime? _targetDate;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _nameCtrl.text   = widget.existing!.name;
      _amountCtrl.text = widget.existing!.targetAmount.toStringAsFixed(0);
      _type            = widget.existing!.type;
      _targetDate      = widget.existing!.targetDate;
    } else {
      _type = GoalType.savings;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _targetDate ?? now.add(const Duration(days: 90)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 10)),
      builder: (ctx, child) {
        final tc = ThemeColors.of(ctx);
        return Theme(
          data: Theme.of(ctx).copyWith(
            colorScheme: Theme.of(ctx).colorScheme.copyWith(
              primary: tc.lime,
              onPrimary: tc.background,
              surface: tc.surface,
              onSurface: tc.text100,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _targetDate = picked);
  }

  void _submit() {
    final name   = _nameCtrl.text.trim();
    final amount = double.tryParse(_amountCtrl.text.replaceAll(',', ''));

    if (name.isEmpty || amount == null || amount <= 0) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a goal name and valid target amount.'),
          backgroundColor: ThemeColors.of(context).red,
        ),
      );
      return;
    }

    final provider = FinanceProvider();

    if (_isEditing) {
      provider.updateGoal(widget.existing!.copyWith(
        name:           name,
        type:           _type,
        targetAmount:   amount,
        targetDate:     _targetDate,
        clearTargetDate: _targetDate == null,
      ));
    } else {
      provider.addGoal(GoalModel(
        id:           provider.newId(),
        name:         name,
        type:         _type,
        targetAmount: amount,
        createdAt:    DateTime.now(),
        targetDate:   _targetDate,
      ));
    }

    if (mounted) Navigator.pop(context);
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

            _Label('Target Amount (Rs.)', tc),
            const SizedBox(height: 6),
            _Field(
                controller: _amountCtrl,
                hint: '0.00',
                icon: Icons.currency_rupee_rounded,
                keyboardType: TextInputType.number,
                tc: tc),
            const SizedBox(height: 14),

            _Label('Target Date (Optional)', tc),
            const SizedBox(height: 6),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: tc.surface2,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: tc.border),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(children: [
                  Icon(Icons.calendar_today_rounded, color: tc.text40, size: 18),
                  const SizedBox(width: 12),
                  Text(
                    _targetDate == null
                        ? 'Pick a date'
                        : '${_targetDate!.day}/${_targetDate!.month}/${_targetDate!.year}',
                    style: TextStyle(
                        color: _targetDate == null ? tc.text40 : tc.text100,
                        fontSize: 14),
                  ),
                  const Spacer(),
                  if (_targetDate != null)
                    GestureDetector(
                      onTap: () => setState(() => _targetDate = null),
                      child: Icon(Icons.close_rounded, color: tc.text40, size: 18),
                    ),
                ]),
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: tc.background,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(
                  _isEditing ? 'Save Changes' : 'Create Goal',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
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
  const AddAmountToGoalSheet({super.key, required this.goalId, required this.goalName});
  final String goalId;
  final String goalName;

  @override
  State<AddAmountToGoalSheet> createState() => _AddAmountToGoalSheetState();
}

class _AddAmountToGoalSheetState extends State<AddAmountToGoalSheet> {
  final _amountCtrl = TextEditingController();

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  void _submit() {
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

    final completed = FinanceProvider().addAmountToGoal(widget.goalId, amount);

    if (!mounted) return;
    Navigator.pop(context);

    if (completed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🎉 Goal "${widget.goalName}" completed!'),
          backgroundColor: ThemeColors.of(context).lime,
        ),
      );
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
            'Add to "${widget.goalName}"',
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
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: tc.lime,
                foregroundColor: tc.background,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Add Amount',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
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
