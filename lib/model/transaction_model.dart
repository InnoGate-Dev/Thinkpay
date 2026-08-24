enum TransactionType {
  income,
  expense,
  transfer;

  String get apiValue {
    switch (this) {
      case TransactionType.income:
        return 'INCOME';
      case TransactionType.expense:
        return 'EXPENSE';
      case TransactionType.transfer:
        return 'TRANSFER';
    }
  }

  static TransactionType fromApi(String value) {
    switch (value.toUpperCase()) {
      case 'INCOME':
        return TransactionType.income;
      case 'TRANSFER':
        return TransactionType.transfer;
      case 'EXPENSE':
      default:
        return TransactionType.expense;
    }
  }
}

class Transaction {
  final int id;
  final int? userId;
  final int? categoryId;
  final int? goalId;
  final TransactionType type;
  final String amount;
  final DateTime date;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Transaction({
    required this.id,
    this.userId,
    this.categoryId,
    this.goalId,
    required this.type,
    required this.amount,
    required this.date,
    this.createdAt,
    this.updatedAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      userId: json['user_id'],
      categoryId: json['category_id'],
      goalId: json['goal_id'],
      type: TransactionType.fromApi(json['type'] ?? 'EXPENSE'),
      amount: json['amount']?.toString() ?? '0.00',
      date: DateTime.parse(json['date']),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'category_id': categoryId,
      'goal_id': goalId,
      'type': type.apiValue,
      'amount': amount,
      'date': date.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}