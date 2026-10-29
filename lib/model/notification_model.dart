enum NotifType {
  reminder,
  goal,
  info,
  alert,
  budgetAlert,
  system;

  static NotifType fromApi(String? typeStr) {
    if (typeStr == null) return NotifType.info;
    switch (typeStr.toLowerCase().replaceAll('_', '').replaceAll(' ', '')) {
      case 'reminder':
        return NotifType.reminder;
      case 'goal':
        return NotifType.goal;
      case 'info':
        return NotifType.info;
      case 'alert':
      case 'warning':
        return NotifType.alert;
      case 'budgetalert':
      case 'budget':
        return NotifType.budgetAlert;
      case 'system':
      default:
        return NotifType.system;
    }
  }

  String get apiValue {
    switch (this) {
      case NotifType.reminder:
        return 'reminder';
      case NotifType.goal:
        return 'goal';
      case NotifType.info:
        return 'info';
      case NotifType.alert:
        return 'alert';
      case NotifType.budgetAlert:
        return 'budget_alert';
      case NotifType.system:
        return 'system';
    }
  }

  String get label {
    switch (this) {
      case NotifType.reminder:
        return 'Reminder';
      case NotifType.goal:
        return 'Goal';
      case NotifType.info:
        return 'Info';
      case NotifType.alert:
        return 'Alert';
      case NotifType.budgetAlert:
        return 'Budget Alert';
      case NotifType.system:
        return 'System';
    }
  }
}

class NotificationModel {
  final int id;
  final int userId;
  final String title;
  final String message;
  final NotifType type;
  final bool isRead;
  final DateTime createdAt;
  final DateTime updatedAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: _parseInt(json['id']),
      userId: _parseInt(json['user_id']),
      title: _parseString(json['title']) ?? '',
      message: _parseString(json['message']) ?? '',
      type: NotifType.fromApi(_parseString(json['type'])),
      isRead: json['read'] == true || json['is_read'] == true,
      createdAt: _parseDateTime(json['created_at']) ?? DateTime.now(),
      updatedAt: _parseDateTime(json['updated_at']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'message': message,
      'type': type.apiValue,
      'read': isRead,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'title': title,
      'message': message,
      'type': type.apiValue,
    };
  }

  NotificationModel copyWith({
    int? id,
    int? userId,
    String? title,
    String? message,
    NotifType? type,
    bool? isRead,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static int _parseInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  static String? _parseString(dynamic v) {
    if (v == null) return null;
    if (v is String) return v;
    if (v is Map) {
      final valid = v['Valid'] == true;
      return valid ? v['String'] as String? : null;
    }
    return v.toString();
  }

  static DateTime? _parseDateTime(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    if (v is String) return DateTime.tryParse(v);
    if (v is Map) {
      final valid = v['Valid'] == true;
      if (!valid) return null;
      return DateTime.tryParse(v['Time'] as String? ?? '');
    }
    return null;
  }
}
