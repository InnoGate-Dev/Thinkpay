import '../core/constant/api_endpoints.dart';
import '../core/network/api_client.dart';


class UserService {
  final ApiClient _apiClient;

  UserService(this._apiClient);

  Future<Map<String, dynamic>> getProfile() async =>
      await _apiClient.get(ApiEndpoints.currentUser) as Map<String, dynamic>;

  Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String? birthday,
  }) async => await _apiClient.put(
        ApiEndpoints.currentUser,
        data: {'name': name, 'birthday': birthday},
      ) as Map<String, dynamic>;

  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async => await _apiClient.put(
        ApiEndpoints.changePassword,
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
        },
      ) as Map<String, dynamic>;

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

  /// Stores the preferences of the profile (`profile_config`): country,
  /// currency and theme.
  ///
  /// Each value is optional — an omitted field keeps what is already stored, so
  /// toggling the theme cannot reset the currency. Changing the currency never
  /// converts amounts, it only changes the symbol.
  Future<Map<String, dynamic>> updateProfileConfig({
    String country = '',
    String currency = '',
    String theme = '',
  }) async => await _apiClient.put(
        ApiEndpoints.profileConfig,
        data: {
          if (country.isNotEmpty) 'country': country,
          if (currency.isNotEmpty) 'currency': currency,
          if (theme.isNotEmpty) 'theme': theme,
        },
      ) as Map<String, dynamic>;

  /// Deactivates the account and schedules its permanent deletion.
  Future<Map<String, dynamic>> deleteAccount() async =>
      await _apiClient.delete(ApiEndpoints.currentUser) as Map<String, dynamic>;
}
