import 'package:flutter/material.dart';

import 'package:Thinkpay/core/constant/app_colors.dart';
import 'package:Thinkpay/model/onboarding/onboarding_draft.dart';
import 'package:Thinkpay/ui/pages/onboarding/widgets/onboarding_widgets.dart';

/// Opens the loan editor. Pops with the saved [LoanDraft], or null on cancel.
Future<LoanDraft?> showLoanEditorSheet({
  required BuildContext context,
  required String symbol,
  LoanDraft? initial,
}) {
  return showOnboardingSheet<LoanDraft>(
    context: context,
    builder: (_) => _LoanEditorSheet(symbol: symbol, initial: initial),
  );
}

class _LoanEditorSheet extends StatefulWidget {
  const _LoanEditorSheet({required this.symbol, this.initial});

  final String symbol;
  final LoanDraft? initial;

  @override
  State<_LoanEditorSheet> createState() => _LoanEditorSheetState();
}

class _LoanEditorSheetState extends State<_LoanEditorSheet> {
  late final TextEditingController _purposeCtrl;
  late final TextEditingController _principalCtrl;
  late final TextEditingController _paidCtrl;
  late final TextEditingController _rateCtrl;
  late final TextEditingController _durationCtrl;
  late final TextEditingController _monthlyCtrl;

