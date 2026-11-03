import 'package:flutter/foundation.dart';
import 'package:Thinkpay/model/budget_model.dart';
import 'package:Thinkpay/model/chat_message_model.dart';
import 'package:Thinkpay/model/goal_model.dart';
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
    for (final t in _transactions.where(_isTransfer)) {
      map[t.category] = (map[t.category] ?? 0) + t.amount;
    }
    return map;
  }

  double get totalTransfers =>
      _transactions.where(_isTransfer).fold(0, (s, t) => s + t.amount);

  static bool _isTransfer(TransactionModel t) =>
      t.type == TransactionType.transferIn ||
      t.type == TransactionType.transferOut;

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
          .where((b) =>
              b.type == TransactionType.transferIn ||
              b.type == TransactionType.transferOut)
          .map((b) => b.name)
          .toList();

  // ── Mutations ──────────────────────────────────────────────────────────────
  void setTransactions(List<TransactionModel> transactions) {
    _transactions.clear();
    _transactions.addAll(transactions);
    notifyListeners();
  }

  /// Adds [t] to the ledger and rolls its amount into the matching budget
  /// category, so the "actual" progress bars react immediately after the
  /// create call succeeds (the backend already applied the same change).
  void addTransaction(TransactionModel t) {
    _transactions.insert(0, t);
    applyTransactionToCategory(t);
    notifyListeners();
  }

  /// Adds [amount] to the budget category [t] belongs to.
  ///
  /// Matching prefers the backend [TransactionModel.categoryId]; rows without an
  /// id (locally built transfer entries) fall back to name + type.
  void applyTransactionToCategory(TransactionModel t) =>
      _applyCategoryDelta(t, t.amount);

  /// Moves the matching budget category's actual total by [delta].
  void _applyCategoryDelta(TransactionModel t, double delta) {
    var index = -1;
    final categoryId = t.categoryId;
    if (categoryId != null) {
      index = _budgets.indexWhere((b) => b.id == categoryId);
    }
    if (index == -1) {
      index = _budgets.indexWhere(
        (b) => b.name == t.category && b.type == t.type,
      );
    }
    if (index == -1) return;
    final budget = _budgets[index];
    final next = budget.actualAmount + delta;
    _budgets[index] = budget.copyWith(actualAmount: next < 0 ? 0 : next);
  }

  void deleteTransaction(String id) {
    final index = _transactions.indexWhere((t) => t.id == id);
    if (index != -1) {
      final removed = _transactions.removeAt(index);
      _applyCategoryDelta(removed, -removed.amount);
    }
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
    final clamped = newSavedAmount.clamp(0.0, _goals[idx].targetAmount);
    // Replace with a new object (copyWith) so downstream widgets always get a
    // fresh reference and rebuild correctly.
    _goals[idx] = _goals[idx].copyWith(savedAmount: clamped);
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
