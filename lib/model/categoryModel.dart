import 'package:Thinkpay/model/budget_model.dart';
import 'package:Thinkpay/model/transaction_model.dart';

/// Mirrors the backend's `TransactionTypeEnum` — values must stay uppercase
/// to match what the Go service accepts and returns.
enum CategoryType {
  income,
  expense,
  transfer;

  /// The uppercase string value expected by the API (e.g. `"INCOME"`).
  String get apiValue {
    switch (this) {
      case CategoryType.income:
        return 'INCOME';
      case CategoryType.expense:
        return 'EXPENSE';
      case CategoryType.transfer:
        return 'TRANSFER';
    }
  }

  /// Converts [CategoryType] to the corresponding UI [TransactionType].
  TransactionType toTransactionType() {
    switch (this) {
      case CategoryType.income:
        return TransactionType.income;
      case CategoryType.transfer:
        return TransactionType.transfer;
      case CategoryType.expense:
        return TransactionType.expense;
    }
  }

  /// Converts UI [TransactionType] to domain [CategoryType].
  static CategoryType fromTransactionType(TransactionType type) {
    switch (type) {
      case TransactionType.income:
        return CategoryType.income;
      case TransactionType.transfer:
        return CategoryType.transfer;
      case TransactionType.expense:
        return CategoryType.expense;
    }
  }

  /// Parses a raw API string into [CategoryType]. Defaults to [expense].
  static CategoryType fromApi(String value) {
    switch (value.toUpperCase()) {
      case 'INCOME':
        return CategoryType.income;
      case 'TRANSFER':
        return CategoryType.transfer;
      case 'EXPENSE':
      default:
        return CategoryType.expense;
    }
  }
}

/// Domain model for a transaction category.
///
/// Maps to the backend's `TransactionCategory` DB row, which exposes:
/// `id`, `user_id`, `name`, `type`, `actual_amount`, `expected_amount`,
/// `created_at`, `updated_at`.
class Category {
  final int id;
  final String name;
  final CategoryType type;

  /// Running total actually spent / received in this category.
  /// Stored as a decimal string on the backend (`"0.00"`); parsed to [double].
  final double actualAmount;

  /// User-defined budget / goal for this category.
  /// Stored as a decimal string on the backend (`"0.00"`); parsed to [double].
  final double expectedAmount;

  final int? userId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Category({
    required this.id,
    required this.name,
    required this.type,
    this.actualAmount = 0.0,
    this.expectedAmount = 0.0,
    this.userId,
    this.createdAt,
    this.updatedAt,
  });

  /// Converts this [Category] to the UI-facing [BudgetCategory].
  BudgetCategory toBudgetCategory() {
    return BudgetCategory(
      id: id,
      name: name,
      expectedAmount: expectedAmount,
      type: type.toTransactionType(),
      actualAmount: actualAmount,
    );
  }

  // ── Serialisation ──────────────────────────────────────────────────────────

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name']?.toString() ?? '',
      type: CategoryType.fromApi(json['type']?.toString() ?? 'EXPENSE'),
      actualAmount:
          double.tryParse(json['actual_amount']?.toString() ?? '0') ?? 0.0,
      expectedAmount:
          double.tryParse(json['expected_amount']?.toString() ?? '0') ?? 0.0,
      userId: (json['user_id'] as num?)?.toInt(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.apiValue,
      'actual_amount': actualAmount.toStringAsFixed(2),
      'expected_amount': expectedAmount.toStringAsFixed(2),
      'user_id': userId,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // ── Convenience ────────────────────────────────────────────────────────────

  Category copyWith({
    int? id,
    String? name,
    CategoryType? type,
    double? actualAmount,
    double? expectedAmount,
    int? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      actualAmount: actualAmount ?? this.actualAmount,
      expectedAmount: expectedAmount ?? this.expectedAmount,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() =>
      'Category(id: $id, name: $name, type: ${type.apiValue}, '
      'actual: $actualAmount, expected: $expectedAmount)';
}