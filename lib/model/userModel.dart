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
