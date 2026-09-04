import 'package:flutter/material.dart';
import 'package:Thinkpay/model/budget_model.dart';
import 'package:Thinkpay/model/transaction_model.dart';
import 'package:Thinkpay/providers/finance_provider.dart';

import '../../core/constant/app_colors.dart';

class AddBudgetSheet extends StatefulWidget {
  const AddBudgetSheet({
    super.key,
    this.existing,
    this.initialType,
  });

  /// When provided, the sheet opens in edit mode pre-filled with this category.
  final BudgetCategory? existing;

  /// Pre-selects this type when creating a new category (ignored if [existing] is set).
  final TransactionType? initialType;

  @override
  State<AddBudgetSheet> createState() => _AddBudgetSheetState();
}

class _AddBudgetSheetState extends State<AddBudgetSheet> {
  final _nameCtrl   = TextEditingController();
  final _amountCtrl = TextEditingController();
  late TransactionType _type;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _nameCtrl.text   = widget.existing!.name;
      _amountCtrl.text = widget.existing!.expectedAmount.toStringAsFixed(0);
      _type            = widget.existing!.type;
    } else {
      _type = widget.initialType ?? TransactionType.expense;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final name   = _nameCtrl.text.trim();
    final amount = double.tryParse(_amountCtrl.text.replaceAll(',', ''));

    if (name.isEmpty || amount == null || amount <= 0) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please fill all fields.'),
          backgroundColor: ThemeColors.of(context).red,
        ),
      );
      return;
    }

    final provider = FinanceProvider();

    if (_isEditing) {
      provider.updateBudget(widget.existing!.copyWith(
        name:           name,
        expectedAmount: amount,
        type:           _type,
      ));
    } else {
      provider.addBudget(BudgetCategory(
        id:             provider.newId(),
        name:           name,
        expectedAmount: amount,
        type:           _type,
      ));
    }

    if (mounted) Navigator.pop(context);
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
          // ── Handle ──────────────────────────────────────────────────────
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                  color: tc.text20,
                  borderRadius: BorderRadius.circular(4)),
            ),
          ),
          const SizedBox(height: 20),

          // ── Title ───────────────────────────────────────────────────────
          Text(
            _isEditing ? 'Edit Budget Category' : 'Add Budget Category',
            style: TextStyle(
                color: tc.text100,
                fontSize: 20,
                fontWeight: FontWeight.w700),
          ),
          if (_isEditing) ...[
            const SizedBox(height: 4),
            Text(
              'Update the details for this category.',
              style: TextStyle(color: tc.text40, fontSize: 13),
            ),
          ],
          const SizedBox(height: 20),

          // ── Type toggle ──────────────────────────────────────────────────
          Container(
            decoration: BoxDecoration(
                color: tc.surface2,
                borderRadius: BorderRadius.circular(14)),
            child: Row(children: [
              _TypeBtn(
                label: 'Expense',
                selected: _type == TransactionType.expense,
                color: tc.red,
                onTap: () => setState(() => _type = TransactionType.expense),
              ),
              _TypeBtn(
                label: 'Income',
                selected: _type == TransactionType.income,
                color: tc.lime,
                onTap: () => setState(() => _type = TransactionType.income),
              ),
            ]),
          ),
          const SizedBox(height: 16),

          _Label('Category Name', tc),
          const SizedBox(height: 6),
          _Field(
              controller: _nameCtrl,
              hint: 'e.g. Food',
              icon: Icons.label_outline_rounded,
              tc: tc),
          const SizedBox(height: 14),

          _Label('Expected Amount (Rs.)', tc),
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
                backgroundColor: _type == TransactionType.expense ? tc.red : tc.lime,
                foregroundColor: tc.background,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(
                _isEditing ? 'Save Changes' : 'Create Budget',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
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
    required this.selected,
    required this.color,
    required this.onTap,
  });
  final String label;
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
              child: Text(
                label,
                style: TextStyle(
                    color: selected
                        ? color
                        : ThemeColors.of(context).text40,
                    fontWeight: FontWeight.w600,
                    fontSize: 14),
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
