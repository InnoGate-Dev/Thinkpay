import 'package:currency_country_picker/currency_country_picker.dart' as ccp;

import '../goal_model.dart';

/// UI-only draft captured while the user moves through onboarding.
///
/// Nothing here is persisted or sent to the backend — the objects are plain
/// mutable holders so the review build can move backwards and forwards between
/// steps without losing what was typed. A future `OnboardingSyncService`
/// receives this object as-is (see docs/onboarding-ux-spec.md, section 11).
class OnboardingDraft {
  /// Picked from the `currency_country_picker` catalogue.
  ccp.Country? country;

  /// ISO 4217 code used for every amount entered during onboarding.
  String currencyCode = 'LKR';

  final List<MoneyItem> incomes = <MoneyItem>[];
  final List<MoneyItem> expenses = <MoneyItem>[];
  final List<CardDraft> cards = <CardDraft>[];
  final List<LoanDraft> loans = <LoanDraft>[];
  final List<GoalDraft> goals = <GoalDraft>[];

  /// Explicit "No cards" / "No loans" answers from the gate questions.
  bool noCards = false;
  bool noLoans = false;

  double get monthlyIncome => incomes.fold(0.0, (sum, i) => sum + i.amount);
  double get monthlyExpense => expenses.fold(0.0, (sum, e) => sum + e.amount);
  double get monthlyKeep => monthlyIncome - monthlyExpense;

  /// Portion of income retained, 0..1. Null until an income exists.
  double? get keepRatio {
    if (monthlyIncome <= 0) return null;
    return (monthlyKeep / monthlyIncome).clamp(0.0, 1.0).toDouble();
  }

  double get totalRemainingDebt =>
      loans.fold(0.0, (sum, l) => sum + l.remaining);

  bool get hasAnything =>
      country != null ||
      incomes.isNotEmpty ||
      expenses.isNotEmpty ||
      cards.isNotEmpty ||
      loans.isNotEmpty ||
      goals.isNotEmpty;

  /// Applies a picked country and adopts its currency as the default.
  void applyCountry(ccp.Country picked) {
    country = picked;
    final code = picked.currencyCode.toUpperCase();
    if (code.isNotEmpty) currencyCode = code;
  }
}

// ── Money rows (income / expenses) ────────────────────────────────────────────
class MoneyItem {
  MoneyItem({required this.label, this.amount = 0});

  String label;
  double amount;
}

// ── Credit card ───────────────────────────────────────────────────────────────
/// Mirrors [CreditCardModel] minus the fields the app cannot store yet.
class CardDraft {
  CardDraft({
    this.name = '',
    this.creditLimit = 0,
    this.apr = 0,
    this.statementDay = 1,
    this.graceDays = 21,
  });

  String name;
  double creditLimit;
  double apr;
  int statementDay;
  int graceDays;

  bool get isUsable => name.trim().isNotEmpty && creditLimit > 0;
}

// ── Loan ──────────────────────────────────────────────────────────────────────
class LoanDraft {
  LoanDraft({
    required this.purpose,
    this.principal = 0,
    this.alreadyPaid = 0,
    this.paymentsMade = 0,
    this.ratePct = 0,
    this.durationMonths = 24,
    this.monthlyPayment = 0,
    DateTime? startDate,
  }) : startDate =
           startDate ?? DateTime(DateTime.now().year, DateTime.now().month, 1);

  String purpose;
  double principal;
  double alreadyPaid;
  int paymentsMade;
  double ratePct;
  int durationMonths;
  double monthlyPayment;
  DateTime startDate;

  double get remaining =>
      (principal - alreadyPaid).clamp(0.0, principal).toDouble();
  double get totalPayable => monthlyPayment * durationMonths;
  bool get isSettled => principal > 0 && alreadyPaid >= principal;

  /// Flat-interest estimate, matching the maths used by `AddLoanPage`.
  double get suggestedMonthly {
    if (principal <= 0 || durationMonths <= 0) return 0;
    return (principal + principal * ratePct / 100) / durationMonths;
  }

  /// How many instalments the "already paid" figure represents.
  int get suggestedPaymentsMade {
    if (monthlyPayment <= 0) return 0;
    return (alreadyPaid / monthlyPayment)
        .floor()
        .clamp(0, durationMonths)
        .toInt();
  }
}

// ── Goal ──────────────────────────────────────────────────────────────────────
class GoalDraft {
  GoalDraft({
    required this.name,
    this.target = 0,
    this.saved = 0,
    this.monthlyPlan = 0,
    this.type = GoalType.savings,
  });

  String name;
  double target;
  double saved;
  double monthlyPlan;
  GoalType type;

  double get progress =>
      target <= 0 ? 0 : (saved / target).clamp(0.0, 1.0).toDouble();
}
