import '../util/credit_card_format.dart';

// ── Model ─────────────────────────────────────────────────────────────────────
/// A single credit-card record as returned by `GET /credit-cards`.
///
/// Only what the user enters is stored. The payment due date is not persisted:
/// it is always statement closing date + grace period, so it is derived here
/// through [nextCloseDate] and [nextDueDate].
///
/// The backend keeps `credit_limit` and `apr` in Postgres NUMERIC columns and
/// serialises them as strings, so [fromJson] accepts both strings and numbers.
class CreditCardModel {
  const CreditCardModel({
    required this.id,
    required this.name,
    required this.creditLimit,
    required this.apr,
    required this.statementDay,
    required this.graceDays,
    this.outstanding = 0,
    this.createdAt,
    this.updatedAt,
  });

  final int id;
  final String name;
  final double creditLimit;

  /// Annual interest rate in %.
  final double apr;

  /// 1-31, day of the month the statement closes.
  final int statementDay;

  /// Days from statement close to payment due date.
  final int graceDays;

  /// Used credit (money spent with the card that has not been paid back).
  /// The backend derives it from the ledger, so it is read-only here.
  final double outstanding;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory CreditCardModel.fromJson(Map<String, dynamic> json) {
    return CreditCardModel(
      id: _parseInt(json['id']) ?? 0,
      name: (json['name'] ?? '').toString(),
      creditLimit: _parseDouble(json['credit_limit']),
      apr: _parseDouble(json['apr']),
      statementDay: _parseInt(json['statement_day']) ?? 1,
      graceDays: _parseInt(json['grace_days']) ?? 21,
      outstanding: _parseDouble(json['outstanding']),
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
    );
  }

  /// Flat payload for `POST /credit-cards` — the backend expects the money
  /// fields as decimal strings, never as JSON numbers.
  Map<String, dynamic> toCreateJson() => {
        'name': name,
        'credit_limit': creditLimit.toStringAsFixed(2),
        'apr': apr.toStringAsFixed(2),
        'statement_day': statementDay,
        'grace_days': graceDays,
      };

  /// `PUT /credit-cards/{id}` takes the exact same body as create.
  Map<String, dynamic> toUpdateJson() => toCreateJson();

  CreditCardModel copyWith({
    int? id,
    String? name,
    double? creditLimit,
    double? apr,
    int? statementDay,
    int? graceDays,
    double? outstanding,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CreditCardModel(
      id: id ?? this.id,
      name: name ?? this.name,
      creditLimit: creditLimit ?? this.creditLimit,
      apr: apr ?? this.apr,
      statementDay: statementDay ?? this.statementDay,
      graceDays: graceDays ?? this.graceDays,
      outstanding: outstanding ?? this.outstanding,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // ── Derived credit figures ─────────────────────────────────────────────────

  /// Credit still available to spend.
  double get availableCredit {
    final left = creditLimit - outstanding;
    return left < 0 ? 0 : left;
  }

  /// Share of the limit already used, clamped to 0..1 for progress bars.
  double get utilisation {
    if (creditLimit <= 0) return 0;
    final ratio = outstanding / creditLimit;
    if (ratio.isNaN || ratio <= 0) return 0;
    return ratio > 1 ? 1 : ratio;
  }

  // ── Derived schedule ───────────────────────────────────────────────────────

  /// When the next statement closes (defaults to today's date as reference).
  DateTime nextCloseDate([DateTime? from]) =>
      nextStatementClose(statementDay, from ?? DateTime.now());

  /// Payment due date for the upcoming statement.
  DateTime nextDueDate([DateTime? from]) =>
      nextCloseDate(from).add(Duration(days: graceDays));

  // ── Parsing helpers ────────────────────────────────────────────────────────

  static int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? double.tryParse(v)?.toInt();
    if (v is Map) return _parseInt(v['Int64']);
    return null;
  }

  static double _parseDouble(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0;
    return 0;
  }

  static DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    return DateTime.tryParse(v.toString());
  }
}
