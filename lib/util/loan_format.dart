// ── Formatting & math helpers shared across the loan feature ─────────────────

import 'package:Thinkpay/core/utils/number_format.dart';

/// Compact currency string, e.g. Rs. 1.25M / Rs. 150K / Rs. 15,000 / Rs. 450
String fmtRs(double v) => compactMoney(v);

/// Full, comma-grouped currency string, e.g. Rs. 15,000.00
String fmtRsFull(double v) => groupedMoney(v);

String daySuffix(int day) {
  if (day >= 11 && day <= 13) return 'th';
  switch (day % 10) {
    case 1:
      return 'st';
    case 2:
      return 'nd';
    case 3:
      return 'rd';
    default:
      return 'th';
  }
}

String fmtDate(DateTime d) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${months[d.month - 1]} ${d.day}, ${d.year}';
}

/// Dart's num.clamp() returns `num`, which doesn't auto-cast to double/int
/// and breaks strict typing. These small helpers keep the call sites clean.
double clampD(double v, double lo, double hi) {
  if (v < lo) return lo;
  if (v > hi) return hi;
  return v;
}

int clampI(int v, int lo, int hi) {
  if (v < lo) return lo;
  if (v > hi) return hi;
  return v;
}
