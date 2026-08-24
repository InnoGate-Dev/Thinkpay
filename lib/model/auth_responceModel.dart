
import 'package:Thinkpay/model/userModel.dart';

class AuthResponse {
  final String token;
  final DateTime? expiresAt;
  final User user;

  AuthResponse({required this.token, this.expiresAt, required this.user});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] ?? '',
      expiresAt: json['expires_at'] != null
          ? DateTime.tryParse(json['expires_at'])
          : null,
      user: User.fromJson(json['user']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'expires_at': expiresAt?.toIso8601String(),
      'user': user.toJson(),
    };
  }
}
