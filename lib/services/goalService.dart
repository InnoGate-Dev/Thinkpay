import '../core/constant/api_endpoints.dart';
import '../core/network/api_client.dart';


class GoalService {
  final ApiClient _apiClient;

  GoalService(this._apiClient);

  Future<Map<String, dynamic>> createGoal({
    required String name,
    required String description,
    required String targetAmount,
  }) async {
    final data = {
      'name': name,
      'description': description,
      'target_amount': targetAmount,
    };
    return await _apiClient.post(ApiEndpoints.goals, data: data) as Map<String, dynamic>;
  }

  Future<List<dynamic>> getGoals() async {
    final response = await _apiClient.get(ApiEndpoints.goals);
    return response as List<dynamic>;
  }

  Future<Map<String, dynamic>> getGoalById(int id) async {
    return await _apiClient.get(ApiEndpoints.goalById(id)) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateGoal(
      int id, {
        required String name,
        required String description,
        required String targetAmount,
      }) async {
    final data = {
      'name': name,
      'description': description,
      'target_amount': targetAmount,
    };
    return await _apiClient.put(ApiEndpoints.goalById(id), data: data) as Map<String, dynamic>;
  }

  Future<void> deleteGoal(int id) async {
    await _apiClient.delete(ApiEndpoints.goalById(id));
  }
}