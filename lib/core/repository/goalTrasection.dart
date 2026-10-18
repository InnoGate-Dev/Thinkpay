import '../../services/goalTrasectionService.dart';
import '../../core/constant/app_config.dart';
import '../../core/network/api_client.dart';

/// Repository that orchestrates goal transaction operations.
class GoalTrasectionRepository {
  late final Goaltrasectionservice _goalTrasectionService;

  GoalTrasectionRepository() {
    final client = ApiClient(baseUrl: AppConfig.baseUrl);
    _goalTrasectionService = Goaltrasectionservice(client);
  }

  /// Returns all goal transactions.
  Future<List<Map<String, dynamic>>> getGoalTransactions() async {
    final rawList = await _goalTrasectionService.getGoalTransactions();
    return rawList.map((e) => e as Map<String, dynamic>).toList();
  }

  /// Creates a new goal transaction.
  Future<Map<String, dynamic>> createGoalTrasection({
    required int goalId,
    required double amount,
    required DateTime transactionDateTime,
  }) async {
    return await _goalTrasectionService.createGoalTrasection(
      goalId: goalId,
      amount: amount.toStringAsFixed(2),
      transactionDateTime: transactionDateTime,
    );
  }

  /// Updates goal transactions by goal ID.
  Future<Map<String, dynamic>> updateTrasectionsByGoal(
    int goalId, {
    required double amount,
    required DateTime transactionDateTime,
  }) async {
    return await _goalTrasectionService.updateTrasectionsByGoal(
      goalId,
      amount: amount.toStringAsFixed(2),
      transactionDateTime: transactionDateTime,
    );
  }

  /// Deletes goal transactions by goal ID.
  Future<void> deleteTrasectionsByGoal(int goalId) async {
    await _goalTrasectionService.deleteTrasectionsByGoal(goalId);
  }
}
