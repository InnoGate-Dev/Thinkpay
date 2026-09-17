import '../core/constant/api_endpoints.dart';
import '../core/network/api_client.dart';


class PostService {
  final ApiClient _apiClient;

  PostService(this._apiClient);

  Future<Map<String, dynamic>> createPost(
      int communityId, {
        required String captionText,
        List<String> medias = const [],
      }) async {
    final data = {
      'caption_text': captionText,
      'medias': medias,
    };
    return await _apiClient.post(
      ApiEndpoints.communityPosts(communityId),
      data: data,
    ) as Map<String, dynamic>;
  }

  Future<List<dynamic>> getCommunityPosts(int communityId) async {
    final response = await _apiClient.get(ApiEndpoints.communityPosts(communityId));
    return response as List<dynamic>;
  }

  Future<Map<String, dynamic>> getPostById(int id) async {
    return await _apiClient.get(ApiEndpoints.postById(id)) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updatePost(
      int id, {
        required String captionText,
        List<String> medias = const [],
      }) async {
    final data = {
      'caption_text': captionText,
      'medias': medias,
    };
    return await _apiClient.put(ApiEndpoints.postById(id), data: data) as Map<String, dynamic>;
  }

  Future<void> deletePost(int id) async {
    await _apiClient.delete(ApiEndpoints.postById(id));
  }

  Future<Map<String, dynamic>> likePost(int id) async {
    return await _apiClient.post(ApiEndpoints.likePost(id)) as Map<String, dynamic>;
  }

  Future<void> unlikePost(int id) async {
    await _apiClient.delete(ApiEndpoints.unlikePost(id));
  }
}