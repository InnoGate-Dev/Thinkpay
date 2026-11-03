import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constant/app_colors.dart';
import '../../core/repository/categoryRepo.dart';
import '../../core/repository/goalRepo.dart';
import '../../core/repository/goalTrasection.dart';
import '../../core/repository/loanRepo.dart';
import '../../core/repository/trasectionRepo.dart';
import '../../core/utils/number_format.dart';
import '../../model/categoryModel.dart';
import '../../model/goal_model.dart';
import '../../model/transaction_model.dart';
import '../../providers/finance_provider.dart';

// ── Record kind ───────────────────────────────────────────────────────────────
/// Which backend table a ledger row actually lives in — decides the endpoint an
/// edit or a delete is sent to.
///
/// The transactions screen merges three tables into one list, so a row's origin
/// has to travel with it rather than being inferred from the UI type.
enum TransactionRecordKind {
  /// `PUT|DELETE /transactions/{id}`
  transaction,

  /// `PUT|DELETE /goaltransactions/{id}`
  goalTransfer,

  /// `PUT|DELETE /loans/{loanId}/payments/{id}`
  loanPayment,
}

/// Everything [TransactionEditSheet] needs to update or delete one record.
///
/// The calling screen resolves the display strings, so the sheet stays free of
/// knowledge about the screen's private unified model.
class TransactionEditDraft {
  const TransactionEditDraft({
    required this.kind,
    required this.recordId,
    required this.recordRef,
    required this.title,
    required this.amount,
    required this.date,
    required this.type,
    this.categoryId,
    this.goalId,
    this.goal,
    this.loanId,
  });

  final TransactionRecordKind kind;

  /// Primary key of the row inside its own table.
  final int recordId;

  /// Human reference shown as a caption, e.g. `TXN-42`.
  final String recordRef;

  /// Headline shown while editing — category, goal or loan name.
  final String title;

  final double amount;
  final DateTime date;
  final TransactionType type;

  /// Existing `category_id`. `PUT /transactions/{id}` always needs one, so the
  /// current value is resent even when the user does not change it.
  final int? categoryId;

  /// Goal attached to a regular TRANSFER row; preserved so the edit does not
  /// drop the goal link.
  final int? goalId;

  /// Goal a transfer was paid into — its saved balance follows the edit.
  final GoalModel? goal;

  /// Parent loan of a payment row.
  final int? loanId;

  /// Only plain income / expense rows may have their category and type
  /// re-picked: TRANSFER rows require a `goal_id` plus a category of matching
  /// type, and OTHER rows have no matching category bucket in the picker.
  bool get canPickCategoryAndType =>
      kind == TransactionRecordKind.transaction &&
      (type == TransactionType.income || type == TransactionType.expense);
}

/// Bottom sheet form that edits one ledger record.
///
/// Pops with `true` when the backend record actually changed, so the caller
/// knows it has to reload the list. Deletion is not offered here — the caller
/// owns the confirmation flow, which keeps the destructive path in one place.
class TransactionEditSheet extends StatefulWidget {
  const TransactionEditSheet({super.key, required this.draft});

  final TransactionEditDraft draft;

  @override
  State<TransactionEditSheet> createState() => _TransactionEditSheetState();
}

class _TransactionEditSheetState extends State<TransactionEditSheet> {
  final _amountCtrl = TextEditingController();
  final _categoryRepo = CategoryRepository();
  final _transactionRepo = TransactionRepository();
  final _goalTransactionRepo = GoalTrasectionRepository();
  final _goalRepo = GoalRepository();
  final _loanRepo = LoanRepository();

  late TransactionType _type;
  late DateTime _date;
  int? _categoryId;
  List<Category> _categories = [];
  bool _loadingCategories = false;

  /// True while the update request is in flight.
  bool _saving = false;

  bool get _isBusy => _saving;

