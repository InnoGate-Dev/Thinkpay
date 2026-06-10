enum TransactionType { income, expense }

const _expenseCategories = [
  'Food', 'Transport', 'Shopping', 'Entertainment',
  'Utilities', 'Health', 'Education', 'Rent', 'Other',
];

const _incomeCategories = [
  'Salary', 'Freelance', 'Business', 'Investment', 'Gift', 'Other',
];

List<String> categoriesFor(TransactionType type) =>
    type == TransactionType.income ? _incomeCategories : _expenseCategories;

class TransactionModel {
  final String id;
  final String title;
  final String category;
  final double amount;
  final TransactionType type;
  final DateTime date;
  final String? note;

  const TransactionModel({
    required this.id,
    required this.title,
    required this.category,
    required this.amount,
    required this.type,
    required this.date,
    this.note,
  });
}
