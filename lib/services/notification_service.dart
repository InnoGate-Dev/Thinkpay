import '../core/constant/api_endpoints.dart';
import '../core/constant/app_config.dart';
import '../core/network/api_client.dart';

class NotificationService {
  final ApiClient _apiClient;

  NotificationService([ApiClient? apiClient])
      : _apiClient = apiClient ?? ApiClient(baseUrl: AppConfig.baseUrl);

  /// Retrieves all notifications for the authenticated user.
  Future<List<dynamic>> fetchNotifications() async {
    final response = await _apiClient.get(ApiEndpoints.notifications);
    if (response is Map<String, dynamic>) {
      final data = response['data'];
      if (data is List) return data;
    } else if (response is List) {
      return response;
    }
    return <dynamic>[];
  }

  /// Retrieves the count of unread notifications.
  Future<int> fetchUnreadCount() async {
    final response = await _apiClient.get(ApiEndpoints.unreadNotificationCount);
    if (response is Map<String, dynamic>) {
      final data = response['data'];
      if (data is Map<String, dynamic> && data.containsKey('unread_count')) {
        final count = data['unread_count'];
        if (count is int) return count;
        if (count is num) return count.toInt();
        if (count is String) return int.tryParse(count) ?? 0;
      }
    }
    return 0;
  }

  /// Fetches details for a single notification by [id].
  Future<Map<String, dynamic>> getNotificationById(int id) async {
    final response = await _apiClient.get(ApiEndpoints.notificationById(id));
    if (response is Map<String, dynamic> && response.containsKey('data')) {
      return response['data'] as Map<String, dynamic>;
    }
    return response as Map<String, dynamic>;
  }

  /// Creates a new notification for the authenticated user.
  Future<Map<String, dynamic>> createNotification({
    required String title,
    required String message,
    required String type,
  }) async {
    final data = {
      'title': title,
      'message': message,
      'type': type,
    };
    final response = await _apiClient.post(
      ApiEndpoints.notifications,
      data: data,
    );
    if (response is Map<String, dynamic> && response.containsKey('data')) {
      return response['data'] as Map<String, dynamic>;
    }
    return response as Map<String, dynamic>;
  }

  /// Marks a specific notification as read.
  Future<Map<String, dynamic>> markAsRead(int id) async {
    final response = await _apiClient.put(
      ApiEndpoints.markNotificationAsRead(id),
    );
    if (response is Map<String, dynamic> && response.containsKey('data')) {
      return response['data'] as Map<String, dynamic>;
    }
    return response is Map<String, dynamic> ? response : <String, dynamic>{};
  }

  /// Marks all notifications as read for the authenticated user.
  Future<void> markAllAsRead() async {
    await _apiClient.put(ApiEndpoints.markAllNotificationsAsRead);
  }

  /// Deletes a specific notification by [id].
  Future<void> deleteNotification(int id) async {
    await _apiClient.delete(ApiEndpoints.deleteNotification(id));
  }
}
