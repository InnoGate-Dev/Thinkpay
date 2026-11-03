
class AccountDeletionSchedule {
  /// When the account's details are replaced for good.
  final DateTime? scheduledFor;

  /// Grace period the backend applied, in days.
  final int graceDays;

  /// Whether the profile is still active. False right after a deletion.
  final bool isActive;

  const AccountDeletionSchedule({
    this.scheduledFor,
    this.graceDays = 30,
    this.isActive = false,
  });

  factory AccountDeletionSchedule.fromJson(Map<String, dynamic> response) {
    final data = (response['data'] is Map<String, dynamic>)
        ? response['data'] as Map<String, dynamic>
        : response;

    return AccountDeletionSchedule(
      scheduledFor: data['scheduled_for'] != null
          ? DateTime.tryParse(data['scheduled_for'].toString())?.toLocal()
          : null,
      graceDays: data['grace_period_days'] is num
          ? (data['grace_period_days'] as num).toInt()
          : int.tryParse(data['grace_period_days']?.toString() ?? '') ?? 30,
      isActive: data['is_active'] == true,
    );
  }
}
