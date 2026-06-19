enum GoalType { savings, investment }

class GoalModel {
  final String id;
  final String name;
  final GoalType type;
  final double targetAmount;
  double savedAmount;
  final DateTime createdAt;
  final DateTime? targetDate;

  GoalModel({
    required this.id,
    required this.name,
    required this.type,
    required this.targetAmount,
    this.savedAmount = 0,
    required this.createdAt,
    this.targetDate,
  });

  double get progress =>
      targetAmount > 0 ? (savedAmount / targetAmount).clamp(0.0, 1.0) : 0.0;

  bool get isCompleted => savedAmount >= targetAmount;

  double get remaining => (targetAmount - savedAmount).clamp(0, double.infinity);

  GoalModel copyWith({
    String? name,
    GoalType? type,
    double? targetAmount,
    double? savedAmount,
    DateTime? createdAt,
    DateTime? targetDate,
    bool clearTargetDate = false,
  }) =>
      GoalModel(
        id: id,
        name: name ?? this.name,
        type: type ?? this.type,
        targetAmount: targetAmount ?? this.targetAmount,
        savedAmount: savedAmount ?? this.savedAmount,
        createdAt: createdAt ?? this.createdAt,
        targetDate: clearTargetDate ? null : (targetDate ?? this.targetDate),
      );
}
