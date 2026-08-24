enum CategoryType {
  income,
  expense,
  transfer;

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

class Category {
  final int id;
  final String name;
  final CategoryType type;
  final int? userId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Category({
    required this.id,
    required this.name,
    required this.type,
    this.userId,
    this.createdAt,
    this.updatedAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'] ?? '',
      type: CategoryType.fromApi(json['type'] ?? 'EXPENSE'),
      userId: json['user_id'],
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
      'name': name,
      'type': type.apiValue,
      'user_id': userId,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}