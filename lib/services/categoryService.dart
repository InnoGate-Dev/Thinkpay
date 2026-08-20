import '../core/constant/api_endpoints.dart';
import '../core/network/api_client.dart';

/// Network service layer for the `/categories` resource.
///
/// Responsible only for making HTTP calls and returning raw decoded JSON.
/// All business logic and model mapping belongs to [CategoryRepository].
class CategoryService {
  final ApiClient _apiClient;

  const CategoryService(this._apiClient);

  // ── Create ─────────────────────────────────────────────────────────────────

  /// Creates a new category.
  ///
  /// [type] must be one of `"INCOME"`, `"EXPENSE"`, or `"TRANSFER"`.
  /// [actualAmount] and [expectedAmount] are optional decimal strings;
  /// the backend defaults them to `"0.00"` when omitted.
  Future<Map<String, dynamic>> createCategory({
    required String name,
    required String type,
    String? actualAmount,
    String? expectedAmount,
  }) async {
    final body = <String, dynamic>{
      'name': name,
      'type': type,
      'actual_amount': ?actualAmount,
      'expected_amount': ?expectedAmount,
    };
    final response =
        await _apiClient.post(ApiEndpoints.categories, data: body);
    // Backend wraps all success responses in {"data": ...}
    return (response as Map<String, dynamic>)['data'] as Map<String, dynamic>;
  }

  // ── Read ───────────────────────────────────────────────────────────────────

  /// Returns all categories belonging to the authenticated user.
  Future<List<Map<String, dynamic>>> getCategories() async {
    final response = await _apiClient.get(ApiEndpoints.categories);
    // Response shape: {"data": [...]} or {"data": null}
    if (response is Map<String, dynamic>) {
      final data = response['data'];
      if (data is List) {
        return data.cast<Map<String, dynamic>>();
      }
    } else if (response is List) {
      return response.cast<Map<String, dynamic>>();
    }
    return <Map<String, dynamic>>[];
  }

  /// Returns a single category by its [id].
  Future<Map<String, dynamic>> getCategoryById(int id) async {
    final response = await _apiClient.get(ApiEndpoints.categoryById(id));
    return (response as Map<String, dynamic>)['data'] as Map<String, dynamic>;
  }

  // ── Update ─────────────────────────────────────────────────────────────────

  /// Updates an existing category identified by [id].
  ///
  /// Both [name] and [type] are required by the backend validator.
  /// Supply [actualAmount] / [expectedAmount] to override the stored values;
  /// omit them to let the backend keep the existing ones.
  Future<Map<String, dynamic>> updateCategory(
    int id, {
    required String name,
    required String type,
    String? actualAmount,
    String? expectedAmount,
  }) async {
    final body = <String, dynamic>{
      'name': name,
      'type': type,
      'actual_amount': ?actualAmount,
      'expected_amount': ?expectedAmount,
    };
    final response =
        await _apiClient.put(ApiEndpoints.categoryById(id), data: body);
    return (response as Map<String, dynamic>)['data'] as Map<String, dynamic>;
  }

  // ── Delete ─────────────────────────────────────────────────────────────────

  /// Deletes the category with the given [id].
  ///
  /// The backend returns 204 No Content on success.
  Future<void> deleteCategory(int id) async {
    await _apiClient.delete(ApiEndpoints.categoryById(id));
  }
}