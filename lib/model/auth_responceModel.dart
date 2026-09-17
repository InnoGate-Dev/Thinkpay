
import 'package:Thinkpay/model/userModel.dart';

class AuthResponse {
  final String token;
  final DateTime? expiresAt;
<<<<<<< HEAD
  final User? user;

  AuthResponse({required this.token, this.expiresAt, this.user});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final payload = (json.containsKey('data') && json['data'] is Map<String, dynamic>)
        ? json['data'] as Map<String, dynamic>
        : json;

    return AuthResponse(
      token: payload['token']?.toString() ?? '',
      expiresAt: payload['expires_at'] != null
          ? DateTime.tryParse(payload['expires_at'].toString())
          : null,
      user: payload['user'] != null && payload['user'] is Map<String, dynamic>
          ? User.fromJson(payload['user'] as Map<String, dynamic>)
          : null,
=======
  final User user;

  AuthResponse({required this.token, this.expiresAt, required this.user});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] ?? '',
      expiresAt: json['expires_at'] != null
          ? DateTime.tryParse(json['expires_at'])
          : null,
      user: User.fromJson(json['user']),
>>>>>>> 7f6af26f56c35ce219fd0a1e9bebf8d9a6be70f7
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'expires_at': expiresAt?.toIso8601String(),
<<<<<<< HEAD
      if (user != null) 'user': user!.toJson(),
=======
      'user': user.toJson(),
>>>>>>> 7f6af26f56c35ce219fd0a1e9bebf8d9a6be70f7
    };
  }
}
