import 'package:flutter/material.dart';

import 'package:Thinkpay/core/constant/app_colors.dart';
import 'package:Thinkpay/model/onboarding/onboarding_draft.dart';
import 'package:Thinkpay/ui/pages/onboarding/widgets/onboarding_widgets.dart';

/// Opens the onboarding income / expense editor.
///
/// Pops with the saved [MoneyItem], or null when dismissed.
Future<MoneyItem?> showMoneyEditorSheet({
  required BuildContext context,
  required bool isIncome,
  required String symbol,
  MoneyItem? initial,
  String? presetLabel,
}) {
  return showModalBottomSheet<MoneyItem>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: const Color(0x99000000),
    builder: (_) => _MoneyEditorSheet(
      isIncome: isIncome,
      symbol: symbol,
      initial: initial,
      presetLabel: presetLabel,
    ),
  );
}

/// Onboarding copy of `AddBudgetCategorySheet` — same handle, title, labelled
/// fields and 54-high filled button, but it writes to the onboarding draft
/// instead of the category API, and the amount carries the picked currency.
class _MoneyEditorSheet extends StatefulWidget {
  const _MoneyEditorSheet({
    required this.isIncome,
    required this.symbol,
    this.initial,
    this.presetLabel,
  });

  final bool isIncome;
  final String symbol;
  final MoneyItem? initial;

  /// Label handed over by a preset chip: pre-fills the name and sends focus
  /// straight to the amount.
  final String? presetLabel;

  @override
  State<_MoneyEditorSheet> createState() => _MoneyEditorSheetState();
}

class _MoneyEditorSheetState extends State<_MoneyEditorSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _amountCtrl;

  String? _error;

  bool get _isEditing => widget.initial != null;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(
      text: widget.initial?.label ?? widget.presetLabel ?? '',
    );
    _amountCtrl = TextEditingController(
      text: widget.initial == null ? '' : plainAmount(widget.initial!.amount),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameCtrl.text.trim();
    final amount = parseMoney(_amountCtrl.text);

    if (name.isEmpty) {
      setState(() => _error = 'Give this a name.');
      return;
    }
    if (amount == null || amount <= 0) {
      setState(() => _error = 'Enter an amount greater than zero.');
      return;
    }

    Navigator.pop(context, MoneyItem(label: name, amount: amount));
  }

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final accent = widget.isIncome ? tc.lime : tc.red;

    final noun = widget.isIncome ? 'income' : 'expense';
    final title = _isEditing ? 'Edit $noun' : 'Add $noun';

    // A preset already named the row, so the keyboard goes to the number.
    final startOnAmount = _nameCtrl.text.trim().isNotEmpty;

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
            // ── Handle ──────────────────────────────────────────────────────
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: tc.text20,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ── Title ───────────────────────────────────────────────────────
            Text(
              title,
              style: TextStyle(
                color: tc.text100,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _isEditing
                  ? 'Update the name or the monthly amount.'
                  : 'Rough numbers are fine — you can change this any time.',
              style: TextStyle(color: tc.text40, fontSize: 13),
            ),
            const SizedBox(height: 20),

            _EditorLabel(widget.isIncome ? 'Income name' : 'Expense name', tc),
            const SizedBox(height: 6),
            _EditorField(
              controller: _nameCtrl,
              hint: widget.isIncome ? 'e.g. Salary' : 'e.g. Groceries',
              icon: Icons.label_outline_rounded,
              tc: tc,
              textCapitalization: TextCapitalization.words,
              autofocus: !startOnAmount,
              onChanged: (_) {
                if (_error != null) setState(() => _error = null);
              },
            ),
            const SizedBox(height: 14),

            _EditorLabel('Monthly amount (${widget.symbol})', tc),
            const SizedBox(height: 6),
            _EditorField(
              controller: _amountCtrl,
              hint: '0.00',
              icon: Icons.payments_outlined,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              textInputAction: TextInputAction.done,
              tc: tc,
              autofocus: startOnAmount,
              onChanged: (_) {
                if (_error != null) setState(() => _error = null);
              },
              onSubmitted: (_) => _save(),
            ),

            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!, style: TextStyle(color: tc.red, fontSize: 12.5)),
            ],
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: tc.background,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  _isEditing ? 'Save changes' : 'Add $noun',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shared field ──────────────────────────────────────────────────────────────
class _EditorField extends StatelessWidget {
  const _EditorField({
    required this.controller,
    required this.hint,
    required this.icon,
    required this.tc,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.textCapitalization = TextCapitalization.none,
    this.autofocus = false,
    this.onChanged,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final ThemeColors tc;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final TextCapitalization textCapitalization;
  final bool autofocus;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) => Container(
    height: 50,
    decoration: BoxDecoration(
      color: tc.surface2,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: tc.border),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 14),
    child: Row(
      children: [
        Icon(icon, color: tc.text40, size: 18),
        const SizedBox(width: 12),
        Expanded(
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            textCapitalization: textCapitalization,
            autofocus: autofocus,
            textInputAction: textInputAction,
            onChanged: onChanged,
            onSubmitted: onSubmitted,
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
      ],
    ),
  );
}

// ── Label ─────────────────────────────────────────────────────────────────────
class _EditorLabel extends StatelessWidget {
  const _EditorLabel(this.text, this.tc);

  final String text;
  final ThemeColors tc;

  @override
  Widget build(BuildContext context) => Text(
    text.toUpperCase(),
    style: TextStyle(
      color: tc.text40,
      fontSize: 11,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.8,
    ),
  );
}
