import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constant/app_colors.dart';
import 'package:Thinkpay/model/transaction_model.dart';
import 'package:Thinkpay/providers/finance_provider.dart';

class AddTransactionSheet extends StatefulWidget {
  const AddTransactionSheet({super.key});

  @override
  State<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<AddTransactionSheet> {
  final _amountCtrl = TextEditingController();
  final _noteCtrl   = TextEditingController();

  TransactionType _type     = TransactionType.expense;
  String?         _category;
  DateTime        _date     = DateTime.now();

  /// Categories are sourced exclusively from budget entries.
  List<String> get _categories {
    if (_type == TransactionType.income) {
      return FinanceProvider().incomeBudgetCategories;
    }
    return FinanceProvider().expenseBudgetCategories;
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final tc = ThemeColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: isDark
              ? ColorScheme.dark(
                  primary: tc.lime,
                  onPrimary: tc.background,
                  primaryContainer: tc.lime,
                  onPrimaryContainer: tc.background,
                  surface: tc.surface,
                  onSurface: tc.text100,
                  surfaceContainerHighest: tc.surface2,
                  onSurfaceVariant: tc.text70,
                  outline: tc.border,
                )
              : ColorScheme.light(
                  primary: tc.lime,
                  onPrimary: tc.background,
                  primaryContainer: tc.lime,
                  onPrimaryContainer: tc.background,
                  surface: tc.surface,
                  onSurface: tc.text100,
                  surfaceContainerHighest: tc.surface2,
                  onSurfaceVariant: tc.text70,
                  outline: tc.border,
                ),
          dialogTheme: DialogThemeData(
            backgroundColor: tc.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(foregroundColor: tc.lime),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null && mounted) setState(() => _date = picked);
  }

  void _submit() {
    final amount = double.tryParse(_amountCtrl.text.replaceAll(',', ''));

    if (amount == null || amount <= 0 || _category == null) {
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
      id:       FinanceProvider().newId().toString(),
      category: _category!,
      amount:   amount,
      type:     _type,
      date:     _date,
      notes:    _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
    ));

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final tc          = ThemeColors.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final cats        = _categories;
    final hasCategories = cats.isNotEmpty;
    final accentColor   = _type == TransactionType.expense
        ? tc.red
        : _type == TransactionType.income
            ? tc.lime
            : tc.intelligenceAccent;

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
            Text(
              'Add Transaction',
              style: AppTypography.headlineMd.copyWith(
                color: tc.text100,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Record a new income, expense or transfer',
              style: AppTypography.bodySm.copyWith(color: tc.text40),
            ),
            const SizedBox(height: 20),
            // ── Amount
            _Label('Amount (Rs.)', tc),
            const SizedBox(height: 8),
            _AmountField(
              controller: _amountCtrl,
              tc: tc,
              accentColor: accentColor,
            ),

            const SizedBox(height: 16),
            // ── Category (from Budget section)
            _Label('Category', tc),
            const SizedBox(height: 8),
            if (!hasCategories) ...[
              Container(
                height: 56,
                decoration: BoxDecoration(
                  color: tc.surface2,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: accentColor.withValues(alpha: 0.35)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(children: [
                  Icon(Icons.info_outline_rounded,
                      color: accentColor, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'No categories — add one in the Budget section first.',
                      style: AppTypography.bodySm.copyWith(color: tc.text40),
                    ),
                  ),
                ]),
              ),
            ] else ...[
              Container(
                decoration: BoxDecoration(
                  color: tc.surface2,
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _category,
                    hint: Text('Select category',
                        style: AppTypography.bodySm.copyWith(color: tc.text40)),
                    dropdownColor: tc.surface2,
                    isExpanded: true,
                    style: AppTypography.bodySm.copyWith(color: tc.text100),
                    iconEnabledColor: tc.text40,
                    borderRadius: BorderRadius.circular(14),
                    items: cats
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) => setState(() => _category = v),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),

            // ── Date
            _Label('Date', tc),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  color: tc.surface2,
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.calendar_today_rounded,
                        color: accentColor, size: 16),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selected date',
                        style: AppTypography.labelCaps.copyWith(
                          color: tc.text40,
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${_date.day.toString().padLeft(2, '0')} / '
                        '${_date.month.toString().padLeft(2, '0')} / '
                        '${_date.year}',
                        style: AppTypography.bodySm.copyWith(
                          color: tc.text100,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Icon(Icons.chevron_right_rounded,
                      color: tc.text40, size: 20),
                ]),
              ),
            ),
            const SizedBox(height: 28),

