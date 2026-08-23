import '../core/constant/api_endpoints.dart';
import '../core/network/api_client.dart';


class UserService {
  final ApiClient _apiClient;

  UserService(this._apiClient);

  Future<Map<String, dynamic>> upgradeToLeader({
    required String socialMediaChannelName,
    required int roughFollowCount,
  }) async {
    final data = {
      'social_media_channel_name': socialMediaChannelName,
      'rough_follow_count': roughFollowCount,
    };
    return await _apiClient.put(ApiEndpoints.upgradeToLeader, data: data) as Map<String, dynamic>;
  }
}