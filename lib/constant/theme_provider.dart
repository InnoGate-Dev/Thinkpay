import 'package:flutter/material.dart';

/// A simple in-memory theme notifier.
/// Toggle between dark and light mode at runtime.
class ThemeNotifier extends ChangeNotifier {
  // ── Singleton ──────────────────────────────────────────────────────────────
  static final ThemeNotifier _instance = ThemeNotifier._internal();
  factory ThemeNotifier() => _instance;
  ThemeNotifier._internal();

  // ── State ──────────────────────────────────────────────────────────────────
  ThemeMode _mode = ThemeMode.dark;

  ThemeMode get mode => _mode;
  bool get isDark => _mode == ThemeMode.dark;

  void toggle() {
    _mode = isDark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }

  void setDark()  { _mode = ThemeMode.dark;  notifyListeners(); }
  void setLight() { _mode = ThemeMode.light; notifyListeners(); }
}
