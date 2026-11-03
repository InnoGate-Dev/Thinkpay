import 'package:flutter/foundation.dart';
import '../core/constant/theme_provider.dart';
import '../core/utils/currency_catalog.dart';
import '../core/utils/number_format.dart';
import '../model/userModel.dart';

/// Currency shown before the user has picked one — matches the app's historic
/// "Rs." amounts and the onboarding default.
const String kDefaultCurrencyCode = 'LKR';

/// Holds user profile data and the country/currency preferences.
/// A ChangeNotifier singleton – all screens share the same instance.
class UserProfileStore extends ChangeNotifier {
  static final UserProfileStore _instance = UserProfileStore._internal();
  factory UserProfileStore() => _instance;
  UserProfileStore._internal();

  // ── Profile fields ─────────────────────────────────────────────────────────
  String name     = 'User';
  String email    = 'user@thinkpay.app';
  String phone    = '';
  String bio      = '';
  DateTime? birthday;
  DateTime? createdAt;
  bool isLeader = false;
  bool isLoaded = false;

  /// True while a country/currency change is being written to the backend.
  bool isSavingConfig = false;

  // ── Country & currency (from profile_config) ───────────────────────────────
  /// Country display name, e.g. `Sri Lanka`. Empty until the user picks one.
  String country = '';

  /// ISO-4217 code of the currency amounts are displayed in, e.g. `LKR`.
  String currencyCode = kDefaultCurrencyCode;

  /// App appearance from `profile_config`, e.g. `dark`.
  String themeCode = kThemeLight;

  bool get hasCountry => country.trim().isNotEmpty;

  String get countryFlag => flagForCountryName(country);

  String get currencySymbol => symbolForCurrency(currencyCode);

  String get currencyName => currencyNameOf(currencyCode);

  void setUser(User user) {
    name      = user.name;
    email     = user.email;
    birthday  = user.birthday;
    createdAt = user.createdAt;
    isLeader  = user.isLeader;

    country = user.country?.trim() ?? '';
    final code = user.currency?.trim() ?? '';
    currencyCode = code.isEmpty ? kDefaultCurrencyCode : code.toUpperCase();
    final theme = user.theme?.trim() ?? '';
    themeCode = theme.isEmpty ? kThemeLight : theme.toLowerCase();

    isLoaded = true;
    _applyPreferences();
    notifyListeners();
  }

  /// Applies a saved country/currency pair (local echo after the API call).
  ///
  /// [themeCode] is optional so a currency change does not touch the theme.
  void setProfileConfig({
    required String country,
    required String currencyCode,
    String? themeCode,
  }) {
    this.country = country.trim();
    this.currencyCode = currencyCode.trim().toUpperCase();
    if (themeCode != null) {
      final theme = themeCode.trim().toLowerCase();
      if (theme.isNotEmpty) this.themeCode = theme;
    }
    _applyPreferences();
    notifyListeners();
  }

  /// Echoes the appearance the user just picked, before the API confirms it.
  void setThemePreference(String theme) {
    final next = theme.trim().toLowerCase();
    if (next.isEmpty || next == themeCode) return;
    themeCode = next;
    _applyPreferences();
    notifyListeners();
  }

  /// Pushes the preferences onto the app-wide singletons: the amount formatters
  /// prefix every figure with [currencySymbol], and the theme decides which
  /// MaterialApp theme is shown.
  void _applyPreferences() {
    setActiveCurrencySymbol(symbolForCurrency(currencyCode));
    ThemeNotifier().applyPreference(themeCode);
  }

  void setSavingConfig(bool saving) {
    if (isSavingConfig == saving) return;
    isSavingConfig = saving;
    notifyListeners();
  }

  void updateProfile({
    required String name,
    required String email,
    required String phone,
    required String bio,
  }) {
    this.name  = name;
    this.email = email;
    this.phone = phone;
    this.bio   = bio;
    notifyListeners();
  }

  // ── Legacy currency helpers ────────────────────────────────────────────────
  Currency get selectedCurrency => currencyForCode(currencyCode);

  void setCurrency(Currency c) => setCurrencyCode(c.code);

  void setCurrencyCode(String code) {
    currencyCode = code.toUpperCase();
    _applyPreferences();
    notifyListeners();
  }

  /// Restores the signed-out defaults so no previous user's data is shown
  /// after a logout or an account deletion.
  void clear() {
    name       = 'User';
    email      = 'user@thinkpay.app';
    phone      = '';
    bio        = '';
    birthday   = null;
    createdAt  = null;
    isLeader   = false;
    isLoaded   = false;
    isSavingConfig = false;
    country    = '';
    currencyCode = kDefaultCurrencyCode;
    themeCode  = kThemeLight;
    _applyPreferences();
    notifyListeners();
  }
}

/// Entry of the short currency list kept for the legacy call sites.
Currency currencyForCode(String code) {
  final upper = code.toUpperCase();
  for (final c in currencies) {
    if (c.code == upper) return c;
  }
  final symbol = symbolForCurrency(upper);
  return Currency(code: upper, symbol: symbol.isEmpty ? upper : symbol, name: currencyNameOf(upper));
}

// ── Currency list ──────────────────────────────────────────────────────────────
class Currency {
  final String code;
  final String symbol;
  final String name;
  const Currency({required this.code, required this.symbol, required this.name});
}

const List<Currency> currencies = [
  Currency(code: 'INR', symbol: '₹',  name: 'Indian Rupee'),
  Currency(code: 'USD', symbol: '\$',  name: 'US Dollar'),
  Currency(code: 'EUR', symbol: '€',  name: 'Euro'),
  Currency(code: 'GBP', symbol: '£',  name: 'British Pound'),
  Currency(code: 'JPY', symbol: '¥',  name: 'Japanese Yen'),
  Currency(code: 'AUD', symbol: 'A\$', name: 'Australian Dollar'),
  Currency(code: 'CAD', symbol: 'C\$', name: 'Canadian Dollar'),
  Currency(code: 'SGD', symbol: 'S\$', name: 'Singapore Dollar'),
  Currency(code: 'AED', symbol: 'د.إ', name: 'UAE Dirham'),
  Currency(code: 'LKR', symbol: 'Rs.', name: 'Sri Lankan Rupee'),
];
