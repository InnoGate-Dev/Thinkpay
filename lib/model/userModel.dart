class User {
  final int id;
  final String name;
  final String email;
  final bool isLeader;
  final DateTime? birthday;
  final String? socialMediaChannelName;
  final DateTime? createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.isLeader,
    this.birthday,
    this.socialMediaChannelName,
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      isLeader: json['is_leader'] ?? false,
      birthday: json['birthday'] != null
          ? DateTime.tryParse(json['birthday'])
          : null,
      socialMediaChannelName: json['social_media_channel_name'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
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
    };
  }
}
