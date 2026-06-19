import 'package:flutter/foundation.dart';

/// Holds user profile data and selected currency.
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

  // ── Currency ───────────────────────────────────────────────────────────────
  Currency selectedCurrency = currencies.first;

  void setCurrency(Currency c) {
    selectedCurrency = c;
    notifyListeners();
  }
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
