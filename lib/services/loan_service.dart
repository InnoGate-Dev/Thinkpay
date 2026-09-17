import '../core/constant/app_config.dart';
import '../core/constant/api_endpoints.dart';
import '../core/network/api_client.dart';
import '../model/loan_model.dart';
import '../model/loan_payment_model.dart';

/// Network service layer for the `/loans` resource.
///
/// Follows the standard architecture pattern used across the app by
/// utilizing [ApiClient] and [ApiEndpoints].
class LoanService {
  final ApiClient _apiClient;

  LoanService([ApiClient? apiClient])
      : _apiClient = apiClient ?? ApiClient(baseUrl: AppConfig.baseUrl);

  /// Returns all loans for the authenticated user as a list of [LoanModel].
  Future<List<LoanModel>> fetchLoans() async {
    final response = await _apiClient.get(ApiEndpoints.loans);
    if (response is Map<String, dynamic>) {
      final list = (response['data'] as List<dynamic>? ?? const []);
      return list
          .map((e) => LoanModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } else if (response is List) {
      return response
          .map((e) => LoanModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return <LoanModel>[];
  }

  /// Creates a new loan.
  Future<LoanModel> createLoan(LoanModel draft) async {
    final response = await _apiClient.post(
      ApiEndpoints.loans,
      data: draft.toCreateJson(),
    );
    if (response is Map<String, dynamic>) {
      final data = response['data'] ?? response;
      final loanJson = data is List ? data.first : data;
      return LoanModel.fromJson(loanJson as Map<String, dynamic>);
    }
    throw Exception('Unexpected response format when creating loan');
  }

  /// Updates status of a loan.
  Future<void> updateLoanStatus(int loanId, LoanStatus status) async {
    await _apiClient.patch(
      ApiEndpoints.loanById(loanId),
      data: {'loanstatus': status.apiValue},
    );
  }

  /// Fetches repayment records for a given [loanId].
  Future<List<LoanPaymentModel>> fetchPayments(int loanId) async {
    final response = await _apiClient.get(ApiEndpoints.loanPayments(loanId));
    if (response is Map<String, dynamic>) {
      final list = (response['data'] as List<dynamic>? ?? const []);
      return list
          .map((e) => LoanPaymentModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } else if (response is List) {
      return response
          .map((e) => LoanPaymentModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return <LoanPaymentModel>[];
  }

  /// Records a new payment against a loan.
  Future<LoanPaymentModel> addPayment(LoanPaymentModel draft) async {
    final response = await _apiClient.post(
      ApiEndpoints.loanPayments(draft.loanId),
      data: draft.toCreateJson(),
    );
    if (response is Map<String, dynamic>) {
      final data = response['data'] ?? response;
      final json = data is List ? data.first : data;
      return LoanPaymentModel.fromJson(json as Map<String, dynamic>);
    }
    throw Exception('Unexpected response format when adding payment');
  }
}

