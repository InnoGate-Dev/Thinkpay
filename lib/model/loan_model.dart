import 'loan_payment_model.dart';
import '../utils/loan_format.dart';

enum LoanStatus { active, paidOff, overdue }

extension LoanStatusX on LoanStatus {
  static LoanStatus fromApi(String v) {
    switch (v.toUpperCase()) {
      case 'PAID_OFF':
      case 'PAIDOFF':
      case 'CLOSED':
        return LoanStatus.paidOff;
      case 'OVERDUE':
        return LoanStatus.overdue;
      case 'ACTIVE':
      default:
        return LoanStatus.active;
    }
  }

  String get apiValue => switch (this) {
        LoanStatus.active => 'ACTIVE',
        LoanStatus.paidOff => 'PAID_OFF',
        LoanStatus.overdue => 'OVERDUE',
      };

  String get label => switch (this) {
        LoanStatus.active => 'Active',
        LoanStatus.paidOff => 'Paid Off',
        LoanStatus.overdue => 'Overdue',
      };
}

class LoanModel {
  const LoanModel({
    required this.id,
    required this.userId,
    required this.purpose,
    required this.amount,
    required this.interestRate,
    required this.loanDurationMonths,
    required this.monthlyPayment,
    required this.startDate,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.payments = const [],
  });

  final int id;
  final int userId;
  final String purpose;
  final double amount;
  final double interestRate;
  final int loanDurationMonths;
  final double monthlyPayment;
  final DateTime startDate;
  final LoanStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Populated separately (see LoanService.fetchPayments) once the loan
  /// detail screen loads. Empty by default in the list view.
  final List<LoanPaymentModel> payments;

  /// Parses the exact GET /loans response shape you shared, where several
  /// fields are wrapped as `{ "String": ..., "Valid": bool }` /
  /// `{ "Time": ..., "Valid": bool }` (Go's sql.NullString / sql.NullTime).
  factory LoanModel.fromJson(Map<String, dynamic> json) {
    return LoanModel(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      purpose: _nullString(json['purpose']) ?? 'Loan',
      amount: _parseDouble(json['amount']),
      interestRate: _parseDouble(json['interest_rate']),
      loanDurationMonths: json['loan_duration'] as int,
      monthlyPayment: _parseDouble(json['loan_month_payment']),
      startDate: _nullTime(json['sdate']) ?? DateTime.now(),
      status: LoanStatusX.fromApi(_nullString(json['loanstatus']) ?? 'ACTIVE'),
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  /// Flat payload for POST /loans — matches your Postman sample exactly
  /// (plain strings, no Valid/String wrapper — that's a read-only API shape).
  Map<String, dynamic> toCreateJson() {
    return {
      'purpose': purpose,
      'amount': amount.toStringAsFixed(2),
      'interest_rate': interestRate.toStringAsFixed(2),
      'loan_duration': loanDurationMonths,
      'loan_month_payment': monthlyPayment.toStringAsFixed(2),
      'sdate': startDate.toUtc().toIso8601String(),
      'loanstatus': status.apiValue,
    };
  }

  LoanModel copyWith({List<LoanPaymentModel>? payments, LoanStatus? status}) {
    return LoanModel(
      id: id,
      userId: userId,
      purpose: purpose,
      amount: amount,
      interestRate: interestRate,
      loanDurationMonths: loanDurationMonths,
      monthlyPayment: monthlyPayment,
      startDate: startDate,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt,
      payments: payments ?? this.payments,
    );
  }

  // ── Computed values used across the UI ──────────────────────────────
  double get totalPayable => monthlyPayment * loanDurationMonths;

  double get totalInterest => totalPayable - amount;

  /// Prefers real recorded payments; falls back to an elapsed-time estimate
  /// so the UI still shows something sensible before any payment exists.
  double get amountPaid {
    if (payments.isNotEmpty) {
      return payments.fold(0.0, (sum, p) => sum + p.amount);
    }
    return monthlyPayment * monthsElapsed;
  }

  double get remainingBalance => clampD(totalPayable - amountPaid, 0, totalPayable);

  int get monthsElapsed {
    final now = DateTime.now();
    var months = (now.year - startDate.year) * 12 + (now.month - startDate.month);
    if (now.day < startDate.day) months -= 1;
    return clampI(months, 0, loanDurationMonths);
  }

  int get paymentsMadeCount => payments.length;

  int get remainingMonths => clampI(loanDurationMonths - paymentsMadeCount, 0, loanDurationMonths);

  double get progress => totalPayable <= 0 ? 0.0 : clampD(amountPaid / totalPayable, 0, 1);

  DateTime get nextPaymentDate =>
      DateTime(startDate.year, startDate.month + paymentsMadeCount + 1, startDate.day);

  int get paymentDay => startDate.day;

  static String? _nullString(dynamic field) {
    if (field == null) return null;
    if (field is String) return field;
    if (field is Map) {
      final valid = field['Valid'] == true;
      return valid ? field['String'] as String? : null;
    }
    return null;
  }

  static DateTime? _nullTime(dynamic field) {
    if (field == null) return null;
    if (field is String) return DateTime.tryParse(field);
    if (field is Map) {
      final valid = field['Valid'] == true;
      if (!valid) return null;
      return DateTime.tryParse(field['Time'] as String? ?? '');
    }
    return null;
  }

  static double _parseDouble(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0;
    return 0;
  }
}
