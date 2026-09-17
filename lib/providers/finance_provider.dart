import 'package:flutter/foundation.dart';
import 'package:Thinkpay/model/budget_model.dart';
import 'package:Thinkpay/model/chat_message_model.dart';
import 'package:Thinkpay/ui/pages/goal/goal_model.dart';
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
  final List<GoalModel>        _goals        = [];

  // ── Public accessors ───────────────────────────────────────────────────────
  List<TransactionModel> get transactions => List.unmodifiable(_transactions);
  List<BudgetCategory>   get budgets      => List.unmodifiable(_budgets);
  List<ChatMessage>      get messages     => List.unmodifiable(_messages);
  List<GoalModel>        get goals        => List.unmodifiable(_goals);

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

  Map<String, double> get transferByCategory {
    final map = <String, double>{};
<<<<<<< HEAD
    for (final t in _transactions.where((t) => t.type == TransactionType.income || t.type == TransactionType.expense)) {
=======
    for (final t in _transactions.where((t) => t.type == TransactionType.transfer)) {
>>>>>>> 7f6af26f56c35ce219fd0a1e9bebf8d9a6be70f7
      map[t.category] = (map[t.category] ?? 0) + t.amount;
    }
    return map;
  }

  double get totalTransfers =>
<<<<<<< HEAD
      _transactions.where((t) => t.type == TransactionType.income || t.type == TransactionType.expense)
=======
      _transactions.where((t) => t.type == TransactionType.transfer)
>>>>>>> 7f6af26f56c35ce219fd0a1e9bebf8d9a6be70f7
          .fold(0, (s, t) => s + t.amount);

  List<TransactionModel> get recentTransactions =>
      _transactions.take(5).toList();

  /// Names of budget categories for expense type (used by transaction picker).
  List<String> get expenseBudgetCategories =>
      _budgets
          .where((b) => b.type == TransactionType.expense)
          .map((b) => b.name)
          .toList();

  /// Names of budget categories for income type (used by transaction picker).
  List<String> get incomeBudgetCategories =>
      _budgets
          .where((b) => b.type == TransactionType.income)
          .map((b) => b.name)
          .toList();

  /// Names of budget categories for transfer type (used by transaction picker).
  List<String> get transferBudgetCategories =>
      _budgets
<<<<<<< HEAD
          .where((b) => b.type == TransactionType.income || b.type == TransactionType.expense)
=======
          .where((b) => b.type == TransactionType.transfer)
>>>>>>> 7f6af26f56c35ce219fd0a1e9bebf8d9a6be70f7
          .map((b) => b.name)
          .toList();

  // ── Mutations ──────────────────────────────────────────────────────────────
  void setTransactions(List<TransactionModel> transactions) {
    _transactions.clear();
    _transactions.addAll(transactions);
    notifyListeners();
  }

  void addTransaction(TransactionModel t) {
    _transactions.insert(0, t);
    notifyListeners();
  }

  void deleteTransaction(String id) {
    _transactions.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  void setBudgetCategories(List<BudgetCategory> categories) {
    _budgets.clear();
    _budgets.addAll(categories);
    notifyListeners();
  }

  void addBudget(BudgetCategory c) {
    _budgets.add(c);
    notifyListeners();
  }

  void updateBudget(BudgetCategory updated) {
    final idx = _budgets.indexWhere((b) => b.id == updated.id);
    if (idx != -1) {
      _budgets[idx] = updated;
      notifyListeners();
    }
  }

  void deleteBudget(int id) {
    _budgets.removeWhere((c) => c.id == id);
    notifyListeners();
  }

  void addMessage(ChatMessage m) {
    _messages.add(m);
    notifyListeners();
  }

  // ── Goal mutations ─────────────────────────────────────────────────────────

  /// Replaces the entire goals list with [goals] fetched from the backend.
  void setGoals(List<GoalModel> goals) {
    _goals
      ..clear()
      ..addAll(goals);
    notifyListeners();
  }

  void addGoal(GoalModel g) {
    _goals.insert(0, g);
    notifyListeners();
  }

  /// Replaces the goal in the list with [updated].
  /// Preserves `savedAmount` only when explicitly requested via [preserveSaved].
  void updateGoal(GoalModel updated, {bool preserveSaved = false}) {
    final idx = _goals.indexWhere((g) => g.id == updated.id);
    if (idx != -1) {
      _goals[idx] = preserveSaved
          ? updated.copyWith(savedAmount: _goals[idx].savedAmount)
          : updated;
      notifyListeners();
    }
  }

  void deleteGoal(String id) {
    _goals.removeWhere((g) => g.id == id);
    notifyListeners();
  }

  /// Updates a goal's savedAmount locally (optimistic update after API call).
  /// Returns true if the goal is now complete.
  bool addAmountToGoal(String id, double newSavedAmount) {
    final idx = _goals.indexWhere((g) => g.id == id);
    if (idx == -1) return false;
    _goals[idx].savedAmount = newSavedAmount.clamp(0, _goals[idx].targetAmount);
    notifyListeners();
    return _goals[idx].isCompleted;
  }

  /// Generates a temporary local-only id for optimistic UI updates.
  /// When categories are fetched from the server, the real backend id is used.
  int newId() => DateTime.now().millisecondsSinceEpoch;

  // ── Seed data ──────────────────────────────────────────────────────────────
  void _seedDemoData() {
    final now = DateTime.now();

    // Goals are fetched from the backend API — no dummy data seeded here.
    // Transactions and categories are also fetched from the backend.

    _messages.add(ChatMessage(
      id: '0',
      content: "Hi! I'm your AI Financial Adviser 🤖\n\nI'm here to help you make smarter financial decisions. Ask me anything about budgeting, savings, or your spending habits!",
      isUser: false,
      timestamp: now,
    ));
  }
}
