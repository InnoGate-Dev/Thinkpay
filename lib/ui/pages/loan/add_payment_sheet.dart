import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Thinkpay/core/constant/app_colors.dart';

import '../../../model/loan_model.dart';
import '../../../model/loan_payment_model.dart';
import '../../../services/loan_service.dart';


/// Shows a bottom sheet to record a payment against [loan].
/// Returns the created [LoanPaymentModel], or null if the sheet was dismissed.
Future<LoanPaymentModel?> showAddPaymentSheet({
  required BuildContext context,
  required LoanModel loan,
  LoanService? service,
}) {
  final activeService = service ?? LoanService();
  return showModalBottomSheet<LoanPaymentModel>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _AddPaymentSheet(loan: loan, service: activeService),
  );
}

class _AddPaymentSheet extends StatefulWidget {
  const _AddPaymentSheet({required this.loan, required this.service});
  final LoanModel loan;
  final LoanService service;

  @override
  State<_AddPaymentSheet> createState() => _AddPaymentSheetState();
}

class _AddPaymentSheetState extends State<_AddPaymentSheet> {
  late final TextEditingController _amountCtrl =
      TextEditingController(text: widget.loan.monthlyPayment.toStringAsFixed(2));
  final TextEditingController _noteCtrl = TextEditingController();
  late DateTime _paidAt = DateTime.now();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final amount = double.tryParse(_amountCtrl.text.trim());
    if (amount == null || amount <= 0) {
      setState(() => _error = 'Enter a valid amount');
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final payment = await widget.service.addPayment(
        LoanPaymentModel(
          id: 0,
          loanId: widget.loan.id,
          amount: amount,
          paidAt: _paidAt,
          note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
        ),
      );
      if (mounted) Navigator.pop(context, payment);
    } catch (_) {
      setState(() {
        _error = 'Could not record the payment. Please try again.';
        _submitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: BoxDecoration(
          color: tc.background,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(color: tc.text20, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            Text('Record Payment', style: GoogleFonts.manrope(color: tc.text100, fontSize: 17, fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text(widget.loan.purpose, style: GoogleFonts.inter(color: tc.text40, fontSize: 12)),
            const SizedBox(height: 18),

            Text('Amount', style: GoogleFonts.inter(color: tc.text70, fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            TextField(
              controller: _amountCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: GoogleFonts.manrope(color: tc.text100, fontSize: 15, fontWeight: FontWeight.w700),
              decoration: InputDecoration(
                prefixText: 'Rs. ',
                filled: true,
                fillColor: tc.surface2,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
            const SizedBox(height: 14),

            Text('Payment Date', style: GoogleFonts.inter(color: tc.text70, fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _paidAt,
                  firstDate: widget.loan.startDate,
                  lastDate: DateTime.now(),
                );
                if (picked != null) setState(() => _paidAt = picked);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(color: tc.surface2, borderRadius: BorderRadius.circular(10)),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today_outlined, size: 16, color: tc.text40),
                    const SizedBox(width: 10),
                    Text(
                      '${_paidAt.year}-${_paidAt.month.toString().padLeft(2, '0')}-${_paidAt.day.toString().padLeft(2, '0')}',
                      style: GoogleFonts.inter(color: tc.text100, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            Text('Note (optional)', style: GoogleFonts.inter(color: tc.text70, fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            TextField(
              controller: _noteCtrl,
              style: GoogleFonts.inter(color: tc.text100, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'e.g. Paid via bank transfer',
                hintStyle: GoogleFonts.inter(color: tc.text20, fontSize: 13),
                filled: true,
                fillColor: tc.surface2,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),

            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(_error!, style: GoogleFonts.inter(color: tc.accentExpense, fontSize: 12)),
            ],

            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: tc.coreAction,
                  foregroundColor: tc.background,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _submitting
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: tc.background),
                      )
                    : const Text('Save Payment'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
