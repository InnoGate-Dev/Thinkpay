import '../../model/categoryModel.dart';
import '../../services/categoryService.dart';
import '../../core/constant/app_config.dart';
import '../../core/network/api_client.dart';

/// Repository that orchestrates all category operations.
///
/// Owns the [CategoryService] instance and is responsible for:
/// - mapping raw API JSON to [Category] domain models.
/// - bubbling typed [ApiException]s from the network layer to the UI.
///
/// Usage:
/// ```dart
/// final repo = CategoryRepository();
/// final categories = await repo.getCategories();
/// ```
class CategoryRepository {
  late final CategoryService _categoryService;

  CategoryRepository() {
    final client = ApiClient(baseUrl: AppConfig.baseUrl);
    _categoryService = CategoryService(client);
  }

  // ── Create ─────────────────────────────────────────────────────────────────

  /// Creates a new category and returns the persisted [Category].
  ///
  /// [type] is taken from [CategoryType.apiValue] so the caller works with
  /// the typed enum; the repo handles the conversion to the API string.
  Future<Category> createCategory({
    required String name,
    required CategoryType type,
    double actualAmount = 0.0,
    double expectedAmount = 0.0,
  }) async {
    final raw = await _categoryService.createCategory(
      name: name,
      type: type.apiValue,
      actualAmount: actualAmount.toStringAsFixed(2),
      expectedAmount: expectedAmount.toStringAsFixed(2),
    );
    return Category.fromJson(raw);
  }

  // ── Read ───────────────────────────────────────────────────────────────────

  /// Returns all categories for the authenticated user.
  Future<List<Category>> getCategories() async {
    final rawList = await _categoryService.getCategories();
    return rawList.map(Category.fromJson).toList();
  }

  /// Returns a single [Category] by its [id].
  Future<Category> getCategoryById(int id) async {
    final raw = await _categoryService.getCategoryById(id);
    return Category.fromJson(raw);
  }

  // ── Update ─────────────────────────────────────────────────────────────────

  /// Updates an existing category and returns the updated [Category].
  ///
  /// Pass [actualAmount] / [expectedAmount] only when you want to change them;
  /// omit to keep the values stored on the server.
  Future<Category> updateCategory(
    int id, {
    required String name,
    required CategoryType type,
    double? actualAmount,
    double? expectedAmount,
  }) async {
    final raw = await _categoryService.updateCategory(
      id,
      name: name,
      type: type.apiValue,
      actualAmount: actualAmount?.toStringAsFixed(2),
      expectedAmount: expectedAmount?.toStringAsFixed(2),
    );
    return Category.fromJson(raw);
  }

  // ── Delete ─────────────────────────────────────────────────────────────────

  /// Deletes the category with the given [id].
  Future<void> deleteCategory(int id) async {
    await _categoryService.deleteCategory(id);
  }
}