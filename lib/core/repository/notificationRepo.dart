import '../../model/notification_model.dart';
import '../../services/notification_service.dart';

class NotificationRepository {
  final NotificationService _notificationService;

  NotificationRepository([NotificationService? notificationService])
      : _notificationService = notificationService ?? NotificationService();

  /// Fetches all notifications for the user.
  Future<List<NotificationModel>> getNotifications() async {
    final rawList = await _notificationService.fetchNotifications();
    final notifications = rawList
        .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
        .toList();
    // Sort newest first
    notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return notifications;
  }

  /// Fetches the count of unread notifications.
  Future<int> getUnreadCount() async {
    return await _notificationService.fetchUnreadCount();
  }

  /// Fetches a single notification by ID.
  Future<NotificationModel> getNotificationById(int id) async {
    final raw = await _notificationService.getNotificationById(id);
    return NotificationModel.fromJson(raw);
  }

  /// Creates a new notification.
  Future<NotificationModel> createNotification({
    required String title,
    required String message,
    required NotifType type,
  }) async {
    final raw = await _notificationService.createNotification(
      title: title,
      message: message,
      type: type.apiValue,
    );
    return NotificationModel.fromJson(raw);
  }

  /// Marks a specific notification as read.
  Future<NotificationModel?> markAsRead(int id) async {
    final raw = await _notificationService.markAsRead(id);
    if (raw.isNotEmpty) {
      return NotificationModel.fromJson(raw);
    }
    return null;
  }

  /// Marks all notifications as read.
  Future<void> markAllAsRead() async {
    await _notificationService.markAllAsRead();
  }

  /// Deletes a notification by ID.
  Future<void> deleteNotification(int id) async {
    await _notificationService.deleteNotification(id);
  }
}
