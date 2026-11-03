import '../../model/credit_card_transaction_model.dart';
import '../../model/transaction_model.dart';
import '../../services/creditCardTransactionService.dart';
import '../../core/constant/app_config.dart';
import '../../core/network/api_client.dart';

/// Repository that orchestrates all credit-card transaction operations.
///
/// Follows the exact same architecture pattern used across the app
/// ([LoanRepository], [TransactionRepository], [GoalTrasectionRepository],
/// etc.):
/// - owns one [CreditCardTransactionService] instance
/// - maps raw API JSON ↔ typed domain models
/// - exposes clean async methods to the UI layer
///
/// Card spending lives in `creditcard_transactions`, a table separate from the
/// main ledger, so every row read here has to be merged into the ledger by the
/// caller — it will never arrive from `GET /transactions`.
///
/// Usage:
/// ```dart
/// final repo = CreditCardTransactionRepository();
/// final rows = await repo.getCardTransactions();
/// ```
class CreditCardTransactionRepository {
  late final CreditCardTransactionService _cardTransactionService;

  CreditCardTransactionRepository() {
    final client = ApiClient(baseUrl: AppConfig.baseUrl);
    _cardTransactionService = CreditCardTransactionService(client);
  }

  // ── Read ──────────────────────────────────────────────────────────────────

  /// Returns every card entry of the authenticated user, newest first.
  ///
  /// The server silently caps [limit] at 100, so that is the widest single
  /// request; older rows need paging.
  Future<List<CreditCardTransactionModel>> getCardTransactions({
    int limit = 100,
  }) async {
    return await _cardTransactionService.fetchAll(limit: limit);
  }

  /// Returns every entry charged to [cardId], newest first.
  ///
  /// Backed by `GET /credit-cards/{id}/transactions` — the same rows the card
  /// history screen lists.
  Future<List<CreditCardTransactionModel>> getCardTransactionsByCard(
    int cardId,
  ) async {
    return await _cardTransactionService.fetchByCard(cardId);
  }

  // ── Create ────────────────────────────────────────────────────────────────

  /// Records a card-paid transaction and returns the persisted row.
  ///
  /// The backend also rolls [amount] into the category's `actual_amount`, so
  /// the caller must not apply its own local budget delta on top.
  Future<CreditCardTransactionModel> createCardTransaction({
    required int cardId,
    required int categoryId,
    required TransactionType type,
    required double amount,
    required DateTime date,
    String? note,
  }) async {
    return await _cardTransactionService.create(
      cardId: cardId,
      categoryId: categoryId,
      type: type,
      amount: amount,
      date: date,
      note: note,
    );
  }

  // ── Update ────────────────────────────────────────────────────────────────

  /// Updates an existing card entry and returns the updated row.
  ///
  /// [cardId] must be resent because the update route replaces the whole row;
  /// the note is preserved server-side when it is not supplied.
  Future<CreditCardTransactionModel> updateCardTransaction(
    int id, {
    required int cardId,
    required int categoryId,
    required TransactionType type,
    required double amount,
    required DateTime date,
  }) async {
    return await _cardTransactionService.update(
      id: id,
      cardId: cardId,
      categoryId: categoryId,
      type: type,
      amount: amount,
      date: date,
    );
  }

  // ── Delete ────────────────────────────────────────────────────────────────

  /// Deletes a card entry; the server also reverses its category amount.
  Future<void> deleteCardTransaction(int id) async {
    await _cardTransactionService.delete(id);
  }
}
