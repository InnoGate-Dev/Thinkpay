import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constant/app_colors.dart';
import '../../core/repository/categoryRepo.dart';
import '../../core/repository/goalRepo.dart';
import '../../core/repository/goalTrasection.dart';
import '../../core/repository/loanRepo.dart';
import '../../core/repository/trasectionRepo.dart';
import '../../model/budget_model.dart';
import '../../model/goal_model.dart';
import '../../model/loan_model.dart';
import 'package:Thinkpay/model/transaction_model.dart';
import 'package:Thinkpay/providers/finance_provider.dart';

// ── Transfer destination discriminator ────────────────────────────────────────
/// Describes what the user is transferring funds to in the Transfer tab.
enum _TransferDest { goal, loan }

class _TransferTarget {
  const _TransferTarget.goal(this.goal)
      : type = _TransferDest.goal,
        loan = null;
  const _TransferTarget.loan(this.loan)
      : type = _TransferDest.loan,
        goal = null;

  final _TransferDest type;
  final GoalModel? goal;
  final LoanModel? loan;

  String get label => type == _TransferDest.goal ? goal!.name : loan!.purpose;
}

class AddTransactionSheet extends StatefulWidget {
  const AddTransactionSheet({super.key, this.initialType});

  /// Optionally pre-select a transaction type (Expense / Income / Transfer).
  final TransactionType? initialType;

  @override
  State<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<AddTransactionSheet> {
  final _amountCtrl = TextEditingController();
  final _noteCtrl   = TextEditingController();

  late TransactionType _type;
  String?         _category;
  DateTime        _date = DateTime.now();

  // ── Transfer-specific state ────────────────────────────────────────────────
  bool _loadingTransferTargets = false;
  List<GoalModel> _goals = [];
  List<LoanModel> _loans = [];
  _TransferTarget? _selectedTarget;

  bool _submitting = false;

  final _transactionRepo = TransactionRepository();
  final _categoryRepo = CategoryRepository();

  @override
  void initState() {
    super.initState();
    _type = widget.initialType ?? TransactionType.expense;
    if (FinanceProvider().budgets.isEmpty) {
      _fetchCategories();
    }
    if (_type == TransactionType.transferOut ||
        _type == TransactionType.transferIn) {
      _fetchTransferTargets();
    }
  }

  Future<void> _fetchCategories() async {
    try {
      final categories = await _categoryRepo.getCategories();
      if (mounted) {
        FinanceProvider().setBudgetCategories(
          categories.map((c) => c.toBudgetCategory()).toList(),
        );
        setState(() {});
      }
    } catch (_) {}
  }

  /// Categories are sourced exclusively from budget entries.
  List<String> get _categories {
    if (_type == TransactionType.income) {
      return FinanceProvider().incomeBudgetCategories;
    }
    return FinanceProvider().expenseBudgetCategories;
  }

  /// Fetches goals and loans for the Transfer destination picker.
  Future<void> _fetchTransferTargets() async {
    setState(() => _loadingTransferTargets = true);
    try {
      final results = await Future.wait([
        GoalRepository().getGoals(),
        LoanRepository().getLoans(),
      ]);
      if (mounted) {
        setState(() {
          _goals = results[0] as List<GoalModel>;
          _loans = results[1] as List<LoanModel>;
        });
      }
    } catch (_) {
      // Silently fail; user will see empty list.
    } finally {
      if (mounted) setState(() => _loadingTransferTargets = false);
    }
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

  Future<void> _submit() async {
    final amount = double.tryParse(_amountCtrl.text.replaceAll(',', ''));

    if (amount == null || amount <= 0) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a valid amount.'),
          backgroundColor: ThemeColors.of(context).red,
        ),
      );
      return;
    }

