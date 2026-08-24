class Goal {
  final int id;
  final String name;
  final String? description;
  final String targetAmount;
  final String? currentAmount;
  final int? userId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Goal({
    required this.id,
    required this.name,
    this.description,
    required this.targetAmount,
    this.currentAmount,
    this.userId,
    this.createdAt,
    this.updatedAt,
  });

  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'],
      targetAmount: json['target_amount']?.toString() ?? '0.00',
      currentAmount: json['current_amount']?.toString(),
      userId: json['user_id'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'target_amount': targetAmount,
      'current_amount': currentAmount,
      'user_id': userId,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
