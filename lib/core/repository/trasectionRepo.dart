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
      id: _parseInt(json['id']) ?? 0,
      categoryId: _parseInt(json['category_id']) ?? _parseInt(json['category']) ?? 0,
      type: TransactionType.fromApi(json['type']?.toString() ?? 'EXPENSE'),
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0,
      date: json['date'] != null
          ? (DateTime.tryParse(json['date'].toString()) ?? DateTime.now())
          : DateTime.now(),
      goalId: _parseInt(json['goal_id']) ?? _parseInt(json['goal']),
      categoryName: _parseCategoryName(json),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  static int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v);
    if (v is Map) {
      return _parseInt(v['id'] ?? v['ID']);
    }
    return null;
  }

  static String? _parseCategoryName(Map<String, dynamic> json) {
    final category = json['category'];
    if (category is Map) {
      final name = category['name'] ?? category['Name'];
      if (name != null) return name.toString();
    } else if (category is String && category.isNotEmpty) {
      return category;
    }

    final categoryId = json['category_id'];
    if (categoryId is Map) {
      final name = categoryId['name'] ?? categoryId['Name'];
      if (name != null) return name.toString();
    }

    final categoryName = json['category_name'];
    if (categoryName != null && categoryName.toString().isNotEmpty) {
      return categoryName.toString();
    }

    return null;
  }

  /// Converts this [ApiTransaction] into the local [TransactionModel] used
  /// by [FinanceProvider] and the UI.
  TransactionModel toLocalModel({String? fallbackCategory}) {
    return TransactionModel(
      id: id.toString(),
      category: categoryName ?? fallbackCategory ?? type.apiValue,
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
    String? notes,
  }) async {
    final raw = await _transactionService.createTransaction(
      categoryId: categoryId,
      type: type.apiValue,
      amount: amount.toStringAsFixed(2),
      date: date.toUtc(),
      goalId: goalId,
      note: notes,
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
