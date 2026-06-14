import 'package:flutter/foundation.dart';
import 'package:Thinkpay/model/budget_model.dart';
import 'package:Thinkpay/model/chat_message_model.dart';
import 'package:Thinkpay/model/transaction_model.dart';

class FinanceProvider extends ChangeNotifier {
  // ── Singleton ──────────────────────────────────────────────────────────────
  static final FinanceProvider _instance = FinanceProvider._internal();
  factory FinanceProvider() => _instance;
  FinanceProvider._internal() {
    _seedDemoData();
  }

  // ── Internal state ─────────────────────────────────────────────────────────
  final List<TransactionModel> _transactions = [];
  final List<BudgetCategory>   _budgets      = [];
  final List<ChatMessage>      _messages     = [];

  // ── Public accessors ───────────────────────────────────────────────────────
  List<TransactionModel> get transactions => List.unmodifiable(_transactions);
  List<BudgetCategory>   get budgets      => List.unmodifiable(_budgets);
  List<ChatMessage>      get messages     => List.unmodifiable(_messages);

  // ── Computed ───────────────────────────────────────────────────────────────
  double get totalIncome =>
      _transactions.where((t) => t.type == TransactionType.income)
          .fold(0, (s, t) => s + t.amount);

  double get totalExpenses =>
      _transactions.where((t) => t.type == TransactionType.expense)
          .fold(0, (s, t) => s + t.amount);

  double get balance => totalIncome - totalExpenses;

  Map<String, double> get expenseByCategory {
    final map = <String, double>{};
    for (final t in _transactions.where((t) => t.type == TransactionType.expense)) {
      map[t.category] = (map[t.category] ?? 0) + t.amount;
    }
    return map;
  }

  Map<String, double> get incomeByCategory {
    final map = <String, double>{};
    for (final t in _transactions.where((t) => t.type == TransactionType.income)) {
      map[t.category] = (map[t.category] ?? 0) + t.amount;
    }
    return map;
  }

  List<TransactionModel> get recentTransactions =>
      _transactions.take(5).toList();

  // ── Mutations ──────────────────────────────────────────────────────────────
  void addTransaction(TransactionModel t) {
    _transactions.insert(0, t);
    notifyListeners();
  }

  void deleteTransaction(String id) {
    _transactions.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  void addBudget(BudgetCategory c) {
    _budgets.add(c);
    notifyListeners();
  }

  void deleteBudget(String id) {
    _budgets.removeWhere((c) => c.id == id);
    notifyListeners();
  }

  void addMessage(ChatMessage m) {
    _messages.add(m);
    notifyListeners();
  }

  String newId() => DateTime.now().millisecondsSinceEpoch.toString();

  // ── Demo seed data ─────────────────────────────────────────────────────────
  void _seedDemoData() {
    final now = DateTime.now();

    _transactions.addAll([
      TransactionModel(id: '1', title: 'Monthly Salary',    category: 'Salary',        amount: 85000, type: TransactionType.income,  date: now.subtract(const Duration(days: 2))),
      TransactionModel(id: '2', title: 'Grocery Shopping',  category: 'Food',          amount: 3200,  type: TransactionType.expense, date: now.subtract(const Duration(days: 1))),
      TransactionModel(id: '3', title: 'Netflix',           category: 'Entertainment', amount: 649,   type: TransactionType.expense, date: now.subtract(const Duration(days: 3))),
      TransactionModel(id: '4', title: 'Freelance Project', category: 'Freelance',     amount: 15000, type: TransactionType.income,  date: now.subtract(const Duration(days: 5))),
      TransactionModel(id: '5', title: 'Electricity Bill',  category: 'Utilities',     amount: 2100,  type: TransactionType.expense, date: now.subtract(const Duration(days: 4))),
      TransactionModel(id: '6', title: 'Restaurant',        category: 'Food',          amount: 1450,  type: TransactionType.expense, date: now),
      TransactionModel(id: '7', title: 'Gym Membership',    category: 'Health',        amount: 1500,  type: TransactionType.expense, date: now.subtract(const Duration(days: 6))),
      TransactionModel(id: '8', title: 'Transport',         category: 'Transport',     amount: 850,   type: TransactionType.expense, date: now.subtract(const Duration(days: 2))),
    ]);

    _budgets.addAll([
      BudgetCategory(id: 'b1', name: 'Food',          expectedAmount: 8000,  type: TransactionType.expense),
      BudgetCategory(id: 'b2', name: 'Entertainment', expectedAmount: 2000,  type: TransactionType.expense),
      BudgetCategory(id: 'b3', name: 'Utilities',     expectedAmount: 3000,  type: TransactionType.expense),
      BudgetCategory(id: 'b4', name: 'Health',        expectedAmount: 2500,  type: TransactionType.expense),
      BudgetCategory(id: 'b5', name: 'Transport',     expectedAmount: 2000,  type: TransactionType.expense),
      BudgetCategory(id: 'b6', name: 'Salary',        expectedAmount: 85000, type: TransactionType.income),
      BudgetCategory(id: 'b7', name: 'Freelance',     expectedAmount: 10000, type: TransactionType.income),
    ]);

    _messages.add(ChatMessage(
      id: '0',
      content: "Hi! I'm your AI Financial Adviser 🤖\n\nI'm here to help you make smarter financial decisions. Ask me anything about budgeting, savings, or your spending habits!",
      isUser: false,
      timestamp: now,
    ));
  }
}