  late DateTime _startDate;
  int _paymentsMade = 0;
  bool _showDetails = false;
  bool _monthlyTouched = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final i = widget.initial;
    _purposeCtrl = TextEditingController(text: i?.purpose ?? '');
    _principalCtrl = TextEditingController(
      text: i == null || i.principal == 0 ? '' : plainAmount(i.principal),
    );
    _paidCtrl = TextEditingController(
      text: i == null || i.alreadyPaid == 0 ? '' : plainAmount(i.alreadyPaid),
    );
    _rateCtrl = TextEditingController(
      text: i == null ? '' : plainAmount(i.ratePct),
    );
    _durationCtrl = TextEditingController(text: '${i?.durationMonths ?? 24}');
    _monthlyCtrl = TextEditingController(
      text: i == null || i.monthlyPayment == 0
          ? ''
          : plainAmount(i.monthlyPayment),
    );
    _startDate =
        i?.startDate ?? DateTime(DateTime.now().year, DateTime.now().month, 1);
    _paymentsMade = i?.paymentsMade ?? 0;
    _monthlyTouched = i != null && i.monthlyPayment > 0;
  }

  @override
  void dispose() {
    _purposeCtrl.dispose();
    _principalCtrl.dispose();
    _paidCtrl.dispose();
    _rateCtrl.dispose();
    _durationCtrl.dispose();
    _monthlyCtrl.dispose();
    super.dispose();
  }

  double get _principal => parseMoney(_principalCtrl.text) ?? 0;
  double get _paid => parseMoney(_paidCtrl.text) ?? 0;
  double get _remaining =>
      (_principal - _paid).clamp(0.0, _principal).toDouble();
  double get _monthly => parseMoney(_monthlyCtrl.text) ?? 0;
  int get _duration => int.tryParse(_durationCtrl.text.trim()) ?? 0;

  /// Suggests a monthly figure from principal, rate and duration. The field
  /// stays editable, and manual edits win.
  void _autoMonthly() {
    if (_monthlyTouched) return;
    final rate = parseMoney(_rateCtrl.text) ?? 0;
    if (_principal <= 0 || _duration <= 0) return;
    final monthly = (_principal + _principal * rate / 100) / _duration;
    _monthlyCtrl.text = monthly.toStringAsFixed(2);
  }

  /// Suggests how many instalments the paid figure represents.
  void _autoPayments() {
    if (_monthly <= 0) return;
    _paymentsMade = (_paid / _monthly).floor().clamp(0, _duration).toInt();
  }

  void _stepPayments(int delta) {
    final max = _duration == 0 ? 0 : _duration;
    setState(() {
      _paymentsMade = (_paymentsMade + delta).clamp(0, max).toInt();
      if (_monthly > 0) {
        _paidCtrl.text = plainAmount(_monthly * _paymentsMade);
      }
    });
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && mounted) setState(() => _startDate = picked);
  }

  void _save() {
    final purpose = _purposeCtrl.text.trim();
    if (purpose.isEmpty) {
      setState(() => _error = 'Give the loan a name so you recognise it.');
      return;
    }
    if (_principal <= 0) {
      setState(() => _error = 'Enter the original loan amount.');
      return;
    }

    final monthly = _monthly > 0
        ? _monthly
        : (_duration > 0
              ? (_principal +
                        _principal * (parseMoney(_rateCtrl.text) ?? 0) / 100) /
                    _duration
              : 0.0);

    Navigator.pop(
      context,
      LoanDraft(
        purpose: purpose,
        principal: _principal,
        alreadyPaid: _paid.clamp(0.0, _principal).toDouble(),
        paymentsMade: _paymentsMade,
        ratePct: parseMoney(_rateCtrl.text) ?? 0,
        durationMonths: _duration == 0 ? 12 : _duration,
        monthlyPayment: monthly,
        startDate: _startDate,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    final symbol = widget.symbol;
    final settled = _principal > 0 && _paid >= _principal;

    return SheetShell(
      title: widget.initial == null ? 'Add a loan' : 'Edit loan',
      subtitle: 'Add how much you have already paid so the balance is right.',
      onClose: () => Navigator.pop(context),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SheetTextField(
            controller: _purposeCtrl,
            label: 'Loan name',
            hint: 'e.g. Car loan',
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: AppSpacing.marginMobile),
          SheetTextField(
            controller: _principalCtrl,
            label: 'Original amount',
            hint: '1850000',
            prefixText: '$symbol ',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) {
              _autoMonthly();
              setState(() {});
            },
          ),
          const SizedBox(height: AppSpacing.marginMobile),

          // Already paid is the field that keeps the balance honest.
          SheetTextField(
            controller: _paidCtrl,
            label: 'Already paid',
            hint: '450000',
            prefixText: '$symbol ',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) => setState(_autoPayments),
          ),
          const SizedBox(height: AppSpacing.base),
          _PaymentsStepper(
            count: _paymentsMade,
            onMinus: () => _stepPayments(-1),
            onPlus: () => _stepPayments(1),
          ),
          const SizedBox(height: AppSpacing.marginMobile),

          _DerivedBox(
            symbol: symbol,
            principal: _principal,
            paid: _paid,
            remaining: _remaining,
          ),

          if (settled) ...[
            const SizedBox(height: AppSpacing.sm),
            const InfoNote(
              icon: Icons.check_circle_outline_rounded,
              text: "This loan is fully repaid. We'll mark it as paid off.",
              tone: NoteTone.positive,
            ),
          ],

          const SizedBox(height: AppSpacing.marginMobile),
          _DetailsToggle(
            expanded: _showDetails,
            summary:
                '${fmtPercent(parseMoney(_rateCtrl.text) ?? 0)}% · '
                '$_duration months · '
                '$symbol${formatMoney(_monthly, decimals: 0)}/month',
            onTap: () => setState(() => _showDetails = !_showDetails),
          ),
          if (_showDetails) ...[
            const SizedBox(height: AppSpacing.marginMobile),
            Row(
              children: [
                Expanded(
                  child: SheetTextField(
                    controller: _rateCtrl,
                    label: 'Interest rate',
                    hint: '0',
                    suffixText: '% p.a.',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    onChanged: (_) {
                      _autoMonthly();
                      setState(() {});
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: SheetTextField(
                    controller: _durationCtrl,
                    label: 'Duration',
                    hint: '24',
                    suffixText: 'months',
                    keyboardType: TextInputType.number,
                    onChanged: (_) {
                      _autoMonthly();
                      setState(() {});
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.marginMobile),
            SheetTextField(
              controller: _monthlyCtrl,
              label: 'Monthly payment',
              hint: '0.00',
              prefixText: '$symbol ',
              helperText: 'Suggested from the loan above — adjust if needed',
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              onChanged: (_) {
                _monthlyTouched = true;
                setState(_autoPayments);
              },
            ),
            const SizedBox(height: AppSpacing.marginMobile),
            _DateRow(
              label: 'Start date',
              value:
                  '${_startDate.year}-'
                  '${_startDate.month.toString().padLeft(2, '0')}-'
                  '${_startDate.day.toString().padLeft(2, '0')}',
              onTap: _pickStartDate,
            ),
          ],

          if (_error != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(_error!, style: AppTypography.bodySm.copyWith(color: tc.red)),
          ],
        ],
      ),
      footer: PrimaryCta(
        label: widget.initial == null ? 'Save loan' : 'Save changes',
        onTap: _save,
      ),
    );
  }
}

class _DateRow extends StatelessWidget {
  const _DateRow({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.marginMobile,
        ),
        decoration: BoxDecoration(
          color: tc.surface2,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_outlined, size: 16, color: tc.text40),
            const SizedBox(width: AppSpacing.sm),
            Text(label, style: AppTypography.bodySm.copyWith(color: tc.text70)),
            const Spacer(),
            Text(
              value,
              style: AppTypography.dataMono.copyWith(
                color: tc.text100,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Icon(Icons.chevron_right_rounded, size: 20, color: tc.text40),
          ],
        ),
      ),
    );
  }
}

class _PaymentsStepper extends StatelessWidget {
  const _PaymentsStepper({
    required this.count,
    required this.onMinus,
    required this.onPlus,
  });

  final int count;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);

    return Row(
      children: [
        Expanded(
          child: Text(
            'Payments already made',
            style: AppTypography.bodySm.copyWith(color: tc.text70),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: tc.surface2,
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
          child: Row(
            children: [
              _StepperButton(icon: Icons.remove_rounded, onTap: onMinus),
              SizedBox(
                width: 32,
                child: Text(
                  '$count',
                  textAlign: TextAlign.center,
                  style: AppTypography.dataMono.copyWith(
                    color: tc.text100,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _StepperButton(icon: Icons.add_rounded, onTap: onPlus),
            ],
          ),
        ),
      ],
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.full),
      child: SizedBox(
        width: 36,
        height: 36,
        child: Icon(icon, size: 18, color: tc.text70),
      ),
    );
  }
}

class _DerivedBox extends StatelessWidget {
  const _DerivedBox({
    required this.symbol,
    required this.principal,
    required this.paid,
    required this.remaining,
  });

  final String symbol;
  final double principal;
  final double paid;
  final double remaining;

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: tc.surface2,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        children: [
          _row(
            tc,
            'Original',
            '$symbol ${formatMoney(principal, decimals: 0)}',
          ),
          const SizedBox(height: 6),
          _row(tc, 'Paid so far', '$symbol ${formatMoney(paid, decimals: 0)}'),
          const SizedBox(height: AppSpacing.base),
          Divider(height: 1, color: tc.divider),
          const SizedBox(height: AppSpacing.base),
          _row(
            tc,
            'Remaining',
            '$symbol ${formatMoney(remaining, decimals: 0)}',
            highlight: true,
          ),
        ],
      ),
    );
  }

  Widget _row(
    ThemeColors tc,
    String label,
    String value, {
    bool highlight = false,
  }) {
    return Row(
      children: [
        Text(
          label,
          style: AppTypography.bodySm.copyWith(
            color: highlight ? tc.text100 : tc.text70,
            fontWeight: highlight ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: AppTypography.dataMono.copyWith(
            color: highlight ? tc.intelligenceAccent : tc.text100,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _DetailsToggle extends StatelessWidget {
  const _DetailsToggle({
    required this.expanded,
    required this.summary,
    required this.onTap,
  });

  final bool expanded;
  final String summary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: tc.divider),
        ),
        child: Row(
          children: [
            Icon(Icons.tune_rounded, size: 16, color: tc.text40),
            const SizedBox(width: AppSpacing.base),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Repayment details',
                    style: AppTypography.bodySm.copyWith(
                      color: tc.text100,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    summary,
                    style: AppTypography.bodySm.copyWith(
                      color: tc.text40,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedRotation(
              turns: expanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                Icons.expand_more_rounded,
                size: 20,
                color: tc.text40,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
