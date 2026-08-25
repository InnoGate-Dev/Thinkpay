import 'package:Thinkpay/model/goal_model.dart';
import '../../model/categoryModel.dart';
import '../../services/goalService.dart';
import '../../services/categoryService.dart';
import '../../core/constant/app_config.dart';
import '../../core/network/api_client.dart';

/// Repository that orchestrates financial goals and categories.
///
/// All goal IDs are composite strings like "42_S", "7_I", "15_L" — matching
/// the backend's `GoalResponse.id` format.
class GoalRepository {
  late final GoalService _goalService;
  late final CategoryService _categoryService;

  GoalRepository() {
    final client = ApiClient(baseUrl: AppConfig.baseUrl);
    _goalService = GoalService(client);
    _categoryService = CategoryService(client);
  }

  // ── Goals ─────────────────────────────────────────────────────────────────

  /// Returns all goals for the authenticated user.
  Future<List<GoalModel>> getGoals() async {
    final rawList = await _goalService.getGoals();
    return rawList
        .map((e) => GoalModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Fetches a single goal by its composite string [id] (e.g. "42_S").
  Future<GoalModel> getGoalById(String id) async {
    final raw = await _goalService.getGoalById(id);
    return GoalModel.fromJson(raw);
  }

  /// Creates a new financial goal.
  ///
  /// [type] defaults to [GoalType.savings].
  Future<GoalModel> createGoal({
    required String name,
    required double targetAmount,
    double actualAmount = 0.0,
    bool? isComplete,
    GoalType type = GoalType.savings,
  }) async {
    final effectiveIsComplete =
        isComplete ?? (actualAmount >= targetAmount && targetAmount > 0);
    final raw = await _goalService.createGoal(
      name: name,
      type: type.apiValue,
      targetAmount: targetAmount.toStringAsFixed(2),
      actualAmount: actualAmount.toStringAsFixed(2),
      isComplete: effectiveIsComplete,
    );
    return GoalModel.fromJson(raw);
  }

  /// Updates an existing goal.
  ///
  /// [id] is the composite goal ID (e.g. "42_S").
  Future<GoalModel> updateGoal(
    String id,
    GoalModel current, {
    required String name,
    required double targetAmount,
    double? actualAmount,
    GoalType? type,
  }) async {
    final effectiveType = type ?? current.type;
    final effectiveActual = actualAmount ?? current.savedAmount;
    final effectiveIsComplete =
        effectiveActual >= targetAmount && targetAmount > 0;
    final raw = await _goalService.updateGoal(
      id,
      name: name,
      type: effectiveType.apiValue,
      targetAmount: targetAmount.toStringAsFixed(2),
      actualAmount: effectiveActual.toStringAsFixed(2),
      isComplete: effectiveIsComplete,
    );
    return GoalModel.fromJson(raw);
  }

  /// Deletes a goal by its composite string [id] (e.g. "42_S").
  Future<void> deleteGoal(String id) async {
    await _goalService.deleteGoal(id);
  }

  /// Adds [amount] to a goal's saved balance by updating the goal on the
  /// backend (PUT /goals/{id}) with the new `actual_amount`.
  ///
  /// Returns the updated [GoalModel].
  Future<GoalModel> addAmountToGoal(String id, double amount, GoalModel current) async {
    final newSaved =
        (current.savedAmount + amount).clamp(0.0, current.targetAmount);
    final raw = await _goalService.updateGoal(
      id,
      name: current.name,
      type: current.type.apiValue,
      targetAmount: current.targetAmount.toStringAsFixed(2),
      actualAmount: newSaved.toStringAsFixed(2),
      isComplete: newSaved >= current.targetAmount,
    );
    return GoalModel.fromJson(raw);
  }

  // ── Categories ────────────────────────────────────────────────────────────

  /// Creates a new financial category.
  Future<Category> createCategory({
    required String name,
    required CategoryType type,
  }) async {
    final raw = await _categoryService.createCategory(
      name: name,
      type: type.apiValue,
    );
    return Category.fromJson(raw);
  }

  /// Returns all categories for the authenticated user.
  Future<List<Category>> getCategories() async {
    final rawList = await _categoryService.getCategories();
    return rawList
        .map((e) => Category.fromJson(e))
        .toList();
  }

  /// Fetches a single category by its [id].
  Future<Category> getCategoryById(int id) async {
    final raw = await _categoryService.getCategoryById(id);
    return Category.fromJson(raw);
  }

  /// Updates an existing category.
  Future<Category> updateCategory(
    int id, {
    required String name,
    required CategoryType type,
  }) async {
    final raw = await _categoryService.updateCategory(
      id,
      name: name,
      type: type.apiValue,
    );
    return Category.fromJson(raw);
  }

  /// Deletes a category by its [id].
  Future<void> deleteCategory(int id) async {
    await _categoryService.deleteCategory(id);
  }
}
