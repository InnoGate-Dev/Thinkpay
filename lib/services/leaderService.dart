import '../core/constant/api_endpoints.dart';
import '../core/network/api_client.dart';


class LeaderService {
  final ApiClient _apiClient;

  LeaderService(this._apiClient);

  Future<Map<String, dynamic>> getDashboardStats() async {
    return await _apiClient.get(ApiEndpoints.leaderDashboard) as Map<String, dynamic>;
  }
}