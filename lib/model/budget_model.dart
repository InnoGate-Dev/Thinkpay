import 'package:Thinkpay/model/transaction_model.dart';

class BudgetCategory {
  final String id;
  final String name;
  final double expectedAmount;
  final TransactionType type;

  const BudgetCategory({
    required this.id,
    required this.name,
    required this.expectedAmount,
    required this.type,
  });
}
