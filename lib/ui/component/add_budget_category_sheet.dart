import 'package:flutter/material.dart';
import 'package:Thinkpay/core/errors/exceptions.dart';
import 'package:Thinkpay/core/repository/categoryRepo.dart';
import 'package:Thinkpay/model/budget_model.dart';
import 'package:Thinkpay/model/categoryModel.dart';
import 'package:Thinkpay/model/transaction_model.dart';
import 'package:Thinkpay/providers/finance_provider.dart';

import '../../core/constant/app_colors.dart';

class AddBudgetCategorySheet extends StatefulWidget {
  const AddBudgetCategorySheet({
    super.key,
    this.existing,
    this.initialType,
  });

  /// When provided, the sheet opens in edit mode pre-filled with this category.
  final BudgetCategory? existing;

  /// Pre-selects this type when creating a new category (ignored if [existing] is set).
  final TransactionType? initialType;

  @override
  State<AddBudgetCategorySheet> createState() => _AddBudgetCategorySheetState();
}

class _AddBudgetCategorySheetState extends State<AddBudgetCategorySheet> {
  final _nameCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _categoryRepo = CategoryRepository();
  late TransactionType _type;
  bool _isSubmitting = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _nameCtrl.text = widget.existing!.name;
      _amountCtrl.text = widget.existing!.expectedAmount.toStringAsFixed(0);
      _type = widget.existing!.type;
    } else {
      // Default: expense. If Transfer tab opened the sheet, use transferOut.
      _type = widget.initialType ?? TransactionType.expense;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;

    final name = _nameCtrl.text.trim();
    final amount = double.tryParse(_amountCtrl.text.replaceAll(',', ''));

    if (name.isEmpty || amount == null || amount <= 0) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a valid category name and expected amount.'),
          backgroundColor: ThemeColors.of(context).red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final categoryType = CategoryType.fromTransactionType(_type);
      final provider = FinanceProvider();

      if (_isEditing) {
        final updated = await _categoryRepo.updateCategory(
          widget.existing!.id,
          name: name,
          type: categoryType,
          expectedAmount: amount,
        );
        provider.updateBudget(updated.toBudgetCategory());
        if (!mounted) return;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Category updated successfully')),
        );
      } else {
        final created = await _categoryRepo.createCategory(
          name: name,
          type: categoryType,
          expectedAmount: amount,
        );
        provider.addBudget(created.toBudgetCategory());
        if (!mounted) return;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Category created successfully')),
        );
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: ThemeColors.of(context).red,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save category: ${e.toString()}'),
          backgroundColor: ThemeColors.of(context).red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
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

          // ── Type toggle ───────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
                color: tc.surface2,
                borderRadius: BorderRadius.circular(14)),
            child: Column(
              children: [
                // ── Main row: Expense | Income | Transfer ────────────────
                Row(children: [
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
                  _TypeBtn(
                    label: 'Transfer',
                    selected: _type == TransactionType.transferIn ||
                        _type == TransactionType.transferOut,
                    color: tc.intelligenceAccent,
                    onTap: () => setState(
                      // Default to transferOut when tapping Transfer
                      () => _type = TransactionType.transferOut,
                    ),
                  ),
                ]),

                // ── Sub-toggle: Transfer In | Transfer Out (only when Transfer selected)
                if (_type == TransactionType.transferIn ||
                    _type == TransactionType.transferOut) ...
                [
                  const SizedBox(height: 4),
                  Container(
                    margin: const EdgeInsets.fromLTRB(4, 0, 4, 4),
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: tc.intelligenceAccent.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: tc.intelligenceAccent.withValues(alpha: 0.2),
                        width: 0.8,
                      ),
                    ),
                    child: Row(children: [
                      _TypeBtn(
                        label: '\u2193 Transfer In',
                        selected: _type == TransactionType.transferIn,
                        color: tc.intelligenceAccent,
                        onTap: () => setState(
                          () => _type = TransactionType.transferIn,
                        ),
                      ),
                      _TypeBtn(
                        label: '\u2191 Transfer Out',
                        selected: _type == TransactionType.transferOut,
                        color: tc.intelligenceAccent,
                        onTap: () => setState(
                          () => _type = TransactionType.transferOut,
                        ),
                      ),
                    ]),
                  ),
                ],
              ],
            ),
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
              onPressed: _isSubmitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: _type == TransactionType.expense
                    ? tc.red
                    : (_type == TransactionType.income)
                        ? tc.lime
                        : tc.intelligenceAccent, // transferIn / transferOut
                foregroundColor: tc.background,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: _isSubmitting
                  ? SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation(tc.background),
                      ),
                    )
                  : Text(
                      _isEditing ? 'Save Changes' : 'Create Category',
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
