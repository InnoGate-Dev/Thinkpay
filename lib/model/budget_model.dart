import 'package:Thinkpay/model/transaction_model.dart';

class BudgetCategory {
  final String id;
  final String name;
  final double expectedAmount;
  final TransactionType type;

  BudgetCategory({
    required this.id,
    required this.name,
    required this.expectedAmount,
    required this.type,
  });

  BudgetCategory copyWith({
    String? name,
    double? expectedAmount,
    TransactionType? type,
  }) =>
      BudgetCategory(
        id: id,
        name: name ?? this.name,
        expectedAmount: expectedAmount ?? this.expectedAmount,
        type: type ?? this.type,
      );
}
