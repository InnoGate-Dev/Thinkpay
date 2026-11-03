import '../../model/credit_card_model.dart';
import '../../services/creditCardService.dart';
import '../../core/constant/app_config.dart';
import '../../core/network/api_client.dart';


class CreditCardRepository {
  late final CreditCardService _creditCardService;

  CreditCardRepository() {
    final client = ApiClient(baseUrl: AppConfig.baseUrl);
    _creditCardService = CreditCardService(client);
  }

  // ── Create ─────────────────────────────────────────────────────────────────

  /// Creates a new card and returns the persisted [CreditCardModel].
  Future<CreditCardModel> createCard(CreditCardModel draft) async {
    return await _creditCardService.createCard(draft);
  }

  // ── Read ───────────────────────────────────────────────────────────────────

  /// Returns all cards of the authenticated user.
  ///
  /// `outstanding` on every card is derived server-side from
  /// `creditcard_transactions`, so it is safe to read straight into the UI.
  Future<List<CreditCardModel>> getCards() async {
    return await _creditCardService.fetchCards();
  }

  // ── Update ─────────────────────────────────────────────────────────────────

  /// Fully updates an existing card and returns the updated [CreditCardModel].
  Future<CreditCardModel> updateCard(CreditCardModel card) async {
    return await _creditCardService.updateCard(card);
  }

  // ── Delete ─────────────────────────────────────────────────────────────────

  /// Deletes the card with the given [id].
  Future<void> deleteCard(int id) async {
    await _creditCardService.deleteCard(id);
  }
}
