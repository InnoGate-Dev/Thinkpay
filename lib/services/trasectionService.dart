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
    final response = await _apiClient.post(ApiEndpoints.transactions, data: data);
    if (response is Map<String, dynamic> && response.containsKey('data')) {
      return response['data'] as Map<String, dynamic>;
    }
    return response as Map<String, dynamic>;
  }

  Future<List<dynamic>> getTransactions() async {
    final response = await _apiClient.get(ApiEndpoints.transactions);
    if (response is Map<String, dynamic>) {
      final data = response['data'];
      if (data is List) return data;
    } else if (response is List) {
      return response;
    }
    return <dynamic>[];
  }

  Future<Map<String, dynamic>> getTransactionById(int id) async {
    final response = await _apiClient.get(ApiEndpoints.transactionById(id));
    if (response is Map<String, dynamic> && response.containsKey('data')) {
      return response['data'] as Map<String, dynamic>;
    }
    return response as Map<String, dynamic>;
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
    final response = await _apiClient.put(ApiEndpoints.transactionById(id), data: data);
    if (response is Map<String, dynamic> && response.containsKey('data')) {
      return response['data'] as Map<String, dynamic>;
    }
    return response as Map<String, dynamic>;
  }

  Future<void> deleteTransaction(int id) async {
    await _apiClient.delete(ApiEndpoints.transactionById(id));
  }
}