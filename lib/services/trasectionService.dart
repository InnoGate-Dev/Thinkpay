import '../core/constant/api_endpoints.dart';
import '../core/network/api_client.dart';

<<<<<<< HEAD
=======

>>>>>>> 7f6af26f56c35ce219fd0a1e9bebf8d9a6be70f7
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
<<<<<<< HEAD
    final response = await _apiClient.post(ApiEndpoints.transactions, data: data);
    if (response is Map<String, dynamic> && response.containsKey('data')) {
      return response['data'] as Map<String, dynamic>;
    }
    return response as Map<String, dynamic>;
=======
    return await _apiClient.post(ApiEndpoints.transactions, data: data) as Map<String, dynamic>;
>>>>>>> 7f6af26f56c35ce219fd0a1e9bebf8d9a6be70f7
  }

  Future<List<dynamic>> getTransactions() async {
    final response = await _apiClient.get(ApiEndpoints.transactions);
<<<<<<< HEAD
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
=======
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
>>>>>>> 7f6af26f56c35ce219fd0a1e9bebf8d9a6be70f7
    final data = {
      'category_id': categoryId,
      'type': type,
      'amount': amount,
      'date': date.toIso8601String(),
      'goal_id': goalId,
    };
<<<<<<< HEAD
    final response = await _apiClient.put(ApiEndpoints.transactionById(id), data: data);
    if (response is Map<String, dynamic> && response.containsKey('data')) {
      return response['data'] as Map<String, dynamic>;
    }
    return response as Map<String, dynamic>;
=======
    return await _apiClient.put(ApiEndpoints.transactionById(id), data: data) as Map<String, dynamic>;
>>>>>>> 7f6af26f56c35ce219fd0a1e9bebf8d9a6be70f7
  }

  Future<void> deleteTransaction(int id) async {
    await _apiClient.delete(ApiEndpoints.transactionById(id));
  }
}