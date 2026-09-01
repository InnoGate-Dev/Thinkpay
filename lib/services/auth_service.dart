import '../core/constant/api_endpoints.dart';
import '../core/network/api_client.dart';

/// Handles all authentication-related API calls.
///
/// Endpoints covered:
///   POST /auth/register
///   POST /auth/login
///   POST /auth/google
class AuthService {
  final ApiClient _apiClient;

  AuthService(this._apiClient);

  /// Registers a new user account.
  ///
  /// [birthday] should be provided as an ISO-8601 UTC string
  /// (e.g. "1995-05-15T00:00:00Z").
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String birthday,
    bool isLeader = false,
    String? socialMediaChannelName,
  }) async {
    final data = {
      'name': name,
      'email': email,
      'password': password,
      'birthday': birthday,
      'is_leader': isLeader,
      'social_media_channel_name': socialMediaChannelName,
    }..removeWhere((_, v) => v == null);
    return await _apiClient.post(
      ApiEndpoints.register,
      data: data,
    ) as Map<String, dynamic>;
  }

  /// Signs in an existing user with email and password.
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final data = {
      'email': email,
      'password': password,
    };
    return await _apiClient.post(
      ApiEndpoints.login,
      data: data,
    ) as Map<String, dynamic>;
  }

  /// Authenticates (or registers) a user via Google OAuth.
  ///
  /// [googleProviderId] is the UID returned by the Google sign-in SDK.
  Future<Map<String, dynamic>> googleAuth({
    required String googleProviderId,
    required String email,
    required String name,
  }) async {
    final data = {
      'google_provider_id': googleProviderId,
      'email': email,
      'name': name,
    };
    return await _apiClient.post(
      ApiEndpoints.googleAuth,
      data: data,
    ) as Map<String, dynamic>;
  }
}
