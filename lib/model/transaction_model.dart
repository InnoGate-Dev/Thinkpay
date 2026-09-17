enum TransactionType {
  income,
  expense,
  transferIn,
  transferOut,
  otherIn,
  otherOut;

  String get apiValue {
    switch (this) {
      case TransactionType.income:
        return 'INCOME';
      case TransactionType.expense:
        return 'EXPENSE';
      case TransactionType.transferIn:
        return 'INCOME';
      case TransactionType.transferOut:
        return 'EXPENSE';
      case TransactionType.otherIn:
        return 'OTHER_IN';
      case TransactionType.otherOut:
        return 'OTHER_OUT';
    }
  }

  static TransactionType fromApi(String value) {
    switch (value.toUpperCase()) {
      case 'INCOME':
        return TransactionType.income;
      case 'EXPENSE':
        return TransactionType.expense;
      case 'TRANSFER_IN':
        return TransactionType.transferIn;
      case 'TRANSFER_OUT':
        return TransactionType.transferOut;
      case 'TRANSFER':
        // Fallback for legacy
        return TransactionType.transferOut;
      default:
        return TransactionType.expense;
    }
  }
}

class TransactionModel {
  final String id;
  final String category;
  final double amount;
  final TransactionType type;
  final DateTime date;
  final String? notes;

  TransactionModel({
    required this.id,
    required this.category,
    required this.amount,
    required this.type,
    required this.date,
    this.notes,
  });

  TransactionModel copyWith({
    String? id,
    String? title,
    String? category,
    double? amount,
    TransactionType? type,
    DateTime? date,
    String? notes,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      date: date ?? this.date,
      notes: notes ?? this.notes,
    );
  }
}