import '../core/constant/api_endpoints.dart';
import '../core/network/api_client.dart';

<<<<<<< HEAD
=======

>>>>>>> 7f6af26f56c35ce219fd0a1e9bebf8d9a6be70f7
class GoalService {
  final ApiClient _apiClient;

  GoalService(this._apiClient);

<<<<<<< HEAD
  /// Creates a new goal.
  /// [type] must be "S" (savings), "I" (investing), or "L" (loan/debt).
  Future<Map<String, dynamic>> createGoal({
    required String name,
    required String type,
    required String targetAmount,
    String actualAmount = '0.00',
    bool isComplete = false,
  }) async {
    final data = {
      'name': name,
      'type': type,
      'target_amount': targetAmount,
      'actual_amount': actualAmount,
      'is_complete': isComplete,
    };
    return await _apiClient.post(ApiEndpoints.goals, data: data)
        as Map<String, dynamic>;
  }

  /// Returns all goals for the authenticated user as a raw list.
  ///
  /// The API returns a wrapped envelope: `{ "data": [...] }`.
  /// This method unwraps the list from the `data` key.
  Future<List<dynamic>> getGoals() async {
    final response = await _apiClient.get(ApiEndpoints.goals);
    // Handle both a plain list and the common `{ "data": [...] }` envelope.
    if (response is Map<String, dynamic>) {
      final inner = response['data'];
      if (inner is List) return inner;
    }
    if (response is List) return response;
    return [];
  }

  /// Fetches a single goal by its composite string ID (e.g. "42_S").
  Future<Map<String, dynamic>> getGoalById(String id) async {
    return await _apiClient.get(ApiEndpoints.goalById(id))
        as Map<String, dynamic>;
  }

  /// Updates an existing goal.
  /// [id] is the composite goal ID (e.g. "42_S").
  Future<Map<String, dynamic>> updateGoal(
    String id, {
    required String name,
    required String type,
    required String targetAmount,
    required String actualAmount,
    required bool isComplete,
  }) async {
    final data = {
      'name': name,
      'type': type,
      'target_amount': targetAmount,
      'actual_amount': actualAmount,
      'is_complete': isComplete,
    };
    return await _apiClient.put(ApiEndpoints.goalById(id), data: data)
        as Map<String, dynamic>;
  }

  /// Deletes a goal by its composite string ID (e.g. "42_S").
  Future<void> deleteGoal(String id) async {
=======
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
>>>>>>> 7f6af26f56c35ce219fd0a1e9bebf8d9a6be70f7
    await _apiClient.delete(ApiEndpoints.goalById(id));
  }
}