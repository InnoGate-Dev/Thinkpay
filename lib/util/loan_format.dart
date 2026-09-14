// ── Formatting & math helpers shared across the loan feature ─────────────────

/// Compact currency string, e.g. Rs. 1.25L / Rs. 15.0K / Rs. 450
String fmtRs(double v) {
  final isNegative = v < 0;
  final abs = v.abs();
  String result;
  if (abs >= 100000) {
    result = 'Rs. ${(abs / 100000).toStringAsFixed(2)}L';
  } else if (abs >= 1000) {
    result = 'Rs. ${(abs / 1000).toStringAsFixed(1)}K';
  } else {
    result = 'Rs. ${abs.toStringAsFixed(0)}';
  }
  return isNegative ? '-$result' : result;
}

/// Full, comma-grouped currency string, e.g. Rs. 15,000.00
String fmtRsFull(double v) {
  final isNeg = v < 0;
  final s = v.abs().toStringAsFixed(2);
  final parts = s.split('.');
  final whole = parts[0];
  final buf = StringBuffer();
  for (int i = 0; i < whole.length; i++) {
    final remain = whole.length - i;
    buf.write(whole[i]);
    if (remain > 1 && remain % 3 == 1) buf.write(',');
  }
  return '${isNeg ? '-' : ''}Rs. ${buf.toString()}.${parts[1]}';
}

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
