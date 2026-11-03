import 'package:flutter/material.dart';

/// App appearance, stored per user in `profile_config.theme`.
///
/// The value the backend keeps is the plain string `light` / `dark`, which is
/// why the preference is exposed as [preference] rather than a [ThemeMode]:
/// one of the two is persisted, the other is what [MaterialApp] consumes.
const String kThemeLight = 'light';
const String kThemeDark = 'dark';

/// A simple theme notifier.
/// Toggle between dark and light mode at runtime.
class ThemeNotifier extends ChangeNotifier {
  // ── Singleton ──────────────────────────────────────────────────────────────
  static final ThemeNotifier _instance = ThemeNotifier._internal();
  factory ThemeNotifier() => _instance;
  ThemeNotifier._internal();

  // ── State ──────────────────────────────────────────────────────────────────
  ThemeMode _mode = ThemeMode.light;

  ThemeMode get mode => _mode;
  bool get isDark => _mode == ThemeMode.dark;

  /// The value persisted in `profile_config.theme`.
  String get preference => isDark ? kThemeDark : kThemeLight;

  void toggle() => setMode(isDark ? ThemeMode.light : ThemeMode.dark);

  void setDark() => setMode(ThemeMode.dark);
  void setLight() => setMode(ThemeMode.light);

  void setMode(ThemeMode mode) {
    if (_mode == mode) return;
    _mode = mode;
    notifyListeners();
  }

  /// Applies a stored preference (`dark` / `light`).
  ///
  /// Anything else — an empty value from an account that never chose one, or a
  /// value from a newer build — leaves the current mode untouched so the app
  /// never flips to a random theme.
  void applyPreference(String? preference) {
    switch (preference?.trim().toLowerCase()) {
      case kThemeDark:
        setDark();
      case kThemeLight:
        setLight();
      default:
        break;
    }
  }
}
