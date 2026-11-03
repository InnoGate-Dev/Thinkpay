// ─────────────────────────────────────────────────────────────────────────────
// Number & money formatting
// ─────────────────────────────────────────────────────────────────────────────
//
// Every amount in the app goes through this file, so the same number always
// reads the same way, wherever it is shown.
//
// Large values collapse onto the internationally familiar K / M / B / T
// suffixes: 1,000,000 is "1M" — never "10L" and never a wall of digits that
// overflows its card. Two shapes are offered:
//
//   compact  →  "1.25M" / "Rs. 1.25M"        cards, tiles, charts, list rows
//   grouped  →  "1,500,000" / "Rs. 1,500,000.00"   forms, receipts, detail screens
//
// Below [kCompactThreshold] an amount is shown exactly, with thousands
// separators (25,000) — that is where cents still matter. Above it the value
// collapses to a suffix (150K, 1.25M) so it stays readable at a glance.
// Decimals are chosen by magnitude (999, 99.9K, 9.99K) and trailing zeros are
// dropped, so a round number reads as "1M" rather than "1.00M".

/// Suffixes in ascending order of magnitude. Index 0 means "no suffix".
const List<String> _scaleSuffixes = <String>['', 'K', 'M', 'B', 'T'];

/// Symbol used when a caller has no currency context (the app's historic "Rs.").
const String kDefaultCurrencySymbol = 'Rs.';

/// The currency symbol every amount falls back to when the caller does not pass
/// one. [UserProfileStore] keeps it in step with the currency saved in
/// `profile_config`, so a user who switched to `$` sees dollars everywhere
/// without every call site having to thread the symbol through.
String _activeCurrencySymbol = kDefaultCurrencySymbol;

/// Symbol in force for callers that do not name one.
String get activeCurrencySymbol => _activeCurrencySymbol;

/// Points the default symbol at the user's chosen currency. An empty value
/// restores the built-in default rather than rendering amounts without one.
void setActiveCurrencySymbol(String symbol) {
  final next = symbol.trim();
  _activeCurrencySymbol = next.isEmpty ? kDefaultCurrencySymbol : next;
}

/// Values below this are shown in full (`25,000`); values above it are
/// abbreviated (`150K`, `1.25M`). 100,000 keeps everyday amounts exact while
/// cutting the numbers that used to turn into "10L".
const int kCompactThreshold = 100000;

/// Placeholder shown when a value cannot be formatted (NaN / infinity).
const String kNotAvailable = '—';

// ─────────────────────────────────────────────────────────────────────────────
// Compact numbers
// ─────────────────────────────────────────────────────────────────────────────

/// Human-readable short form of [value].
///
/// ```dart
/// compactNumber(999)        // 999
/// compactNumber(1250)       // 1,250
/// compactNumber(25000.5)    // 25,000.50
/// compactNumber(150000)     // 150K
/// compactNumber(1000000)    // 1M
/// compactNumber(1250000)    // 1.25M
/// compactNumber(-2500000)   // -2.5M
/// ```
///
/// Pass [decimals] to force a fixed precision; by default it follows the
/// magnitude so the result stays legible inside narrow tiles. Pass a lower
/// [compactFrom] to abbreviate earlier (chart axes, very narrow tiles).
String compactNumber(
  num value, {
  int? decimals,
  num compactFrom = kCompactThreshold,
}) {
  if (value.isNaN || value.isInfinite) return kNotAvailable;

  final sign = value < 0 ? '-' : '';
  var scaled = value.abs().toDouble();

  // Small enough to read in full — keep every digit the user typed.
  if (scaled < compactFrom) {
    final places =
        decimals ?? (scaled == scaled.roundToDouble() ? 0 : 2);
    return _signed(
      sign,
      groupedNumber(scaled, decimals: places, trimZeros: true),
    );
  }

  var tier = 0;
  while (scaled >= 1000 && tier < _scaleSuffixes.length - 1) {
    scaled /= 1000;
    tier++;
  }

  var places = decimals ?? _placesFor(scaled);
  var shown = _round(scaled, places);

  // Rounding must never produce "1000K": promote it to the next suffix.
  if (shown >= 1000 && tier < _scaleSuffixes.length - 1) {
    shown = shown / 1000;
    tier++;
    places = decimals ?? _placesFor(shown);
    shown = _round(shown, places);
  }

  return _signed(sign, '${_fixed(shown, places)}${_scaleSuffixes[tier]}');
}

/// Compact money with the currency symbol in front, e.g. `Rs. 1.25M`.
///
/// [symbol] defaults to the active currency ([activeCurrencySymbol]), so the
/// amount follows the currency chosen in the profile settings.
/// The sign always leads: `-Rs. 450`, never `Rs. -450`.
String compactMoney(
  num value, {
  String? symbol,
  int? decimals,
  num compactFrom = kCompactThreshold,
}) =>
    _withSymbol(
      value,
      compactNumber(
        value.abs(),
        decimals: decimals,
        compactFrom: compactFrom,
      ),
      symbol ?? activeCurrencySymbol,
    );

