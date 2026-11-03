class User {
  final int id;
  final String name;
  final String email;
  final bool isLeader;
  final DateTime? birthday;
  final String? socialMediaChannelName;
  final DateTime? createdAt;

  /// Country display name from `profile_config` (null/empty until chosen).
  final String? country;

  /// ISO-4217 code from `profile_config` (null/empty until chosen).
  final String? currency;

  /// App appearance from `profile_config`: `light` or `dark`.
  final String? theme;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.isLeader,
    this.birthday,
    this.socialMediaChannelName,
    this.createdAt,
    this.country,
    this.currency,
    this.theme,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      isLeader: json['is_leader'] == true || json['is_leader'] == 1,
      birthday: json['birthday'] != null
          ? DateTime.tryParse(json['birthday'].toString())
          : null,
      socialMediaChannelName: json['social_media_channel_name']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      country: _optionalText(json['country']),
      currency: _optionalText(json['currency']),
      theme: _optionalText(json['theme']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'is_leader': isLeader,
      'birthday': birthday?.toIso8601String(),
      'social_media_channel_name': socialMediaChannelName,
      'created_at': createdAt?.toIso8601String(),
      'country': country,
      'currency': currency,
      'theme': theme,
    };
  }

  /// Empty strings from the API mean "not set yet", not a real value.
  static String? _optionalText(Object? value) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? null : text;
  }
}