            // ── Submit
            SizedBox(
              width: double.infinity,
              height: 56,
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
                  style: AppTypography.bodySm.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
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
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            margin: const EdgeInsets.all(2),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: selected ? color.withValues(alpha: 0.15) : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon,
                      color: selected ? color : ThemeColors.of(context).text40,
                      size: 15),
                  const SizedBox(width: 5),
                  Text(label,
                      style: AppTypography.bodySm.copyWith(
                          color: selected
                              ? color
                              : ThemeColors.of(context).text40,
                          fontWeight: FontWeight.w600,
                          fontSize: 13)),
                ]),
          ),
        ),
      );
}

// ── Large amount field ────────────────────────────────────────────────────────
class _AmountField extends StatefulWidget {
  const _AmountField({
    required this.controller,
    required this.tc,
    required this.accentColor,
  });
  final TextEditingController controller;
  final ThemeColors tc;
  final Color accentColor;

  @override
  State<_AmountField> createState() => _AmountFieldState();
}

class _AmountFieldState extends State<_AmountField> {

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: widget.tc.surface2,
        borderRadius: BorderRadius.circular(14),

      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: widget.accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Center(
              child: Text(
                'Rs',
                style: AppTypography.labelCaps.copyWith(
                  color: widget.accentColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Focus(
              child: TextField(
                controller: widget.controller,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
                ],
                style: AppTypography.headlineMd.copyWith(
                  color: widget.tc.text100,
                  fontWeight: FontWeight.w700,
                  fontSize: 22,
                ),
                decoration: InputDecoration(
                  hintText: '0.00',
                  hintStyle: AppTypography.headlineMd.copyWith(
                    color: widget.tc.text20,
                    fontWeight: FontWeight.w700,
                    fontSize: 22,
                  ),
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shared styled text field ──────────────────────────────────────────────────
class _StyledField extends StatefulWidget {
  const _StyledField({
    required this.controller,
    required this.hint,
    required this.icon,
    required this.tc,
    required this.accentColor,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
  });
  final TextEditingController controller;
  final String    hint;
  final IconData  icon;
  final ThemeColors tc;
  final Color accentColor;
  final TextInputType keyboardType;
  final int maxLines;

  @override
  State<_StyledField> createState() => _StyledFieldState();
}

class _StyledFieldState extends State<_StyledField> {

  @override
  Widget build(BuildContext context) {
    final isMultiline = widget.maxLines > 1;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: widget.tc.surface2,
        borderRadius: BorderRadius.circular(14),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: isMultiline ? 12 : 4,
      ),
      child: Row(
        crossAxisAlignment: isMultiline
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(top: isMultiline ? 2 : 0),
            child: Icon(widget.icon,
                color: widget.accentColor ,
                size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Focus(
              child: TextField(
                controller: widget.controller,
                keyboardType: widget.keyboardType,
                maxLines: widget.maxLines,
                style: AppTypography.bodySm.copyWith(
                  color: widget.tc.text100,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: widget.hint,
                  hintStyle: AppTypography.bodySm.copyWith(
                    color: widget.tc.text40,
                  ),
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                    vertical: isMultiline ? 0 : 12,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Label ─────────────────────────────────────────────────────────────────────
class _Label extends StatelessWidget {
  const _Label(this.text, this.tc);
  final String text;
  final ThemeColors tc;
  @override
  Widget build(BuildContext context) => Text(
        text.toUpperCase(),
        style: AppTypography.labelCaps.copyWith(
          color: tc.text40,
          fontSize: 11,
          letterSpacing: 0.8,
        ),
      );
}
