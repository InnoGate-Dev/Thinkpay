import '../../model/transaction_model.dart';
import '../../services/trasectionService.dart';
import '../../core/constant/app_config.dart';
import '../../core/network/api_client.dart';

/// A lightweight API-facing transaction model.
///
/// The existing local [TransactionModel] is designed for the UI (string id,
/// double amount, named category).  The backend uses integer ids and string
/// decimal amounts, so this thin model bridges the two without breaking
/// the existing local UI state.
class ApiTransaction {
  final int id;
  final int categoryId;
  final TransactionType type;
  final double amount;
  final DateTime date;
  final int? goalId;
  final String? categoryName;
  final DateTime? createdAt;

  ApiTransaction({
    required this.id,
    required this.categoryId,
    required this.type,
    required this.amount,
    required this.date,
    this.goalId,
    this.categoryName,
    this.createdAt,
  });

  factory ApiTransaction.fromJson(Map<String, dynamic> json) {
    return ApiTransaction(
      id: json['id'] as int,
      categoryId: (json['category_id'] as int?) ?? 0,
      type: TransactionType.fromApi(json['type']?.toString() ?? 'EXPENSE'),
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0,
      date: json['date'] != null
          ? (DateTime.tryParse(json['date']) ?? DateTime.now())
          : DateTime.now(),
      goalId: json['goal_id'] as int?,
      categoryName: (json['category'] as Map<String, dynamic>?)?['name']
              as String? ??
          json['category_name'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }

  /// Converts this [ApiTransaction] into the local [TransactionModel] used
  /// by [FinanceProvider] and the UI.
  TransactionModel toLocalModel() {
    return TransactionModel(
      id: id.toString(),
      category: categoryName ?? type.apiValue,
      amount: amount,
      type: type,
      date: date,
    );
  }
}

/// Repository that orchestrates all transaction API operations.
class TransactionRepository {
  late final TransactionService _transactionService;

  TransactionRepository() {
    final client = ApiClient(baseUrl: AppConfig.baseUrl);
    _transactionService = TransactionService(client);
  }

  // ── CRUD ──────────────────────────────────────────────────────────────────

  /// Creates a new transaction.
  ///
  /// Set [type] to [TransactionType.transferIn] or [TransactionType.transferOut] and provide a [goalId] to
  /// atomically adjust the goal's balance on the server side.
  Future<ApiTransaction> createTransaction({
    required int categoryId,
    required TransactionType type,
    required double amount,
    required DateTime date,
    int? goalId,
  }) async {
    final raw = await _transactionService.createTransaction(
      categoryId: categoryId,
      type: type.apiValue,
      amount: amount.toStringAsFixed(2),
      date: date.toUtc(),
      goalId: goalId,
    );
    return ApiTransaction.fromJson(raw);
  }

  /// Returns all transactions for the authenticated user.
  Future<List<ApiTransaction>> getTransactions() async {
    final rawList = await _transactionService.getTransactions();
    return rawList
        .map((e) => ApiTransaction.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Returns all transactions converted to the local [TransactionModel]
  /// format used by [FinanceProvider].
  Future<List<TransactionModel>> getTransactionsAsLocalModels() async {
    final apiTransactions = await getTransactions();
    return apiTransactions.map((t) => t.toLocalModel()).toList();
  }

  /// Fetches a single transaction by its [id].
  Future<ApiTransaction> getTransactionById(int id) async {
    final raw = await _transactionService.getTransactionById(id);
    return ApiTransaction.fromJson(raw);
  }

  /// Updates an existing transaction.
  Future<ApiTransaction> updateTransaction(
    int id, {
    required int categoryId,
    required TransactionType type,
    required double amount,
    required DateTime date,
    int? goalId,
  }) async {
    final raw = await _transactionService.updateTransaction(
      id,
      categoryId: categoryId,
      type: type.apiValue,
      amount: amount.toStringAsFixed(2),
      date: date.toUtc(),
      goalId: goalId,
    );
    return ApiTransaction.fromJson(raw);
  }

  /// Deletes a transaction by its [id].
  Future<void> deleteTransaction(int id) async {
    await _transactionService.deleteTransaction(id);
  }
}
