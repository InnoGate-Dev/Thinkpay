import '../core/constant/api_endpoints.dart';
import '../core/network/api_client.dart';


class TransactionService {
  final ApiClient _apiClient;

  TransactionService(this._apiClient);

  Future<Map<String, dynamic>> createTransaction({
    required int categoryId,
    required String type, // INCOME, EXPENSE, TRANSFER
    required String amount,
    required DateTime date,
    int? goalId,
  }) async {
    final data = {
      'category_id': categoryId,
      'type': type,
      'amount': amount,
      'date': date.toIso8601String(),
      'goal_id': goalId,
    };
    return await _apiClient.post(ApiEndpoints.transactions, data: data) as Map<String, dynamic>;
  }

  Future<List<dynamic>> getTransactions() async {
    final response = await _apiClient.get(ApiEndpoints.transactions);
    return response as List<dynamic>;
  }

  Future<Map<String, dynamic>> getTransactionById(int id) async {
    return await _apiClient.get(ApiEndpoints.transactionById(id)) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateTransaction(
      int id, {
        required int categoryId,
        required String type,
        required String amount,
        required DateTime date,
        int? goalId,
      }) async {
    final data = {
      'category_id': categoryId,
      'type': type,
      'amount': amount,
      'date': date.toIso8601String(),
      'goal_id': goalId,
    };
    return await _apiClient.put(ApiEndpoints.transactionById(id), data: data) as Map<String, dynamic>;
  }

  Future<void> deleteTransaction(int id) async {
    await _apiClient.delete(ApiEndpoints.transactionById(id));
  }
}