// ── Formatting & date helpers shared across the credit card feature ──────────

const List<String> _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

/// Comma-grouped currency string, e.g. Rs. 100,000 or Rs. 12,500.50.
String fmtCardMoney(double v) {
  final fixed =
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2);
  final parts = fixed.split('.');
  final whole =
      parts[0].replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');
  return parts.length > 1 ? 'Rs. $whole.${parts[1]}' : 'Rs. $whole';
}

/// Percentage without trailing zeros, e.g. 28 or 28.5.
String fmtApr(double v) =>
    v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();

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
