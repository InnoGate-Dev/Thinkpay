import 'package:flutter/material.dart';

import 'package:Thinkpay/core/utils/number_format.dart';

String _dateStr(DateTime d) {
  final now = DateTime.now();
  if (d.year == now.year && d.month == now.month && d.day == now.day) {
    return 'Today';
  }
  if (d.year == now.year && d.month == now.month && d.day == now.day - 1) {
    return 'Yesterday';
  }
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${d.day} ${months[d.month - 1]}';
}

IconData _categoryIcon(String cat) {
  switch (cat.toLowerCase()) {
    case 'food':
      return Icons.restaurant_rounded;
    case 'transport':
      return Icons.directions_car_rounded;
    case 'shopping':
      return Icons.shopping_bag_rounded;
    case 'entertainment':
      return Icons.movie_rounded;
    case 'utilities':
      return Icons.bolt_rounded;
    case 'health':
      return Icons.favorite_rounded;
    case 'education':
      return Icons.school_rounded;
    case 'rent':
      return Icons.home_rounded;
    case 'salary':
      return Icons.account_balance_wallet_rounded;
    case 'freelance':
      return Icons.work_rounded;
    case 'business':
      return Icons.business_center_rounded;
    case 'investment':
      return Icons.trending_up_rounded;
    case 'savings':
    case 'savings account':
      return Icons.savings_rounded;
    case 'brokerage':
    case 'transfer':
    case 'bank transfer':
      return Icons.swap_horiz_rounded;
    case 'gift':
      return Icons.card_giftcard_rounded;
    default:
      return Icons.receipt_rounded;
  }
}

// Expose them as public functions
/// Compact amount for cards and rows, prefixed with the currency the user
/// picked in their profile: `Rs. 1.25M` / `$ 150K` / `Rs. 25,000`.
String formatAmount(double v) => compactMoney(v);
String formatDate(DateTime d) => _dateStr(d);
IconData getCategoryIcon(String cat) => _categoryIcon(cat);