  @override
  void initState() {
    super.initState();
    _type = widget.draft.type;
    _date = widget.draft.date;
    _categoryId = widget.draft.categoryId;
    _amountCtrl.text = groupedNumber(
      widget.draft.amount,
      decimals: 2,
      trimZeros: true,
    );
    if (widget.draft.canPickCategoryAndType) {
      _loadCategories();
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  // ── Data ────────────────────────────────────────────────────────────────────
  /// Loads the user's categories so the row can be re-filed. A failure leaves
  /// the picker empty and the edit sheet falls back to amount + date only.
  Future<void> _loadCategories() async {
    setState(() => _loadingCategories = true);
    try {
      final categories = await _categoryRepo.getCategories();
      if (mounted) setState(() => _categories = categories);
    } catch (_) {
      // Non-fatal: the rest of the form still works.
    } finally {
      if (mounted) setState(() => _loadingCategories = false);
    }
  }

  /// Categories valid for the currently selected direction.
  List<Category> get _selectableCategories {
    final wantsIncome = _type == TransactionType.income;
    return _categories.where((c) {
      return wantsIncome
          ? c.type == CategoryType.income || c.type == CategoryType.otherIn
          : c.type == CategoryType.expense || c.type == CategoryType.otherOut;
    }).toList();
  }

  // ── Parsing / formatting ────────────────────────────────────────────────────
  /// API literal for [type]. [TransactionType.apiValue] collapses
  /// `transferOut` / `transferIn` onto `EXPENSE` / `INCOME`, which would turn a
  /// transfer into a plain expense on save.
  String _apiTypeValue(TransactionType type) {
    switch (type) {
      case TransactionType.income:
        return 'INCOME';
      case TransactionType.expense:
        return 'EXPENSE';
      case TransactionType.transferIn:
        return 'TRANSFER_IN';
      case TransactionType.transferOut:
        return 'TRANSFER_OUT';
      case TransactionType.otherIn:
        return 'OTHER_IN';
      case TransactionType.otherOut:
        return 'OTHER_OUT';
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: ThemeColors.of(context).red,
      ),
    );
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

  // ── Save ────────────────────────────────────────────────────────────────────
  Future<void> _save() async {
    final amount = parseAmount(_amountCtrl.text);
    if (amount == null || amount <= 0) {
      _showError('Please enter a valid amount.');
      return;
    }
    if (_categoryId == null &&
        widget.draft.kind == TransactionRecordKind.transaction) {
      _showError('This record needs a category before it can be updated.');
      return;
    }

    setState(() => _saving = true);
    try {
      switch (widget.draft.kind) {
        case TransactionRecordKind.transaction:
          await _updateTransaction(amount);
        case TransactionRecordKind.goalTransfer:
          await _updateGoalTransfer(amount);
        case TransactionRecordKind.loanPayment:
          await _updateLoanPayment(amount);
      }
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      _showError('Update failed: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _updateTransaction(double amount) async {
    await _transactionRepo.updateTransaction(
      widget.draft.recordId,
      categoryId: _categoryId!,
      type: _type,
      amount: amount,
      date: _date,
      goalId: widget.draft.goalId,
      apiType: _apiTypeValue(_type),
    );
  }

  /// `goaltrasections` rows never touch the goal balance on the server, so the
  /// difference is applied to the goal here — the same reconciliation the add
  /// sheet performs after creating a transfer.
  Future<void> _updateGoalTransfer(double amount) async {
    await _goalTransactionRepo.updateGoalTrasection(
      widget.draft.recordId,
      amount: amount,
      transactionDateTime: _date,
    );

    final goal = widget.draft.goal;
    final delta = amount - widget.draft.amount;
    if (goal != null && delta.abs() >= 0.01) {
      final updated = await _goalRepo.addAmountToGoal(goal.id, delta, goal);
      FinanceProvider().addAmountToGoal(goal.id, updated.savedAmount);
    }
  }

  Future<void> _updateLoanPayment(double amount) async {
    await _loanRepo.updateLoanPayment(
      loanId: widget.draft.loanId!,
      paymentId: widget.draft.recordId,
      amount: amount,
      paidAt: _date,
    );
  }

  // ── Build ───────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final accent = _type == TransactionType.expense
        ? tc.accentExpense
        : _type == TransactionType.income
            ? tc.coreAction
            : tc.intelligenceAccent;
    final categories = _selectableCategories;
    final showPicker = widget.draft.canPickCategoryAndType;

    return Container(
      decoration: BoxDecoration(
        color: tc.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.xl),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.md + bottomInset,
      ),
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
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Header ──────────────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Edit record',
                        style: AppTypography.headlineMd.copyWith(
                          color: tc.text100,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${widget.draft.title} · ${widget.draft.recordRef}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:
                            AppTypography.bodySm.copyWith(color: tc.text40),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: _isBusy ? null : () => Navigator.pop(context),
                  icon: Icon(Icons.close_rounded, color: tc.text40, size: 20),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),

            // ── Amount ──────────────────────────────────────────────────────
            _SectionLabel(label: 'AMOUNT', tc: tc),
            const SizedBox(height: AppSpacing.xs),
            Container(
              height: 58,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.marginMobile,
              ),
              decoration: BoxDecoration(
                color: tc.surface2,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: tc.border, width: 0.8),
              ),
              child: Row(
                children: [
                  Text(
                    activeCurrencySymbol,
                    style: AppTypography.bodyMd.copyWith(color: tc.text40),
                  ),
                  const SizedBox(width: AppSpacing.base),
                  Expanded(
                    child: TextField(
                      controller: _amountCtrl,
                      enabled: !_isBusy,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'[0-9.,]'),
                        ),
                      ],
                      style: AppTypography.headlineMd.copyWith(
                        color: accent,
                        fontWeight: FontWeight.w800,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Type ────────────────────────────────────────────────────────
            if (showPicker) ...[
              const SizedBox(height: AppSpacing.marginMobile),
              _SectionLabel(label: 'TYPE', tc: tc),
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  _ChoicePill(
                    label: '↑ Expense',
                    selected: _type == TransactionType.expense,
                    color: tc.accentExpense,
                    tc: tc,
                    onTap: _isBusy
                        ? null
                        : () => setState(
                              () => _type = TransactionType.expense,
                            ),
                  ),
                  const SizedBox(width: AppSpacing.base),
                  _ChoicePill(
                    label: '↓ Income',
                    selected: _type == TransactionType.income,
                    color: tc.coreAction,
                    tc: tc,
                    onTap: _isBusy
                        ? null
                        : () => setState(
                              () => _type = TransactionType.income,
                            ),
                  ),
                ],
              ),
            ],

            // ── Category ────────────────────────────────────────────────────
            if (showPicker) ...[
              const SizedBox(height: AppSpacing.marginMobile),
              _SectionLabel(label: 'CATEGORY', tc: tc),
              const SizedBox(height: AppSpacing.xs),
              if (_loadingCategories)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: tc.coreAction,
                    ),
                  ),
                )
              else if (categories.isEmpty)
                Text(
                  'No categories available — amount and date are still editable.',
                  style: AppTypography.bodySm.copyWith(color: tc.text40),
                )
              else
                Wrap(
                  spacing: AppSpacing.base,
                  runSpacing: AppSpacing.base,
                  children: [
                    for (final c in categories)
                      _ChoicePill(
                        label: c.name,
                        selected: _categoryId == c.id,
                        color: accent,
                        tc: tc,
                        onTap: _isBusy
                            ? null
                            : () => setState(() => _categoryId = c.id),
                      ),
                  ],
                ),
            ],