    // ── Transfer tab: route to goal or loan transaction table ────────────────
    if (_type == TransactionType.transferOut ||
        _type == TransactionType.transferIn) {
      if (_selectedTarget == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please select a Goal or Loan to transfer to.'),
            backgroundColor: ThemeColors.of(context).red,
          ),
        );
        return;
      }
      await _submitTransfer(amount);
      return;
    }

    // ── Income / Expense tab ─────────────────────────────────────────────────
    if (_category == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a category.'),
          backgroundColor: ThemeColors.of(context).red,
        ),
      );
      return;
    }

    final budgets = FinanceProvider().budgets;
    final matchingCategory = budgets.firstWhere(
      (b) => b.name == _category,
      orElse: () => BudgetCategory(
        id: 0,
        name: _category!,
        expectedAmount: 0,
        type: _type,
      ),
    );

    setState(() => _submitting = true);

    try {
      final note = _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim();
      final createdApiTx = await _transactionRepo.createTransaction(
        categoryId: matchingCategory.id,
        type: _type,
        amount: amount,
        date: _date,
        notes: note,
      );

      FinanceProvider().addTransaction(
        createdApiTx.toLocalModel(fallbackCategory: _category),
      );

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add transaction: $e'),
          backgroundColor: ThemeColors.of(context).red,
        ),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  /// Routes a transfer to the correct backend table:
  /// - Goal → goal transaction table (via [GoalTrasectionRepository])
  /// - Loan → loan payment table (via [LoanRepository])
  Future<void> _submitTransfer(double amount) async {
    final target = _selectedTarget!;
    setState(() => _submitting = true);
    try {
      if (target.type == _TransferDest.goal) {
        final goal = target.goal!;
        final idParts = goal.id.split('_');
        final numericGoalId = int.tryParse(idParts.first);
        if (numericGoalId == null) throw Exception('Invalid goal ID: ${goal.id}');

        // 1. Record goal transaction
        await GoalTrasectionRepository().createGoalTrasection(
          goalId: numericGoalId,
          amount: amount,
          transactionDateTime: _date,
        );
        // 2. Update goal's saved amount
        final updatedGoal = await GoalRepository().addAmountToGoal(
          goal.id,
          amount,
          goal,
        );
        FinanceProvider().addAmountToGoal(goal.id, updatedGoal.savedAmount);
      } else {
        final loan = target.loan!;
        // Record loan payment
        await LoanRepository().addLoanPayment(
          loanId: loan.id,
          amount: amount,
          paidAt: _date,
          note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
        );
      }

      // Add a local TransactionModel so it shows in the transactions page immediately.
      FinanceProvider().addTransaction(TransactionModel(
        id:       FinanceProvider().newId().toString(),
        category: target.label,
        amount:   amount,
        type:     TransactionType.transferOut,
        date:     _date,
        notes:    _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
      ));

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Transfer failed: $e'),
          backgroundColor: ThemeColors.of(context).red,
        ),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  bool get _isTransfer =>
      _type == TransactionType.transferOut ||
      _type == TransactionType.transferIn;

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

            // ── Type Toggle (3 buttons: Expense | Income | Transfer)
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: tc.surface2,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  _TypeBtn(
                    label: 'Expense',
                    icon: Icons.arrow_upward_rounded,
                    selected: _type == TransactionType.expense,
                    color: tc.red,
                    onTap: () => setState(() {
                      _type = TransactionType.expense;
                      _category = null;
                      _selectedTarget = null;
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
                      _selectedTarget = null;
                    }),
                  ),
                  _TypeBtn(
                    label: 'Transfer',
                    icon: Icons.swap_horiz_rounded,
                    selected: _isTransfer,
                    color: tc.intelligenceAccent,
                    onTap: () {
                      setState(() {
                        _type = TransactionType.transferOut;
                        _category = null;
                        _selectedTarget = null;
                      });
                      if (_goals.isEmpty && _loans.isEmpty) {
                        _fetchTransferTargets();
                      }
                    },
                  ),
                ],
              ),
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

            // ── Category picker (Expense / Income) or Transfer destination ───
            if (_isTransfer) ...[
              _Label('Transfer To (Goal or Loan)', tc),
              const SizedBox(height: 8),
              _TransferTargetPicker(
                goals: _goals,
                loans: _loans,
                selected: _selectedTarget,
                loading: _loadingTransferTargets,
                accentColor: accentColor,
                tc: tc,
                onChanged: (t) => setState(() => _selectedTarget = t),
              ),
            ] else ...[
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
            const SizedBox(height: 16),

            // ── Notes
            _Label('Notes', tc),
            const SizedBox(height: 8),
            _StyledField(
              controller: _noteCtrl,
              hint: 'Add a note (optional)',
              icon: Icons.notes_rounded,
              tc: tc,
              accentColor: accentColor,
            ),
            const SizedBox(height: 28),

            // ── Submit
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: (_submitting || (!_isTransfer && !hasCategories))
                    ? null
                    : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: tc.background,
                  disabledBackgroundColor: tc.surface2,
                  disabledForegroundColor: tc.text40,
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
                        !_isTransfer && !hasCategories
                            ? 'Add a Budget Category First'
                            : 'Add Transaction',
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

// ── Transfer target picker ─────────────────────────────────────────────────────
/// Shows a scrollable list of goals and loans for the user to pick from.
class _TransferTargetPicker extends StatelessWidget {
  const _TransferTargetPicker({
    required this.goals,
    required this.loans,
    required this.selected,
    required this.loading,
    required this.accentColor,
    required this.tc,
    required this.onChanged,
  });

  final List<GoalModel> goals;
  final List<LoanModel> loans;
  final _TransferTarget? selected;
  final bool loading;
  final Color accentColor;
  final ThemeColors tc;
  final ValueChanged<_TransferTarget> onChanged;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Container(
        height: 56,
        decoration: BoxDecoration(
          color: tc.surface2,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: accentColor,
            ),
          ),
        ),
      );
    }

    if (goals.isEmpty && loans.isEmpty) {
      return Container(
        height: 56,
        decoration: BoxDecoration(
          color: tc.surface2,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: accentColor.withValues(alpha: 0.35)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(children: [
          Icon(Icons.info_outline_rounded, color: accentColor, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'No goals or loans found. Add one first.',
              style: AppTypography.bodySm.copyWith(color: tc.text40),
            ),
          ),
        ]),
      );
    }

    // Build unified dropdown items from goals + loans.
    final items = <DropdownMenuItem<_TransferTarget>>[];
    for (final g in goals) {
      final t = _TransferTarget.goal(g);
      items.add(DropdownMenuItem(
        value: t,
        child: Row(
          children: [
            Icon(Icons.flag_rounded, color: tc.coreAction, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                g.name,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.bodySm.copyWith(color: tc.text100),
              ),
            ),
            Text(
              'Goal',
              style: AppTypography.bodySm.copyWith(
                color: tc.coreAction,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ));
    }
    for (final l in loans) {
      final t = _TransferTarget.loan(l);
      items.add(DropdownMenuItem(
        value: t,
        child: Row(
          children: [
            Icon(Icons.account_balance_rounded,
                color: tc.intelligenceAccent, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l.purpose,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.bodySm.copyWith(color: tc.text100),
              ),
            ),
            Text(
              'Loan',
              style: AppTypography.bodySm.copyWith(
                color: tc.intelligenceAccent,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ));
    }

    return Container(
      decoration: BoxDecoration(
        color: tc.surface2,
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<_TransferTarget>(
          value: selected,
          hint: Text('Select Goal or Loan',
              style: AppTypography.bodySm.copyWith(color: tc.text40)),
          dropdownColor: tc.surface2,
          isExpanded: true,
          iconEnabledColor: tc.text40,
          borderRadius: BorderRadius.circular(14),
          items: items,
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}

// ── Type toggle button ────────────────────────────────────────────────────────
class _TypeBtn extends StatelessWidget {
  const _TypeBtn({
    super.key,
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
    super.key,
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