// ─────────────────────────────────────────────────────────────────────────────
// Grouped numbers
// ─────────────────────────────────────────────────────────────────────────────

/// Full number with thousands separators, for forms and receipts.
///
/// ```dart
/// groupedNumber(1500000)                     // 1,500,000
/// groupedNumber(1250.5, decimals: 2)         // 1,250.50
/// groupedNumber(1250.5, decimals: 2, trimZeros: true) // 1,250.5
/// ```
String groupedNumber(
  num value, {
  int decimals = 0,
  bool trimZeros = false,
}) {
  if (value.isNaN || value.isInfinite) return kNotAvailable;

  final fixed = value.abs().toStringAsFixed(decimals);
  final parts = fixed.split('.');
  final whole = parts[0].replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => ',',
  );

  var fraction = parts.length > 1 ? parts[1] : '';
  if (trimZeros) fraction = fraction.replaceFirst(RegExp(r'0+$'), '');

  final body = fraction.isEmpty ? whole : '$whole.$fraction';
  final negative = value < 0 && RegExp(r'[1-9]').hasMatch(body);
  return negative ? '-$body' : body;
}

/// Grouped money with the currency symbol in front, e.g. `Rs. 1,500,000`.
///
/// [symbol] defaults to the active currency ([activeCurrencySymbol]).
String groupedMoney(
  num value, {
  String? symbol,
  int decimals = 2,
  bool trimZeros = true,
}) =>
    _withSymbol(
      value,
      groupedNumber(value.abs(), decimals: decimals, trimZeros: trimZeros),
      symbol ?? activeCurrencySymbol,
    );

// ─────────────────────────────────────────────────────────────────────────────
// Percentages
// ─────────────────────────────────────────────────────────────────────────────

/// Percentage without trailing zeros: `28` → `28%`, `28.5` → `28.5%`.
String percentNumber(num value, {int decimals = 2}) {
  if (value.isNaN || value.isInfinite) return kNotAvailable;
  final sign = value < 0 ? '-' : '';
  return '${_signed(sign, _fixed(value.abs().toDouble(), decimals))}%';
}

// ─────────────────────────────────────────────────────────────────────────────
// Parsing
// ─────────────────────────────────────────────────────────────────────────────

/// Forgiving amount parser used by every money input in the app.
///
/// Accepts grouped and compact input, in any case, with or without a currency
/// symbol — `1,200`, ` 1200.50 `, `Rs 1200`, `1.2k`, `1.5m`, `2B`.
/// Returns null when nothing numeric is present.
double? parseAmount(String raw) {
  var text = raw.toLowerCase().replaceAll(RegExp(r'[\s,\u00A0]'), '');
  if (text.isEmpty) return null;

  var negative = false;
  if (text.startsWith('-') || text.startsWith('−')) {
    negative = true;
    text = text.substring(1);
  }

  // Digits with an optional decimal part, optionally followed by a scale letter.
  final match =
      RegExp(r'(\d+(?:\.\d+)?|\.\d+)([kmbt])?').firstMatch(text);
  if (match == null) return null;

  final parsed = double.tryParse(match.group(1)!);
  if (parsed == null) return null;

  final value = parsed * _multiplierFor(match.group(2));
  return negative ? -value : value;
}

double _multiplierFor(String? scale) {
  switch (scale) {
    case 'k':
      return 1e3;
    case 'm':
      return 1e6;
    case 'b':
      return 1e9;
    case 't':
      return 1e12;
    default:
      return 1;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Internals
// ─────────────────────────────────────────────────────────────────────────────

/// Two decimals below 10, one below 100, none above — keeps compact values
/// to a predictable width.
int _placesFor(double scaled) {
  if (scaled < 10) return 2;
  if (scaled < 100) return 1;
  return 0;
}

double _round(double value, int places) =>
    double.parse(value.toStringAsFixed(places));

/// Drops the sign when rounding left nothing worth signing (`-0` → `0`).
String _signed(String sign, String body) =>
    sign.isEmpty || !RegExp(r'[1-9]').hasMatch(body) ? body : '$sign$body';

/// `toStringAsFixed` with trailing zeros (and a bare trailing dot) removed.
String _fixed(double value, int places) {
  var text = value.toStringAsFixed(places);
  if (text.contains('.')) {
    text = text.replaceFirst(RegExp(r'\.?0+$'), '');
  }
  return text.isEmpty ? '0' : text;
}

String _withSymbol(num original, String body, String symbol) {
  final trimmed = symbol.trim();
  final sign = original < 0 && RegExp(r'[1-9]').hasMatch(body) ? '-' : '';
  if (trimmed.isEmpty) return '$sign$body';

  // Word-like symbols (Rs., AED, LKR) read better with a space; glyph symbols
  // ($, ₹, €) sit flush against the number.
  final spaced = RegExp(r'[A-Za-z.]$').hasMatch(trimmed);
  return '$sign$trimmed${spaced ? ' ' : ''}$body';
}
