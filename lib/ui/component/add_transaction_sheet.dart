import 'package:flutter/material.dart';
import 'package:Thinkpay/constant/app_colors.dart';
import 'package:Thinkpay/model/transaction_model.dart';
import 'package:Thinkpay/providers/finance_provider.dart';

class AddTransactionSheet extends StatefulWidget {
  const AddTransactionSheet({super.key});

  @override
  State<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<AddTransactionSheet> {
  final _titleCtrl  = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _noteCtrl   = TextEditingController();

  TransactionType _type     = TransactionType.expense;
  String?         _category;
  DateTime        _date     = DateTime.now();

  /// Categories are sourced exclusively from budget entries.
  List<String> get _categories => _type == TransactionType.income
      ? FinanceProvider().incomeBudgetCategories
      : FinanceProvider().expenseBudgetCategories;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final tc = ThemeColors.of(context);
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.dark(
            primary: tc.lime,
            onPrimary: tc.background,
            surface: tc.surface,
          ),
          dialogTheme: DialogThemeData(backgroundColor: tc.surface),
        ),
        child: child!,
      ),
    );
    if (picked != null && mounted) setState(() => _date = picked);
  }

  void _submit() {
    final title  = _titleCtrl.text.trim();
    final amount = double.tryParse(_amountCtrl.text.replaceAll(',', ''));

    if (title.isEmpty || amount == null || amount <= 0 || _category == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please fill all required fields.'),
          backgroundColor: ThemeColors.of(context).red,
        ),
      );
      return;
    }

    FinanceProvider().addTransaction(TransactionModel(
      id:       FinanceProvider().newId(),
      title:    title,
      category: _category!,
      amount:   amount,
      type:     _type,
      date:     _date,
      note:     _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
    ));

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final tc          = ThemeColors.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final cats        = _categories;
    final hasCategories = cats.isNotEmpty;
    final accentColor   = _type == TransactionType.expense ? tc.red : tc.lime;

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
            // ── Handle
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                    color: tc.text20,
                    borderRadius: BorderRadius.circular(4)),
              ),
            ),
            const SizedBox(height: 20),

            // ── Title
            Text('Add Transaction',
                style: TextStyle(
                    color: tc.text100,
                    fontSize: 20,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),

            // ── Type toggle
            Container(
              decoration: BoxDecoration(
                  color: tc.surface2,
                  borderRadius: BorderRadius.circular(14)),
              child: Row(children: [
                _TypeBtn(
                  label: 'Expense',
                  icon: Icons.arrow_upward_rounded,
                  selected: _type == TransactionType.expense,
                  color: tc.red,
                  onTap: () => setState(() {
                    _type = TransactionType.expense;
                    _category = null;
                  }),
                ),
                _TypeBtn(
                  label: 'Income',
                  icon: Icons.arrow_downward_rounded,
                  selected: _type == TransactionType.income,
                  color: tc.lime,
                  onTap: () => setState(() {
                    _type = TransactionType.income;
                    _category = null;
                  }),
                ),
              ]),
            ),
            const SizedBox(height: 16),

            // ── Amount
            _Label('Amount (Rs.)', tc),
            const SizedBox(height: 6),
            _Field(
                controller: _amountCtrl,
                hint: '0.00',
                icon: Icons.currency_rupee_rounded,
                keyboardType: TextInputType.number,
                tc: tc),
            const SizedBox(height: 14),

            // ── Transaction Title
            _Label('Title', tc),
            const SizedBox(height: 6),
            _Field(
                controller: _titleCtrl,
                hint: 'e.g. Monthly Rent',
                icon: Icons.title_rounded,
                tc: tc),
            const SizedBox(height: 14),

            // ── Category (from Budget section)
            _Label('Category', tc),
            const SizedBox(height: 6),
            if (!hasCategories) ...[
              // Empty-state when no budget categories exist for this type
              Container(
                height: 50,
                decoration: BoxDecoration(
                  color: tc.surface2,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: accentColor.withValues(alpha: 0.3)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(children: [
                  Icon(Icons.info_outline_rounded,
                      color: accentColor, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'No categories — add one in the Budget section first.',
                      style: TextStyle(color: tc.text40, fontSize: 13),
                    ),
                  ),
                ]),
              ),
            ] else ...[
              Container(
                decoration: BoxDecoration(
                  color: tc.surface2,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: tc.border),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _category,
                    hint: Text('Select category',
                        style:
                            TextStyle(color: tc.text40, fontSize: 14)),
                    dropdownColor: tc.surface2,
                    isExpanded: true,
                    style: TextStyle(color: tc.text100, fontSize: 14),
                    iconEnabledColor: tc.text40,
                    items: cats
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) => setState(() => _category = v),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 14),

            // ── Date
            _Label('Date', tc),
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
                  Icon(Icons.calendar_today_rounded,
                      color: tc.text40, size: 18),
                  const SizedBox(width: 12),
                  Text(
                    '${_date.day}/${_date.month}/${_date.year}',
                    style: TextStyle(color: tc.text100, fontSize: 14),
                  ),
                  const Spacer(),
                  Icon(Icons.chevron_right_rounded,
                      color: tc.text40, size: 18),
                ]),
              ),
            ),
            const SizedBox(height: 14),

            // ── Note (optional)
            _Label('Note (optional)', tc),
            const SizedBox(height: 6),
            _Field(
                controller: _noteCtrl,
                hint: 'Add a note…',
                icon: Icons.notes_rounded,
                tc: tc),
            const SizedBox(height: 24),

            // ── Submit
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: hasCategories ? _submit : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: tc.background,
                  disabledBackgroundColor: tc.surface2,
                  disabledForegroundColor: tc.text40,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(
                  hasCategories
                      ? 'Add Transaction'
                      : 'Add a Budget Category First',
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

// ── Type toggle button ────────────────────────────────────────────────────────
class _TypeBtn extends StatelessWidget {
  const _TypeBtn({
    required this.label,
    required this.icon,
    required this.selected,
    required this.color,
    required this.onTap,
  });
  final String    label;
  final IconData  icon;
  final bool      selected;
  final Color     color;
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
              color: selected ? color.withValues(alpha: 0.15) : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              border: selected
                  ? Border.all(color: color.withValues(alpha: 0.4))
                  : null,
            ),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon,
                      color: selected ? color : ThemeColors.of(context).text40,
                      size: 16),
                  const SizedBox(width: 6),
                  Text(label,
                      style: TextStyle(
                          color: selected
                              ? color
                              : ThemeColors.of(context).text40,
                          fontWeight: FontWeight.w600,
                          fontSize: 14)),
                ]),
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
  final String    hint;
  final IconData  icon;
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
