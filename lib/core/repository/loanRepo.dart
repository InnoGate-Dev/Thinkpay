import '../../model/loan_model.dart';
import '../../model/loan_payment_model.dart';
import '../../services/loan_service.dart';
import '../../core/constant/app_config.dart';
import '../../core/network/api_client.dart';

/// Repository that orchestrates all loan and loan-payment API operations.
///
/// Follows the exact same architecture pattern used across the app
/// ([GoalTrasectionRepository], [TransactionRepository], etc.):
/// - owns one [LoanService] instance
/// - maps raw API JSON ↔ typed domain models
/// - exposes clean async methods to the UI layer
class LoanRepository {
  late final LoanService _loanService;

  LoanRepository() {
    final client = ApiClient(baseUrl: AppConfig.baseUrl);
    _loanService = LoanService(client);
  }

  // ── Loans ─────────────────────────────────────────────────────────────────

  /// Returns all loans for the authenticated user.
  ///
  /// Set [withPayments] to `true` to also fetch payment history for every
  /// loan (used by the Transactions page). Defaults to `false` for the
  /// standard loan list view which doesn't need payment details immediately.
  Future<List<LoanModel>> getLoans({bool withPayments = false}) async {
    final loans = await _loanService.fetchLoans();
    if (!withPayments) return loans;

    // Fetch payments for each loan in parallel.
    final List<List<LoanPaymentModel>> allPayments = await Future.wait(
      loans.map((l) => _loanService.fetchPayments(l.id)),
    );
    return [
      for (int i = 0; i < loans.length; i++)
        loans[i].copyWith(payments: allPayments[i]),
    ];
  }

  /// Creates a new loan and returns the persisted [LoanModel].
  Future<LoanModel> createLoan(LoanModel draft) async {
    return await _loanService.createLoan(draft);
  }

  /// Updates the status of a loan identified by [loanId].
  Future<void> updateLoanStatus(int loanId, LoanStatus status) async {
    await _loanService.updateLoanStatus(loanId, status);
  }

  // ── Loan Payments (Transactions) ──────────────────────────────────────────

  /// Returns all payment records for the loan identified by [loanId].
  Future<List<LoanPaymentModel>> getLoanPayments(int loanId) async {
    return await _loanService.fetchPayments(loanId);
  }

  /// Records a new payment against a loan.
  ///
  /// [loanId] is the numeric loan ID.
  /// [amount] is the payment amount.
  /// [paidAt] is the payment date.
  /// [note] is an optional note for the payment.
  Future<LoanPaymentModel> addLoanPayment({
    required int loanId,
    required double amount,
    required DateTime paidAt,
    String? note,
  }) async {
    final draft = LoanPaymentModel(
      id: 0,
      loanId: loanId,
      amount: amount,
      paidAt: paidAt,
      note: note,
    );
    return await _loanService.addPayment(draft);
  }
}
