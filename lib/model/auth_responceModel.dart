
import 'package:Thinkpay/model/userModel.dart';

class AuthResponse {
  final String token;
  final DateTime? expiresAt;
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
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'expires_at': expiresAt?.toIso8601String(),
      if (user != null) 'user': user!.toJson(),
    };
  }
}
