import '../core/constant/api_endpoints.dart';
import '../core/network/api_client.dart';


class CategoryService {
  final ApiClient _apiClient;

  CategoryService(this._apiClient);

  Future<Map<String, dynamic>> createCategory({
    required String name,
    required String type, // INCOME, EXPENSE, TRANSFER
  }) async {
    final data = {
      'name': name,
      'type': type,
    };
    return await _apiClient.post(ApiEndpoints.categories, data: data) as Map<String, dynamic>;
  }

  Future<List<dynamic>> getCategories() async {
    final response = await _apiClient.get(ApiEndpoints.categories);
    return response as List<dynamic>;
  }

  Future<Map<String, dynamic>> getCategoryById(int id) async {
    return await _apiClient.get(ApiEndpoints.categoryById(id)) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateCategory(
      int id, {
        required String name,
        required String type,
      }) async {
    final data = {
      'name': name,
      'type': type,
    };
    return await _apiClient.put(ApiEndpoints.categoryById(id), data: data) as Map<String, dynamic>;
  }

  Future<void> deleteCategory(int id) async {
    await _apiClient.delete(ApiEndpoints.categoryById(id));
  }
}