            // ── Date ────────────────────────────────────────────────────────
            const SizedBox(height: AppSpacing.marginMobile),
            _SectionLabel(label: 'DATE', tc: tc),
            const SizedBox(height: AppSpacing.xs),
            InkWell(
              onTap: _isBusy ? null : _pickDate,
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: Container(
                height: 52,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.marginMobile,
                ),
                decoration: BoxDecoration(
                  color: tc.surface2,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: tc.border, width: 0.8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 16,
                      color: tc.text40,
                    ),
                    const SizedBox(width: AppSpacing.base),
                    Expanded(
                      child: Text(
                        _longDate(_date),
                        style: AppTypography.bodyMd.copyWith(
                          color: tc.text100,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.expand_more_rounded,
                      size: 18,
                      color: tc.text40,
                    ),
                  ],
                ),
              ),
            ),

            // ── Actions ─────────────────────────────────────────────────────
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: TextButton(
                onPressed: _isBusy ? null : _save,
                style: TextButton.styleFrom(
                  backgroundColor: accent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
                child: _saving
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: tc.background,
                        ),
                      )
                    : Text(
                        'Save changes',
                        style: AppTypography.bodySm.copyWith(
                          color: tc.background,
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

// ── Pieces ────────────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, required this.tc});

  final String label;
  final ThemeColors tc;

  @override
  Widget build(BuildContext context) => Text(
        label,
        style: AppTypography.labelCaps.copyWith(
          color: tc.text40,
          fontSize: 10,
          letterSpacing: 0.8,
        ),
      );
}

class _ChoicePill extends StatelessWidget {
  const _ChoicePill({
    required this.label,
    required this.selected,
    required this.color,
    required this.tc,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color color;
  final ThemeColors tc;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? color.withValues(alpha: 0.12) : tc.surface2,
            borderRadius: BorderRadius.circular(AppRadius.base),
            border: Border.all(
              color: selected ? color.withValues(alpha: 0.4) : tc.border,
              width: 0.8,
            ),
          ),
          child: Text(
            label,
            style: AppTypography.bodySm.copyWith(
              color: selected ? color : tc.text70,
              fontSize: 12,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      );
}

/// `12 November 2026` — full month so the edited date is unambiguous.
String _longDate(DateTime d) {
  const months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];
  return '${d.day} ${months[d.month - 1]} ${d.year}';
}
