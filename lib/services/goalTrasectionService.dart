import 'package:Thinkpay/core/constant/api_endpoints.dart';
import '../core/network/api_client.dart';

class Goaltrasectionservice {
  final ApiClient _apiClient;

  Goaltrasectionservice(this._apiClient);

  Future<List<dynamic>> getGoalTransactions() async {
    final response = await _apiClient.get(ApiEndpoints.getgoalTrasection());
    if (response is Map<String, dynamic>) {
      final data = response['data'];
      if (data is List) return data;
    } else if (response is List) {
      return response;
    }
    return <dynamic>[];
  }

  Future<Map<String, dynamic>> createGoalTrasection({
    required int goalId,
    required String amount,
    required DateTime transactionDateTime,
  }) async {
    final data = {
      'goal_id': goalId,
      'amount': amount.toString(),
      'transaction_date': transactionDateTime.toUtc().toIso8601String(),
    };
    final response = await _apiClient.post(
      ApiEndpoints.CreateGoalTrasection(),
      data: data,
    );
    if (response is Map<String, dynamic> && response.containsKey('data')) {
      return response['data'] as Map<String, dynamic>;
    }
    return response as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateTrasectionsByGoal(
    int goalId, {
    required String amount,
    required DateTime transactionDateTime,
  }) async {
    final data = {
      'amount': amount,
      'transaction_date': transactionDateTime.toIso8601String(),
    };
    final response = await _apiClient.put(
      ApiEndpoints.UpdateGoalTrasections(goalId),
      data: data,
    );
    if (response is Map<String, dynamic> && response.containsKey('data')) {
      return response['data'] as Map<String, dynamic>;
    }
    return response as Map<String, dynamic>;
  }

  Future<void> deleteTrasectionsByGoal(int goalId) async {
    await _apiClient.delete(ApiEndpoints.DeleteGoalTrasections(goalId));
  }
}
