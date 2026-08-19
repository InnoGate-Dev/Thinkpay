import 'package:Thinkpay/model/transaction_model.dart';

/// A budget category as displayed on the Finance page.
///
/// The [id] is an `int` to match the backend's `int64` primary key.
class BudgetCategory {
  final int id;
  final String name;
  final double expectedAmount;
  final TransactionType type;
  final double actualAmount;

  const BudgetCategory({
    required this.id,
    required this.name,
    required this.expectedAmount,
    required this.type,
    this.actualAmount = 0.0,
  });

  BudgetCategory copyWith({
    String? name,
    double? expectedAmount,
    TransactionType? type,
    double? actualAmount,
  }) =>
      BudgetCategory(
        id: id,
        name: name ?? this.name,
        expectedAmount: expectedAmount ?? this.expectedAmount,
        type: type ?? this.type,
        actualAmount: actualAmount ?? this.actualAmount,
      );
}
