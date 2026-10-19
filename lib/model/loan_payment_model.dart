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
      id: (json['id'] as num?)?.toInt() ?? 0,
      loanId: (json['loan_id'] as num?)?.toInt() ?? (json['loanId'] as num?)?.toInt() ?? 0,
      amount: double.tryParse(json['amount'].toString()) ?? 0,
      paidAt: DateTime.tryParse(json['payment_date'] as String? ?? json['paid_at'] as String? ?? '') ?? DateTime.now(),
      note: json['note'] as String?,
    );
  }

  Map<String, dynamic> toCreateJson() {
    final year = paidAt.year.toString().padLeft(4, '0');
    final month = paidAt.month.toString().padLeft(2, '0');
    final day = paidAt.day.toString().padLeft(2, '0');
    final formattedAmount = amount % 1 == 0
        ? amount.toInt().toString()
        : amount.toStringAsFixed(2);
    return {
      'loan_id': loanId,
      'amount': formattedAmount,
      'payment_date': '$year-$month-${day}T00:00:00Z',
      if (note != null && note!.trim().isNotEmpty) 'note': note!.trim(),
    };
  }
}
