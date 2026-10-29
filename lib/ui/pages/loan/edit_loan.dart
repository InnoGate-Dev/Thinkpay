import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Thinkpay/core/constant/app_colors.dart';

import '../../../model/loan_model.dart';
import '../../../services/loan_service.dart';


class EditLoanDialog extends StatefulWidget {
  EditLoanDialog({
    super.key,
    required this.loan,
    LoanService? service,
  }) : service = service ?? LoanService();

  final LoanModel loan;
  final LoanService service;

  /// Shows the edit loan dialog and returns the updated loan (or null).
  static Future<LoanModel?> show(
      BuildContext context, {
        required LoanModel loan,
        LoanService? service,
      }) {
    return showDialog<LoanModel>(
      context: context,
      barrierDismissible: false,
      builder: (_) => EditLoanDialog(loan: loan, service: service),
    );
  }

  @override
  State<EditLoanDialog> createState() => _EditLoanDialogState();
}

class _EditLoanDialogState extends State<EditLoanDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _purposeCtrl;
  late final TextEditingController _amountCtrl;
  late final TextEditingController _rateCtrl;
  late final TextEditingController _durationCtrl;
  late final TextEditingController _paymentCtrl;
  late DateTime _startDate;
  late LoanStatus _status;
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final l = widget.loan;
    _purposeCtrl = TextEditingController(text: l.purpose);
    _amountCtrl = TextEditingController(text: _fmt(l.amount));
    _rateCtrl = TextEditingController(text: _fmt(l.interestRate));
    _durationCtrl = TextEditingController(text: l.loanDurationMonths.toString());
    _paymentCtrl = TextEditingController(text: _fmt(l.monthlyPayment));
    _startDate = l.startDate;
    _status = l.status;
  }

  String _fmt(double v) {
    // Show integer amounts without trailing .0
    if (v == v.roundToDouble()) return v.toInt().toString();
    return v.toString();
  }

  @override
  void dispose() {
    _purposeCtrl.dispose();
    _amountCtrl.dispose();
    _rateCtrl.dispose();
    _durationCtrl.dispose();
    _paymentCtrl.dispose();
    super.dispose();
  }

  /// Suggests a monthly payment from principal, rate & duration using a
  /// simple flat-interest estimate. The field stays editable so the user
  /// (or a more precise amortization calc down the line) can override it.
  void _autoCalcPayment() {
    final p = double.tryParse(_amountCtrl.text);
    final r = double.tryParse(_rateCtrl.text);
    final n = int.tryParse(_durationCtrl.text);
    if (p == null || r == null || n == null || n <= 0) return;
    final totalInterest = p * (r / 100);
    final monthly = (p + totalInterest) / n;
    _paymentCtrl.text = monthly.toStringAsFixed(2);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final updated = widget.loan.copyWith(
        purpose: _purposeCtrl.text.trim(),
        amount: double.parse(_amountCtrl.text.trim()),
        interestRate: double.parse(_rateCtrl.text.trim()),
        loanDurationMonths: int.parse(_durationCtrl.text.trim()),
        monthlyPayment: double.parse(_paymentCtrl.text.trim()),
        startDate: _startDate,
        status: _status,
        updatedAt: DateTime.now(),
      );
      final saved = await widget.service.updateLoan(updated);
      if (mounted) Navigator.pop(context, saved);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Could not update the loan. Please check your details and try again.';
        _submitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    final media = MediaQuery.of(context);

    return Dialog(
      backgroundColor: tc.background,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 520,
          maxHeight: media.size.height * 0.85,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Edit Loan',
                      style: GoogleFonts.manrope(
                        color: tc.text100,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _submitting ? null : () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: tc.text70, size: 20),
                  ),
                ],
              ),
            ),

            // Form body
            Flexible(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                  shrinkWrap: true,
                  children: [
                    _label(tc, 'Loan Purpose'),
                    _textField(tc, _purposeCtrl,
                        hint: 'e.g. Home Renovation', validator: _req),
                    const SizedBox(height: 16),

                    _label(tc, 'Principal Amount'),
                    _textField(
                      tc,
                      _amountCtrl,
                      hint: '0.00',
                      prefix: 'Rs. ',
                      keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                      validator: _reqNumber,
                      onChanged: (_) => setState(_autoCalcPayment),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _label(tc, 'Interest Rate (% p.a.)'),
                              _textField(
                                tc,
                                _rateCtrl,
                                hint: '0',
                                keyboardType: const TextInputType.numberWithOptions(
                                    decimal: true),
                                validator: _reqNumber,
                                onChanged: (_) => setState(_autoCalcPayment),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _label(tc, 'Duration (months)'),
                              _textField(
                                tc,
                                _durationCtrl,
                                hint: '0',
                                keyboardType: TextInputType.number,
                                validator: _reqNumber,
                                onChanged: (_) => setState(_autoCalcPayment),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    _label(tc, 'Monthly Payment'),
                    _textField(
                      tc,
                      _paymentCtrl,
                      hint: '0.00',
                      prefix: 'Rs. ',
                      keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                      validator: _reqNumber,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Auto-suggested from principal, rate & duration — adjust if needed.',
                      style: GoogleFonts.inter(color: tc.text40, fontSize: 11),
                    ),
                    const SizedBox(height: 16),

                    _label(tc, 'Start Date'),
                    InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: _submitting
                          ? null
                          : () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _startDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setState(() => _startDate = picked);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 14),
                        decoration: BoxDecoration(
                          color: tc.surface2,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today_outlined,
                                size: 16, color: tc.text40),
                            const SizedBox(width: 10),
                            Text(
                              '${_startDate.year}-${_startDate.month.toString().padLeft(2, '0')}-${_startDate.day.toString().padLeft(2, '0')}',
                              style: GoogleFonts.inter(
                                  color: tc.text100, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    _label(tc, 'Status'),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: tc.surface2,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<LoanStatus>(
                          value: _status,
                          isExpanded: true,
                          dropdownColor: tc.surface2,
                          icon: Icon(Icons.keyboard_arrow_down,
                              color: tc.text70, size: 18),
                          style: GoogleFonts.manrope(
                            color: tc.text100,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          onChanged: _submitting
                              ? null
                              : (v) {
                            if (v != null) setState(() => _status = v);
                          },
                          items: LoanStatus.values
                              .map((s) => DropdownMenuItem(
                            value: s,
                            child: Text(_statusLabel(s)),
                          ))
                              .toList(),
                        ),
                      ),
                    ),

                    if (_error != null) ...[
                      const SizedBox(height: 14),
                      Text(_error!,
                          style: GoogleFonts.inter(
                              color: tc.accentExpense, fontSize: 12)),
                    ],
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),

            // Footer buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                      _submitting ? null : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: tc.text20),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.manrope(
                          color: tc.text70,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submitting ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: tc.coreAction,
                        foregroundColor: tc.background,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _submitting
                          ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: tc.background,
                        ),
                      )
                          : Text(
                        'Save Changes',
                        style: GoogleFonts.manrope(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _statusLabel(LoanStatus s) {
    switch (s) {
      case LoanStatus.active:
        return 'Active';
      case LoanStatus.paidOff:
        return 'Paid Off';
      case LoanStatus.overdue:
        return 'Overdue';
    }
  }

  Widget _label(ThemeColors tc, String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text,
      style: GoogleFonts.inter(
          color: tc.text70, fontSize: 12, fontWeight: FontWeight.w600),
    ),
  );

  Widget _textField(
      ThemeColors tc,
      TextEditingController ctrl, {
        String? hint,
        String? prefix,
        TextInputType? keyboardType,
        String? Function(String?)? validator,
        void Function(String)? onChanged,
      }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged,
      style: GoogleFonts.manrope(
          color: tc.text100, fontSize: 14, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        hintText: hint,
        prefixText: prefix,
        hintStyle: GoogleFonts.inter(color: tc.text20, fontSize: 13),
        filled: true,
        fillColor: tc.surface2,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: tc.accentExpense)),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }

  String? _req(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Required' : null;

  String? _reqNumber(String? v) {
    if (v == null || v.trim().isEmpty) return 'Required';
    if (double.tryParse(v.trim()) == null) return 'Enter a valid number';
    return null;
  }
}