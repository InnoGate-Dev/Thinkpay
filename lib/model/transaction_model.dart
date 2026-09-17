enum TransactionType {
  income,
  expense,
<<<<<<< HEAD
  transferIn,
  transferOut,
  otherIn,
  otherOut;
=======
  transfer;
>>>>>>> 7f6af26f56c35ce219fd0a1e9bebf8d9a6be70f7

  String get apiValue {
    switch (this) {
      case TransactionType.income:
        return 'INCOME';
      case TransactionType.expense:
        return 'EXPENSE';
<<<<<<< HEAD
      case TransactionType.transferIn:
        return 'INCOME';
      case TransactionType.transferOut:
        return 'EXPENSE';
      case TransactionType.otherIn:
        return 'OTHER_IN';
      case TransactionType.otherOut:
        return 'OTHER_OUT';
=======
      case TransactionType.transfer:
        return 'TRANSFER';
>>>>>>> 7f6af26f56c35ce219fd0a1e9bebf8d9a6be70f7
    }
  }

  static TransactionType fromApi(String value) {
    switch (value.toUpperCase()) {
      case 'INCOME':
        return TransactionType.income;
<<<<<<< HEAD
      case 'EXPENSE':
        return TransactionType.expense;
      case 'TRANSFER_IN':
        return TransactionType.transferIn;
      case 'TRANSFER_OUT':
        return TransactionType.transferOut;
      case 'TRANSFER':
        // Fallback for legacy
        return TransactionType.transferOut;
=======
      case 'TRANSFER':
        return TransactionType.transfer;
      case 'EXPENSE':
>>>>>>> 7f6af26f56c35ce219fd0a1e9bebf8d9a6be70f7
      default:
        return TransactionType.expense;
    }
  }
}

<<<<<<< HEAD
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
=======
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
>>>>>>> 7f6af26f56c35ce219fd0a1e9bebf8d9a6be70f7
}