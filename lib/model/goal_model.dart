enum GoalType {
  savings,
  investment,
  debt;

  /// Maps enum value to the type letter sent to the API.
  String get apiValue {
    switch (this) {
      case GoalType.savings:
        return 'S';
      case GoalType.investment:
        return 'I';
      case GoalType.debt:
        return 'L';
    }
  }

  /// Parses the API type string back into the enum.
  /// Accepts both the short suffix form ("S", "I", "L") and the full DB
  /// enum strings ("SAVING", "SAVINGS", "INVESTING", "INVESTMENT", "LOAN",
  /// "DEBT") — defaulting to [savings] on anything unknown.
  static GoalType fromApi(String value) {
    switch (value.toUpperCase()) {
      case 'I':
      case 'INVESTMENT':
      case 'INVESTING':
        return GoalType.investment;
      case 'L':
      case 'LOAN':
      case 'DEBT':
        return GoalType.debt;
      case 'S':
      case 'SAVING':
      case 'SAVINGS':
      default:
        return GoalType.savings;
    }
  }
}

class GoalModel {
  final String id;
  final String name;
  final GoalType type;
  final double targetAmount;
  double savedAmount;
  final DateTime createdAt;

  GoalModel({
    required this.id,
    required this.name,
    required this.type,
    required this.targetAmount,
    required this.savedAmount,
    required this.createdAt,
  });

  bool get isCompleted => savedAmount >= targetAmount;
  double get progress =>
      targetAmount > 0 ? (savedAmount / targetAmount).clamp(0.0, 1.0) : 0.0;
  double get remaining => targetAmount - savedAmount;

  /// Decode the [GoalType] from a composite ID string like "42_S", "7_I", "15_L".
  static GoalType _typeFromId(String id, {String? fallbackType}) {
    final cleanId = id.trim().toUpperCase();
    if (cleanId.endsWith('_S')) {
      return GoalType.savings;
    } else if (cleanId.endsWith('_I')) {
      return GoalType.investment;
    } else if (cleanId.endsWith('_L')) {
      return GoalType.debt;
    }

    final idx = cleanId.lastIndexOf('_');
    if (idx >= 0 && idx < cleanId.length - 1) {
      return GoalType.fromApi(cleanId.substring(idx + 1));
    }

    if (fallbackType != null && fallbackType.isNotEmpty) {
      return GoalType.fromApi(fallbackType);
    }

    return GoalType.savings;
  }

  /// Constructs a [GoalModel] from the backend JSON response.
  ///
  /// The backend `GoalResponse` shape:
  /// ```json
  /// {
  ///   "id":              "42_S",
  ///   "user_id":         1,
  ///   "name":            "Emergency Fund",
  ///   "actual_amount":   "0.00",
  ///   "target_amount":   "50000.00",
  ///   "current_balance": "32000.00",
  ///   "is_complete":     false,
  ///   "created_at":      "2026-09-01T00:00:00Z"
  /// }
  /// ```
  factory GoalModel.fromJson(Map<String, dynamic> json) {
    final id = (json['id'] ?? '').toString();

    // Type is determined by ID suffix (e.g. "42_S" → savings, "7_I" → investment, "15_L" → loan/debt).
    final GoalType type = _typeFromId(
      id,
      fallbackType: json['type']?.toString(),
    );

    return GoalModel(
      id: id,
      name: json['name']?.toString() ?? '',
      type: type,
      targetAmount:
          double.tryParse(json['target_amount']?.toString() ?? '0') ?? 0,
      savedAmount: double.tryParse(
              (json['actual_amount'] ??
                      json['current_balance'] ??
                      json['saved_amount'] ??
                      json['current_amount'])
                  ?.toString() ??
                  '0') ??
          0,
      createdAt: json['created_at'] != null
          ? (DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now())
          : DateTime.now(),
    );
  }

  /// Serialises this model to a create/update request body.
  ///
  /// Maps to `CreateGoalRequest` / `UpdateGoalRequest`:
  /// ```json
  /// { "name", "actual_amount", "target_amount", "is_complete", "type" }
  /// ```
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type.apiValue,
      'actual_amount': savedAmount.toStringAsFixed(2),
      'target_amount': targetAmount.toStringAsFixed(2),
      'is_complete': isCompleted,
    };
  }

  GoalModel copyWith({
    String? id,
    String? name,
    GoalType? type,
    double? targetAmount,
    double? savedAmount,
    DateTime? createdAt,
  }) {
    return GoalModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      targetAmount: targetAmount ?? this.targetAmount,
      savedAmount: savedAmount ?? this.savedAmount,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
