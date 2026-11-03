import 'transaction_model.dart';

/// One row of `creditcard_transactions`.
///
/// Card spending lives in its own table (not in the main ledger), so this model
/// mirrors the card entry — including the optional note and the card it was
/// charged to — and can be projected onto the UI's [TransactionModel] with
/// [toLocalModel] wherever a normal ledger row is expected.
class CreditCardTransactionModel {
  const CreditCardTransactionModel({
    required this.id,
    required this.categoryId,
    required this.type,
    required this.amount,
    required this.date,
    this.cardId,
    this.note,
    this.createdAt,
  });

  final int id;
  final int categoryId;
  final TransactionType type;
  final double amount;
  final DateTime date;

  /// Card the entry was charged to. Null when the card was deleted.
  final int? cardId;

  final String? note;
  final DateTime? createdAt;

  factory CreditCardTransactionModel.fromJson(Map<String, dynamic> json) {
    return CreditCardTransactionModel(
      id: _parseInt(json['id']) ?? 0,
      categoryId: _parseInt(json['category_id']) ?? 0,
      type: TransactionType.fromApi(json['type']?.toString() ?? 'EXPENSE'),
      amount: _parseDouble(json['amount']),
      date: _parseDate(json['date']) ?? DateTime.now(),
      cardId: _parseInt(json['card_id']),
      note: _parseNote(json['note']),
      createdAt: _parseDate(json['created_at']),
    );
  }

  /// Projects this card entry onto the UI model.
  TransactionModel toLocalModel({String? fallbackCategory}) {
    return TransactionModel(
      id: id.toString(),
      category: fallbackCategory ?? type.apiValue,
      amount: amount,
      type: type,
      date: date,
      notes: note,
      categoryId: categoryId > 0 ? categoryId : null,
    );
  }

  static int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v);
    if (v is Map) return _parseInt(v['Int64'] ?? v['int64']);
    return null;
  }

  static double _parseDouble(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0;
    return 0;
  }

  /// Postgres TEXT columns arrive as strings or as `{String, Valid}` maps.
  static String? _parseNote(dynamic v) {
    if (v == null) return null;
    if (v is String) return v.isEmpty ? null : v;
    if (v is Map) {
      final valid = v['Valid'] ?? v['valid'];
      if (valid == false) return null;
      return _parseNote(v['String'] ?? v['string']);
    }
    return null;
  }

  static DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    return DateTime.tryParse(v.toString());
  }
}
