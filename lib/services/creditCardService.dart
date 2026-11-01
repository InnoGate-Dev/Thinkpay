import '../core/constant/api_endpoints.dart';
import '../core/constant/app_config.dart';
import '../core/network/api_client.dart';
import '../model/credit_card_model.dart';

/// Network service layer for the `/credit-cards` resource.
///
/// Follows the standard architecture pattern used across the app by
/// utilizing [ApiClient] and [ApiEndpoints].
class CreditCardService {
  final ApiClient _apiClient;

  CreditCardService([ApiClient? apiClient])
      : _apiClient = apiClient ?? ApiClient(baseUrl: AppConfig.baseUrl);

  /// Returns all credit cards for the authenticated user.
  Future<List<CreditCardModel>> fetchCards() async {
    final response = await _apiClient.get(ApiEndpoints.creditCards);
    if (response is Map<String, dynamic>) {
      final list = response['data'] as List<dynamic>? ?? const [];
      return list
          .map((e) => CreditCardModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } else if (response is List) {
      return response
          .map((e) => CreditCardModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return <CreditCardModel>[];
  }

  /// Creates a new credit card and returns the persisted record.
  Future<CreditCardModel> createCard(CreditCardModel draft) async {
    final response = await _apiClient.post(
      ApiEndpoints.creditCards,
      data: draft.toCreateJson(),
    );
    return _unwrapCard(response, 'creating');
  }

  /// Fully updates an existing credit card via `PUT /credit-cards/{id}`.
  Future<CreditCardModel> updateCard(CreditCardModel card) async {
    final response = await _apiClient.put(
      ApiEndpoints.creditCardById(card.id),
      data: card.toUpdateJson(),
    );
    return _unwrapCard(response, 'updating');
  }

  /// Deletes the card via `DELETE /credit-cards/{id}` (204 No Content).
  Future<void> deleteCard(int id) async {
    await _apiClient.delete(ApiEndpoints.creditCardById(id));
  }

  /// Unwraps the `{"data": {...}}` envelope of a single-card response.
  CreditCardModel _unwrapCard(dynamic response, String action) {
    if (response is Map<String, dynamic>) {
      final data = response['data'] ?? response;
      final json = data is List ? data.first : data;
      if (json is Map<String, dynamic>) return CreditCardModel.fromJson(json);
    }
    throw Exception('Unexpected response format when $action credit card');
  }
}
