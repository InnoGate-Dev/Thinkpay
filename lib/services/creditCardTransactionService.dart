import '../core/constant/api_endpoints.dart';
import '../core/constant/app_config.dart';
import '../core/network/api_client.dart';
import '../model/credit_card_transaction_model.dart';
import '../model/transaction_model.dart';

/// Network service for `creditcard_transactions`.
///
/// Card spending has its own table and endpoints (`/credit-card-transactions`),
/// separate from the main ledger. Creating an entry here also rolls the amount
/// into the category's `actual_amount` server-side, which is what the budget
/// screens read.
class CreditCardTransactionService {
  final ApiClient _apiClient;

  CreditCardTransactionService([ApiClient? apiClient])
      : _apiClient = apiClient ?? ApiClient(baseUrl: AppConfig.baseUrl);

  /// Returns every entry charged to [cardId], newest first.
  Future<List<CreditCardTransactionModel>> fetchByCard(int cardId) async {
    final response = await _apiClient.get(
      ApiEndpoints.creditCardTransactionsByCard(cardId),
      queryParameters: const {'limit': 200},
    );

    final rows = _unwrapList(response);
    return rows
        .whereType<Map<String, dynamic>>()
        .map(CreditCardTransactionModel.fromJson)
        .toList();
  }

  /// Records a card-paid expense.
  ///
  /// [type] must match the category's type — the backend rejects a mismatch —
  /// which is why callers pass [TransactionType.expense.apiValue] for spending.
  Future<CreditCardTransactionModel> create({
    required int cardId,
    required int categoryId,
    required TransactionType type,
    required double amount,
    required DateTime date,
    String? note,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.creditCardTransactions,
      data: {
        'card_id': cardId,
        'category_id': categoryId,
        'type': type.apiValue,
        'amount': amount.toStringAsFixed(2),
        'date': date.toUtc().toIso8601String(),
        if (note != null && note.trim().isNotEmpty) 'note': note.trim(),
      },
    );

    final data = _unwrapObject(response);
    return CreditCardTransactionModel.fromJson(data);
  }

  /// Deletes an entry; the server also reverses its category amount.
  Future<void> delete(int id) async {
    await _apiClient.delete(
      '${ApiEndpoints.creditCardTransactions}/$id',
    );
  }

  // ── Envelope helpers ──────────────────────────────────────────────────────
  List<dynamic> _unwrapList(dynamic response) {
    if (response is Map<String, dynamic>) {
      final data = response['data'];
      if (data is List) return data;
    }
    if (response is List) return response;
    return const [];
  }

  Map<String, dynamic> _unwrapObject(dynamic response) {
    if (response is Map<String, dynamic>) {
      final data = response['data'];
      if (data is Map<String, dynamic>) return data;
      if (data is List && data.isNotEmpty && data.first is Map<String, dynamic>) {
        return data.first as Map<String, dynamic>;
      }
      return response;
    }
    throw Exception('Unexpected response format when saving a card transaction');
  }
}
