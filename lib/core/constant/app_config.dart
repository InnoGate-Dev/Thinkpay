/// Centralised application configuration.
/// Update [baseUrl] to point to your running backend server.
class AppConfig {
  AppConfig._();

  // ── API ─────────────────────────────────────────────────────────────────────
  /// Base URL including the versioned prefix.
  /// Change this to your production / staging URL before releasing.
  //static const String baseUrl = 'http://192.168.43.1:8080/api/v1';
  static const String baseUrl = 'http://172.22.48.1:8080/api/v1';
}
