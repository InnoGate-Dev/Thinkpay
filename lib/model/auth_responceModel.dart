
import 'package:Thinkpay/model/userModel.dart';

class AuthResponse {
  final String token;
  final DateTime? expiresAt;
  final User? user;

  /// True when this sign-in cancelled a scheduled deletion: the profile had
  /// been deactivated by `DELETE /users/me` and the backend just reactivated
  /// it, so the app should welcome the user back.
  final bool deletionCancelled;

  AuthResponse({
    required this.token,
    this.expiresAt,
    this.user,
    this.deletionCancelled = false,
  });

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
      deletionCancelled: payload['deletion_cancelled'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'expires_at': expiresAt?.toIso8601String(),
      if (user != null) 'user': user!.toJson(),
      if (deletionCancelled) 'deletion_cancelled': true,
    };
  }
}
