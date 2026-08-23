import '../core/constant/api_endpoints.dart';
import '../core/network/api_client.dart';


class CommentService {
  final ApiClient _apiClient;

  CommentService(this._apiClient);

  Future<Map<String, dynamic>> createComment(
      int postId, {
        required String content,
        int? parentCommentId,
      }) async {
    final data = {
      'content': content,
      'parent_comment_id': parentCommentId,
    };
    return await _apiClient.post(
      ApiEndpoints.postComments(postId),
      data: data,
    ) as Map<String, dynamic>;
  }

  Future<List<dynamic>> getPostComments(int postId) async {
    final response = await _apiClient.get(ApiEndpoints.postComments(postId));
    return response as List<dynamic>;
  }

  Future<Map<String, dynamic>> updateComment(
      int id, {
        required String content,
      }) async {
    final data = {'content': content};
    return await _apiClient.put(ApiEndpoints.commentById(id), data: data) as Map<String, dynamic>;
  }

  Future<void> deleteComment(int id) async {
    await _apiClient.delete(ApiEndpoints.commentById(id));
  }
}