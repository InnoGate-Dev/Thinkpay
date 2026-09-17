import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  static const _tokenKey = 'auth_token';
<<<<<<< HEAD
  static const _expiresAtKey = 'auth_expires_at';
=======
>>>>>>> 7f6af26f56c35ce219fd0a1e9bebf8d9a6be70f7

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> deleteToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
<<<<<<< HEAD
    await prefs.remove(_expiresAtKey);
  }

  Future<void> saveExpiresAt(DateTime expiresAt) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_expiresAtKey, expiresAt.toUtc().toIso8601String());
  }

  Future<DateTime?> getExpiresAt() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_expiresAtKey);
    return raw != null ? DateTime.tryParse(raw) : null;
=======
>>>>>>> 7f6af26f56c35ce219fd0a1e9bebf8d9a6be70f7
  }
}