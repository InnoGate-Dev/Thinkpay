// ── Formatting & date helpers shared across the credit card feature ──────────

import 'package:flutter/material.dart';
import 'package:Thinkpay/core/constant/app_colors.dart';
import 'package:Thinkpay/core/utils/number_format.dart';

const List<String> _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

/// Compact currency string used on card tiles and detail rows,
/// e.g. Rs. 1.25M / Rs. 150K / Rs. 12,500.50.
String fmtCardMoney(double v) => compactMoney(v);

/// Percentage without trailing zeros, e.g. 28 or 28.5.
String fmtApr(double v) => groupedNumber(v, decimals: 2, trimZeros: true);

/// 1 → 1st, 2 → 2nd, 3 → 3rd, 11 → 11th.
String ordinalDay(int day) {
  if (day >= 11 && day <= 13) return '${day}th';
  switch (day % 10) {
    case 1:
      return '${day}st';
    case 2:
      return '${day}nd';
    case 3:
      return '${day}rd';
    default:
      return '${day}th';
  }
}

/// Short date without the year, e.g. Mar 5.
String fmtShortDate(DateTime d) => '${_months[d.month - 1]} ${d.day}';

/// Colour for a used-credit progress bar, ramping from calm to alarming as
/// [utilisation] (0..1) approaches the limit.
Color creditUtilisationColor(ThemeColors tc, double utilisation) {
  if (utilisation >= 0.9) return tc.red;
  if (utilisation >= 0.7) return tc.accentExpense;
  if (utilisation >= 0.4) return tc.accent;
  return tc.intelligenceAccent;
}

/// Day 31 doesn't exist in every month, so clamp to the last day of the month.
DateTime statementCloseFor(int year, int month, int day) {
  final lastDay = DateTime(year, month + 1, 0).day;
  return DateTime(year, month, day > lastDay ? lastDay : day);
}

/// The next time a statement closing on [day] closes, on or after [today].
DateTime nextStatementClose(int day, DateTime today) {
  final t = DateTime(today.year, today.month, today.day);
  final thisMonth = statementCloseFor(t.year, t.month, day);
  if (!thisMonth.isBefore(t)) return thisMonth;
  return statementCloseFor(t.year, t.month + 1, day);
}
