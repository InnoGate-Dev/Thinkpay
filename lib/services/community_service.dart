import '../core/constant/api_endpoints.dart';
import '../core/network/api_client.dart';


class CommunityService {
  final ApiClient _apiClient;

  CommunityService(this._apiClient);

  Future<Map<String, dynamic>> createCommunity({
    required String name,
    required String description,
    String? logoUrl,
    String? bannerUrl,
  }) async {
    final data = {
      'name': name,
      'description': description,
      'logo_url': ?logoUrl,
      'banner_url': ?bannerUrl,
    };
    return await _apiClient.post(ApiEndpoints.communities, data: data) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getCommunityById(int id) async {
    return await _apiClient.get(ApiEndpoints.communityById(id)) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateCommunity(
      int id, {
        required String name,
        required String description,
        String? logoUrl,
        String? bannerUrl,
      }) async {
    final data = {
      'name': name,
      'description': description,
      'logo_url': ?logoUrl,
      'banner_url': ?bannerUrl,
    };
    return await _apiClient.put(ApiEndpoints.communityById(id), data: data) as Map<String, dynamic>;
  }

  Future<void> deleteCommunity(int id) async {
    await _apiClient.delete(ApiEndpoints.communityById(id));
  }

  Future<Map<String, dynamic>> followCommunity(int id) async {
    return await _apiClient.post(ApiEndpoints.followCommunity(id)) as Map<String, dynamic>;
  }

  Future<void> unfollowCommunity(int id) async {
    await _apiClient.delete(ApiEndpoints.unfollowCommunity(id));
  }
}