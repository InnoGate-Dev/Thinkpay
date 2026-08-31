/// A single recorded repayment against a loan.
///
/// Suggested backend contract (adjust to match your actual routes):
///   GET  /loans/:id/payments  -> { "data": [LoanPaymentModel, ...] }
///   POST /loans/:id/payments  -> { "data": LoanPaymentModel }
class LoanPaymentModel {
  const LoanPaymentModel({
    required this.id,
    required this.loanId,
    required this.amount,
    required this.paidAt,
    this.note,
  });

  final int id;
  final int loanId;
  final double amount;
  final DateTime paidAt;
  final String? note;

  factory LoanPaymentModel.fromJson(Map<String, dynamic> json) {
    return LoanPaymentModel(
      id: json['id'] as int,
      loanId: json['loan_id'] as int,
      amount: double.tryParse(json['amount'].toString()) ?? 0,
      paidAt: DateTime.tryParse(json['paid_at'] as String? ?? '') ?? DateTime.now(),
      note: json['note'] as String?,
    );
  }

  Map<String, dynamic> toCreateJson() => {
        'loan_id': loanId,
        'amount': amount.toStringAsFixed(2),
        'paid_at': paidAt.toUtc().toIso8601String(),
        if (note != null && note!.trim().isNotEmpty) 'note': note!.trim(),
      };
}
