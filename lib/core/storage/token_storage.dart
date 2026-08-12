import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  static const _tokenKey = 'auth_token';
  static const _expiresAtKey = 'auth_expires_at';

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
  }
}