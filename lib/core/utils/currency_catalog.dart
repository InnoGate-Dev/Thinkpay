import 'package:currency_country_picker/currency_country_picker.dart' as ccp;

// ─────────────────────────────────────────────────────────────────────────────
// Country & currency catalogue
// ─────────────────────────────────────────────────────────────────────────────
//
// The backend only stores plain strings: `profile_config.country` holds the
// country's display name and `profile_config.currency` an ISO-4217 code. This
// file resolves both against the `currency_country_picker` catalogue so any
// screen can render the right symbol, name and flag without shipping its own
// copy of the data.
//
// The catalogue is parsed lazily and cached — it has ~250 entries and most
// sessions never touch it.

List<ccp.Currency>? _currencyCache;
Map<String, ccp.Currency>? _currencyByCode;
List<ccp.Country>? _countryCache;
Map<String, ccp.Country>? _countryByName;

/// Every currency the picker knows about (code, name, symbol, flag).
List<ccp.Currency> get currencyCatalogue =>
    _currencyCache ??= ccp.CurrencyService().getAllCurrencies();

Map<String, ccp.Currency> get _currencyIndex => _currencyByCode ??= {
  for (final currency in currencyCatalogue) currency.code.toUpperCase(): currency,
};

/// Every country the picker knows about (name, flag, currency).
List<ccp.Country> get countryCatalogue =>
    _countryCache ??= ccp.CountryService().getAllCountries();

Map<String, ccp.Country> get _countryIndex => _countryByName ??= {
  for (final country in countryCatalogue) country.name.toLowerCase(): country,
};

/// Symbol of an ISO-4217 [code]: `LKR` → `Rs.`, `USD` → `$`.
/// Falls back to the code itself so an unknown value still renders.
String symbolForCurrency(String? code) {
  final currency = currencyFromCode(code);
  if (currency != null && currency.symbol.trim().isNotEmpty) {
    return currency.symbol;
  }
  final upper = (code ?? '').trim().toUpperCase();
  return upper.isEmpty ? '' : upper;
}

/// Display name of an ISO-4217 [code]: `LKR` → `Sri Lankan Rupee`.
String currencyNameOf(String? code) {
  final currency = currencyFromCode(code);
  if (currency != null && currency.name.trim().isNotEmpty) return currency.name;
  return (code ?? '').trim().toUpperCase();
}

/// Flag emoji of an ISO-4217 [code], taken from a country that uses it.
String currencyFlagOf(String? code) {
  final currency = currencyFromCode(code);
  return currency?.flag ?? '';
}

/// Catalogue entry for an ISO-4217 [code].
ccp.Currency? currencyFromCode(String? code) {
  final upper = (code ?? '').trim().toUpperCase();
  if (upper.isEmpty) return null;
  return _currencyIndex[upper];
}

/// Catalogue entry for a country display name.
ccp.Country? countryFromName(String? name) {
  final key = (name ?? '').trim().toLowerCase();
  if (key.isEmpty) return null;
  return _countryIndex[key];
}

/// Flag emoji of a country display name; a globe when nothing is set or the
/// stored name is not in the catalogue.
String flagForCountryName(String? name) {
  final country = countryFromName(name);
  return country != null && country.emoji.isNotEmpty ? country.emoji : '🌐';
}

/// The first country that uses [code] — used to suggest a default country.
ccp.Country? countryForCurrencyCode(String? code) {
  final upper = (code ?? '').trim().toUpperCase();
  if (upper.isEmpty) return null;
  for (final country in countryCatalogue) {
    if (country.currencyCode.toUpperCase() == upper) return country;
  }
  return null;
}
