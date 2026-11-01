import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:Thinkpay/core/constant/app_colors.dart';
import 'package:Thinkpay/model/onboarding/onboarding_draft.dart';
import 'package:Thinkpay/ui/pages/onboarding/sheets/loan_editor_sheet.dart';
import 'package:Thinkpay/ui/pages/onboarding/widgets/onboarding_scaffold.dart';
import 'package:Thinkpay/ui/pages/onboarding/widgets/onboarding_widgets.dart';

/// Step 5 — loans, with the already-paid figure kept front and centre.
class LoansStep extends StatefulWidget {
  const LoansStep({
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
  State<LoansStep> createState() => _LoansStepState();
}

class _LoansStepState extends State<LoansStep> {
  bool? _hasLoans;

  @override
  void initState() {
    super.initState();
    if (widget.draft.loans.isNotEmpty) {
      _hasLoans = true;
    } else if (widget.draft.noLoans) {
      _hasLoans = false;
    }
  }

  void _answer(bool value) {
    HapticFeedback.selectionClick();
    setState(() {
      _hasLoans = value;
      widget.draft.noLoans = !value;
    });
  }

  Future<void> _addLoan() async {
    final loan = await showLoanEditorSheet(
      context: context,
      symbol: symbolForCode(widget.draft.currencyCode),
    );
    if (loan == null || !mounted) return;
    setState(() => widget.draft.loans.add(loan));
    HapticFeedback.lightImpact();
  }

  Future<void> _editLoan(int index) async {
    final loan = await showLoanEditorSheet(
      context: context,
      symbol: symbolForCode(widget.draft.currencyCode),
      initial: widget.draft.loans[index],
    );
    if (loan == null || !mounted) return;
    setState(() => widget.draft.loans[index] = loan);
  }

  void _removeLoan(int index) {
    setState(() => widget.draft.loans.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    final symbol = symbolForCode(widget.draft.currencyCode);

    return OnboardingScaffold(
      stepIndex: widget.stepIndex,
      stepLabel: 'Loans',
      onBack: widget.onBack,
      onSkip: widget.onSkip,
      content: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.base,
          AppSpacing.md,
          AppSpacing.md,
        ),
        children: [
          const StepTitle(
            title: 'Are you paying off a loan?',
            subtitle:
                'We track the remaining balance from what you have '
                'already paid.',
          ),
          const SizedBox(height: AppSpacing.md),

          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: GateOption(
                    icon: Icons.account_balance_rounded,
                    title: 'Yes, one or more',
                    subtitle: 'Add what you owe today',
                    selected: _hasLoans == true,
                    onTap: () => _answer(true),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: GateOption(
                    icon: Icons.remove_circle_outline_rounded,
                    title: 'No loans',
                    subtitle: 'Nothing to track',
                    selected: _hasLoans == false,
                    onTap: () => _answer(false),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          if (_hasLoans == true) ...[
            if (widget.draft.loans.isEmpty)
              const EmptyHint(
                'No loans added yet. Add one now, or any time from the '
                'Loan tab.',
              )
            else
              for (var i = 0; i < widget.draft.loans.length; i++) ...[
                _LoanTile(
                  loan: widget.draft.loans[i],
                  symbol: symbol,
                  onEdit: () => _editLoan(i),
                  onRemove: () => _removeLoan(i),
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: _addLoan,
                icon: Icon(Icons.add_rounded, size: 18, color: tc.text70),
                style: TextButton.styleFrom(
                  foregroundColor: tc.text70,
                  minimumSize: const Size(44, 44),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.base,
                  ),
                ),
                label: Text(
                  widget.draft.loans.isEmpty
                      ? 'Add a loan'
                      : 'Add another loan',
                  style: AppTypography.bodySm.copyWith(
                    fontWeight: FontWeight.w600,
                    color: tc.text70,
                  ),
                ),
              ),
            ),
            if (widget.draft.loans.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.base),
              InfoNote(
                icon: Icons.info_outline_rounded,
                text:
                    '${widget.draft.loans.length} loan'
                    '${widget.draft.loans.length == 1 ? '' : 's'} · '
                    '$symbol${formatMoney(widget.draft.totalRemainingDebt, decimals: 0)} '
                    'still to pay.',
              ),
            ],
          ] else if (_hasLoans == false)
            const InfoNote(
              icon: Icons.check_circle_outline_rounded,
              text:
                  'Good to know. You can add a loan any time from the '
                  'Loan tab.',
              tone: NoteTone.positive,
            )
          else
            const EmptyHint(
              'Pick either option to continue. Nothing is required here.',
            ),
        ],
      ),
      footer: PrimaryCta(label: 'Continue', onTap: widget.onNext),
    );
  }
}

class _LoanTile extends StatelessWidget {
  const _LoanTile({
    required this.loan,
    required this.symbol,
    required this.onEdit,
    required this.onRemove,
  });

  final LoanDraft loan;
  final String symbol;
  final VoidCallback onEdit;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    final progress = loan.principal <= 0
        ? 0.0
        : (loan.alreadyPaid / loan.principal).clamp(0.0, 1.0).toDouble();

    return TileCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  loan.purpose,
                  style: AppTypography.bodyMd.copyWith(
                    color: tc.text100,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              TileActionButton(
                icon: Icons.edit_outlined,
                onTap: onEdit,
                tooltip: 'Edit loan',
              ),
              TileActionButton(
                icon: Icons.close_rounded,
                onTap: onRemove,
                tooltip: 'Remove loan',
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.base),
          Text(
            '$symbol${formatMoney(loan.principal, decimals: 0)} · '
            '${loan.durationMonths} months · '
            '$symbol${formatMoney(loan.monthlyPayment, decimals: 0)}/month',
            style: AppTypography.bodySm.copyWith(
              color: tc.text40,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          MiniProgress(value: progress),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Text(
                'Paid $symbol${formatMoney(loan.alreadyPaid, decimals: 0)}',
                style: AppTypography.bodySm.copyWith(
                  color: tc.intelligenceAccent,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                loan.isSettled
                    ? 'Paid off'
                    : 'Left $symbol${formatMoney(loan.remaining, decimals: 0)}',
                style: AppTypography.bodySm.copyWith(
                  color: tc.text70,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
